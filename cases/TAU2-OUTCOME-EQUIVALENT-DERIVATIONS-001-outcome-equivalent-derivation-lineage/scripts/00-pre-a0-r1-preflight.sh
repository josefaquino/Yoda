#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="PRE-A0-R1-PREFLIGHT"

ROOT="$HOME/cmu/$CASE"
WORK="$ROOT/.pre-a0-r1-preflight"
REPO="$WORK/tau2-bench"

UPSTREAM="https://github.com/sierra-research/tau2-bench.git"
RELEASE_TAG="v1.0.1"
EXPECTED_COMMIT="fc0055dc4e0a316c3f83133267fbd6faaa770992"

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

abort()
{
    echo
    echo "PRE_A0_PREFLIGHT=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "FINAL_TASK_SELECTED=NO"
    echo "TRAJECTORY_EXECUTED=NO"
    echo "MODEL_ENDPOINT_CALLED=NO"
    echo "GOLDEN_STATE_MATERIALIZED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        abort "LOCAL_TOOLCHAIN_MISSING_$2"

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
        abort "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

rm -rf "$WORK"
mkdir -p "$WORK"

section "0. LOCAL TOOLCHAIN"

require_cmd git GIT
require_cmd jq JQ
require_cmd awk AWK
require_cmd grep GREP
require_cmd sed SED
require_cmd sort SORT
require_cmd head HEAD
require_cmd cut CUT
require_cmd wc WC
require_cmd sha256sum SHA256SUM
require_cmd mkdir MKDIR
require_cmd rm RM

section "1. PINNED RELEASE AUTHORITY"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM" \
    "$REPO" ||
    abort "UPSTREAM_RELEASE_FETCH_FAILURE"

ACTUAL_COMMIT="$(git -C "$REPO" rev-parse HEAD)"

echo "RELEASE_TAG=$RELEASE_TAG"
echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
echo "ACTUAL_COMMIT=$ACTUAL_COMMIT"

test "$ACTUAL_COMMIT" = "$EXPECTED_COMMIT" ||
    abort "UPSTREAM_RELEASE_COMMIT_MISMATCH"

echo "TAU2_REPOSITORY_AVAILABLE=PASS"
echo "TAU2_RELEASE_AUTHORITY=PASS"

section "2. FROZEN FILE IDENTITIES"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "docs/evaluation.md" "$EXPECTED_EVAL_DOC_BLOB" "EVALUATION_DOC_BLOB"
blob_check "LICENSE" "$EXPECTED_LICENSE_BLOB" "LICENSE_BLOB"

blob_check "data/tau2/domains/airline/db.json" "$EXPECTED_DB_BLOB" "AIRLINE_DB_BLOB"
blob_check "data/tau2/domains/airline/policy.md" "$EXPECTED_POLICY_BLOB" "AIRLINE_POLICY_BLOB"
blob_check "data/tau2/domains/airline/split_tasks.json" "$EXPECTED_SPLIT_BLOB" "AIRLINE_SPLIT_BLOB"
blob_check "data/tau2/domains/airline/tasks.json" "$EXPECTED_TASKS_BLOB" "AIRLINE_TASKS_BLOB"
blob_check "src/tau2/domains/airline/tools.py" "$EXPECTED_TOOLS_BLOB" "AIRLINE_TOOLS_BLOB"

echo "AIRLINE_DOMAIN_AVAILABLE=PASS"
echo "AIRLINE_POLICY_AUTHORITY=PASS"
echo "AIRLINE_TOOL_AUTHORITY=PASS"
echo "AIRLINE_TASK_AUTHORITY=PASS"

section "3. RELEASE METADATA"

grep -F 'version = "1.0.1"' "$REPO/pyproject.toml" >/dev/null ||
    abort "PYPROJECT_VERSION_MISMATCH"

grep -F 'requires-python = ">=3.12,<3.14"' "$REPO/pyproject.toml" >/dev/null ||
    abort "UPSTREAM_RUNTIME_REQUIREMENT_MISMATCH"

grep -F 'MIT License' "$REPO/LICENSE" >/dev/null ||
    abort "LICENSE_AUTHORITY_MISMATCH"

echo "UPSTREAM_PROJECT_VERSION=1.0.1"
echo "UPSTREAM_PYTHON_REQUIREMENT=>=3.12,<3.14"
echo "LICENSE_AUTHORITY=PASS"
echo "UPSTREAM_RUNTIME_EXECUTED=NO"

section "4. EVALUATION AUTHORITY"

grep -F 'one reference trajectory' "$REPO/docs/evaluation.md" >/dev/null ||
    abort "EVALUATION_DOCUMENTATION_MISMATCH"

grep -F 'any sequence of' "$REPO/docs/evaluation.md" >/dev/null ||
    abort "EVALUATION_DOCUMENTATION_MISMATCH"

grep -F 'not used at all' "$REPO/docs/evaluation.md" >/dev/null ||
    abort "EVALUATION_DOCUMENTATION_MISMATCH"

grep -F '["DB", "COMMUNICATE"]' "$REPO/docs/evaluation.md" >/dev/null ||
    abort "EVALUATION_DOCUMENTATION_MISMATCH"

echo "EVALUATION_DOCUMENTATION_AUTHORITY=PASS"
echo "OUTCOME_BASED_DB_JUDGE_AUTHORITY=PASS"
echo "AIRLINE_ACTION_MATCHING_REQUIRED=NO"

section "5. JSON CAPABILITY"

jq -e 'type == "array"' \
    "$REPO/data/tau2/domains/airline/tasks.json" \
    >/dev/null ||
    abort "AIRLINE_TASKS_JSON_INVALID"

jq -e '
    type == "object" and
    (.base | type == "array")
' \
    "$REPO/data/tau2/domains/airline/split_tasks.json" \
    >/dev/null ||
    abort "AIRLINE_SPLIT_JSON_INVALID"

TASK_COUNT="$(
    jq 'length' \
        "$REPO/data/tau2/domains/airline/tasks.json"
)"

BASE_COUNT="$(
    jq '.base | length' \
        "$REPO/data/tau2/domains/airline/split_tasks.json"
)"

echo "AIRLINE_TASK_COUNT=$TASK_COUNT"
echo "AIRLINE_BASE_SPLIT_COUNT=$BASE_COUNT"

test "$TASK_COUNT" -gt 0 ||
    abort "AIRLINE_TASK_SET_EMPTY"

test "$BASE_COUNT" -gt 0 ||
    abort "AIRLINE_BASE_SPLIT_EMPTY"

jq -e \
    --slurpfile tasks "$REPO/data/tau2/domains/airline/tasks.json" '
    .base as $base
    | ($tasks[0] | map(.id)) as $ids
    | all($base[]; . as $id | ($ids | index($id)) != null)
' \
    "$REPO/data/tau2/domains/airline/split_tasks.json" \
    >/dev/null ||
    abort "AIRLINE_BASE_SPLIT_REFERENTIAL_INTEGRITY_FAILURE"

echo "AIRLINE_BASE_SPLIT_AVAILABLE=PASS"
echo "AIRLINE_BASE_SPLIT_REFERENTIAL_INTEGRITY=PASS"

section "6. UPSTREAM TOOL TYPE EXTRACTION"

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
> "$WORK/tool-types.tsv"

test -s "$WORK/tool-types.tsv" ||
    abort "TOOL_TYPE_EXTRACTION_FAILURE"

for required in \
    "get_reservation_details	READ" \
    "get_user_details	READ" \
    "search_direct_flight	READ" \
    "book_reservation	WRITE" \
    "cancel_reservation	WRITE" \
    "update_reservation_flights	WRITE"
do
    grep -Fx "$required" "$WORK/tool-types.tsv" >/dev/null ||
        abort "TOOL_TYPE_AUTHORITY_MISMATCH"
done

echo "TOOL_TYPE_EXTRACTION=PASS"
echo "TOOL_TYPE_AUTHORITY=UPSTREAM_DECORATORS"

jq -Rn '
    [inputs
     | split("\t")
     | {(.[0]): .[1]}]
    | add
' < "$WORK/tool-types.tsv" \
> "$WORK/tool-map.json"

jq -e 'type == "object"' "$WORK/tool-map.json" >/dev/null ||
    abort "TOOL_MAP_MATERIALIZATION_FAILURE"

UNKNOWN_ACTION_COUNT="$(
    jq \
        --slurpfile map "$WORK/tool-map.json" '
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

echo "UNKNOWN_REFERENCE_ACTION_TOOL_COUNT=$UNKNOWN_ACTION_COUNT"

test "$UNKNOWN_ACTION_COUNT" -eq 0 ||
    abort "REFERENCE_ACTION_TOOL_TYPE_UNKNOWN"

echo "REFERENCE_ACTION_TOOL_COVERAGE=PASS"

section "7. SYNTHETIC SELECTOR SELF-TEST"

cat > "$WORK/synthetic-tasks.json" <<'EOF'
[
  {
    "id": "0",
    "evaluation_criteria": {
      "reward_basis": ["DB", "COMMUNICATE"],
      "actions": [
        {"name": "get_reservation_details", "arguments": {"reservation_id": "A"}},
        {"name": "get_reservation_details", "arguments": {"reservation_id": "B"}}
      ]
    }
  },
  {
    "id": "1",
    "evaluation_criteria": {
      "reward_basis": ["DB", "COMMUNICATE"],
      "actions": [
        {"name": "get_reservation_details", "arguments": {"reservation_id": "A"}},
        {"name": "cancel_reservation", "arguments": {"reservation_id": "A"}},
        {"name": "get_reservation_details", "arguments": {"reservation_id": "B"}}
      ]
    }
  },
  {
    "id": "2",
    "evaluation_criteria": {
      "reward_basis": ["DB", "COMMUNICATE"],
      "actions": [
        {"name": "get_reservation_details", "arguments": {"reservation_id": "A"}},
        {"name": "get_reservation_details", "arguments": {"reservation_id": "B"}},
        {"name": "cancel_reservation", "arguments": {"reservation_id": "A"}}
      ]
    }
  }
]
EOF

cat > "$WORK/synthetic-split.json" <<'EOF'
{"base":["0","1","2"]}
EOF

cat > "$WORK/selector.jq" <<'EOF'
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
    | {
        task_id: $task.id,
        reward_has_db: ($rb | index("DB") != null),
        reward_has_action: ($rb | index("ACTION") != null),
        reference_action_count: ($actions | length),
        state_changing_action_count: state_changing_count($map),
        adjacent_read_pairs: $pairs
      }
    | select(
        .reward_has_db
        and (.reward_has_action | not)
        and .reference_action_count >= 3
        and .state_changing_action_count >= 1
        and (.adjacent_read_pairs | length) >= 1
      )
  ]
| sort_by(.task_id | tonumber)
| .[0]
EOF

SYNTHETIC_SELECTED="$(
    jq \
        --slurpfile map "$WORK/tool-map.json" \
        --argjson base "$(jq -c '.base' "$WORK/synthetic-split.json")" \
        -f "$WORK/selector.jq" \
        "$WORK/synthetic-tasks.json"
)"

SYNTHETIC_TASK_ID="$(
    printf '%s\n' "$SYNTHETIC_SELECTED" |
    jq -r '.task_id'
)"

SYNTHETIC_PAIR_LEFT="$(
    printf '%s\n' "$SYNTHETIC_SELECTED" |
    jq -r '.adjacent_read_pairs[0].left_index'
)"

SYNTHETIC_PAIR_RIGHT="$(
    printf '%s\n' "$SYNTHETIC_SELECTED" |
    jq -r '.adjacent_read_pairs[0].right_index'
)"

test "$SYNTHETIC_TASK_ID" = "2" ||
    abort "SYNTHETIC_SELECTOR_TASK_MISMATCH"

test "$SYNTHETIC_PAIR_LEFT" = "0" ||
    abort "SYNTHETIC_SELECTOR_PAIR_MISMATCH"

test "$SYNTHETIC_PAIR_RIGHT" = "1" ||
    abort "SYNTHETIC_SELECTOR_PAIR_MISMATCH"

echo "SYNTHETIC_SELECTOR=PASS"
echo "SYNTHETIC_SELECTED_TASK_ID=2"
echo "SYNTHETIC_TRANSFORMATION_PAIR=0,1"

section "8. PRE-A0 PREFLIGHT VERDICT"

echo "PRE_A0_PREFLIGHT=PASS"
echo "RELEASE_AUTHORITY=PASS"
echo "EVALUATION_AUTHORITY=PASS"
echo "TOOL_TYPE_AUTHORITY=PASS"
echo "SELECTOR_SELF_TEST=PASS"

echo "REAL_TASK_SELECTION_EXECUTED=NO"
echo "FINAL_TASK_SELECTED=NO"
echo "TRAJECTORY_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "GOLDEN_STATE_MATERIALIZED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=PRE_A0_R1_DETERMINISTIC_TASK_SELECTION"

rm -rf "$WORK"
