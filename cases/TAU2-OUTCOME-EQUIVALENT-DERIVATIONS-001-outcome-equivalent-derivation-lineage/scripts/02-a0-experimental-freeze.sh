#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="A0-R1"

ROOT="$HOME/cmu/$CASE"
PRE="$ROOT/pre-a0-r1"
PRE_LOCK="$ROOT/.pre-a0-r1-selection-started"

PRE_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-selection-r2-console.log"

STAGE="$ROOT/stage-a0-r1"
PREP="$ROOT/.stage-a0-r1-prep"
LOCK="$ROOT/.stage-a0-r1-freeze-started"

UPSTREAM="$PREP/tau2-bench"
AUTHORITY="$STAGE/authority"
TASK="$STAGE/task"
TRAJECTORIES="$STAGE/trajectories"
CONTRACTS="$STAGE/contracts"
EVIDENCE="$STAGE/evidence"

UPSTREAM_URL="https://github.com/sierra-research/tau2-bench.git"
RELEASE_TAG="v1.0.1"
EXPECTED_RELEASE_COMMIT="fc0055dc4e0a316c3f83133267fbd6faaa770992"

EXPECTED_PRE_LOCK_SHA256="3fadca4c055749eaabcf1a5ef5186cabf2636c0c3044d41ae7c13388e39840dd"
EXPECTED_PRE_MANIFEST_SHA256="dbc68eb5611218bb8064adb16e0177572e87b94ad68de18f7f8f609b4b546597"
EXPECTED_PRE_CONSOLE_SHA256="0786d3928f4cc112e6172e9ab993410a5d3cfd69847eb67f662f798b2f99731a"

EXPECTED_SELECTED_TASK_SHA256="3afcd45425f2397430b1680a51350043b0beefc825635ac6a32cc1f8b9182c6d"
EXPECTED_REFERENCE_SEQUENCE_SHA256="686d852e4d51fbf780cc030e55a36f066972ac67e477b3b39d563685d03b8a77"
EXPECTED_ALTERNATIVE_SEQUENCE_SHA256="b1d6615d0fa826545702f7db61194359b1d919cfc7667fe10d330bc546c4ffe6"
EXPECTED_SELECTION_SHA256="699e66590dfeb78c950a87854b96e275c53e69c82a1f0b809b9bdb82dce52977"
EXPECTED_TRANSFORMATION_SHA256="b9f3501cf6d8ed5bd1e630f76fbf2a1c146529733eb8369b5b4f8e9999d9e493"

EXPECTED_PYPROJECT_BLOB="55a9d9cf6ebd8bf2326798f4923988917e431086"
EXPECTED_EVAL_DOC_BLOB="2552c6c488e157a4366238880a870e83b7aa1758"
EXPECTED_DB_BLOB="c6a1e817aa9102c5822e83affb3595acbc312701"
EXPECTED_POLICY_BLOB="8098be7db3f47de943fad39d1e057ede6cc6cd04"
EXPECTED_TASKS_BLOB="ea4ff5e3f5e3d97ca391846a6e8dd9eb3437dc80"
EXPECTED_SPLIT_BLOB="c83cce155671e66a6bf07450fd2845fe0eb1f229"
EXPECTED_TOOLS_BLOB="adc5c09a155d82d91e2f0647682023419eaca2ea"
EXPECTED_AIR_ENV_BLOB="e1cabffe7ed4ad895904aa5248319dd307e77a97"
EXPECTED_AIR_DATA_MODEL_BLOB="1b65884c10349950a1fc31c8ad96a8d804e093a1"
EXPECTED_ENVIRONMENT_BLOB="0dce3d21826273e789eb25fa167b95ab148fa4f4"
EXPECTED_MESSAGE_BLOB="0449e2f2ce82cc03dd351520549eb9e24eb70bf9"
EXPECTED_TASK_MODEL_BLOB="28f37885f0282bd3b82eed18bfe8aa2350fba2b7"
EXPECTED_SIMULATION_BLOB="edc805ee2e645d62edd6e8b1c20b24a12b175d74"
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
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A0=NOT_EVALUATED"
    echo "A0_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"

    if test -f "$LOCK"
    then
        echo "A0_FREEZE_LOCK_CONSUMED=YES"
        echo "A0_R1_RERUN=NO"
    else
        echo "A0_FREEZE_LOCK_CONSUMED=NO"
    fi

    echo "TRAJECTORY_EXECUTED=NO"
    echo "TAU2_RUNTIME_EXECUTED=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "USER_SIMULATOR_EXECUTED=NO"
    echo "GOLDEN_STATE_MATERIALIZED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
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

    actual="$(git -C "$UPSTREAM" hash-object "$file")"

    test "$actual" = "$expected" ||
        not_evaluated "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

prep_copy()
{
    cp "$1" "$2" ||
        not_evaluated "A0_PREP_MATERIALIZATION_FAILURE"
}

stage_copy()
{
    cp "$1" "$2" ||
        not_evaluated "A0_STAGE_MATERIALIZATION_FAILURE"
}

test ! -e "$LOCK" ||
    not_evaluated "A0_FREEZE_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "A0_STAGE_ALREADY_EXISTS"

rm -rf "$PREP" ||
    not_evaluated "A0_PREP_WORKSPACE_FAILURE"

mkdir -p "$PREP/frozen" ||
    not_evaluated "A0_PREP_WORKSPACE_FAILURE"

section "0. LOCAL TOOLCHAIN"

require_cmd git GIT
require_cmd jq JQ
require_cmd awk AWK
require_cmd grep GREP
require_cmd sort SORT
require_cmd cmp CMP
require_cmd find FIND
require_cmd xargs XARGS
require_cmd sha256sum SHA256SUM
require_cmd wc WC
require_cmd cp CP
require_cmd mkdir MKDIR
require_cmd rm RM
require_cmd cat CAT

section "1. PRE-A0 AUTHORITY"

test -f "$PRE_LOCK" ||
    not_evaluated "PRE_A0_LOCK_MISSING"

test "$(sha "$PRE_LOCK")" = "$EXPECTED_PRE_LOCK_SHA256" ||
    not_evaluated "PRE_A0_LOCK_IDENTITY_MISMATCH"

test -f "$PRE/evidence/SHA256SUMS" ||
    not_evaluated "PRE_A0_MANIFEST_MISSING"

test "$(sha "$PRE/evidence/SHA256SUMS")" = "$EXPECTED_PRE_MANIFEST_SHA256" ||
    not_evaluated "PRE_A0_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$PRE"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "PRE_A0_EVIDENCE_INTEGRITY_FAILURE"

test -f "$PRE_CONSOLE" ||
    not_evaluated "PRE_A0_CONSOLE_MISSING"

test "$(sha "$PRE_CONSOLE")" = "$EXPECTED_PRE_CONSOLE_SHA256" ||
    not_evaluated "PRE_A0_CONSOLE_IDENTITY_MISMATCH"

test "$(sha "$PRE/selection/selected-task.json")" = "$EXPECTED_SELECTED_TASK_SHA256" ||
    not_evaluated "SELECTED_TASK_IDENTITY_MISMATCH"

test "$(sha "$PRE/selection/reference-sequence.ndjson")" = "$EXPECTED_REFERENCE_SEQUENCE_SHA256" ||
    not_evaluated "REFERENCE_SEQUENCE_IDENTITY_MISMATCH"

test "$(sha "$PRE/selection/alternative-sequence.ndjson")" = "$EXPECTED_ALTERNATIVE_SEQUENCE_SHA256" ||
    not_evaluated "ALTERNATIVE_SEQUENCE_IDENTITY_MISMATCH"

test "$(sha "$PRE/selection/selection.tsv")" = "$EXPECTED_SELECTION_SHA256" ||
    not_evaluated "SELECTION_IDENTITY_MISMATCH"

test "$(sha "$PRE/selection/transformation.tsv")" = "$EXPECTED_TRANSFORMATION_SHA256" ||
    not_evaluated "TRANSFORMATION_IDENTITY_MISMATCH"

echo "PRE_A0_LOCK_IDENTITY=PASS"
echo "PRE_A0_MANIFEST_IDENTITY=PASS"
echo "PRE_A0_EVIDENCE_INTEGRITY=PASS"
echo "PRE_A0_CONSOLE_IDENTITY=PASS"
echo "PRE_A0_SELECTION_AUTHORITY=PASS"

section "2. UPSTREAM RELEASE AUTHORITY"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM_URL" \
    "$UPSTREAM" ||
    not_evaluated "UPSTREAM_RELEASE_FETCH_FAILURE"

ACTUAL_RELEASE_COMMIT="$(git -C "$UPSTREAM" rev-parse HEAD)"

test "$ACTUAL_RELEASE_COMMIT" = "$EXPECTED_RELEASE_COMMIT" ||
    not_evaluated "UPSTREAM_RELEASE_COMMIT_MISMATCH"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "docs/evaluation.md" "$EXPECTED_EVAL_DOC_BLOB" "EVALUATION_DOC_BLOB"
blob_check "data/tau2/domains/airline/db.json" "$EXPECTED_DB_BLOB" "AIRLINE_DB_BLOB"
blob_check "data/tau2/domains/airline/policy.md" "$EXPECTED_POLICY_BLOB" "AIRLINE_POLICY_BLOB"
blob_check "data/tau2/domains/airline/tasks.json" "$EXPECTED_TASKS_BLOB" "AIRLINE_TASKS_BLOB"
blob_check "data/tau2/domains/airline/split_tasks.json" "$EXPECTED_SPLIT_BLOB" "AIRLINE_SPLIT_BLOB"
blob_check "src/tau2/domains/airline/tools.py" "$EXPECTED_TOOLS_BLOB" "AIRLINE_TOOLS_BLOB"
blob_check "src/tau2/domains/airline/environment.py" "$EXPECTED_AIR_ENV_BLOB" "AIRLINE_ENVIRONMENT_BLOB"
blob_check "src/tau2/domains/airline/data_model.py" "$EXPECTED_AIR_DATA_MODEL_BLOB" "AIRLINE_DATA_MODEL_BLOB"
blob_check "src/tau2/environment/environment.py" "$EXPECTED_ENVIRONMENT_BLOB" "ENVIRONMENT_BLOB"
blob_check "src/tau2/data_model/message.py" "$EXPECTED_MESSAGE_BLOB" "MESSAGE_MODEL_BLOB"
blob_check "src/tau2/data_model/tasks.py" "$EXPECTED_TASK_MODEL_BLOB" "TASK_MODEL_BLOB"
blob_check "src/tau2/data_model/simulation.py" "$EXPECTED_SIMULATION_BLOB" "SIMULATION_MODEL_BLOB"
blob_check "src/tau2/evaluator/evaluator.py" "$EXPECTED_EVALUATOR_BLOB" "EVALUATOR_BLOB"
blob_check "src/tau2/evaluator/evaluator_env.py" "$EXPECTED_EVALUATOR_ENV_BLOB" "EVALUATOR_ENV_BLOB"
blob_check "src/tau2/evaluator/evaluator_communicate.py" "$EXPECTED_EVALUATOR_COMM_BLOB" "EVALUATOR_COMMUNICATE_BLOB"

echo "RELEASE_TAG=$RELEASE_TAG"
echo "RELEASE_COMMIT=$ACTUAL_RELEASE_COMMIT"
echo "UPSTREAM_AUTHORITY=PASS"

section "3. TASK 7 RECONSTRUCTION"

jq \
    --arg id "7" '
    map(select(.id == $id))
    | .[0]
' "$UPSTREAM/data/tau2/domains/airline/tasks.json" \
> "$PREP/frozen/selected-task.json" ||
    not_evaluated "TASK_7_EXTRACTION_FAILURE"

cmp -s \
    "$PREP/frozen/selected-task.json" \
    "$PRE/selection/selected-task.json" ||
    not_evaluated "TASK_7_PRE_A0_MISMATCH"

jq '.evaluation_criteria.actions' \
    "$PREP/frozen/selected-task.json" \
> "$PREP/frozen/reference-actions.json" ||
    not_evaluated "REFERENCE_ACTION_EXTRACTION_FAILURE"

cmp -s \
    "$PREP/frozen/reference-actions.json" \
    "$PRE/selection/reference-actions.json" ||
    not_evaluated "REFERENCE_ACTION_PRE_A0_MISMATCH"

jq '
    . as $actions
    | $actions[0] as $left
    | $actions[1] as $right
    | $actions
    | .[0] = $right
    | .[1] = $left
' "$PREP/frozen/reference-actions.json" \
> "$PREP/frozen/alternative-actions.json" ||
    not_evaluated "ALTERNATIVE_ACTION_MATERIALIZATION_FAILURE"

cmp -s \
    "$PREP/frozen/alternative-actions.json" \
    "$PRE/selection/alternative-actions-candidate.json" ||
    not_evaluated "ALTERNATIVE_ACTION_PRE_A0_MISMATCH"

echo "TASK_7_RECONSTRUCTION=PASS"
echo "REFERENCE_ACTIONS_RECONSTRUCTION=PASS"
echo "ALTERNATIVE_ACTIONS_RECONSTRUCTION=PASS"

section "4. TASK-SPECIFIC CONTRACT AUDIT"

TASK_ID="$(
    jq -r '.id' \
        "$PREP/frozen/selected-task.json"
)"

test "$TASK_ID" = "7" ||
    not_evaluated "TASK_ID_MISMATCH"

REWARD_BASIS="$(
    jq -r '.evaluation_criteria.reward_basis | join(",")' \
        "$PREP/frozen/selected-task.json"
)"

test "$REWARD_BASIS" = "DB,COMMUNICATE" ||
    not_evaluated "TASK_REWARD_BASIS_MISMATCH"

COMMUNICATE_INFO="$(
    jq -r '.evaluation_criteria.communicate_info | join(",")' \
        "$PREP/frozen/selected-task.json"
)"

test "$COMMUNICATE_INFO" = "1628" ||
    not_evaluated "TASK_COMMUNICATE_INFO_MISMATCH"

jq -e '
    (.evaluation_criteria.reward_basis | index("ACTION")) == null
    and
    (.evaluation_criteria.reward_basis | index("NL_ASSERTION")) == null
' "$PREP/frozen/selected-task.json" >/dev/null ||
    not_evaluated "TASK_REWARD_BASIS_SCOPE_MISMATCH"

test "$(
    jq -r '.[0].name' \
        "$PREP/frozen/reference-actions.json"
)" = "get_reservation_details" ||
    not_evaluated "LEFT_READ_TOOL_MISMATCH"

test "$(
    jq -r '.[0].arguments.reservation_id' \
        "$PREP/frozen/reference-actions.json"
)" = "XEHM4B" ||
    not_evaluated "LEFT_READ_ARGUMENT_MISMATCH"

test "$(
    jq -r '.[1].name' \
        "$PREP/frozen/reference-actions.json"
)" = "get_reservation_details" ||
    not_evaluated "RIGHT_READ_TOOL_MISMATCH"

test "$(
    jq -r '.[1].arguments.reservation_id' \
        "$PREP/frozen/reference-actions.json"
)" = "59XX6W" ||
    not_evaluated "RIGHT_READ_ARGUMENT_MISMATCH"

grep -Fx "$(printf 'get_reservation_details\tREAD')" \
    "$PRE/authority/tool-types.tsv" >/dev/null ||
    not_evaluated "READ_TOOL_AUTHORITY_MISMATCH"

jq -cS '.[] | {name,arguments}' \
    "$PREP/frozen/reference-actions.json" \
> "$PREP/frozen/reference-sequence.ndjson"

jq -cS '.[] | {name,arguments}' \
    "$PREP/frozen/alternative-actions.json" \
> "$PREP/frozen/alternative-sequence.ndjson"

test "$(sha "$PREP/frozen/reference-sequence.ndjson")" = "$EXPECTED_REFERENCE_SEQUENCE_SHA256" ||
    not_evaluated "REFERENCE_SEQUENCE_RECONSTRUCTION_MISMATCH"

test "$(sha "$PREP/frozen/alternative-sequence.ndjson")" = "$EXPECTED_ALTERNATIVE_SEQUENCE_SHA256" ||
    not_evaluated "ALTERNATIVE_SEQUENCE_RECONSTRUCTION_MISMATCH"

if cmp -s \
    "$PREP/frozen/reference-sequence.ndjson" \
    "$PREP/frozen/alternative-sequence.ndjson"
then
    not_evaluated "DERIVATION_DISTINCTNESS_MISMATCH"
fi

jq -cS '.[] | select(.name == "update_reservation_flights" or .name == "cancel_reservation") | {name,arguments}' \
    "$PREP/frozen/reference-actions.json" \
> "$PREP/frozen/reference-writes.ndjson"

jq -cS '.[] | select(.name == "update_reservation_flights" or .name == "cancel_reservation") | {name,arguments}' \
    "$PREP/frozen/alternative-actions.json" \
> "$PREP/frozen/alternative-writes.ndjson"

cmp -s \
    "$PREP/frozen/reference-writes.ndjson" \
    "$PREP/frozen/alternative-writes.ndjson" ||
    not_evaluated "WRITE_SEQUENCE_MISMATCH"

echo "TASK_ID=7"
echo "REWARD_BASIS=DB,COMMUNICATE"
echo "COMMUNICATE_INFO=1628"
echo "ACTION_REWARD_GATE=NO"
echo "NL_ASSERTION_REWARD_GATE=NO"
echo "READ_SWAP_AUTHORITY=PASS"
echo "DERIVATION_SEQUENCE_DISTINCTNESS=PASS"
echo "WRITE_SEQUENCE_PRESERVATION=PASS"

section "5. MATERIALIZE FROZEN EXECUTION CONTRACT"

cat > "$PREP/frozen/execution-contract.tsv" <<'EOF'
field	value
case	TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001
task_id	7
domain	airline
mode	HALF_DUPLEX
trajectory_A_action_order	0,1,2,3,4
trajectory_B_action_order	1,0,2,3,4
transformation	SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS
agent_model	NONE
user_model	NONE
trajectory_generator	DETERMINISTIC_HARNESS
termination_reason	AGENT_STOP
evaluation_type	ALL
solo_mode	FALSE
strict_replay	TRUE
reward_basis	DB,COMMUNICATE
communicate_info	1628
action_reward_gate	NO
nl_assertion_reward_gate	NO
EOF

cat > "$PREP/frozen/communication.txt" <<'EOF'
The total cost of your other upcoming flights is $1,628.
EOF

cat > "$PREP/frozen/outcome-equivalence-contract.tsv" <<'EOF'
criterion	required_value
trajectory_A_final_reward	1.0
trajectory_B_final_reward	1.0
trajectory_A_db_reward	1.0
trajectory_B_db_reward	1.0
trajectory_A_communicate_reward	1.0
trajectory_B_communicate_reward	1.0
final_agent_db_hash_equal	YES
reference_sequence_distinct_from_alternative	YES
EOF

echo "EXECUTION_CONTRACT=FROZEN"
echo "COMMUNICATION_CONTRACT=FROZEN"
echo "OUTCOME_EQUIVALENCE_CONTRACT=FROZEN"

section "6. A0 FREEZE GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
PRE_A0_LOCK_SHA256=$EXPECTED_PRE_LOCK_SHA256
PRE_A0_MANIFEST_SHA256=$EXPECTED_PRE_MANIFEST_SHA256
PRE_A0_CONSOLE_SHA256=$EXPECTED_PRE_CONSOLE_SHA256
SELECTED_TASK_ID=7
SELECTED_TASK_SHA256=$EXPECTED_SELECTED_TASK_SHA256
REFERENCE_SEQUENCE_SHA256=$EXPECTED_REFERENCE_SEQUENCE_SHA256
ALTERNATIVE_SEQUENCE_SHA256=$EXPECTED_ALTERNATIVE_SEQUENCE_SHA256
RELEASE_TAG=$RELEASE_TAG
RELEASE_COMMIT=$EXPECTED_RELEASE_COMMIT
EXECUTION_POLICY=ONE_FREEZE
LOCK_CREATED_BEFORE_STAGE_A0_MATERIALIZATION=YES
EOF

test -f "$LOCK" ||
    not_evaluated "A0_FREEZE_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_FREEZE"
echo "A0_FREEZE_LOCK_SHA256=$(sha "$LOCK")"
echo "A0_FREEZE_GATE=PASS"

mkdir -p "$AUTHORITY/upstream" "$TASK" "$TRAJECTORIES" "$CONTRACTS" "$EVIDENCE" ||
    not_evaluated "A0_STAGE_MATERIALIZATION_FAILURE"

section "7. FREEZE AUTHORITY ARTIFACTS"

stage_copy "$UPSTREAM/pyproject.toml" "$AUTHORITY/upstream/pyproject.toml"
stage_copy "$UPSTREAM/docs/evaluation.md" "$AUTHORITY/upstream/evaluation.md"
stage_copy "$UPSTREAM/data/tau2/domains/airline/db.json" "$AUTHORITY/upstream/airline-db.json"
stage_copy "$UPSTREAM/data/tau2/domains/airline/policy.md" "$AUTHORITY/upstream/airline-policy.md"
stage_copy "$UPSTREAM/data/tau2/domains/airline/tasks.json" "$AUTHORITY/upstream/airline-tasks.json"
stage_copy "$UPSTREAM/data/tau2/domains/airline/split_tasks.json" "$AUTHORITY/upstream/airline-split-tasks.json"
stage_copy "$UPSTREAM/src/tau2/domains/airline/tools.py" "$AUTHORITY/upstream/airline-tools.py"
stage_copy "$UPSTREAM/src/tau2/domains/airline/environment.py" "$AUTHORITY/upstream/airline-environment.py"
stage_copy "$UPSTREAM/src/tau2/domains/airline/data_model.py" "$AUTHORITY/upstream/airline-data-model.py"
stage_copy "$UPSTREAM/src/tau2/environment/environment.py" "$AUTHORITY/upstream/environment.py"
stage_copy "$UPSTREAM/src/tau2/data_model/message.py" "$AUTHORITY/upstream/message.py"
stage_copy "$UPSTREAM/src/tau2/data_model/tasks.py" "$AUTHORITY/upstream/tasks-model.py"
stage_copy "$UPSTREAM/src/tau2/data_model/simulation.py" "$AUTHORITY/upstream/simulation.py"
stage_copy "$UPSTREAM/src/tau2/evaluator/evaluator.py" "$AUTHORITY/upstream/evaluator.py"
stage_copy "$UPSTREAM/src/tau2/evaluator/evaluator_env.py" "$AUTHORITY/upstream/evaluator-env.py"
stage_copy "$UPSTREAM/src/tau2/evaluator/evaluator_communicate.py" "$AUTHORITY/upstream/evaluator-communicate.py"

stage_copy "$PRE/authority/tool-types.tsv" "$AUTHORITY/tool-types.tsv"
stage_copy "$PRE/selection/selection.tsv" "$AUTHORITY/pre-a0-selection.tsv"
stage_copy "$PRE/selection/transformation.tsv" "$AUTHORITY/pre-a0-transformation.tsv"

stage_copy "$PREP/frozen/selected-task.json" "$TASK/selected-task.json"

stage_copy "$PREP/frozen/reference-actions.json" "$TRAJECTORIES/reference-actions.json"
stage_copy "$PREP/frozen/alternative-actions.json" "$TRAJECTORIES/alternative-actions.json"
stage_copy "$PREP/frozen/reference-sequence.ndjson" "$TRAJECTORIES/reference-sequence.ndjson"
stage_copy "$PREP/frozen/alternative-sequence.ndjson" "$TRAJECTORIES/alternative-sequence.ndjson"
stage_copy "$PREP/frozen/reference-writes.ndjson" "$TRAJECTORIES/reference-writes.ndjson"
stage_copy "$PREP/frozen/alternative-writes.ndjson" "$TRAJECTORIES/alternative-writes.ndjson"

stage_copy "$PREP/frozen/execution-contract.tsv" "$CONTRACTS/execution-contract.tsv"
stage_copy "$PREP/frozen/communication.txt" "$CONTRACTS/communication.txt"
stage_copy "$PREP/frozen/outcome-equivalence-contract.tsv" "$CONTRACTS/outcome-equivalence-contract.tsv"

echo "UPSTREAM_AUTHORITY=FROZEN"
echo "TASK_7=FROZEN"
echo "TRAJECTORY_A=FROZEN"
echo "TRAJECTORY_B=FROZEN"

section "8. FREEZE A0 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
PRE_A0_LOCK_SHA256	$EXPECTED_PRE_LOCK_SHA256
PRE_A0_MANIFEST_SHA256	$EXPECTED_PRE_MANIFEST_SHA256
PRE_A0_CONSOLE_SHA256	$EXPECTED_PRE_CONSOLE_SHA256
RELEASE_TAG	$RELEASE_TAG
RELEASE_COMMIT	$EXPECTED_RELEASE_COMMIT
TASK_ID	7
SELECTED_TASK_SHA256	$EXPECTED_SELECTED_TASK_SHA256
REFERENCE_SEQUENCE_SHA256	$EXPECTED_REFERENCE_SEQUENCE_SHA256
ALTERNATIVE_SEQUENCE_SHA256	$EXPECTED_ALTERNATIVE_SEQUENCE_SHA256
EXECUTION_CONTRACT_SHA256	$(sha "$CONTRACTS/execution-contract.tsv")
COMMUNICATION_SHA256	$(sha "$CONTRACTS/communication.txt")
OUTCOME_EQUIVALENCE_CONTRACT_SHA256	$(sha "$CONTRACTS/outcome-equivalence-contract.tsv")
TRAJECTORY_EXECUTED	NO
TAU2_RUNTIME_EXECUTED	NO
MODEL_ENDPOINT_CALLED	NO
USER_SIMULATOR_EXECUTED	NO
GOLDEN_STATE_MATERIALIZED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

stage_copy "$0" "$EVIDENCE/stage-a0-r1-script.sh"
stage_copy "$LOCK" "$EVIDENCE/freeze-started.txt"

(
    cd "$STAGE"

    find authority task trajectories contracts evidence \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

A0_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "A0_EVIDENCE_MANIFEST_SHA256=$A0_MANIFEST_SHA256"

section "9. A0 HOMOLOGATION"

echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A0=PASS"
echo "A0_REVISION=$REVISION"

echo "TASK_ID=7"
echo "TRAJECTORY_A=FROZEN"
echo "TRAJECTORY_B=FROZEN"
echo "COMMUNICATION_CONTRACT=FROZEN"
echo "EVALUATION_CONTRACT=FROZEN"
echo "UPSTREAM_AUTHORITY=FROZEN"

echo "TRAJECTORY_EXECUTED=NO"
echo "TAU2_RUNTIME_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "USER_SIMULATOR_EXECUTED=NO"
echo "GOLDEN_STATE_MATERIALIZED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A1_DUAL_DERIVATION_EXTERNAL_JUDGMENT"

rm -rf "$PREP" || true
