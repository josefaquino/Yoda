#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="PRE-A0-R1"

ROOT="$HOME/cmu/$CASE"
PREP="$ROOT/.pre-a0-r1-selection-prep"
STAGE="$ROOT/pre-a0-r1"
LOCK="$ROOT/.pre-a0-r1-selection-started"

REPO="$PREP/tau2-bench"
SELECTION="$STAGE/selection"
AUTHORITY="$STAGE/authority"
EVIDENCE="$STAGE/evidence"

PREFLIGHT_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-preflight-console.log"
EXPECTED_PREFLIGHT_CONSOLE_SHA256="fdb2578012c50478978744434da03d0c29cc241ebe71dd7b5ea04ab9098c0e08"

UPSTREAM="https://github.com/sierra-research/tau2-bench.git"
RELEASE_TAG="v1.0.1"
EXPECTED_COMMIT="fc0055dc4e0a316c3f83133267fbd6faaa770992"

POLICY_COMMIT="ca68b7050f0ace6674a69512ae6ea5e21651de0c"

EXPECTED_PYPROJECT_BLOB="55a9d9cf6ebd8bf2326798f4923988917e431086"
EXPECTED_EVAL_DOC_BLOB="2552c6c488e157a4366238880a870e83b7aa1758"
EXPECTED_LICENSE_BLOB="f0323a32227c1327820da33d2fb9d3338a27ac84"
EXPECTED_DB_BLOB="c6a1e817aa9102c5822e83affb3595acbc312701"
EXPECTED_POLICY_BLOB="8098be7db3f47de943fad39d1e057ede6cc6cd04"
EXPECTED_SPLIT_BLOB="c83cce155671e66a6bf07450fd2845fe0eb1f229"
EXPECTED_TASKS_BLOB="ea4ff5e3f5e3d97ca391846a6e8dd9eb3437dc80"
EXPECTED_TOOLS_BLOB="adc5c09a155d82d91e2f0647682023419eaca2ea"

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
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_PRE_A0=NOT_EVALUATED"
    echo "PRE_A0_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "TRAJECTORY_EXECUTED=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "GOLDEN_STATE_MATERIALIZED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

not_ready()
{
    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_PRE_A0=NOT_READY"
    echo "PRE_A0_REVISION=$REVISION"
    echo "CASE_HYPOTHESIS=NOT_EVALUATED"
    echo "REASON=$1"
    echo "PRE_A0_R1_RERUN=NO"
    echo "TRAJECTORY_EXECUTED=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "GOLDEN_STATE_MATERIALIZED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 2
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

    test "$actual" = "$expected" ||
        not_evaluated "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

test ! -e "$LOCK" ||
    not_evaluated "PRE_A0_R1_SELECTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "PRE_A0_R1_STAGE_ALREADY_EXISTS"

rm -rf "$PREP"
mkdir -p "$PREP"

section "0. TOOLCHAIN"

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

section "1. PREFLIGHT AUTHORITY"

test -f "$PREFLIGHT_CONSOLE" ||
    not_evaluated "PRE_A0_PREFLIGHT_CONSOLE_MISSING"

ACTUAL_PREFLIGHT_CONSOLE_SHA256="$(sha "$PREFLIGHT_CONSOLE")"

echo "EXPECTED_PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256"
echo "ACTUAL_PREFLIGHT_CONSOLE_SHA256=$ACTUAL_PREFLIGHT_CONSOLE_SHA256"

test "$ACTUAL_PREFLIGHT_CONSOLE_SHA256" = "$EXPECTED_PREFLIGHT_CONSOLE_SHA256" ||
    not_evaluated "PRE_A0_PREFLIGHT_CONSOLE_IDENTITY_MISMATCH"

grep -F "PRE_A0_PREFLIGHT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_PREFLIGHT_AUTHORITY_MISSING"

grep -F "SELECTOR_SELF_TEST=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_PREFLIGHT_SELECTOR_AUTHORITY_MISSING"

grep -F "REAL_TASK_SELECTION_EXECUTED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_PREFLIGHT_BOUNDARY_MISMATCH"

grep -F "FINAL_TASK_SELECTED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_PREFLIGHT_BOUNDARY_MISMATCH"

grep -F "PRE_A0_R1_SELECTION_LOCK=ABSENT" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_PREFLIGHT_LOCK_BOUNDARY_MISMATCH"

echo "PRE_A0_PREFLIGHT_AUTHORITY=PASS"

section "2. PINNED UPSTREAM AUTHORITY"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM" \
    "$REPO" ||
    not_evaluated "UPSTREAM_RELEASE_FETCH_FAILURE"

ACTUAL_COMMIT="$(git -C "$REPO" rev-parse HEAD)"

test "$ACTUAL_COMMIT" = "$EXPECTED_COMMIT" ||
    not_evaluated "UPSTREAM_RELEASE_COMMIT_MISMATCH"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "docs/evaluation.md" "$EXPECTED_EVAL_DOC_BLOB" "EVALUATION_DOC_BLOB"
blob_check "LICENSE" "$EXPECTED_LICENSE_BLOB" "LICENSE_BLOB"
blob_check "data/tau2/domains/airline/db.json" "$EXPECTED_DB_BLOB" "AIRLINE_DB_BLOB"
blob_check "data/tau2/domains/airline/policy.md" "$EXPECTED_POLICY_BLOB" "AIRLINE_POLICY_BLOB"
blob_check "data/tau2/domains/airline/split_tasks.json" "$EXPECTED_SPLIT_BLOB" "AIRLINE_SPLIT_BLOB"
blob_check "data/tau2/domains/airline/tasks.json" "$EXPECTED_TASKS_BLOB" "AIRLINE_TASKS_BLOB"
blob_check "src/tau2/domains/airline/tools.py" "$EXPECTED_TOOLS_BLOB" "AIRLINE_TOOLS_BLOB"

echo "RELEASE_TAG=$RELEASE_TAG"
echo "RELEASE_COMMIT=$ACTUAL_COMMIT"
echo "UPSTREAM_AUTHORITY=PASS"

section "3. EVALUATION + TOOL AUTHORITY"

grep -F 'one reference trajectory' "$REPO/docs/evaluation.md" >/dev/null ||
    not_evaluated "EVALUATION_DOCUMENTATION_MISMATCH"

grep -F 'not used at all' "$REPO/docs/evaluation.md" >/dev/null ||
    not_evaluated "EVALUATION_DOCUMENTATION_MISMATCH"

echo "OUTCOME_BASED_DB_JUDGE_AUTHORITY=PASS"
echo "AIRLINE_ACTION_MATCHING_REQUIRED=NO"

awk '
    /@is_tool\(ToolType\./ {
        line = $0
        sub(/^.*ToolType\./, "", line)
        sub(/\).*$/, "", line)
        type = line

        if ((getline nextline) <= 0)
            next

        if (match(nextline, /def[[:space:]]+[A-Za-z_][A-Za-z0-9_]*/)) {
            name = substr(nextline, RSTART, RLENGTH)
            sub(/^def[[:space:]]+/, "", name)
            print name "\t" type
        }
    }
' "$REPO/src/tau2/domains/airline/tools.py" \
| LC_ALL=C sort \
> "$PREP/tool-types.tsv"

test -s "$PREP/tool-types.tsv" ||
    not_evaluated "TOOL_TYPE_EXTRACTION_FAILURE"

jq -Rn '
    [inputs
     | split("\t")
     | {(.[0]): .[1]}]
    | add
' < "$PREP/tool-types.tsv" \
> "$PREP/tool-map.json"

jq -e 'type == "object"' "$PREP/tool-map.json" >/dev/null ||
    not_evaluated "TOOL_MAP_MATERIALIZATION_FAILURE"

UNKNOWN_ACTION_COUNT="$(
    jq \
        --slurpfile map "$PREP/tool-map.json" '
        [
          .[]
          | .evaluation_criteria.actions[]?
          | .name
          | select(($map[0][.] // "UNKNOWN") == "UNKNOWN")
        ]
        | unique
        | length
    ' "$REPO/data/tau2/domains/airline/tasks.json"
)"

test "$UNKNOWN_ACTION_COUNT" -eq 0 ||
    not_evaluated "REFERENCE_ACTION_TOOL_TYPE_UNKNOWN"

echo "TOOL_TYPE_AUTHORITY=PASS"
echo "REFERENCE_ACTION_TOOL_COVERAGE=PASS"

section "4. FREEZE SELECTOR IMPLEMENTATION"

cat > "$PREP/inventory.jq" <<'EOF'
def tool_type($map; $name):
  ($map[$name] // "UNKNOWN");

def adjacent_read_pairs($map):
  .evaluation_criteria.actions as $a
  | [
      range(0; (($a | length) - 1)) as $i
      | select(
          tool_type($map; $a[$i].name) == "READ"
          and
          tool_type($map; $a[$i + 1].name) == "READ"
          and
          (($a[$i].arguments | type) == "object")
          and
          (($a[$i + 1].arguments | type) == "object")
          and
          ($a[$i] != $a[$i + 1])
        )
      | {
          left_index: $i,
          right_index: ($i + 1),
          left_action: $a[$i],
          right_action: $a[$i + 1]
        }
    ];

def state_changing_count($map):
  [
    .evaluation_criteria.actions[]?
    | select(tool_type($map; .name) == "WRITE")
  ]
  | length;

. as $tasks
| $base as $base_ids
| [
    $tasks[]
    | select(.id as $id | ($base_ids | index($id)) != null)
    | . as $task
    | ($task.evaluation_criteria.reward_basis // []) as $rb
    | ($task.evaluation_criteria.actions // []) as $actions
    | (adjacent_read_pairs($map)) as $pairs
    | (($rb | index("DB")) != null) as $has_db
    | (($rb | index("ACTION")) != null) as $has_action
    | ($actions | length) as $action_count
    | (state_changing_count($map)) as $write_count
    | {
        task_id: $task.id,
        reward_has_db: $has_db,
        reward_has_action: $has_action,
        reference_action_count: $action_count,
        state_changing_action_count: $write_count,
        adjacent_read_pairs: $pairs,
        eligible: (
          $has_db
          and ($has_action | not)
          and $action_count >= 3
          and $write_count >= 1
          and ($pairs | length) >= 1
        )
      }
  ]
| sort_by(.task_id | tonumber)
EOF

cat > "$PREP/swap.jq" <<'EOF'
. as $actions
| $left as $li
| $right as $ri
| $actions[$li] as $left_action
| $actions[$ri] as $right_action
| $actions
| .[$li] = $right_action
| .[$ri] = $left_action
EOF

echo "SELECTOR_IMPLEMENTATION=FROZEN"
echo "TRANSFORMATION_IMPLEMENTATION=FROZEN"

section "5. ONE-EXECUTION SELECTION GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256
POLICY_COMMIT=$POLICY_COMMIT
RELEASE_TAG=$RELEASE_TAG
RELEASE_COMMIT=$EXPECTED_COMMIT
DOMAIN=airline
TASK_SPLIT=base
SELECTION_ORDER=NUMERIC_ASCENDING_TASK_ID
TRANSFORMATION_CLASS=SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_REAL_TASK_SELECTION=YES
EOF

test -f "$LOCK" ||
    not_evaluated "PRE_A0_R1_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "PRE_A0_R1_SELECTION_LOCK_SHA256=$(sha "$LOCK")"
echo "SELECTION_GATE=PASS"

mkdir -p "$SELECTION" "$AUTHORITY" "$EVIDENCE" ||
    not_evaluated "PRE_A0_STAGE_MATERIALIZATION_FAILURE"

section "6. DETERMINISTIC REAL TASK INVENTORY"

BASE_JSON="$(jq -c '.base' "$REPO/data/tau2/domains/airline/split_tasks.json")"
TOOL_MAP_JSON="$(cat "$PREP/tool-map.json")"

jq \
    --argjson map "$TOOL_MAP_JSON" \
    --argjson base "$BASE_JSON" \
    -f "$PREP/inventory.jq" \
    "$REPO/data/tau2/domains/airline/tasks.json" \
    > "$SELECTION/task-inventory.json" ||
    not_evaluated "REAL_TASK_INVENTORY_FAILURE"

INVENTORY_COUNT="$(jq 'length' "$SELECTION/task-inventory.json")"

test "$INVENTORY_COUNT" -eq 50 ||
    not_evaluated "REAL_TASK_INVENTORY_COUNT_MISMATCH"

jq -r '
    [
      "task_id",
      "reward_has_db",
      "reward_has_action",
      "reference_action_count",
      "state_changing_action_count",
      "adjacent_read_pair_count",
      "eligible"
    ],
    (
      .[]
      | [
          .task_id,
          .reward_has_db,
          .reward_has_action,
          .reference_action_count,
          .state_changing_action_count,
          (.adjacent_read_pairs | length),
          .eligible
        ]
    )
    | @tsv
' "$SELECTION/task-inventory.json" \
> "$SELECTION/task-inventory.tsv"

jq -r '.[] | select(.eligible) | .task_id' \
    "$SELECTION/task-inventory.json" \
> "$SELECTION/eligible-task-ids.txt"

ELIGIBLE_TASK_COUNT="$(wc -l < "$SELECTION/eligible-task-ids.txt" | awk '{print $1}')"

echo "REAL_TASK_SELECTION_EXECUTED=YES"
echo "TASK_INVENTORY_COUNT=$INVENTORY_COUNT"
echo "ELIGIBLE_TASK_COUNT=$ELIGIBLE_TASK_COUNT"

test "$ELIGIBLE_TASK_COUNT" -gt 0 ||
    not_ready "NO_TASK_SATISFIES_FROZEN_SELECTION_POLICY"

section "7. FREEZE FIRST ELIGIBLE TASK"

jq '
    [.[] | select(.eligible)]
    | .[0]
' "$SELECTION/task-inventory.json" \
> "$SELECTION/selected-inventory-record.json"

SELECTED_TASK_ID="$(
    jq -r '.task_id' \
        "$SELECTION/selected-inventory-record.json"
)"

PAIR_LEFT="$(
    jq -r '.adjacent_read_pairs[0].left_index' \
        "$SELECTION/selected-inventory-record.json"
)"

PAIR_RIGHT="$(
    jq -r '.adjacent_read_pairs[0].right_index' \
        "$SELECTION/selected-inventory-record.json"
)"

jq \
    --arg id "$SELECTED_TASK_ID" '
    map(select(.id == $id))
    | .[0]
' "$REPO/data/tau2/domains/airline/tasks.json" \
> "$SELECTION/selected-task.json"

jq '.evaluation_criteria.actions' \
    "$SELECTION/selected-task.json" \
> "$SELECTION/reference-actions.json"

jq \
    --argjson left "$PAIR_LEFT" \
    --argjson right "$PAIR_RIGHT" \
    -f "$PREP/swap.jq" \
    "$SELECTION/reference-actions.json" \
> "$SELECTION/alternative-actions-candidate.json"

jq -cS '.[] | {name,arguments}' \
    "$SELECTION/reference-actions.json" \
> "$SELECTION/reference-sequence.ndjson"

jq -cS '.[] | {name,arguments}' \
    "$SELECTION/alternative-actions-candidate.json" \
> "$SELECTION/alternative-sequence.ndjson"

if cmp -s \
    "$SELECTION/reference-sequence.ndjson" \
    "$SELECTION/alternative-sequence.ndjson"
then
    not_evaluated "TRANSFORMATION_NOT_MATERIALLY_DISTINCT"
fi

LC_ALL=C sort "$SELECTION/reference-sequence.ndjson" \
    > "$PREP/reference-multiset.txt"

LC_ALL=C sort "$SELECTION/alternative-sequence.ndjson" \
    > "$PREP/alternative-multiset.txt"

cmp -s "$PREP/reference-multiset.txt" "$PREP/alternative-multiset.txt" ||
    not_evaluated "TRANSFORMATION_ACTION_MULTISET_MISMATCH"

jq \
    --argjson map "$TOOL_MAP_JSON" '
    .[]
    | select(($map[.name] // "UNKNOWN") == "WRITE")
    | {name, arguments}
' "$SELECTION/reference-actions.json" \
| jq -cS . \
> "$PREP/reference-writes.ndjson"

jq \
    --argjson map "$TOOL_MAP_JSON" '
    .[]
    | select(($map[.name] // "UNKNOWN") == "WRITE")
    | {name, arguments}
' "$SELECTION/alternative-actions-candidate.json" \
| jq -cS . \
> "$PREP/alternative-writes.ndjson"

cmp -s "$PREP/reference-writes.ndjson" "$PREP/alternative-writes.ndjson" ||
    not_evaluated "TRANSFORMATION_WRITE_SEQUENCE_MISMATCH"

LEFT_TYPE="$(
    jq \
        --argjson map "$TOOL_MAP_JSON" \
        --argjson idx "$PAIR_LEFT" \
        -r '$map[.[$idx].name]' \
        "$SELECTION/reference-actions.json"
)"

RIGHT_TYPE="$(
    jq \
        --argjson map "$TOOL_MAP_JSON" \
        --argjson idx "$PAIR_RIGHT" \
        -r '$map[.[$idx].name]' \
        "$SELECTION/reference-actions.json"
)"

test "$LEFT_TYPE" = "READ" ||
    not_evaluated "SELECTED_PAIR_LEFT_NOT_READ"

test "$RIGHT_TYPE" = "READ" ||
    not_evaluated "SELECTED_PAIR_RIGHT_NOT_READ"

test "$PAIR_RIGHT" -eq $((PAIR_LEFT + 1)) ||
    not_evaluated "SELECTED_PAIR_NOT_ADJACENT"

LEFT_NAME="$(
    jq -r \
        --argjson idx "$PAIR_LEFT" \
        '.[$idx].name' \
        "$SELECTION/reference-actions.json"
)"

RIGHT_NAME="$(
    jq -r \
        --argjson idx "$PAIR_RIGHT" \
        '.[$idx].name' \
        "$SELECTION/reference-actions.json"
)"

cat > "$SELECTION/transformation.tsv" <<EOF
transformation	left_index	right_index	left_tool	right_tool
SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS	$PAIR_LEFT	$PAIR_RIGHT	$LEFT_NAME	$RIGHT_NAME
EOF

cat > "$SELECTION/selection.tsv" <<EOF
case	domain	split	task_id	transformation	left_index	right_index
$CASE	airline	base	$SELECTED_TASK_ID	SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS	$PAIR_LEFT	$PAIR_RIGHT
EOF

echo "FINAL_TASK_SELECTED=YES"
echo "SELECTED_TASK_ID=$SELECTED_TASK_ID"
echo "SELECTED_TRANSFORMATION=SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS"
echo "SELECTED_PAIR_INDEXES=$PAIR_LEFT,$PAIR_RIGHT"
echo "SELECTED_PAIR_LEFT_TOOL=$LEFT_NAME"
echo "SELECTED_PAIR_RIGHT_TOOL=$RIGHT_NAME"

echo "CANONICAL_TOOL_SEQUENCE_DISTINCT=PASS"
echo "ACTION_MULTISET_PRESERVED=PASS"
echo "WRITE_SEQUENCE_PRESERVED=PASS"
echo "ALTERNATIVE_TRANSFORMATION_PLAUSIBILITY=PASS"

section "8. FREEZE SELECTION AUTHORITY"

cp "$REPO/data/tau2/domains/airline/tasks.json" \
    "$AUTHORITY/tasks.json"

cp "$REPO/data/tau2/domains/airline/split_tasks.json" \
    "$AUTHORITY/split_tasks.json"

cp "$REPO/data/tau2/domains/airline/policy.md" \
    "$AUTHORITY/policy.md"

cp "$REPO/src/tau2/domains/airline/tools.py" \
    "$AUTHORITY/tools.py"

cp "$REPO/docs/evaluation.md" \
    "$AUTHORITY/evaluation.md"

cp "$PREP/tool-types.tsv" \
    "$AUTHORITY/tool-types.tsv"

cp "$PREP/inventory.jq" \
    "$AUTHORITY/inventory.jq"

cp "$PREP/swap.jq" \
    "$AUTHORITY/swap.jq"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
PREFLIGHT_CONSOLE_SHA256	$EXPECTED_PREFLIGHT_CONSOLE_SHA256
POLICY_COMMIT	$POLICY_COMMIT
RELEASE_TAG	$RELEASE_TAG
RELEASE_COMMIT	$EXPECTED_COMMIT
DOMAIN	airline
TASK_SPLIT	base
TASK_INVENTORY_COUNT	$INVENTORY_COUNT
ELIGIBLE_TASK_COUNT	$ELIGIBLE_TASK_COUNT
SELECTED_TASK_ID	$SELECTED_TASK_ID
TRANSFORMATION	SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS
PAIR_LEFT_INDEX	$PAIR_LEFT
PAIR_RIGHT_INDEX	$PAIR_RIGHT
PAIR_LEFT_TOOL	$LEFT_NAME
PAIR_RIGHT_TOOL	$RIGHT_NAME
REFERENCE_SEQUENCE_SHA256	$(sha "$SELECTION/reference-sequence.ndjson")
ALTERNATIVE_SEQUENCE_SHA256	$(sha "$SELECTION/alternative-sequence.ndjson")
SELECTED_TASK_SHA256	$(sha "$SELECTION/selected-task.json")
SELECTION_SHA256	$(sha "$SELECTION/selection.tsv")
TRANSFORMATION_SHA256	$(sha "$SELECTION/transformation.tsv")
TRAJECTORY_EXECUTED	NO
MODEL_ENDPOINT_CALLED	NO
GOLDEN_STATE_MATERIALIZED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/pre-a0-r1-selection-script.sh"
cp "$LOCK" "$EVIDENCE/selection-started.txt"

(
    cd "$STAGE"

    find authority selection evidence \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
) || not_evaluated "PRE_A0_EVIDENCE_INTEGRITY_FAILURE"

PRE_A0_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "PRE_A0_EVIDENCE_INTEGRITY=PASS"
echo "PRE_A0_EVIDENCE_MANIFEST_SHA256=$PRE_A0_MANIFEST_SHA256"

section "9. PRE-A0 HOMOLOGATION"

echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_PRE_A0=PASS"
echo "PRE_A0_REVISION=$REVISION"

echo "RELEASE=FROZEN"
echo "DOMAIN=airline"
echo "TASK_SPLIT=base"
echo "TASK_SELECTION_POLICY=FROZEN"

echo "CANDIDATE_TASK_IDENTIFIED=PASS"
echo "ALTERNATIVE_TRANSFORMATION_PLAUSIBILITY=PASS"

echo "SELECTED_TASK_ID=$SELECTED_TASK_ID"
echo "SELECTED_PAIR_INDEXES=$PAIR_LEFT,$PAIR_RIGHT"

echo "TRAJECTORY_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "GOLDEN_STATE_MATERIALIZED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A0_EXPERIMENTAL_FREEZE"

rm -rf "$PREP" || true
