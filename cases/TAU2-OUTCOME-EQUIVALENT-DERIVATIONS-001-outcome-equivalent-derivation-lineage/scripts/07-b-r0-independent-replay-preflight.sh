#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="B-R0-INDEPENDENT-REPLAY-PREFLIGHT"

ROOT="$HOME/cmu/$CASE"
A2="$ROOT/stage-a2-r1"
STORE="$A2/yoda-store"

B_LOCK="$ROOT/.stage-b-r1-execution-started"
B_STAGE="$ROOT/stage-b-r1"

WORK="$ROOT/b-r0-independent-replay-preflight"
RECOVERED="$WORK/recovered"
EVIDENCE="$WORK/evidence"
TAU2_REPO="$WORK/tau2-bench"
ADAPTER="$WORK/b-independent-replay-authority.py"

A2_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a2-r1-console.log"
A2_LOCK="$ROOT/.stage-a2-r1-execution-started"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"

EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

EXPECTED_A2_LOCK_SHA256="678d87d60c3661209b73674961afb42a8139fef66c6cdbbe57ebb51487b39bb7"
EXPECTED_A2_MANIFEST_SHA256="d6ac6b8d4fbd61f7c210d998f8feb407759dd3df3d068c82187653c006099a2c"
EXPECTED_A2_CONSOLE_SHA256="f37708f77cf45ce2da56e3b2d5c11601c7f9ca5a01bc881dfa3d160b4313d4f5"
EXPECTED_DATA_YODA_SHA256="0d790fb57c3fe092a1567327f049f0b123dd143c379f4afa21692b614f40d42a"
EXPECTED_DATA_YODA_BYTES=24801

EXPECTED_OBJECT_COUNT=10
EXPECTED_LINEAGE_A_SHA256="965417ca555dd70eff7d39e822326305b1e81b9e16864dcd7a92b43197d5d36b"
EXPECTED_LINEAGE_B_SHA256="1933529e5aa2902bd83a45d90f2692e07f0c3ef00ac4442db98ffdd114ae8340"

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

not_evaluated()
{
    echo
    echo "B_R0_INDEPENDENT_REPLAY_PREFLIGHT=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "B_EXECUTION_LOCK_CONSUMED=NO"
    echo "INDEPENDENT_REPLAY_EXECUTED=NO"
    echo "EXTERNAL_JUDGE_EXECUTED=NO"
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

    actual="$(git -C "$TAU2_REPO" hash-object "$file")"

    test "$actual" = "$expected" ||
        not_evaluated "$label""_IDENTITY_MISMATCH"

    printf '%s_IDENTITY=PASS\n' "$label"
}

store_manifest()
{
    output="$1"

    (
        cd "$STORE"
        find . -type f -print |
        LC_ALL=C sort |
        xargs sha256sum
    ) > "$output"
}

test ! -e "$B_LOCK" ||
    not_evaluated "B_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$B_STAGE" ||
    not_evaluated "B_STAGE_ALREADY_EXISTS"

rm -rf "$WORK"
mkdir -p "$RECOVERED" "$EVIDENCE"

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
require_cmd mkdir MKDIR
require_cmd rm RM

section "1. A2 FROZEN AUTHORITY"

test -x "$YODA" ||
    not_evaluated "YODA_BINARY_MISSING"

test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    not_evaluated "YODA_BINARY_IDENTITY_MISMATCH"

test -f "$A2_LOCK" ||
    not_evaluated "A2_LOCK_MISSING"

test "$(sha "$A2_LOCK")" = "$EXPECTED_A2_LOCK_SHA256" ||
    not_evaluated "A2_LOCK_IDENTITY_MISMATCH"

test -f "$A2/evidence/SHA256SUMS" ||
    not_evaluated "A2_MANIFEST_MISSING"

test "$(sha "$A2/evidence/SHA256SUMS")" = "$EXPECTED_A2_MANIFEST_SHA256" ||
    not_evaluated "A2_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A2"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A2_EVIDENCE_INTEGRITY_FAILURE"

test -f "$A2_CONSOLE" ||
    not_evaluated "A2_CONSOLE_MISSING"

test "$(sha "$A2_CONSOLE")" = "$EXPECTED_A2_CONSOLE_SHA256" ||
    not_evaluated "A2_CONSOLE_IDENTITY_MISMATCH"

test -f "$STORE/data.yoda" ||
    not_evaluated "A2_DATA_YODA_MISSING"

test "$(sha "$STORE/data.yoda")" = "$EXPECTED_DATA_YODA_SHA256" ||
    not_evaluated "A2_DATA_YODA_IDENTITY_MISMATCH"

ACTUAL_DATA_BYTES="$(
    wc -c < "$STORE/data.yoda" |
    awk '{print $1}'
)"

test "$ACTUAL_DATA_BYTES" -eq "$EXPECTED_DATA_YODA_BYTES" ||
    not_evaluated "A2_DATA_YODA_SIZE_MISMATCH"

echo "YODA_AUTHORITY=PASS"
echo "A2_LOCK_AUTHORITY=PASS"
echo "A2_EVIDENCE_AUTHORITY=PASS"
echo "A2_STORE_AUTHORITY=PASS"

section "2. SNAPSHOT STORE BEFORE READ-ONLY RECOVERY"

store_manifest "$EVIDENCE/store-before.sha256"

STORE_BEFORE_SHA256="$(sha "$EVIDENCE/store-before.sha256")"

echo "STORE_BEFORE_MANIFEST_SHA256=$STORE_BEFORE_SHA256"

section "3. RECOVER ALL 10 OBJECTS FROM YODA"

OBJECT_MAP="$A2/maps/object-map.tsv"
CANDIDATE_SHA="$A2/evidence/candidate-SHA256SUMS"

test -f "$OBJECT_MAP" ||
    not_evaluated "A2_OBJECT_MAP_MISSING"

test -f "$CANDIDATE_SHA" ||
    not_evaluated "A2_CANDIDATE_SHA_AUTHORITY_MISSING"

RECOVERED_COUNT=0

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    "$YODA" -d "$STORE" get "$key" \
        > "$RECOVERED/$file" ||
        not_evaluated "YODA_READ_RECOVERY_FAILURE"

    expected="$(
        awk -v f="$file" '
            $2 == f {
                print $1
                exit
            }
        ' "$CANDIDATE_SHA"
    )"

    test -n "$expected" ||
        not_evaluated "RECOVERED_OBJECT_EXPECTED_HASH_MISSING"

    test "$(sha "$RECOVERED/$file")" = "$expected" ||
        not_evaluated "RECOVERED_OBJECT_IDENTITY_MISMATCH"

    RECOVERED_COUNT=$((RECOVERED_COUNT + 1))

done < "$OBJECT_MAP"

test "$RECOVERED_COUNT" -eq "$EXPECTED_OBJECT_COUNT" ||
    not_evaluated "RECOVERED_OBJECT_COUNT_MISMATCH"

test "$(sha "$RECOVERED/derivation-A.ndjson")" = "$EXPECTED_LINEAGE_A_SHA256" ||
    not_evaluated "RECOVERED_LINEAGE_A_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/derivation-B.ndjson")" = "$EXPECTED_LINEAGE_B_SHA256" ||
    not_evaluated "RECOVERED_LINEAGE_B_IDENTITY_MISMATCH"

echo "YODA_READ_RECOVERY=PASS"
echo "RECOVERED_OBJECT_COUNT=$RECOVERED_COUNT"
echo "RECOVERED_LINEAGE_A_IDENTITY=PASS"
echo "RECOVERED_LINEAGE_B_IDENTITY=PASS"

section "4. RECOVERED TAU2 AUTHORITY"

AUTH="$RECOVERED/tau2-authority.tsv"

test -f "$AUTH" ||
    not_evaluated "RECOVERED_TAU2_AUTHORITY_MISSING"

authority_value()
{
    key="$1"

    awk -F '\t' -v key="$key" '
        $1 == key {
            print $2
            exit
        }
    ' "$AUTH"
}

test "$(authority_value repository)" = "sierra-research/tau2-bench" ||
    not_evaluated "RECOVERED_TAU2_REPOSITORY_MISMATCH"

test "$(authority_value release_tag)" = "$RELEASE_TAG" ||
    not_evaluated "RECOVERED_TAU2_RELEASE_TAG_MISMATCH"

test "$(authority_value release_commit)" = "$EXPECTED_RELEASE_COMMIT" ||
    not_evaluated "RECOVERED_TAU2_RELEASE_COMMIT_MISMATCH"

test "$(authority_value evaluation_type)" = "ALL" ||
    not_evaluated "RECOVERED_EVALUATION_TYPE_MISMATCH"

test "$(authority_value strict_replay)" = "TRUE" ||
    not_evaluated "RECOVERED_STRICT_REPLAY_MISMATCH"

echo "RECOVERED_TAU2_AUTHORITY=PASS"

section "5. PINNED EXTERNAL RUNTIME"

git clone \
    --quiet \
    --depth 1 \
    --branch "$RELEASE_TAG" \
    "$UPSTREAM" \
    "$TAU2_REPO" ||
    not_evaluated "UPSTREAM_RELEASE_FETCH_FAILURE"

test "$(git -C "$TAU2_REPO" rev-parse HEAD)" = "$EXPECTED_RELEASE_COMMIT" ||
    not_evaluated "UPSTREAM_RELEASE_COMMIT_MISMATCH"

blob_check "pyproject.toml" "$EXPECTED_PYPROJECT_BLOB" "PYPROJECT_BLOB"
blob_check "uv.lock" "$EXPECTED_UV_LOCK_BLOB" "UV_LOCK_BLOB"
blob_check "src/tau2/domains/airline/environment.py" "$EXPECTED_AIRLINE_ENV_BLOB" "AIRLINE_ENVIRONMENT_BLOB"
blob_check "src/tau2/evaluator/evaluator.py" "$EXPECTED_EVALUATOR_BLOB" "EVALUATOR_BLOB"

ACTUAL_UV_VERSION="$(uv --version)"

test "$ACTUAL_UV_VERSION" = "$EXPECTED_UV_VERSION" ||
    not_evaluated "UV_VERSION_DRIFT"

(
    cd "$TAU2_REPO"
    uv sync --frozen
) ||
    not_evaluated "TAU2_UV_SYNC_FAILURE"

PY="$TAU2_REPO/.venv/bin/python"

test -x "$PY" ||
    not_evaluated "TAU2_PYTHON_MISSING"

ACTUAL_PYTHON_VERSION="$(
    "$PY" -c 'import platform; print(platform.python_version())'
)"

test "$ACTUAL_PYTHON_VERSION" = "$EXPECTED_PYTHON_VERSION" ||
    not_evaluated "PYTHON_VERSION_DRIFT"

ACTUAL_TAU2_VERSION="$(
    "$PY" -c 'import importlib.metadata; print(importlib.metadata.version("tau2"))'
)"

test "$ACTUAL_TAU2_VERSION" = "$EXPECTED_TAU2_VERSION" ||
    not_evaluated "TAU2_VERSION_DRIFT"

echo "UV_VERSION=$ACTUAL_UV_VERSION"
echo "PYTHON_VERSION=$ACTUAL_PYTHON_VERSION"
echo "TAU2_VERSION=$ACTUAL_TAU2_VERSION"
echo "PINNED_RUNTIME=PASS"

section "6. INDEPENDENT ADAPTER AUTHORITY"

curl -fsSL "$ADAPTER_URL" -o "$ADAPTER" ||
    not_evaluated "B_ADAPTER_FETCH_FAILURE"

ACTUAL_ADAPTER_SHA256="$(sha "$ADAPTER")"

echo "EXPECTED_B_ADAPTER_SHA256=$EXPECTED_ADAPTER_SHA256"
echo "ACTUAL_B_ADAPTER_SHA256=$ACTUAL_ADAPTER_SHA256"

test "$ACTUAL_ADAPTER_SHA256" = "$EXPECTED_ADAPTER_SHA256" ||
    not_evaluated "B_ADAPTER_IDENTITY_MISMATCH"

if grep -F "a1-dual-derivation-authority" "$ADAPTER" >/dev/null
then
    not_evaluated "B_ADAPTER_DEPENDS_ON_A1_ADAPTER"
fi

if grep -Eiq 'openai|anthropic|litellm' "$ADAPTER"
then
    not_evaluated "B_ADAPTER_MODEL_PROVIDER_REFERENCE_PRESENT"
fi

"$PY" -m py_compile "$ADAPTER" ||
    not_evaluated "B_ADAPTER_PARSE_FAILURE"

AUDIT_STDOUT="$EVIDENCE/adapter-audit.json"
AUDIT_STDERR="$EVIDENCE/adapter-audit.stderr"

"$PY" "$ADAPTER" \
    --mode audit \
    --recovered-dir "$RECOVERED" \
    > "$AUDIT_STDOUT" \
    2> "$AUDIT_STDERR" ||
    not_evaluated "B_ADAPTER_AUDIT_FAILURE"

jq -e \
    --arg a "$EXPECTED_LINEAGE_A_SHA256" \
    --arg b "$EXPECTED_LINEAGE_B_SHA256" '
    .audit == "PASS"
    and .task_id == "7"
    and .trajectory_A_tool_calls == 5
    and .trajectory_B_tool_calls == 5
    and .derivations_distinct == true
    and .communication_matches_both == true
    and .original_equivalence_pass == true
    and .lineage_A_sha256 == $a
    and .lineage_B_sha256 == $b
    and .trajectory_executed == false
    and .external_judge_executed == false
' "$AUDIT_STDOUT" >/dev/null ||
    not_evaluated "B_ADAPTER_AUDIT_RESULT_MISMATCH"

echo "B_ADAPTER_IDENTITY=PASS"
echo "B_ADAPTER_PARSE=PASS"
echo "B_ADAPTER_PRE_EXECUTION_AUDIT=PASS"
echo "INDEPENDENT_IMPLEMENTATION_BOUNDARY=PASS"

section "7. PROVE YODA STORE UNCHANGED"

store_manifest "$EVIDENCE/store-after.sha256"

STORE_AFTER_SHA256="$(sha "$EVIDENCE/store-after.sha256")"

echo "STORE_AFTER_MANIFEST_SHA256=$STORE_AFTER_SHA256"

cmp -s \
    "$EVIDENCE/store-before.sha256" \
    "$EVIDENCE/store-after.sha256" ||
    not_evaluated "YODA_STORE_MUTATED_DURING_PREFLIGHT"

test "$(sha "$STORE/data.yoda")" = "$EXPECTED_DATA_YODA_SHA256" ||
    not_evaluated "DATA_YODA_MUTATED_DURING_PREFLIGHT"

echo "YODA_STORE_MUTATED=NO"
echo "YODA_WRITES=ZERO"

section "8. FREEZE B-R0 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
A2_LOCK_SHA256	$EXPECTED_A2_LOCK_SHA256
A2_MANIFEST_SHA256	$EXPECTED_A2_MANIFEST_SHA256
A2_CONSOLE_SHA256	$EXPECTED_A2_CONSOLE_SHA256
DATA_YODA_SHA256	$EXPECTED_DATA_YODA_SHA256
DATA_YODA_BYTES	$ACTUAL_DATA_BYTES
RECOVERED_OBJECT_COUNT	$RECOVERED_COUNT
LINEAGE_A_SHA256	$EXPECTED_LINEAGE_A_SHA256
LINEAGE_B_SHA256	$EXPECTED_LINEAGE_B_SHA256
RELEASE_TAG	$RELEASE_TAG
RELEASE_COMMIT	$EXPECTED_RELEASE_COMMIT
B_ADAPTER_SHA256	$ACTUAL_ADAPTER_SHA256
STORE_BEFORE_MANIFEST_SHA256	$STORE_BEFORE_SHA256
STORE_AFTER_MANIFEST_SHA256	$STORE_AFTER_SHA256
YODA_STORE_MUTATED	NO
INDEPENDENT_REPLAY_EXECUTED	NO
EXTERNAL_JUDGE_EXECUTED	NO
B_EXECUTION_LOCK_CONSUMED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/b-r0-independent-replay-preflight.sh"

(
    cd "$WORK"

    find recovered evidence \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
)

B_R0_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "B_R0_EVIDENCE_INTEGRITY=PASS"
echo "B_R0_EVIDENCE_MANIFEST_SHA256=$B_R0_MANIFEST_SHA256"

section "9. PREFLIGHT VERDICT"

test ! -e "$B_LOCK" ||
    not_evaluated "B_EXECUTION_LOCK_UNEXPECTEDLY_CONSUMED"

test ! -e "$B_STAGE" ||
    not_evaluated "B_STAGE_UNEXPECTEDLY_CREATED"

echo "B_R0_INDEPENDENT_REPLAY_PREFLIGHT=PASS"
echo "YODA_RECOVERY_AUTHORITY=PASS"
echo "PINNED_RUNTIME=PASS"
echo "INDEPENDENT_IMPLEMENTATION_BOUNDARY=PASS"
echo "YODA_STORE_MUTATED=NO"

echo "B_EXECUTION_LOCK=ABSENT"
echo "B_STAGE=ABSENT"
echo "INDEPENDENT_REPLAY_EXECUTED=NO"
echo "EXTERNAL_JUDGE_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

echo "NEXT_GATE=B_R1_INDEPENDENT_DUAL_DERIVATION_REPLAY"
