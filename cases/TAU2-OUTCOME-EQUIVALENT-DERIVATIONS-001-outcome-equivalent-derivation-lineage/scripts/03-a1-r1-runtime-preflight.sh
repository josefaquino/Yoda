#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="A1-R1-PREFLIGHT"

ROOT="$HOME/cmu/$CASE"

A0="$ROOT/stage-a0-r1"
A0_LOCK="$ROOT/.stage-a0-r1-freeze-started"
A0_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a0-r1-console.log"

A1_LOCK="$ROOT/.stage-a1-r1-execution-started"
A1_STAGE="$ROOT/stage-a1-r1"

WORK="$ROOT/.a1-r1-preflight"
REPO="$WORK/tau2-bench"

UPSTREAM="https://github.com/sierra-research/tau2-bench.git"
RELEASE_TAG="v1.0.1"
EXPECTED_RELEASE_COMMIT="fc0055dc4e0a316c3f83133267fbd6faaa770992"

EXPECTED_A0_LOCK_SHA256="e051f5b80216a0c99005043ec90f95ca452c9f82ef677a525e2b4a9be1426449"
EXPECTED_A0_MANIFEST_SHA256="333301ea6e61dfb6de91831eb51c9a956b5d18b006a3c3d9be518bf96b2da7bc"
EXPECTED_A0_CONSOLE_SHA256="a70af99d2e78a5682c77a7e984b75a14f094e38ba871a2b91a4129350fd015b0"

EXPECTED_EXECUTION_CONTRACT_SHA256="309e1ff91adabb906c3d8b343aed635e702d7004e871a3b78caf2d05b3ccd0fb"
EXPECTED_COMMUNICATION_SHA256="e2fcd502dd50c4ba6a65c390461fc38f2963774f2f3147e01ee59ec828aa08e1"
EXPECTED_OUTCOME_CONTRACT_SHA256="36cb7978585b176302959d9d98c0bc76253858bf710c9a999e679adfbe7f9672"

EXPECTED_PYPROJECT_BLOB="55a9d9cf6ebd8bf2326798f4923988917e431086"
EXPECTED_UV_LOCK_BLOB="09f0b4a86b4aaf82bf87511df1ff970ff23ec6bd"
EXPECTED_AIRLINE_ENV_BLOB="e1cabffe7ed4ad895904aa5248319dd307e77a97"
EXPECTED_EVALUATOR_BLOB="76c95a83e9049d70a5570b93989797c0626974b6"
EXPECTED_EVALUATOR_ENV_BLOB="a2e0a1a07cffd9394cc462376799289b1e9fbedd"
EXPECTED_EVALUATOR_COMM_BLOB="1bac18fd8830304894da767d2e6b7efe6e779e89"

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

not_evaluated()
{
    echo
    echo "A1_R1_PREFLIGHT=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A1_EXECUTION_LOCK_CONSUMED=NO"
    echo "TRAJECTORY_A_EXECUTED=NO"
    echo "TRAJECTORY_B_EXECUTED=NO"
    echo "EXTERNAL_JUDGE_EXECUTED=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "USER_SIMULATOR_EXECUTED=NO"
    echo "GOLDEN_STATE_MATERIALIZED=NO"
    echo "YODA_WRITES=ZERO"
    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        not_evaluated "LOCAL_TOOLCHAIN_MISSING_$2"

    echo "$2=PASS"
}

blob_check()
{
    file="$1"
    expected="$2"
    label="$3"

    actual="$(git -C "$REPO" hash-object "$file")"

    printf '%s_EXPECTED=%s\n' "$label" "$expected"
    printf '%s_ACTUAL=%s\n' "$label" "$actual"

    test "$actual" = "$expected" ||
        not_evaluated "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

test ! -e "$A1_LOCK" ||
    not_evaluated "A1_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$A1_STAGE" ||
    not_evaluated "A1_STAGE_ALREADY_EXISTS"

rm -rf "$WORK"
mkdir -p "$WORK"

section "0. LOCAL TOOLCHAIN"

require_cmd git GIT
require_cmd uv UV
require_cmd jq JQ
require_cmd grep GREP
require_cmd awk AWK
require_cmd sha256sum SHA256SUM
require_cmd rm RM
require_cmd mkdir MKDIR

UV_VERSION="$(uv --version 2>/dev/null || true)"

test -n "$UV_VERSION" ||
    not_evaluated "UV_VERSION_UNAVAILABLE"

echo "UV_VERSION=$UV_VERSION"

section "1. A0 AUTHORITY"

test -f "$A0_LOCK" ||
    not_evaluated "A0_LOCK_MISSING"

test "$(sha "$A0_LOCK")" = "$EXPECTED_A0_LOCK_SHA256" ||
    not_evaluated "A0_LOCK_IDENTITY_MISMATCH"

test -f "$A0/evidence/SHA256SUMS" ||
    not_evaluated "A0_MANIFEST_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    not_evaluated "A0_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

test -f "$A0_CONSOLE" ||
    not_evaluated "A0_CONSOLE_MISSING"

test "$(sha "$A0_CONSOLE")" = "$EXPECTED_A0_CONSOLE_SHA256" ||
    not_evaluated "A0_CONSOLE_IDENTITY_MISMATCH"

test "$(sha "$A0/contracts/execution-contract.tsv")" = "$EXPECTED_EXECUTION_CONTRACT_SHA256" ||
    not_evaluated "A0_EXECUTION_CONTRACT_IDENTITY_MISMATCH"

test "$(sha "$A0/contracts/communication.txt")" = "$EXPECTED_COMMUNICATION_SHA256" ||
    not_evaluated "A0_COMMUNICATION_IDENTITY_MISMATCH"

test "$(sha "$A0/contracts/outcome-equivalence-contract.tsv")" = "$EXPECTED_OUTCOME_CONTRACT_SHA256" ||
    not_evaluated "A0_OUTCOME_CONTRACT_IDENTITY_MISMATCH"

echo "A0_LOCK_IDENTITY=PASS"
echo "A0_MANIFEST_IDENTITY=PASS"
echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "A0_CONSOLE_IDENTITY=PASS"
echo "A0_CONTRACT_AUTHORITY=PASS"

section "2. PINNED TAU2 RELEASE"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM" \
    "$REPO" ||
    not_evaluated "UPSTREAM_RELEASE_FETCH_FAILURE"

ACTUAL_RELEASE_COMMIT="$(git -C "$REPO" rev-parse HEAD)"

echo "RELEASE_TAG=$RELEASE_TAG"
echo "EXPECTED_RELEASE_COMMIT=$EXPECTED_RELEASE_COMMIT"
echo "ACTUAL_RELEASE_COMMIT=$ACTUAL_RELEASE_COMMIT"

test "$ACTUAL_RELEASE_COMMIT" = "$EXPECTED_RELEASE_COMMIT" ||
    not_evaluated "UPSTREAM_RELEASE_COMMIT_MISMATCH"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "uv.lock" "$EXPECTED_UV_LOCK_BLOB" "UV_LOCK_BLOB"
blob_check "src/tau2/domains/airline/environment.py" "$EXPECTED_AIRLINE_ENV_BLOB" "AIRLINE_ENVIRONMENT_BLOB"
blob_check "src/tau2/evaluator/evaluator.py" "$EXPECTED_EVALUATOR_BLOB" "EVALUATOR_BLOB"
blob_check "src/tau2/evaluator/evaluator_env.py" "$EXPECTED_EVALUATOR_ENV_BLOB" "EVALUATOR_ENV_BLOB"
blob_check "src/tau2/evaluator/evaluator_communicate.py" "$EXPECTED_EVALUATOR_COMM_BLOB" "EVALUATOR_COMMUNICATE_BLOB"

echo "UPSTREAM_RELEASE_AUTHORITY=PASS"

section "3. FROZEN CORE RUNTIME INSTALL"

(
    cd "$REPO"
    uv sync --frozen
) ||
    not_evaluated "TAU2_UV_SYNC_FAILURE"

echo "TAU2_UV_SYNC=PASS"

section "4. PYTHON + PACKAGE AUTHORITY"

PYTHON_VERSION="$(
    cd "$REPO"
    uv run --frozen python -c 'import platform; print(platform.python_version())'
)" || not_evaluated "PYTHON_RUNTIME_UNAVAILABLE"

echo "PYTHON_VERSION=$PYTHON_VERSION"

case "$PYTHON_VERSION" in
    3.12.*|3.13.*)
        echo "PYTHON_VERSION_POLICY=PASS"
        ;;
    *)
        not_evaluated "PYTHON_VERSION_POLICY_MISMATCH"
        ;;
esac

TAU2_VERSION="$(
    cd "$REPO"
    uv run --frozen python -c 'import importlib.metadata; print(importlib.metadata.version("tau2"))'
)" || not_evaluated "TAU2_PACKAGE_VERSION_UNAVAILABLE"

echo "TAU2_PACKAGE_VERSION=$TAU2_VERSION"

test "$TAU2_VERSION" = "1.0.1" ||
    not_evaluated "TAU2_PACKAGE_VERSION_MISMATCH"

echo "TAU2_PACKAGE_VERSION_AUTHORITY=PASS"

section "5. IMPORT-ONLY API CAPABILITY"

cat > "$WORK/import-audit.py" <<'PY'
import inspect
import json

from tau2.data_model.message import AssistantMessage, ToolCall, ToolMessage
from tau2.data_model.simulation import SimulationRun, TerminationReason
from tau2.data_model.tasks import Task
from tau2.domains.airline.environment import get_environment, get_tasks
from tau2.evaluator.evaluator import EvaluationType, evaluate_simulation
from tau2.evaluator.evaluator_communicate import CommunicateEvaluator
from tau2.evaluator.evaluator_env import EnvironmentEvaluator

report = {
    "assistant_message": AssistantMessage.__name__,
    "tool_call": ToolCall.__name__,
    "tool_message": ToolMessage.__name__,
    "simulation_run": SimulationRun.__name__,
    "termination_reason_agent_stop": TerminationReason.AGENT_STOP.value,
    "task_model": Task.__name__,
    "get_environment_callable": callable(get_environment),
    "get_tasks_callable": callable(get_tasks),
    "evaluation_type_all": EvaluationType.ALL.value,
    "evaluate_simulation_callable": callable(evaluate_simulation),
    "environment_evaluator_callable": callable(EnvironmentEvaluator.calculate_reward),
    "communicate_evaluator_callable": callable(CommunicateEvaluator.calculate_reward),
    "evaluate_simulation_signature": str(inspect.signature(evaluate_simulation)),
}

print(json.dumps(report, sort_keys=True, separators=(",", ":")))
PY

IMPORT_REPORT="$(
    cd "$REPO"
    uv run --frozen python "$WORK/import-audit.py"
)" || not_evaluated "TAU2_IMPORT_CAPABILITY_FAILURE"

echo "IMPORT_REPORT=$IMPORT_REPORT"

printf '%s\n' "$IMPORT_REPORT" |
jq -e '
    .assistant_message == "AssistantMessage"
    and .tool_call == "ToolCall"
    and .tool_message == "ToolMessage"
    and .simulation_run == "SimulationRun"
    and .termination_reason_agent_stop == "agent_stop"
    and .task_model == "Task"
    and .get_environment_callable == true
    and .get_tasks_callable == true
    and .evaluation_type_all == "all"
    and .evaluate_simulation_callable == true
    and .environment_evaluator_callable == true
    and .communicate_evaluator_callable == true
' >/dev/null ||
    not_evaluated "TAU2_IMPORT_API_MISMATCH"

echo "TAU2_IMPORT_CAPABILITY=PASS"
echo "TAU2_EVALUATOR_API_AVAILABLE=PASS"
echo "AIRLINE_RUNTIME_API_AVAILABLE=PASS"

section "6. A1 SCIENTIFIC BOUNDARY"

test ! -e "$A1_LOCK" ||
    not_evaluated "A1_EXECUTION_LOCK_UNEXPECTEDLY_CREATED"

test ! -e "$A1_STAGE" ||
    not_evaluated "A1_STAGE_UNEXPECTEDLY_CREATED"

echo "A1_R1_PREFLIGHT=PASS"
echo "A1_EXECUTION_LOCK=ABSENT"
echo "A1_STAGE=ABSENT"

echo "TRAJECTORY_A_EXECUTED=NO"
echo "TRAJECTORY_B_EXECUTED=NO"
echo "EXTERNAL_JUDGE_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "USER_SIMULATOR_EXECUTED=NO"
echo "GOLDEN_STATE_MATERIALIZED=NO"
echo "YODA_WRITES=ZERO"

echo "NEXT_GATE=A1_R1_DUAL_DERIVATION_EXTERNAL_JUDGMENT"

rm -rf "$WORK"
