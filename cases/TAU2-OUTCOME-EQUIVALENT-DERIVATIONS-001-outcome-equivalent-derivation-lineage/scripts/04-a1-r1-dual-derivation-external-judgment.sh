#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="A1-R1"

ROOT="$HOME/cmu/$CASE"

A0="$ROOT/stage-a0-r1"
A0_LOCK="$ROOT/.stage-a0-r1-freeze-started"

PREFLIGHT_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a1-r1-runtime-preflight-console.log"

A1_LOCK="$ROOT/.stage-a1-r1-execution-started"
A1_STAGE="$ROOT/stage-a1-r1"
EVIDENCE="$A1_STAGE/evidence"
RESULTS="$A1_STAGE/results"

WORK="$ROOT/.stage-a1-r1-prep"
REPO="$WORK/tau2-bench"
ADAPTER="$WORK/a1-dual-derivation-authority.py"

UPSTREAM="https://github.com/sierra-research/tau2-bench.git"
RELEASE_TAG="v1.0.1"
EXPECTED_RELEASE_COMMIT="fc0055dc4e0a316c3f83133267fbd6faaa770992"

EXPECTED_A0_LOCK_SHA256="e051f5b80216a0c99005043ec90f95ca452c9f82ef677a525e2b4a9be1426449"
EXPECTED_A0_MANIFEST_SHA256="333301ea6e61dfb6de91831eb51c9a956b5d18b006a3c3d9be518bf96b2da7bc"
EXPECTED_PREFLIGHT_CONSOLE_SHA256="ac32149a14eb98cd40e4329ee302fa5d5f4b8a9bfa4867af83b18fb74b17846a"

EXPECTED_EXECUTION_CONTRACT_SHA256="309e1ff91adabb906c3d8b343aed635e702d7004e871a3b78caf2d05b3ccd0fb"
EXPECTED_COMMUNICATION_SHA256="e2fcd502dd50c4ba6a65c390461fc38f2963774f2f3147e01ee59ec828aa08e1"
EXPECTED_OUTCOME_CONTRACT_SHA256="36cb7978585b176302959d9d98c0bc76253858bf710c9a999e679adfbe7f9672"

EXPECTED_UV_VERSION="uv 0.12.23 (x86_64-unknown-linux-gnu)"
EXPECTED_PYTHON_VERSION="3.12.15"
EXPECTED_TAU2_VERSION="1.0.1"

EXPECTED_PYPROJECT_BLOB="55a9d9cf6ebd8bf2326798f4923988917e431086"
EXPECTED_UV_LOCK_BLOB="09f0b4a86b4aaf82bf87511df1ff970ff23ec6bd"
EXPECTED_AIRLINE_ENV_BLOB="e1cabffe7ed4ad895904aa5248319dd307e77a97"
EXPECTED_EVALUATOR_BLOB="76c95a83e9049d70a5570b93989797c0626974b6"
EXPECTED_EVALUATOR_ENV_BLOB="a2e0a1a07cffd9394cc462376799289b1e9fbedd"
EXPECTED_EVALUATOR_COMM_BLOB="1bac18fd8830304894da767d2e6b7efe6e779e89"

ADAPTER_COMMIT="360ab0552488ca06e9f1c2cbf1cc45d6b6b94b63"
EXPECTED_ADAPTER_SHA256="94424c62a06f1b24cf45c1a6bacd1ce1bbb44753f9caf1281a86fb37b96cdf16"

ADAPTER_URL="https://raw.githubusercontent.com/josefaquino/Yoda/$ADAPTER_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/adapters/a1-dual-derivation-authority.py"

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

prelock_not_evaluated()
{
    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A1=NOT_EVALUATED"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A1_EXECUTION_LOCK_CONSUMED=NO"
    echo "TRAJECTORY_A_EXECUTED=NO"
    echo "TRAJECTORY_B_EXECUTED=NO"
    echo "EXTERNAL_JUDGE_EXECUTED=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "USER_SIMULATOR_EXECUTED=NO"
    echo "YODA_WRITES=ZERO"
    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        prelock_not_evaluated "LOCAL_TOOLCHAIN_MISSING_$2"

    echo "$2=PASS"
}

blob_check()
{
    file="$1"
    expected="$2"
    label="$3"

    actual="$(git -C "$REPO" hash-object "$file")"

    test "$actual" = "$expected" ||
        prelock_not_evaluated "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

freeze_manifest()
{
    (
        cd "$A1_STAGE"
        find evidence results \
            -type f \
            ! -name SHA256SUMS \
            ! -name SHA256SUMS.check \
            -print |
        LC_ALL=C sort |
        xargs sha256sum > evidence/SHA256SUMS

        sha256sum -c evidence/SHA256SUMS \
            > evidence/SHA256SUMS.check
    )
}

postlock_not_evaluated()
{
    failure="$1"

    echo "CASE	$CASE" > "$EVIDENCE/summary.tsv"
    echo "REVISION	$REVISION" >> "$EVIDENCE/summary.tsv"
    echo "VERDICT	NOT_EVALUATED" >> "$EVIDENCE/summary.tsv"
    echo "FAILURE_CLASS	$failure" >> "$EVIDENCE/summary.tsv"
    echo "A1_R1_RERUN	NO" >> "$EVIDENCE/summary.tsv"
    echo "MODEL_ENDPOINT_CALLED	NO" >> "$EVIDENCE/summary.tsv"
    echo "USER_SIMULATOR_EXECUTED	NO" >> "$EVIDENCE/summary.tsv"
    echo "YODA_WRITES	ZERO" >> "$EVIDENCE/summary.tsv"

    freeze_manifest || true

    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A1=NOT_EVALUATED"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$failure"
    echo "A1_EXECUTION_LOCK_CONSUMED=YES"
    echo "A1_R1_RERUN=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "USER_SIMULATOR_EXECUTED=NO"
    echo "YODA_WRITES=ZERO"

    if test -f "$RESULTS/progress.tsv"
    then
        echo
        echo "=== A1 PROGRESS ==="
        cat "$RESULTS/progress.tsv"
    fi

    if test -f "$EVIDENCE/SHA256SUMS"
    then
        echo "A1_EVIDENCE_MANIFEST_SHA256=$(sha "$EVIDENCE/SHA256SUMS")"
    fi

    exit 2
}

test ! -e "$A1_LOCK" ||
    prelock_not_evaluated "A1_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$A1_STAGE" ||
    prelock_not_evaluated "A1_STAGE_ALREADY_EXISTS"

rm -rf "$WORK"
mkdir -p "$WORK"

section "0. LOCAL TOOLCHAIN"

require_cmd git GIT
require_cmd uv UV
require_cmd curl CURL
require_cmd jq JQ
require_cmd grep GREP
require_cmd awk AWK
require_cmd cmp CMP
require_cmd find FIND
require_cmd xargs XARGS
require_cmd sha256sum SHA256SUM
require_cmd wc WC
require_cmd cp CP
require_cmd mkdir MKDIR
require_cmd rm RM
require_cmd cat CAT

section "1. A0 AUTHORITY"

test -f "$A0_LOCK" ||
    prelock_not_evaluated "A0_LOCK_MISSING"

test "$(sha "$A0_LOCK")" = "$EXPECTED_A0_LOCK_SHA256" ||
    prelock_not_evaluated "A0_LOCK_IDENTITY_MISMATCH"

test -f "$A0/evidence/SHA256SUMS" ||
    prelock_not_evaluated "A0_MANIFEST_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    prelock_not_evaluated "A0_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || prelock_not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

test "$(sha "$A0/contracts/execution-contract.tsv")" = "$EXPECTED_EXECUTION_CONTRACT_SHA256" ||
    prelock_not_evaluated "A0_EXECUTION_CONTRACT_IDENTITY_MISMATCH"

test "$(sha "$A0/contracts/communication.txt")" = "$EXPECTED_COMMUNICATION_SHA256" ||
    prelock_not_evaluated "A0_COMMUNICATION_IDENTITY_MISMATCH"

test "$(sha "$A0/contracts/outcome-equivalence-contract.tsv")" = "$EXPECTED_OUTCOME_CONTRACT_SHA256" ||
    prelock_not_evaluated "A0_OUTCOME_CONTRACT_IDENTITY_MISMATCH"

echo "A0_LOCK_IDENTITY=PASS"
echo "A0_MANIFEST_IDENTITY=PASS"
echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "A0_CONTRACT_AUTHORITY=PASS"

section "2. A1 PREFLIGHT AUTHORITY"

test -f "$PREFLIGHT_CONSOLE" ||
    prelock_not_evaluated "A1_PREFLIGHT_CONSOLE_MISSING"

ACTUAL_PREFLIGHT_CONSOLE_SHA256="$(sha "$PREFLIGHT_CONSOLE")"

echo "EXPECTED_PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256"
echo "ACTUAL_PREFLIGHT_CONSOLE_SHA256=$ACTUAL_PREFLIGHT_CONSOLE_SHA256"

test "$ACTUAL_PREFLIGHT_CONSOLE_SHA256" = "$EXPECTED_PREFLIGHT_CONSOLE_SHA256" ||
    prelock_not_evaluated "A1_PREFLIGHT_CONSOLE_IDENTITY_MISMATCH"

grep -F "A1_R1_PREFLIGHT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_not_evaluated "A1_PREFLIGHT_RESULT_MISSING"

grep -F "TAU2_UV_SYNC=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_not_evaluated "A1_PREFLIGHT_RUNTIME_AUTHORITY_MISSING"

grep -F "TAU2_IMPORT_CAPABILITY=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_not_evaluated "A1_PREFLIGHT_IMPORT_AUTHORITY_MISSING"

grep -F "A1_EXECUTION_LOCK=ABSENT" "$PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_not_evaluated "A1_PREFLIGHT_LOCK_BOUNDARY_MISMATCH"

echo "A1_PREFLIGHT_AUTHORITY=PASS"

section "3. PINNED RUNTIME"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM" \
    "$REPO" ||
    prelock_not_evaluated "UPSTREAM_RELEASE_FETCH_FAILURE"

ACTUAL_RELEASE_COMMIT="$(git -C "$REPO" rev-parse HEAD)"

test "$ACTUAL_RELEASE_COMMIT" = "$EXPECTED_RELEASE_COMMIT" ||
    prelock_not_evaluated "UPSTREAM_RELEASE_COMMIT_MISMATCH"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "uv.lock" "$EXPECTED_UV_LOCK_BLOB" "UV_LOCK_BLOB"
blob_check "src/tau2/domains/airline/environment.py" "$EXPECTED_AIRLINE_ENV_BLOB" "AIRLINE_ENVIRONMENT_BLOB"
blob_check "src/tau2/evaluator/evaluator.py" "$EXPECTED_EVALUATOR_BLOB" "EVALUATOR_BLOB"
blob_check "src/tau2/evaluator/evaluator_env.py" "$EXPECTED_EVALUATOR_ENV_BLOB" "EVALUATOR_ENV_BLOB"
blob_check "src/tau2/evaluator/evaluator_communicate.py" "$EXPECTED_EVALUATOR_COMM_BLOB" "EVALUATOR_COMMUNICATE_BLOB"

ACTUAL_UV_VERSION="$(uv --version)"

echo "EXPECTED_UV_VERSION=$EXPECTED_UV_VERSION"
echo "ACTUAL_UV_VERSION=$ACTUAL_UV_VERSION"

test "$ACTUAL_UV_VERSION" = "$EXPECTED_UV_VERSION" ||
    prelock_not_evaluated "UV_VERSION_DRIFT"

(
    cd "$REPO"
    uv sync --frozen
) ||
    prelock_not_evaluated "TAU2_UV_SYNC_FAILURE"

PY="$REPO/.venv/bin/python"

test -x "$PY" ||
    prelock_not_evaluated "TAU2_PYTHON_RUNTIME_MISSING"

ACTUAL_PYTHON_VERSION="$(
    "$PY" -c 'import platform; print(platform.python_version())'
)" || prelock_not_evaluated "PYTHON_VERSION_UNAVAILABLE"

echo "EXPECTED_PYTHON_VERSION=$EXPECTED_PYTHON_VERSION"
echo "ACTUAL_PYTHON_VERSION=$ACTUAL_PYTHON_VERSION"

test "$ACTUAL_PYTHON_VERSION" = "$EXPECTED_PYTHON_VERSION" ||
    prelock_not_evaluated "PYTHON_VERSION_DRIFT"

ACTUAL_TAU2_VERSION="$(
    "$PY" -c 'import importlib.metadata; print(importlib.metadata.version("tau2"))'
)" || prelock_not_evaluated "TAU2_VERSION_UNAVAILABLE"

echo "EXPECTED_TAU2_VERSION=$EXPECTED_TAU2_VERSION"
echo "ACTUAL_TAU2_VERSION=$ACTUAL_TAU2_VERSION"

test "$ACTUAL_TAU2_VERSION" = "$EXPECTED_TAU2_VERSION" ||
    prelock_not_evaluated "TAU2_VERSION_DRIFT"

echo "PINNED_RUNTIME=PASS"

section "4. AUTHORITY ADAPTER"

curl -fsSL "$ADAPTER_URL" -o "$ADAPTER" ||
    prelock_not_evaluated "ADAPTER_FETCH_FAILURE"

ACTUAL_ADAPTER_SHA256="$(sha "$ADAPTER")"

echo "EXPECTED_ADAPTER_SHA256=$EXPECTED_ADAPTER_SHA256"
echo "ACTUAL_ADAPTER_SHA256=$ACTUAL_ADAPTER_SHA256"

test "$ACTUAL_ADAPTER_SHA256" = "$EXPECTED_ADAPTER_SHA256" ||
    prelock_not_evaluated "ADAPTER_IDENTITY_MISMATCH"

if grep -Eiq 'openai|anthropic|litellm' "$ADAPTER"
then
    prelock_not_evaluated "ADAPTER_MODEL_PROVIDER_REFERENCE_PRESENT"
fi

"$PY" -m py_compile "$ADAPTER" ||
    prelock_not_evaluated "ADAPTER_PYTHON_PARSE_FAILURE"

AUDIT_STDOUT="$WORK/adapter-audit.json"
AUDIT_STDERR="$WORK/adapter-audit.stderr"

"$PY" "$ADAPTER" \
    --mode audit \
    --a0-stage "$A0" \
    > "$AUDIT_STDOUT" \
    2> "$AUDIT_STDERR" ||
    prelock_not_evaluated "ADAPTER_AUDIT_FAILURE"

jq -e '
    .audit == "PASS"
    and .task_id == "7"
    and .reference_action_count == 5
    and .alternative_action_count == 5
    and .sequence_distinct == true
    and .trajectory_executed == false
    and .judge_executed == false
' "$AUDIT_STDOUT" >/dev/null ||
    prelock_not_evaluated "ADAPTER_AUDIT_RESULT_MISMATCH"

echo "ADAPTER_IDENTITY=PASS"
echo "ADAPTER_PARSE=PASS"
echo "ADAPTER_PRE_EXECUTION_AUDIT=PASS"

section "5. FINAL PRE-GATE BOUNDARY"

test ! -e "$A1_LOCK" ||
    prelock_not_evaluated "A1_EXECUTION_LOCK_UNEXPECTEDLY_PRESENT"

test ! -e "$A1_STAGE" ||
    prelock_not_evaluated "A1_STAGE_UNEXPECTEDLY_PRESENT"

echo "A1_EXECUTION_LOCK=ABSENT"
echo "A1_STAGE=ABSENT"
echo "TRAJECTORY_A_EXECUTED=NO"
echo "TRAJECTORY_B_EXECUTED=NO"
echo "EXTERNAL_JUDGE_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "YODA_WRITES=ZERO"

section "6. ONE-EXECUTION SCIENTIFIC GATE"

cat > "$A1_LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
A0_LOCK_SHA256=$EXPECTED_A0_LOCK_SHA256
A0_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256
ADAPTER_SHA256=$EXPECTED_ADAPTER_SHA256
ADAPTER_COMMIT=$ADAPTER_COMMIT
RELEASE_TAG=$RELEASE_TAG
RELEASE_COMMIT=$EXPECTED_RELEASE_COMMIT
UV_VERSION=$EXPECTED_UV_VERSION
PYTHON_VERSION=$EXPECTED_PYTHON_VERSION
TAU2_VERSION=$EXPECTED_TAU2_VERSION
TASK_ID=7
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_TRAJECTORY_A=YES
EOF

test -f "$A1_LOCK" ||
    prelock_not_evaluated "A1_EXECUTION_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A1_EXECUTION_LOCK_SHA256=$(sha "$A1_LOCK")"
echo "A1_EXECUTION_GATE=PASS"

mkdir -p "$EVIDENCE" ||
    postlock_not_evaluated "A1_STAGE_MATERIALIZATION_FAILURE"

cp "$ADAPTER" "$EVIDENCE/a1-dual-derivation-authority.py" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$A1_LOCK" "$EVIDENCE/execution-started.txt" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$A0/contracts/execution-contract.tsv" "$EVIDENCE/a0-execution-contract.tsv" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$A0/contracts/communication.txt" "$EVIDENCE/a0-communication.txt" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$A0/contracts/outcome-equivalence-contract.tsv" "$EVIDENCE/a0-outcome-equivalence-contract.tsv" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$AUDIT_STDOUT" "$EVIDENCE/adapter-audit.json" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$AUDIT_STDERR" "$EVIDENCE/adapter-audit.stderr" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

section "7. DUAL DERIVATION EXECUTION + EXTERNAL JUDGMENT"

unset OPENAI_API_KEY || true
unset ANTHROPIC_API_KEY || true
unset GOOGLE_API_KEY || true
unset GEMINI_API_KEY || true
unset XAI_API_KEY || true
unset AWS_ACCESS_KEY_ID || true
unset AWS_SECRET_ACCESS_KEY || true

set +e
"$PY" "$ADAPTER" \
    --mode execute \
    --a0-stage "$A0" \
    --out-dir "$RESULTS" \
    > "$EVIDENCE/authority.stdout.log" \
    2> "$EVIDENCE/authority.stderr.log"
WORKER_RC=$?
set -e

echo "AUTHORITY_ADAPTER_RC=$WORKER_RC"

if test "$WORKER_RC" -ne 0
then
    postlock_not_evaluated "EXTERNAL_AUTHORITY_EXECUTION_FAILURE"
fi

test -f "$RESULTS/overall-result.json" ||
    postlock_not_evaluated "OVERALL_RESULT_MISSING"

test -f "$RESULTS/trajectory-A-result.json" ||
    postlock_not_evaluated "TRAJECTORY_A_RESULT_MISSING"

test -f "$RESULTS/trajectory-B-result.json" ||
    postlock_not_evaluated "TRAJECTORY_B_RESULT_MISSING"

test -f "$RESULTS/progress.tsv" ||
    postlock_not_evaluated "PROGRESS_EVIDENCE_MISSING"

grep -Fx "TRAJECTORY_A_STARTED" "$RESULTS/progress.tsv" >/dev/null ||
    postlock_not_evaluated "TRAJECTORY_A_NOT_STARTED"

grep -Fx "TRAJECTORY_A_JUDGED" "$RESULTS/progress.tsv" >/dev/null ||
    postlock_not_evaluated "TRAJECTORY_A_JUDGMENT_INCOMPLETE"

grep -Fx "TRAJECTORY_B_STARTED" "$RESULTS/progress.tsv" >/dev/null ||
    postlock_not_evaluated "TRAJECTORY_B_NOT_STARTED"

grep -Fx "TRAJECTORY_B_JUDGED" "$RESULTS/progress.tsv" >/dev/null ||
    postlock_not_evaluated "TRAJECTORY_B_JUDGMENT_INCOMPLETE"

grep -Fx "OVERALL_RESULT_FROZEN" "$RESULTS/progress.tsv" >/dev/null ||
    postlock_not_evaluated "OVERALL_RESULT_NOT_FROZEN"

jq -e '
    .case == "TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
    and .task_id == "7"
    and .trajectory_A.tool_call_count == 5
    and .trajectory_B.tool_call_count == 5
    and .model_endpoint_called == false
    and .user_simulator_executed == false
    and .yoda_writes == 0
' "$RESULTS/overall-result.json" >/dev/null ||
    postlock_not_evaluated "OVERALL_RESULT_SCHEMA_MISMATCH"

echo "TRAJECTORY_A_EXECUTED=YES"
echo "TRAJECTORY_A_EXTERNAL_JUDGE=COMPLETE"
echo "TRAJECTORY_B_EXECUTED=YES"
echo "TRAJECTORY_B_EXTERNAL_JUDGE=COMPLETE"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "USER_SIMULATOR_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

section "8. SCIENTIFIC ADJUDICATION"

A_FINAL="$(jq -r '.trajectory_A.final_reward' "$RESULTS/overall-result.json")"
B_FINAL="$(jq -r '.trajectory_B.final_reward' "$RESULTS/overall-result.json")"

A_DB="$(jq -r '.trajectory_A.db_reward' "$RESULTS/overall-result.json")"
B_DB="$(jq -r '.trajectory_B.db_reward' "$RESULTS/overall-result.json")"

A_COMM="$(jq -r '.trajectory_A.communicate_reward' "$RESULTS/overall-result.json")"
B_COMM="$(jq -r '.trajectory_B.communicate_reward' "$RESULTS/overall-result.json")"

A_DB_MATCH="$(jq -r '.trajectory_A.db_match' "$RESULTS/overall-result.json")"
B_DB_MATCH="$(jq -r '.trajectory_B.db_match' "$RESULTS/overall-result.json")"

A_ERRORS="$(jq -r '.trajectory_A.tool_error_count' "$RESULTS/overall-result.json")"
B_ERRORS="$(jq -r '.trajectory_B.tool_error_count' "$RESULTS/overall-result.json")"

A_HASH="$(jq -r '.trajectory_A.live_agent_db_hash' "$RESULTS/overall-result.json")"
B_HASH="$(jq -r '.trajectory_B.live_agent_db_hash' "$RESULTS/overall-result.json")"

A_LINEAGE="$(jq -r '.trajectory_A.lineage_sha256' "$RESULTS/overall-result.json")"
B_LINEAGE="$(jq -r '.trajectory_B.lineage_sha256' "$RESULTS/overall-result.json")"

SCIENTIFIC_PASS="$(jq -r '.scientific_pass' "$RESULTS/overall-result.json")"

echo "TRAJECTORY_A_FINAL_REWARD=$A_FINAL"
echo "TRAJECTORY_B_FINAL_REWARD=$B_FINAL"
echo "TRAJECTORY_A_DB_REWARD=$A_DB"
echo "TRAJECTORY_B_DB_REWARD=$B_DB"
echo "TRAJECTORY_A_COMMUNICATE_REWARD=$A_COMM"
echo "TRAJECTORY_B_COMMUNICATE_REWARD=$B_COMM"
echo "TRAJECTORY_A_DB_MATCH=$A_DB_MATCH"
echo "TRAJECTORY_B_DB_MATCH=$B_DB_MATCH"
echo "TRAJECTORY_A_TOOL_ERROR_COUNT=$A_ERRORS"
echo "TRAJECTORY_B_TOOL_ERROR_COUNT=$B_ERRORS"
echo "TRAJECTORY_A_FINAL_DB_HASH=$A_HASH"
echo "TRAJECTORY_B_FINAL_DB_HASH=$B_HASH"
echo "TRAJECTORY_A_LINEAGE_SHA256=$A_LINEAGE"
echo "TRAJECTORY_B_LINEAGE_SHA256=$B_LINEAGE"

if test "$A_HASH" = "$B_HASH" && test "$A_HASH" != "null"
then
    echo "FINAL_DB_HASH_EQUIVALENCE=PASS"
else
    echo "FINAL_DB_HASH_EQUIVALENCE=FAIL"
fi

if test "$A_LINEAGE" != "$B_LINEAGE"
then
    echo "DERIVATION_LINEAGE_DISTINCTNESS=PASS"
else
    echo "DERIVATION_LINEAGE_DISTINCTNESS=FAIL"
fi

if test "$SCIENTIFIC_PASS" = "true"
then
    VERDICT="PASS"
else
    VERDICT="FAIL"
fi

section "9. FREEZE A1 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	$VERDICT
A0_LOCK_SHA256	$EXPECTED_A0_LOCK_SHA256
A0_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
PREFLIGHT_CONSOLE_SHA256	$EXPECTED_PREFLIGHT_CONSOLE_SHA256
ADAPTER_SHA256	$EXPECTED_ADAPTER_SHA256
ADAPTER_COMMIT	$ADAPTER_COMMIT
RELEASE_TAG	$RELEASE_TAG
RELEASE_COMMIT	$EXPECTED_RELEASE_COMMIT
UV_VERSION	$EXPECTED_UV_VERSION
PYTHON_VERSION	$EXPECTED_PYTHON_VERSION
TAU2_VERSION	$EXPECTED_TAU2_VERSION
TASK_ID	7
TRAJECTORY_A_FINAL_REWARD	$A_FINAL
TRAJECTORY_B_FINAL_REWARD	$B_FINAL
TRAJECTORY_A_DB_REWARD	$A_DB
TRAJECTORY_B_DB_REWARD	$B_DB
TRAJECTORY_A_COMMUNICATE_REWARD	$A_COMM
TRAJECTORY_B_COMMUNICATE_REWARD	$B_COMM
TRAJECTORY_A_DB_MATCH	$A_DB_MATCH
TRAJECTORY_B_DB_MATCH	$B_DB_MATCH
TRAJECTORY_A_TOOL_ERROR_COUNT	$A_ERRORS
TRAJECTORY_B_TOOL_ERROR_COUNT	$B_ERRORS
TRAJECTORY_A_FINAL_DB_HASH	$A_HASH
TRAJECTORY_B_FINAL_DB_HASH	$B_HASH
TRAJECTORY_A_LINEAGE_SHA256	$A_LINEAGE
TRAJECTORY_B_LINEAGE_SHA256	$B_LINEAGE
SCIENTIFIC_PASS	$SCIENTIFIC_PASS
TRAJECTORY_A_EXECUTED	YES
TRAJECTORY_B_EXECUTED	YES
EXTERNAL_JUDGE_EXECUTED	YES
MODEL_ENDPOINT_CALLED	NO
USER_SIMULATOR_EXECUTED	NO
GOLDEN_STATE_MATERIALIZED	YES_BY_EXTERNAL_JUDGE
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-a1-r1-script.sh" ||
    postlock_not_evaluated "A1_EVIDENCE_MATERIALIZATION_FAILURE"

freeze_manifest ||
    postlock_not_evaluated "A1_EVIDENCE_INTEGRITY_FAILURE"

A1_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A1_EVIDENCE_INTEGRITY=PASS"
echo "A1_EVIDENCE_MANIFEST_SHA256=$A1_MANIFEST_SHA256"

section "10. A1 HOMOLOGATION"

if test "$VERDICT" = "PASS"
then
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A1=PASS"
    echo "A1_REVISION=$REVISION"
    echo "TRAJECTORY_A_EXTERNAL_JUDGE=PASS"
    echo "TRAJECTORY_B_EXTERNAL_JUDGE=PASS"
    echo "OUTCOME_EQUIVALENCE=PASS"
    echo "DERIVATION_DISTINCTNESS=PASS"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    echo "NEXT_GATE=A2_YODA_DUAL_DERIVATION_LINEAGE"
    rm -rf "$WORK" || true
    exit 0
fi

echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A1=FAIL"
echo "A1_REVISION=$REVISION"
echo "FAILURE_CLASS=OUTCOME_EQUIVALENCE_CRITERIA_NOT_MET"
echo "A1_R1_RERUN=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

rm -rf "$WORK" || true
exit 1
