#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="B-R1"

ROOT="$HOME/cmu/$CASE"

B0="$ROOT/b-r0-independent-replay-preflight"
B0_RECOVERED="$B0/recovered"
B0_EVIDENCE="$B0/evidence"
B0_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-b-r0-independent-replay-preflight-console.log"

A2_STORE="$ROOT/stage-a2-r1/yoda-store"

LOCK="$ROOT/.stage-b-r1-execution-started"
STAGE="$ROOT/stage-b-r1"
INPUTS="$STAGE/inputs"
EVIDENCE="$STAGE/evidence"
RESULTS="$STAGE/results"

PREP="$ROOT/.stage-b-r1-prep"
TAU2_REPO="$PREP/tau2-bench"
ADAPTER="$PREP/b-independent-replay-authority.py"

EXPECTED_B0_CONSOLE_SHA256="b35aa7052c76dd76fd44c587b5bb0ad302e3788fe8a2a919f9c11325ed8c6a2e"
EXPECTED_B0_MANIFEST_SHA256="93de5132aa3f43e8f7b5a3befd13e5270d9e372b9b0d55ee30711e7848416650"
EXPECTED_B0_STORE_MANIFEST_SHA256="28373a1e9a0b97e6f5b508d0a3847aefea1dd615e62f8cae486895727818398c"

EXPECTED_DATA_YODA_SHA256="0d790fb57c3fe092a1567327f049f0b123dd143c379f4afa21692b614f40d42a"
EXPECTED_DATA_YODA_BYTES=24801

EXPECTED_LINEAGE_A_SHA256="965417ca555dd70eff7d39e822326305b1e81b9e16864dcd7a92b43197d5d36b"
EXPECTED_LINEAGE_B_SHA256="1933529e5aa2902bd83a45d90f2692e07f0c3ef00ac4442db98ffdd114ae8340"
EXPECTED_FINAL_DB_HASH="0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7"

UPSTREAM="https://github.com/sierra-research/tau2-bench.git"
RELEASE_TAG="v1.0.1"
EXPECTED_RELEASE_COMMIT="fc0055dc4e0a316c3f83133267fbd6faaa770992"

EXPECTED_PYPROJECT_BLOB="55a9d9cf6ebd8bf2326798f4923988917e431086"
EXPECTED_UV_LOCK_BLOB="09f0b4a86b4aaf82bf87511df1ff970ff23ec6bd"
EXPECTED_AIRLINE_ENV_BLOB="e1cabffe7ed4ad895904aa5248319dd307e77a97"
EXPECTED_EVALUATOR_BLOB="76c95a83e9049d70a5570b93989797c0626974b6"

EXPECTED_UV_VERSION="uv 0.12.23 (x86_64-unknown-linux-gnu)"
EXPECTED_PYTHON_VERSION="3.12.15"
EXPECTED_TAU2_VERSION="1.0.1"

ADAPTER_COMMIT="fc2821cb9d590d35f3409d1b092cfbb29415a5c5"
EXPECTED_ADAPTER_SHA256="c63c1349e6eefc950f791382c1fc2caf9f1ae0e3a516107679ecd3dfbc1ca16a"

ADAPTER_URL="https://raw.githubusercontent.com/josefaquino/Yoda/$ADAPTER_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/adapters/b-independent-replay-authority.py"

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

store_manifest()
{
    output="$1"

    (
        cd "$A2_STORE"

        find . -type f -print |
        LC_ALL=C sort |
        xargs sha256sum
    ) > "$output"
}

prelock_not_evaluated()
{
    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_B=NOT_EVALUATED"
    echo "B_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "B_EXECUTION_LOCK_CONSUMED=NO"
    echo "INDEPENDENT_REPLAY_EXECUTED=NO"
    echo "EXTERNAL_JUDGE_EXECUTED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

freeze_manifest()
{
    (
        cd "$STAGE"

        find inputs evidence results \
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

    mkdir -p "$EVIDENCE" || true

    cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	NOT_EVALUATED
FAILURE_CLASS	$failure
B_R1_RERUN	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

    freeze_manifest || true

    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_B=NOT_EVALUATED"
    echo "B_REVISION=$REVISION"
    echo "FAILURE_CLASS=$failure"
    echo "B_EXECUTION_LOCK_CONSUMED=YES"
    echo "B_R1_RERUN=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"

    if test -f "$EVIDENCE/SHA256SUMS"
    then
        echo "B_EVIDENCE_MANIFEST_SHA256=$(sha "$EVIDENCE/SHA256SUMS")"
    fi

    exit 2
}

fail()
{
    failure="$1"

    mkdir -p "$EVIDENCE" || true

    cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	FAIL
FAILURE_CLASS	$failure
B_R1_RERUN	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

    freeze_manifest || true

    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_B=FAIL"
    echo "B_REVISION=$REVISION"
    echo "FAILURE_CLASS=$failure"
    echo "B_EXECUTION_LOCK_CONSUMED=YES"
    echo "B_R1_RERUN=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"

    if test -f "$EVIDENCE/SHA256SUMS"
    then
        echo "B_EVIDENCE_MANIFEST_SHA256=$(sha "$EVIDENCE/SHA256SUMS")"
    fi

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

    actual="$(git -C "$TAU2_REPO" hash-object "$file")"

    test "$actual" = "$expected" ||
        prelock_not_evaluated "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

test ! -e "$LOCK" ||
    prelock_not_evaluated "B_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_not_evaluated "B_STAGE_ALREADY_EXISTS"

rm -rf "$PREP"
mkdir -p "$PREP"

section "0. LOCAL TOOLCHAIN"

require_cmd git GIT
require_cmd uv UV
require_cmd curl CURL
require_cmd jq JQ
require_cmd awk AWK
require_cmd grep GREP
require_cmd sort SORT
require_cmd find FIND
require_cmd xargs XARGS
require_cmd sha256sum SHA256SUM
require_cmd cmp CMP
require_cmd wc WC
require_cmd cp CP
require_cmd mkdir MKDIR
require_cmd rm RM

section "1. B-R0 AUTHORITY"

test -f "$B0_CONSOLE" ||
    prelock_not_evaluated "B_R0_CONSOLE_MISSING"

test "$(sha "$B0_CONSOLE")" = "$EXPECTED_B0_CONSOLE_SHA256" ||
    prelock_not_evaluated "B_R0_CONSOLE_IDENTITY_MISMATCH"

test -f "$B0_EVIDENCE/SHA256SUMS" ||
    prelock_not_evaluated "B_R0_MANIFEST_MISSING"

test "$(sha "$B0_EVIDENCE/SHA256SUMS")" = "$EXPECTED_B0_MANIFEST_SHA256" ||
    prelock_not_evaluated "B_R0_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$B0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || prelock_not_evaluated "B_R0_EVIDENCE_INTEGRITY_FAILURE"

grep -F "B_R0_INDEPENDENT_REPLAY_PREFLIGHT=PASS" "$B0_CONSOLE" >/dev/null ||
    prelock_not_evaluated "B_R0_PASS_AUTHORITY_MISSING"

grep -F "INDEPENDENT_IMPLEMENTATION_BOUNDARY=PASS" "$B0_CONSOLE" >/dev/null ||
    prelock_not_evaluated "B_R0_INDEPENDENCE_AUTHORITY_MISSING"

grep -F "YODA_STORE_MUTATED=NO" "$B0_CONSOLE" >/dev/null ||
    prelock_not_evaluated "B_R0_YODA_READ_ONLY_AUTHORITY_MISSING"

grep -F "INDEPENDENT_REPLAY_EXECUTED=NO" "$B0_CONSOLE" >/dev/null ||
    prelock_not_evaluated "B_R0_REPLAY_BOUNDARY_MISMATCH"

echo "B_R0_AUTHORITY=PASS"

section "2. RECOVERED INPUT AUTHORITY"

for file in \
    task-7.json \
    derivation-A.ndjson \
    derivation-B.ndjson \
    outcome-A.json \
    outcome-B.json \
    outcome-equivalence.json \
    execution-contract.tsv \
    communication.txt \
    tau2-authority.tsv \
    a1-summary.tsv
do
    test -f "$B0_RECOVERED/$file" ||
        prelock_not_evaluated "B_R0_RECOVERED_INPUT_MISSING"
done

test "$(sha "$B0_RECOVERED/derivation-A.ndjson")" = "$EXPECTED_LINEAGE_A_SHA256" ||
    prelock_not_evaluated "RECOVERED_LINEAGE_A_IDENTITY_MISMATCH"

test "$(sha "$B0_RECOVERED/derivation-B.ndjson")" = "$EXPECTED_LINEAGE_B_SHA256" ||
    prelock_not_evaluated "RECOVERED_LINEAGE_B_IDENTITY_MISMATCH"

jq -e \
    --arg db "$EXPECTED_FINAL_DB_HASH" \
    --arg a "$EXPECTED_LINEAGE_A_SHA256" \
    --arg b "$EXPECTED_LINEAGE_B_SHA256" '
    .scientific_pass == true
    and .trajectory_A.final_reward == 1.0
    and .trajectory_B.final_reward == 1.0
    and .trajectory_A.db_reward == 1.0
    and .trajectory_B.db_reward == 1.0
    and .trajectory_A.communicate_reward == 1.0
    and .trajectory_B.communicate_reward == 1.0
    and .trajectory_A.db_match == true
    and .trajectory_B.db_match == true
    and .trajectory_A.live_agent_db_hash == $db
    and .trajectory_B.live_agent_db_hash == $db
    and .trajectory_A.lineage_sha256 == $a
    and .trajectory_B.lineage_sha256 == $b
' "$B0_RECOVERED/outcome-equivalence.json" >/dev/null ||
    prelock_not_evaluated "RECOVERED_REFERENCE_OUTCOME_MISMATCH"

echo "RECOVERED_INPUT_AUTHORITY=PASS"
echo "RECOVERED_LINEAGE_A_IDENTITY=PASS"
echo "RECOVERED_LINEAGE_B_IDENTITY=PASS"
echo "RECOVERED_REFERENCE_OUTCOME=PASS"

section "3. FROZEN A2 STORE AUTHORITY"

test -f "$A2_STORE/data.yoda" ||
    prelock_not_evaluated "A2_DATA_YODA_MISSING"

test "$(sha "$A2_STORE/data.yoda")" = "$EXPECTED_DATA_YODA_SHA256" ||
    prelock_not_evaluated "A2_DATA_YODA_IDENTITY_MISMATCH"

ACTUAL_DATA_BYTES="$(
    wc -c < "$A2_STORE/data.yoda" |
    awk '{print $1}'
)"

test "$ACTUAL_DATA_BYTES" -eq "$EXPECTED_DATA_YODA_BYTES" ||
    prelock_not_evaluated "A2_DATA_YODA_SIZE_MISMATCH"

store_manifest "$PREP/store-before.sha256"

STORE_BEFORE_SHA256="$(sha "$PREP/store-before.sha256")"

echo "EXPECTED_STORE_MANIFEST_SHA256=$EXPECTED_B0_STORE_MANIFEST_SHA256"
echo "ACTUAL_STORE_MANIFEST_SHA256=$STORE_BEFORE_SHA256"

test "$STORE_BEFORE_SHA256" = "$EXPECTED_B0_STORE_MANIFEST_SHA256" ||
    prelock_not_evaluated "A2_STORE_MANIFEST_IDENTITY_MISMATCH"

echo "A2_STORE_AUTHORITY=PASS"

section "4. PINNED EXTERNAL RUNTIME"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM" \
    "$TAU2_REPO" ||
    prelock_not_evaluated "UPSTREAM_RELEASE_FETCH_FAILURE"

test "$(git -C "$TAU2_REPO" rev-parse HEAD)" = "$EXPECTED_RELEASE_COMMIT" ||
    prelock_not_evaluated "UPSTREAM_RELEASE_COMMIT_MISMATCH"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "uv.lock" "$EXPECTED_UV_LOCK_BLOB" "UV_LOCK_BLOB"
blob_check "src/tau2/domains/airline/environment.py" "$EXPECTED_AIRLINE_ENV_BLOB" "AIRLINE_ENVIRONMENT_BLOB"
blob_check "src/tau2/evaluator/evaluator.py" "$EXPECTED_EVALUATOR_BLOB" "EVALUATOR_BLOB"

ACTUAL_UV_VERSION="$(uv --version)"

test "$ACTUAL_UV_VERSION" = "$EXPECTED_UV_VERSION" ||
    prelock_not_evaluated "UV_VERSION_DRIFT"

(
    cd "$TAU2_REPO"
    uv sync --frozen
) ||
    prelock_not_evaluated "TAU2_UV_SYNC_FAILURE"

PY="$TAU2_REPO/.venv/bin/python"

test -x "$PY" ||
    prelock_not_evaluated "TAU2_PYTHON_RUNTIME_MISSING"

ACTUAL_PYTHON_VERSION="$(
    "$PY" -c 'import platform; print(platform.python_version())'
)" || prelock_not_evaluated "PYTHON_VERSION_UNAVAILABLE"

test "$ACTUAL_PYTHON_VERSION" = "$EXPECTED_PYTHON_VERSION" ||
    prelock_not_evaluated "PYTHON_VERSION_DRIFT"

ACTUAL_TAU2_VERSION="$(
    "$PY" -c 'import importlib.metadata; print(importlib.metadata.version("tau2"))'
)" || prelock_not_evaluated "TAU2_VERSION_UNAVAILABLE"

test "$ACTUAL_TAU2_VERSION" = "$EXPECTED_TAU2_VERSION" ||
    prelock_not_evaluated "TAU2_VERSION_DRIFT"

echo "UV_VERSION=$ACTUAL_UV_VERSION"
echo "PYTHON_VERSION=$ACTUAL_PYTHON_VERSION"
echo "TAU2_VERSION=$ACTUAL_TAU2_VERSION"
echo "PINNED_RUNTIME=PASS"

section "5. INDEPENDENT ADAPTER AUTHORITY"

curl -fsSL "$ADAPTER_URL" -o "$ADAPTER" ||
    prelock_not_evaluated "B_ADAPTER_FETCH_FAILURE"

ACTUAL_ADAPTER_SHA256="$(sha "$ADAPTER")"

echo "EXPECTED_B_ADAPTER_SHA256=$EXPECTED_ADAPTER_SHA256"
echo "ACTUAL_B_ADAPTER_SHA256=$ACTUAL_ADAPTER_SHA256"

test "$ACTUAL_ADAPTER_SHA256" = "$EXPECTED_ADAPTER_SHA256" ||
    prelock_not_evaluated "B_ADAPTER_IDENTITY_MISMATCH"

if grep -F "a1-dual-derivation-authority" "$ADAPTER" >/dev/null
then
    prelock_not_evaluated "B_ADAPTER_DEPENDS_ON_A1_ADAPTER"
fi

if grep -F "get_tasks" "$ADAPTER" >/dev/null
then
    prelock_not_evaluated "B_ADAPTER_RELOADS_TASK_DATASET"
fi

if grep -Eiq 'openai|anthropic|litellm' "$ADAPTER"
then
    prelock_not_evaluated "B_ADAPTER_MODEL_PROVIDER_REFERENCE_PRESENT"
fi

"$PY" -m py_compile "$ADAPTER" ||
    prelock_not_evaluated "B_ADAPTER_PARSE_FAILURE"

"$PY" "$ADAPTER" \
    --mode audit \
    --recovered-dir "$B0_RECOVERED" \
    > "$PREP/adapter-audit.json" \
    2> "$PREP/adapter-audit.stderr" ||
    prelock_not_evaluated "B_ADAPTER_AUDIT_FAILURE"

jq -e \
    --arg db "$EXPECTED_FINAL_DB_HASH" \
    --arg a "$EXPECTED_LINEAGE_A_SHA256" \
    --arg b "$EXPECTED_LINEAGE_B_SHA256" '
    .audit == "PASS"
    and .task_id == "7"
    and .trajectory_A_tool_calls == 5
    and .trajectory_B_tool_calls == 5
    and .derivations_distinct == true
    and .communication_matches_both == true
    and .original_equivalence_pass == true
    and .original_final_db_hash == $db
    and .lineage_A_sha256 == $a
    and .lineage_B_sha256 == $b
    and .trajectory_executed == false
    and .external_judge_executed == false
' "$PREP/adapter-audit.json" >/dev/null ||
    prelock_not_evaluated "B_ADAPTER_AUDIT_RESULT_MISMATCH"

echo "B_ADAPTER_IDENTITY=PASS"
echo "B_ADAPTER_PARSE=PASS"
echo "B_ADAPTER_PRE_EXECUTION_AUDIT=PASS"
echo "INDEPENDENT_IMPLEMENTATION_BOUNDARY=PASS"

section "6. FINAL PRE-GATE BOUNDARY"

test ! -e "$LOCK" ||
    prelock_not_evaluated "B_EXECUTION_LOCK_UNEXPECTEDLY_PRESENT"

test ! -e "$STAGE" ||
    prelock_not_evaluated "B_STAGE_UNEXPECTEDLY_PRESENT"

echo "B_EXECUTION_LOCK=ABSENT"
echo "B_STAGE=ABSENT"
echo "INDEPENDENT_REPLAY_EXECUTED=NO"
echo "EXTERNAL_JUDGE_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "USER_SIMULATOR_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

section "7. ONE-EXECUTION SCIENTIFIC GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
B_R0_CONSOLE_SHA256=$EXPECTED_B0_CONSOLE_SHA256
B_R0_MANIFEST_SHA256=$EXPECTED_B0_MANIFEST_SHA256
B_R0_STORE_MANIFEST_SHA256=$EXPECTED_B0_STORE_MANIFEST_SHA256
DATA_YODA_SHA256=$EXPECTED_DATA_YODA_SHA256
LINEAGE_A_SHA256=$EXPECTED_LINEAGE_A_SHA256
LINEAGE_B_SHA256=$EXPECTED_LINEAGE_B_SHA256
FINAL_DB_HASH=$EXPECTED_FINAL_DB_HASH
B_ADAPTER_SHA256=$EXPECTED_ADAPTER_SHA256
B_ADAPTER_COMMIT=$ADAPTER_COMMIT
RELEASE_TAG=$RELEASE_TAG
RELEASE_COMMIT=$EXPECTED_RELEASE_COMMIT
UV_VERSION=$EXPECTED_UV_VERSION
PYTHON_VERSION=$EXPECTED_PYTHON_VERSION
TAU2_VERSION=$EXPECTED_TAU2_VERSION
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_INDEPENDENT_REPLAY=YES
EOF

test -f "$LOCK" ||
    prelock_not_evaluated "B_EXECUTION_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "B_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "B_EXECUTION_GATE=PASS"

mkdir -p "$INPUTS" "$EVIDENCE" ||
    postlock_not_evaluated "B_STAGE_MATERIALIZATION_FAILURE"

for file in \
    task-7.json \
    derivation-A.ndjson \
    derivation-B.ndjson \
    outcome-A.json \
    outcome-B.json \
    outcome-equivalence.json \
    execution-contract.tsv \
    communication.txt \
    tau2-authority.tsv \
    a1-summary.tsv
do
    cp "$B0_RECOVERED/$file" "$INPUTS/$file" ||
        postlock_not_evaluated "B_INPUT_MATERIALIZATION_FAILURE"
done

cp "$ADAPTER" "$EVIDENCE/b-independent-replay-authority.py" ||
    postlock_not_evaluated "B_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$PREP/adapter-audit.json" "$EVIDENCE/adapter-audit.json" ||
    postlock_not_evaluated "B_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$PREP/adapter-audit.stderr" "$EVIDENCE/adapter-audit.stderr" ||
    postlock_not_evaluated "B_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$PREP/store-before.sha256" "$EVIDENCE/store-before.sha256" ||
    postlock_not_evaluated "B_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$LOCK" "$EVIDENCE/execution-started.txt" ||
    postlock_not_evaluated "B_EVIDENCE_MATERIALIZATION_FAILURE"

section "8. INDEPENDENT DUAL DERIVATION REPLAY + EXTERNAL JUDGMENT"

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
    --recovered-dir "$INPUTS" \
    --out-dir "$RESULTS" \
    > "$EVIDENCE/authority.stdout.log" \
    2> "$EVIDENCE/authority.stderr.log"
ADAPTER_RC=$?
set -e

echo "INDEPENDENT_REPLAY_ADAPTER_RC=$ADAPTER_RC"

if test "$ADAPTER_RC" -ne 0
then
    postlock_not_evaluated "INDEPENDENT_REPLAY_AUTHORITY_EXECUTION_FAILURE"
fi

test -f "$RESULTS/overall-replay.json" ||
    postlock_not_evaluated "INDEPENDENT_REPLAY_RESULT_MISSING"

test -f "$RESULTS/replay-A.json" ||
    postlock_not_evaluated "INDEPENDENT_REPLAY_A_RESULT_MISSING"

test -f "$RESULTS/replay-B.json" ||
    postlock_not_evaluated "INDEPENDENT_REPLAY_B_RESULT_MISSING"

echo "INDEPENDENT_REPLAY_EXECUTED=YES"
echo "EXTERNAL_JUDGE_EXECUTED=YES"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "USER_SIMULATOR_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

section "9. SCIENTIFIC ADJUDICATION"

jq -e \
    --arg db "$EXPECTED_FINAL_DB_HASH" \
    --arg a "$EXPECTED_LINEAGE_A_SHA256" \
    --arg b "$EXPECTED_LINEAGE_B_SHA256" '
    .case == "TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
    and .stage == "B-R1"
    and .task_id == "7"
    and .implementation == "independent-replay-v1"

    and .trajectory_A.tool_call_count == 5
    and .trajectory_B.tool_call_count == 5

    and .trajectory_A.tool_response_match_count == 5
    and .trajectory_B.tool_response_match_count == 5
    and .trajectory_A.tool_error_match_count == 5
    and .trajectory_B.tool_error_match_count == 5

    and .trajectory_A.all_tool_responses_match == true
    and .trajectory_B.all_tool_responses_match == true
    and .trajectory_A.all_tool_error_flags_match == true
    and .trajectory_B.all_tool_error_flags_match == true

    and .trajectory_A.final_reward == 1.0
    and .trajectory_B.final_reward == 1.0

    and .trajectory_A.db_reward == 1.0
    and .trajectory_B.db_reward == 1.0

    and .trajectory_A.communicate_reward == 1.0
    and .trajectory_B.communicate_reward == 1.0

    and .trajectory_A.db_match == true
    and .trajectory_B.db_match == true

    and .trajectory_A.matches_original_final_reward == true
    and .trajectory_B.matches_original_final_reward == true

    and .trajectory_A.matches_original_db_reward == true
    and .trajectory_B.matches_original_db_reward == true

    and .trajectory_A.matches_original_communicate_reward == true
    and .trajectory_B.matches_original_communicate_reward == true

    and .trajectory_A.matches_original_db_match == true
    and .trajectory_B.matches_original_db_match == true

    and .trajectory_A.matches_original_live_db_hash == true
    and .trajectory_B.matches_original_live_db_hash == true

    and .trajectory_A.live_agent_db_hash == $db
    and .trajectory_B.live_agent_db_hash == $db

    and .trajectory_A.lineage_sha256 == $a
    and .trajectory_B.lineage_sha256 == $b

    and .original_common_final_db_hash == $db

    and .criteria.common_final_db_hash_reproduced == true
    and .criteria.recovered_lineages_remain_distinct == true

    and .independent_replay_pass == true

    and .model_endpoint_called == false
    and .user_simulator_executed == false
    and .yoda_writes == 0
' "$RESULTS/overall-replay.json" >/dev/null ||
    fail "INDEPENDENT_REPLAY_CRITERIA_NOT_MET"

A_FINAL="$(jq -r '.trajectory_A.final_reward' "$RESULTS/overall-replay.json")"
B_FINAL="$(jq -r '.trajectory_B.final_reward' "$RESULTS/overall-replay.json")"

A_DB="$(jq -r '.trajectory_A.db_reward' "$RESULTS/overall-replay.json")"
B_DB="$(jq -r '.trajectory_B.db_reward' "$RESULTS/overall-replay.json")"

A_COMM="$(jq -r '.trajectory_A.communicate_reward' "$RESULTS/overall-replay.json")"
B_COMM="$(jq -r '.trajectory_B.communicate_reward' "$RESULTS/overall-replay.json")"

A_HASH="$(jq -r '.trajectory_A.live_agent_db_hash' "$RESULTS/overall-replay.json")"
B_HASH="$(jq -r '.trajectory_B.live_agent_db_hash' "$RESULTS/overall-replay.json")"

A_RESPONSES="$(jq -r '.trajectory_A.tool_response_match_count' "$RESULTS/overall-replay.json")"
B_RESPONSES="$(jq -r '.trajectory_B.tool_response_match_count' "$RESULTS/overall-replay.json")"

echo "TRAJECTORY_A_REPLAY_FINAL_REWARD=$A_FINAL"
echo "TRAJECTORY_B_REPLAY_FINAL_REWARD=$B_FINAL"
echo "TRAJECTORY_A_REPLAY_DB_REWARD=$A_DB"
echo "TRAJECTORY_B_REPLAY_DB_REWARD=$B_DB"
echo "TRAJECTORY_A_REPLAY_COMMUNICATE_REWARD=$A_COMM"
echo "TRAJECTORY_B_REPLAY_COMMUNICATE_REWARD=$B_COMM"
echo "TRAJECTORY_A_TOOL_RESPONSES_REPRODUCED=$A_RESPONSES/5"
echo "TRAJECTORY_B_TOOL_RESPONSES_REPRODUCED=$B_RESPONSES/5"
echo "TRAJECTORY_A_REPLAY_FINAL_DB_HASH=$A_HASH"
echo "TRAJECTORY_B_REPLAY_FINAL_DB_HASH=$B_HASH"
echo "INDEPENDENT_REPLAY_CRITERIA=PASS"

section "10. PROVE FROZEN YODA STORE UNCHANGED"

store_manifest "$EVIDENCE/store-after.sha256"

STORE_AFTER_SHA256="$(sha "$EVIDENCE/store-after.sha256")"

echo "STORE_BEFORE_MANIFEST_SHA256=$STORE_BEFORE_SHA256"
echo "STORE_AFTER_MANIFEST_SHA256=$STORE_AFTER_SHA256"

cmp -s \
    "$EVIDENCE/store-before.sha256" \
    "$EVIDENCE/store-after.sha256" ||
    fail "YODA_STORE_MUTATED_DURING_INDEPENDENT_REPLAY"

test "$(sha "$A2_STORE/data.yoda")" = "$EXPECTED_DATA_YODA_SHA256" ||
    fail "DATA_YODA_MUTATED_DURING_INDEPENDENT_REPLAY"

echo "YODA_STORE_MUTATED=NO"
echo "YODA_WRITES=ZERO"

section "11. FREEZE STAGE B EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
B_R0_CONSOLE_SHA256	$EXPECTED_B0_CONSOLE_SHA256
B_R0_MANIFEST_SHA256	$EXPECTED_B0_MANIFEST_SHA256
B_R0_STORE_MANIFEST_SHA256	$EXPECTED_B0_STORE_MANIFEST_SHA256
DATA_YODA_SHA256	$EXPECTED_DATA_YODA_SHA256
B_ADAPTER_SHA256	$ACTUAL_ADAPTER_SHA256
B_ADAPTER_COMMIT	$ADAPTER_COMMIT
RELEASE_TAG	$RELEASE_TAG
RELEASE_COMMIT	$EXPECTED_RELEASE_COMMIT
UV_VERSION	$ACTUAL_UV_VERSION
PYTHON_VERSION	$ACTUAL_PYTHON_VERSION
TAU2_VERSION	$ACTUAL_TAU2_VERSION
LINEAGE_A_SHA256	$EXPECTED_LINEAGE_A_SHA256
LINEAGE_B_SHA256	$EXPECTED_LINEAGE_B_SHA256
EXPECTED_FINAL_DB_HASH	$EXPECTED_FINAL_DB_HASH
TRAJECTORY_A_FINAL_REWARD	$A_FINAL
TRAJECTORY_B_FINAL_REWARD	$B_FINAL
TRAJECTORY_A_DB_REWARD	$A_DB
TRAJECTORY_B_DB_REWARD	$B_DB
TRAJECTORY_A_COMMUNICATE_REWARD	$A_COMM
TRAJECTORY_B_COMMUNICATE_REWARD	$B_COMM
TRAJECTORY_A_TOOL_RESPONSE_MATCH_COUNT	$A_RESPONSES
TRAJECTORY_B_TOOL_RESPONSE_MATCH_COUNT	$B_RESPONSES
TRAJECTORY_A_FINAL_DB_HASH	$A_HASH
TRAJECTORY_B_FINAL_DB_HASH	$B_HASH
INDEPENDENT_REPLAY_CRITERIA	PASS
YODA_STORE_MUTATED	NO
MODEL_ENDPOINT_CALLED	NO
USER_SIMULATOR_EXECUTED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-b-r1-script.sh" ||
    postlock_not_evaluated "B_EVIDENCE_MATERIALIZATION_FAILURE"

freeze_manifest ||
    postlock_not_evaluated "B_EVIDENCE_INTEGRITY_FAILURE"

B_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "B_EVIDENCE_INTEGRITY=PASS"
echo "B_EVIDENCE_MANIFEST_SHA256=$B_MANIFEST_SHA256"

section "12. STAGE B HOMOLOGATION"

echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_B=PASS"
echo "B_REVISION=$REVISION"
echo "INDEPENDENT_IMPLEMENTATION=PASS"
echo "YODA_RECOVERED_INPUTS=PASS"
echo "TRAJECTORY_A_INDEPENDENT_REPLAY=PASS"
echo "TRAJECTORY_B_INDEPENDENT_REPLAY=PASS"
echo "TRAJECTORY_A_EXTERNAL_JUDGE=PASS"
echo "TRAJECTORY_B_EXTERNAL_JUDGE=PASS"
echo "TOOL_RESPONSE_REPRODUCTION=PASS"
echo "OUTCOME_REPRODUCTION=PASS"
echo "COMMON_FINAL_DB_HASH_REPRODUCTION=PASS"
echo "DISTINCT_LINEAGE_PRESERVATION=PASS"
echo "YODA_STORE_MUTATED=NO"
echo "B_EVIDENCE_MANIFEST_SHA256=$B_MANIFEST_SHA256"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=FINAL_CASE_HOMOLOGATION"

rm -rf "$PREP" || true
exit 0
