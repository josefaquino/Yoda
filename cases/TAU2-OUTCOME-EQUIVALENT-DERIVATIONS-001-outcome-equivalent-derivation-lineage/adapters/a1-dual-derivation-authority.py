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
from tau2.domains.airline.environment import get_environment, get_tasks
from tau2.evaluator.evaluator import EvaluationType, evaluate_simulation


def canonical_json_bytes(value):
    return json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=True,
    ).encode("ascii")


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest()


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fp:
        while True:
            block = fp.read(1024 * 1024)
            if not block:
                break
            h.update(block)
    return h.hexdigest()


def load_json(path):
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


def parse_tsv_contract(path):
    rows = {}
    with open(path, "r", encoding="utf-8") as fp:
        header = fp.readline().rstrip("\n").split("\t")
        if header != ["field", "value"]:
            raise ValueError("execution contract header mismatch")
        for line in fp:
            line = line.rstrip("\n")
            if not line:
                continue
            field, value = line.split("\t", 1)
            rows[field] = value
    return rows


def assert_frozen_contract(a0):
    execution = parse_tsv_contract(a0 / "contracts" / "execution-contract.tsv")

    required = {
        "case": "TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001",
        "task_id": "7",
        "domain": "airline",
        "mode": "HALF_DUPLEX",
        "trajectory_A_action_order": "0,1,2,3,4",
        "trajectory_B_action_order": "1,0,2,3,4",
        "transformation": "SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS",
        "agent_model": "NONE",
        "user_model": "NONE",
        "trajectory_generator": "DETERMINISTIC_HARNESS",
        "termination_reason": "AGENT_STOP",
        "evaluation_type": "ALL",
        "solo_mode": "FALSE",
        "strict_replay": "TRUE",
        "reward_basis": "DB,COMMUNICATE",
        "communicate_info": "1628",
        "action_reward_gate": "NO",
        "nl_assertion_reward_gate": "NO",
    }

    if execution != required:
        raise ValueError("frozen execution contract mismatch")

    communication = (
        a0 / "contracts" / "communication.txt"
    ).read_text(encoding="utf-8")

    if communication != (
        "The total cost of your other upcoming flights is $1,628.\n"
    ):
        raise ValueError("frozen communication mismatch")

    reference = load_json(a0 / "trajectories" / "reference-actions.json")
    alternative = load_json(a0 / "trajectories" / "alternative-actions.json")

    if len(reference) != 5 or len(alternative) != 5:
        raise ValueError("action count mismatch")

    if reference[0]["name"] != "get_reservation_details":
        raise ValueError("reference action 0 mismatch")
    if reference[0]["arguments"] != {"reservation_id": "XEHM4B"}:
        raise ValueError("reference action 0 arguments mismatch")

    if reference[1]["name"] != "get_reservation_details":
        raise ValueError("reference action 1 mismatch")
    if reference[1]["arguments"] != {"reservation_id": "59XX6W"}:
        raise ValueError("reference action 1 arguments mismatch")

    if alternative[0] != reference[1]:
        raise ValueError("alternative action 0 is not frozen swap")
    if alternative[1] != reference[0]:
        raise ValueError("alternative action 1 is not frozen swap")
    if alternative[2:] != reference[2:]:
        raise ValueError("alternative writes changed")

    if canonical_json_bytes(reference) == canonical_json_bytes(alternative):
        raise ValueError("trajectory sequences are not distinct")

    return reference, alternative, communication.rstrip("\n")


def task_initial_state(task):
    if task.initial_state is None:
        return None, None, []

    initialization_data = task.initial_state.initialization_data
    initialization_actions = task.initial_state.initialization_actions
    message_history = copy.deepcopy(task.initial_state.message_history or [])

    return initialization_data, initialization_actions, message_history


def deterministic_timestamp(index):
    return f"2000-01-01T00:00:{index:02d}Z"


def execute_one(label, task, sequence, final_text, out_dir):
    environment = get_environment(solo_mode=False)

    (
        initialization_data,
        initialization_actions,
        initial_messages,
    ) = task_initial_state(task)

    environment.set_state(
        initialization_data=initialization_data,
        initialization_actions=initialization_actions,
        message_history=copy.deepcopy(initial_messages),
        strict=True,
    )

    messages = copy.deepcopy(initial_messages)
    lineage = []
    tool_error_count = 0
    turn = len(messages)

    for ordinal, action in enumerate(sequence):
        requestor = action.get("requestor", "assistant")
        call_id = f"trajectory-{label}-call-{ordinal}"

        tool_call = ToolCall(
            id=call_id,
            name=action["name"],
            arguments=copy.deepcopy(action["arguments"]),
            requestor=requestor,
        )

        assistant_message = AssistantMessage(
            role="assistant",
            content=None,
            tool_calls=[tool_call],
            timestamp=deterministic_timestamp(turn),
            turn_idx=turn,
        )
        messages.append(assistant_message)
        turn += 1

        tool_message = environment.get_response(tool_call)
        tool_message.timestamp = deterministic_timestamp(turn)
        tool_message.turn_idx = turn
        messages.append(tool_message)
        turn += 1

        if tool_message.error:
            tool_error_count += 1

        lineage.append(
            {
                "ordinal": ordinal,
                "tool_call_id": call_id,
                "name": action["name"],
                "arguments": copy.deepcopy(action["arguments"]),
                "requestor": requestor,
                "tool_response": tool_message.content,
                "tool_error": bool(tool_message.error),
            }
        )

    final_message = AssistantMessage(
        role="assistant",
        content=final_text,
        tool_calls=None,
        timestamp=deterministic_timestamp(turn),
        turn_idx=turn,
    )
    messages.append(final_message)

    live_agent_db_hash = environment.get_db_hash()
    live_user_db_hash = environment.get_user_db_hash()

    simulation = SimulationRun(
        id=f"tau2-outcome-equivalent-derivations-001-{label}",
        task_id=str(task.id),
        timestamp="2000-01-01T00:00:00Z",
        start_time="2000-01-01T00:00:00Z",
        end_time="2000-01-01T00:00:00Z",
        duration=0.0,
        termination_reason=TerminationReason.AGENT_STOP,
        agent_cost=0.0,
        user_cost=0.0,
        messages=messages,
        trial=0,
        seed=0,
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

    simulation.reward_info = reward_info

    reward_breakdown = reward_info.reward_breakdown or {}
    db_reward = reward_breakdown.get(RewardType.DB)
    communicate_reward = reward_breakdown.get(RewardType.COMMUNICATE)

    db_match = None
    if reward_info.db_check is not None:
        db_match = bool(reward_info.db_check.db_match)

    communicate_checks = []
    for check in reward_info.communicate_checks or []:
        communicate_checks.append(
            {
                "info": check.info,
                "met": bool(check.met),
                "justification": check.justification,
            }
        )

    action_checks = []
    for check in reward_info.action_checks or []:
        action_checks.append(
            {
                "action_match": bool(check.action_match),
                "tool_type": (
                    check.tool_type.value
                    if check.tool_type is not None
                    else None
                ),
            }
        )

    trajectory_path = out_dir / f"trajectory-{label}.json"
    write_json(
        trajectory_path,
        simulation.model_dump(mode="json"),
    )

    lineage_path = out_dir / f"trajectory-{label}-lineage.ndjson"
    with open(lineage_path, "w", encoding="ascii", newline="\n") as fp:
        for item in lineage:
            fp.write(
                json.dumps(
                    item,
                    sort_keys=True,
                    separators=(",", ":"),
                    ensure_ascii=True,
                )
            )
            fp.write("\n")
        fp.write(
            json.dumps(
                {
                    "type": "assistant_final",
                    "content": final_text,
                },
                sort_keys=True,
                separators=(",", ":"),
                ensure_ascii=True,
            )
        )
        fp.write("\n")

    result = {
        "label": label,
        "task_id": str(task.id),
        "tool_call_count": len(sequence),
        "tool_error_count": tool_error_count,
        "live_agent_db_hash": live_agent_db_hash,
        "live_user_db_hash": live_user_db_hash,
        "final_reward": reward_info.reward,
        "db_reward": db_reward,
        "db_match": db_match,
        "communicate_reward": communicate_reward,
        "communicate_checks": communicate_checks,
        "action_checks": action_checks,
        "trajectory_sha256": sha256_file(trajectory_path),
        "lineage_sha256": sha256_file(lineage_path),
    }

    write_json(
        out_dir / f"trajectory-{label}-result.json",
        result,
    )

    return result


def audit_only(a0):
    reference, alternative, final_text = assert_frozen_contract(a0)

    report = {
        "audit": "PASS",
        "task_id": "7",
        "reference_action_count": len(reference),
        "alternative_action_count": len(alternative),
        "sequence_distinct": (
            canonical_json_bytes(reference)
            != canonical_json_bytes(alternative)
        ),
        "fixed_communication": final_text,
        "trajectory_executed": False,
        "judge_executed": False,
    }

    print(
        json.dumps(
            report,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=True,
        )
    )


def append_progress(path, event):
    with open(path, "a", encoding="ascii", newline="\n") as fp:
        fp.write(event)
        fp.write("\n")


def execute(a0, out_dir):
    reference, alternative, final_text = assert_frozen_contract(a0)

    frozen_task_dict = load_json(a0 / "task" / "selected-task.json")
    frozen_task = Task.model_validate(frozen_task_dict)

    tasks = get_tasks("base")
    matches = [task for task in tasks if str(task.id) == "7"]

    if len(matches) != 1:
        raise ValueError("runtime task 7 resolution mismatch")

    runtime_task = matches[0]

    if runtime_task != frozen_task:
        raise ValueError("runtime task 7 differs from frozen A0 task")

    out_dir.mkdir(parents=True, exist_ok=False)
    progress_path = out_dir / "progress.tsv"
    progress_path.write_text("event\n", encoding="ascii")

    append_progress(progress_path, "TRAJECTORY_A_STARTED")
    result_a = execute_one(
        "A",
        runtime_task,
        reference,
        final_text,
        out_dir,
    )

    append_progress(progress_path, "TRAJECTORY_A_JUDGED")
    append_progress(progress_path, "TRAJECTORY_B_STARTED")
    result_b = execute_one(
        "B",
        runtime_task,
        alternative,
        final_text,
        out_dir,
    )

    append_progress(progress_path, "TRAJECTORY_B_JUDGED")

    final_hash_equal = (
        result_a["live_agent_db_hash"] is not None
        and result_b["live_agent_db_hash"] is not None
        and result_a["live_agent_db_hash"]
        == result_b["live_agent_db_hash"]
    )

    criteria = {
        "trajectory_A_tool_errors_zero": (
            result_a["tool_error_count"] == 0
        ),
        "trajectory_B_tool_errors_zero": (
            result_b["tool_error_count"] == 0
        ),
        "trajectory_A_final_reward_1": (
            result_a["final_reward"] == 1.0
        ),
        "trajectory_B_final_reward_1": (
            result_b["final_reward"] == 1.0
        ),
        "trajectory_A_db_reward_1": (
            result_a["db_reward"] == 1.0
        ),
        "trajectory_B_db_reward_1": (
            result_b["db_reward"] == 1.0
        ),
        "trajectory_A_db_match": (
            result_a["db_match"] is True
        ),
        "trajectory_B_db_match": (
            result_b["db_match"] is True
        ),
        "trajectory_A_communicate_reward_1": (
            result_a["communicate_reward"] == 1.0
        ),
        "trajectory_B_communicate_reward_1": (
            result_b["communicate_reward"] == 1.0
        ),
        "final_agent_db_hash_equal": final_hash_equal,
        "derivation_lineage_distinct": (
            result_a["lineage_sha256"]
            != result_b["lineage_sha256"]
        ),
    }

    scientific_pass = all(criteria.values())

    overall = {
        "case": "TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001",
        "task_id": "7",
        "trajectory_A": result_a,
        "trajectory_B": result_b,
        "criteria": criteria,
        "scientific_pass": scientific_pass,
        "model_endpoint_called": False,
        "user_simulator_executed": False,
        "yoda_writes": 0,
    }

    write_json(out_dir / "overall-result.json", overall)
    append_progress(progress_path, "OVERALL_RESULT_FROZEN")

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
        "--a0-stage",
        required=True,
    )
    parser.add_argument(
        "--out-dir",
    )
    args = parser.parse_args()

    a0 = Path(args.a0_stage)

    if args.mode == "audit":
        audit_only(a0)
        return 0

    if args.out_dir is None:
        raise ValueError("--out-dir is required in execute mode")

    execute(a0, Path(args.out_dir))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(
            "WORKER_RUNTIME_ERROR="
            + type(exc).__name__
            + ":"
            + str(exc),
            file=sys.stderr,
        )
        raise
