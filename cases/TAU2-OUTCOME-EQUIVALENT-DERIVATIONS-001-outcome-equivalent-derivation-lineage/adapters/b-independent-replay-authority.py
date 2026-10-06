#!/usr/bin/env python3
import argparse
import copy
import hashlib
import json
import sys
from pathlib import Path

from tau2.data_model.message import AssistantMessage, ToolCall
from tau2.data_model.simulation import SimulationRun, TerminationReason
from tau2.data_model.tasks import RewardType, Task
from tau2.domains.airline.environment import get_environment
from tau2.evaluator.evaluator import EvaluationType, evaluate_simulation


def read_json(path):
    with open(path, "r", encoding="utf-8") as fp:
        return json.load(fp)


def write_json(path, value):
    with open(path, "w", encoding="ascii", newline="\n") as fp:
        json.dump(
            value,
            fp,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=True,
        )
        fp.write("\n")


def digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as fp:
        for block in iter(lambda: fp.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def read_lineage(path):
    calls = []
    final_text = None

    with open(path, "r", encoding="ascii") as fp:
        for raw in fp:
            raw = raw.rstrip("\n")
            if not raw:
                continue

            item = json.loads(raw)

            if item.get("type") == "assistant_final":
                if final_text is not None:
                    raise ValueError("duplicate assistant_final")
                final_text = item.get("content")
                continue

            required = {
                "ordinal",
                "tool_call_id",
                "name",
                "arguments",
                "requestor",
                "tool_response",
                "tool_error",
            }

            if set(item.keys()) != required:
                raise ValueError("unexpected lineage row shape")

            calls.append(item)

    calls.sort(key=lambda row: row["ordinal"])

    if [row["ordinal"] for row in calls] != list(range(len(calls))):
        raise ValueError("non-contiguous lineage ordinals")

    if final_text is None:
        raise ValueError("assistant_final missing")

    return calls, final_text


def task_state(task):
    if task.initial_state is None:
        return None, None, []

    return (
        task.initial_state.initialization_data,
        task.initial_state.initialization_actions,
        copy.deepcopy(task.initial_state.message_history or []),
    )


def stamp(index):
    return f"2001-01-01T00:00:{index:02d}Z"


def reward_value(reward_info, reward_type):
    if reward_info.reward_breakdown is None:
        return None
    return reward_info.reward_breakdown.get(reward_type)


def replay_one(label, task, lineage_path, communication, original_result):
    calls, stored_final = read_lineage(lineage_path)

    if stored_final != communication:
        raise ValueError(f"{label}: stored final communication mismatch")

    if len(calls) != 5:
        raise ValueError(f"{label}: frozen tool-call count mismatch")

    env = get_environment(solo_mode=False)

    initialization_data, initialization_actions, initial_messages = task_state(task)

    env.set_state(
        initialization_data=initialization_data,
        initialization_actions=initialization_actions,
        message_history=copy.deepcopy(initial_messages),
        strict=True,
    )

    messages = copy.deepcopy(initial_messages)
    turn = len(messages)

    response_match_count = 0
    error_match_count = 0
    replay_rows = []

    for row in calls:
        call = ToolCall(
            id=f"independent-{label}-{row['ordinal']}",
            name=row["name"],
            arguments=copy.deepcopy(row["arguments"]),
            requestor=row["requestor"],
        )

        assistant = AssistantMessage(
            role="assistant",
            content=None,
            tool_calls=[call],
            timestamp=stamp(turn),
            turn_idx=turn,
        )
        messages.append(assistant)
        turn += 1

        live_tool = env.get_response(call)
        live_tool.timestamp = stamp(turn)
        live_tool.turn_idx = turn
        messages.append(live_tool)
        turn += 1

        content_match = live_tool.content == row["tool_response"]
        error_match = bool(live_tool.error) == bool(row["tool_error"])

        response_match_count += int(content_match)
        error_match_count += int(error_match)

        replay_rows.append(
            {
                "ordinal": row["ordinal"],
                "name": row["name"],
                "arguments": row["arguments"],
                "stored_tool_response": row["tool_response"],
                "live_tool_response": live_tool.content,
                "stored_tool_error": bool(row["tool_error"]),
                "live_tool_error": bool(live_tool.error),
                "response_match": content_match,
                "error_match": error_match,
            }
        )

    final_message = AssistantMessage(
        role="assistant",
        content=communication,
        tool_calls=None,
        timestamp=stamp(turn),
        turn_idx=turn,
    )
    messages.append(final_message)

    live_db_hash = env.get_db_hash()
    live_user_db_hash = env.get_user_db_hash()

    simulation = SimulationRun(
        id=f"tau2-independent-replay-{label}",
        task_id=str(task.id),
        timestamp="2001-01-01T00:00:00Z",
        start_time="2001-01-01T00:00:00Z",
        end_time="2001-01-01T00:00:00Z",
        duration=0.0,
        termination_reason=TerminationReason.AGENT_STOP,
        agent_cost=0.0,
        user_cost=0.0,
        messages=messages,
        trial=1,
        seed=1,
        mode="half_duplex",
    )

    reward_info = evaluate_simulation(
        simulation=simulation,
        task=task,
        evaluation_type=EvaluationType.ALL,
        solo_mode=False,
        domain="airline",
        strict_replay=True,
    )

    final_reward = reward_info.reward
    db_reward = reward_value(reward_info, RewardType.DB)
    communicate_reward = reward_value(
        reward_info,
        RewardType.COMMUNICATE,
    )

    db_match = (
        reward_info.db_check is not None
        and reward_info.db_check.db_match is True
    )

    result = {
        "label": label,
        "tool_call_count": len(calls),
        "tool_response_match_count": response_match_count,
        "tool_error_match_count": error_match_count,
        "all_tool_responses_match": response_match_count == len(calls),
        "all_tool_error_flags_match": error_match_count == len(calls),
        "lineage_sha256": digest(lineage_path),
        "live_agent_db_hash": live_db_hash,
        "live_user_db_hash": live_user_db_hash,
        "final_reward": final_reward,
        "db_reward": db_reward,
        "communicate_reward": communicate_reward,
        "db_match": db_match,
        "matches_original_final_reward": (
            final_reward == original_result["final_reward"]
        ),
        "matches_original_db_reward": (
            db_reward == original_result["db_reward"]
        ),
        "matches_original_communicate_reward": (
            communicate_reward
            == original_result["communicate_reward"]
        ),
        "matches_original_db_match": (
            db_match == original_result["db_match"]
        ),
        "matches_original_live_db_hash": (
            live_db_hash == original_result["live_agent_db_hash"]
        ),
        "replay_rows": replay_rows,
    }

    return result


def recovered_inputs(root):
    return {
        "task": root / "task-7.json",
        "lineage_a": root / "derivation-A.ndjson",
        "lineage_b": root / "derivation-B.ndjson",
        "outcome_a": root / "outcome-A.json",
        "outcome_b": root / "outcome-B.json",
        "equivalence": root / "outcome-equivalence.json",
        "execution_contract": root / "execution-contract.tsv",
        "communication": root / "communication.txt",
        "tau2_authority": root / "tau2-authority.tsv",
        "a1_summary": root / "a1-summary.tsv",
    }


def audit(root):
    paths = recovered_inputs(root)

    for path in paths.values():
        if not path.is_file():
            raise ValueError(f"missing recovered input: {path.name}")

    task = Task.model_validate(read_json(paths["task"]))

    if str(task.id) != "7":
        raise ValueError("recovered task id mismatch")

    calls_a, final_a = read_lineage(paths["lineage_a"])
    calls_b, final_b = read_lineage(paths["lineage_b"])

    communication = paths["communication"].read_text(
        encoding="utf-8"
    ).rstrip("\n")

    if final_a != communication or final_b != communication:
        raise ValueError("recovered communication mismatch")

    sequence_a = [
        (row["name"], row["arguments"], row["requestor"])
        for row in calls_a
    ]
    sequence_b = [
        (row["name"], row["arguments"], row["requestor"])
        for row in calls_b
    ]

    if len(sequence_a) != 5 or len(sequence_b) != 5:
        raise ValueError("recovered derivation length mismatch")

    if sequence_a == sequence_b:
        raise ValueError("recovered derivations are not distinct")

    if sequence_b[0] != sequence_a[1]:
        raise ValueError("recovered B first action mismatch")

    if sequence_b[1] != sequence_a[0]:
        raise ValueError("recovered B second action mismatch")

    if sequence_b[2:] != sequence_a[2:]:
        raise ValueError("recovered B write suffix mismatch")

    original_a = read_json(paths["outcome_a"])
    original_b = read_json(paths["outcome_b"])
    equivalence = read_json(paths["equivalence"])

    if equivalence.get("scientific_pass") is not True:
        raise ValueError("recovered original equivalence is not PASS")

    if original_a["live_agent_db_hash"] != original_b["live_agent_db_hash"]:
        raise ValueError("recovered original DB hashes differ")

    report = {
        "audit": "PASS",
        "task_id": "7",
        "trajectory_A_tool_calls": len(sequence_a),
        "trajectory_B_tool_calls": len(sequence_b),
        "derivations_distinct": True,
        "communication_matches_both": True,
        "original_equivalence_pass": True,
        "original_final_db_hash": original_a["live_agent_db_hash"],
        "lineage_A_sha256": digest(paths["lineage_a"]),
        "lineage_B_sha256": digest(paths["lineage_b"]),
        "trajectory_executed": False,
        "external_judge_executed": False,
    }

    print(
        json.dumps(
            report,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=True,
        )
    )


def execute(root, out_dir):
    paths = recovered_inputs(root)

    task = Task.model_validate(read_json(paths["task"]))
    communication = paths["communication"].read_text(
        encoding="utf-8"
    ).rstrip("\n")

    original_a = read_json(paths["outcome_a"])
    original_b = read_json(paths["outcome_b"])
    original_equivalence = read_json(paths["equivalence"])

    out_dir.mkdir(parents=True, exist_ok=False)

    result_a = replay_one(
        "A",
        task,
        paths["lineage_a"],
        communication,
        original_a,
    )

    write_json(out_dir / "replay-A.json", result_a)

    result_b = replay_one(
        "B",
        task,
        paths["lineage_b"],
        communication,
        original_b,
    )

    write_json(out_dir / "replay-B.json", result_b)

    common_hash = (
        result_a["live_agent_db_hash"] is not None
        and result_b["live_agent_db_hash"] is not None
        and result_a["live_agent_db_hash"]
        == result_b["live_agent_db_hash"]
    )

    original_common_hash = original_equivalence[
        "trajectory_A"
    ]["live_agent_db_hash"]

    criteria = {
        "trajectory_A_five_calls": (
            result_a["tool_call_count"] == 5
        ),
        "trajectory_B_five_calls": (
            result_b["tool_call_count"] == 5
        ),
        "trajectory_A_tool_responses_reproduced": (
            result_a["all_tool_responses_match"]
        ),
        "trajectory_B_tool_responses_reproduced": (
            result_b["all_tool_responses_match"]
        ),
        "trajectory_A_tool_error_flags_reproduced": (
            result_a["all_tool_error_flags_match"]
        ),
        "trajectory_B_tool_error_flags_reproduced": (
            result_b["all_tool_error_flags_match"]
        ),
        "trajectory_A_final_reward_reproduced": (
            result_a["matches_original_final_reward"]
            and result_a["final_reward"] == 1.0
        ),
        "trajectory_B_final_reward_reproduced": (
            result_b["matches_original_final_reward"]
            and result_b["final_reward"] == 1.0
        ),
        "trajectory_A_db_reward_reproduced": (
            result_a["matches_original_db_reward"]
            and result_a["db_reward"] == 1.0
        ),
        "trajectory_B_db_reward_reproduced": (
            result_b["matches_original_db_reward"]
            and result_b["db_reward"] == 1.0
        ),
        "trajectory_A_communicate_reward_reproduced": (
            result_a["matches_original_communicate_reward"]
            and result_a["communicate_reward"] == 1.0
        ),
        "trajectory_B_communicate_reward_reproduced": (
            result_b["matches_original_communicate_reward"]
            and result_b["communicate_reward"] == 1.0
        ),
        "trajectory_A_db_match_reproduced": (
            result_a["matches_original_db_match"]
            and result_a["db_match"] is True
        ),
        "trajectory_B_db_match_reproduced": (
            result_b["matches_original_db_match"]
            and result_b["db_match"] is True
        ),
        "trajectory_A_final_db_hash_reproduced": (
            result_a["matches_original_live_db_hash"]
        ),
        "trajectory_B_final_db_hash_reproduced": (
            result_b["matches_original_live_db_hash"]
        ),
        "common_final_db_hash_reproduced": (
            common_hash
            and result_a["live_agent_db_hash"]
            == original_common_hash
        ),
        "recovered_lineages_remain_distinct": (
            result_a["lineage_sha256"]
            != result_b["lineage_sha256"]
        ),
    }

    replay_pass = all(criteria.values())

    overall = {
        "case": "TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001",
        "stage": "B-R1",
        "task_id": "7",
        "implementation": "independent-replay-v1",
        "trajectory_A": result_a,
        "trajectory_B": result_b,
        "original_common_final_db_hash": original_common_hash,
        "criteria": criteria,
        "independent_replay_pass": replay_pass,
        "model_endpoint_called": False,
        "user_simulator_executed": False,
        "yoda_writes": 0,
    }

    write_json(out_dir / "overall-replay.json", overall)

    print(
        json.dumps(
            overall,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=True,
        )
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mode",
        required=True,
        choices=["audit", "execute"],
    )
    parser.add_argument(
        "--recovered-dir",
        required=True,
    )
    parser.add_argument(
        "--out-dir",
    )

    args = parser.parse_args()
    recovered = Path(args.recovered_dir)

    if args.mode == "audit":
        audit(recovered)
        return 0

    if args.out_dir is None:
        raise ValueError("--out-dir required for execute")

    execute(recovered, Path(args.out_dir))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(
            "INDEPENDENT_REPLAY_ERROR="
            + type(exc).__name__
            + ":"
            + str(exc),
            file=sys.stderr,
        )
        raise
