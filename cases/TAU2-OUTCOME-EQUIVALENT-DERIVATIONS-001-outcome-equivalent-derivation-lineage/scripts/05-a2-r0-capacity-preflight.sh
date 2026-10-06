#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="A2-R0-CAPACITY-PREFLIGHT"

ROOT="$HOME/cmu/$CASE"

A0="$ROOT/stage-a0-r1"
A1="$ROOT/stage-a1-r1"

A1_LOCK="$ROOT/.stage-a1-r1-execution-started"

A2_LOCK="$ROOT/.stage-a2-r1-execution-started"
A2_STAGE="$ROOT/stage-a2-r1"

PREFLIGHT="$ROOT/a2-r0-capacity-preflight"
CANDIDATE="$PREFLIGHT/candidate"
EVIDENCE="$PREFLIGHT/evidence"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
YODA_SOURCE="/home/jose/YodaCore-015-FROZEN/product/yoda.c"

EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"
EXPECTED_YODA_SOURCE_SHA256="cac855eaeabddbf27b6ffbc344de479d625956555118e6fbcb178668361fdf14"

EXPECTED_A0_LOCK_SHA256="e051f5b80216a0c99005043ec90f95ca452c9f82ef677a525e2b4a9be1426449"
EXPECTED_A0_MANIFEST_SHA256="333301ea6e61dfb6de91831eb51c9a956b5d18b006a3c3d9be518bf96b2da7bc"

EXPECTED_A1_LOCK_SHA256="e047439babba668a4bfa9a408e6a58afb926e7ca0e029f4526ace064611cfa2d"
EXPECTED_A1_MANIFEST_SHA256="d9ff35821c0b69d642a42e2653b8841c919e62477e9d0867bb0556af12edb0fd"

EXPECTED_FINAL_DB_HASH="0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7"
EXPECTED_LINEAGE_A_SHA256="965417ca555dd70eff7d39e822326305b1e81b9e16864dcd7a92b43197d5d36b"
EXPECTED_LINEAGE_B_SHA256="1933529e5aa2902bd83a45d90f2692e07f0c3ef00ac4442db98ffdd114ae8340"

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
    echo "A2_R0_CAPACITY_PREFLIGHT=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A2_EXECUTION_LOCK_CONSUMED=NO"
    echo "YODA_STORE_CREATED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

not_ready()
{
    echo
    echo "A2_R0_CAPACITY_PREFLIGHT=NOT_READY"
    echo "REASON=$1"
    echo "A2_EXECUTION_LOCK_CONSUMED=NO"
    echo "YODA_STORE_CREATED=NO"
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

extract_numeric_define()
{
    name="$1"

    expr="$(
        awk -v name="$name" '
            $1 == "#define" && $2 == name {
                $1=""
                $2=""
                sub(/^[[:space:]]+/, "")
                sub(/[[:space:]]*\/\/.*/, "")
                sub(/[[:space:]]*\/\*.*/, "")
                print
                exit
            }
        ' "$YODA_SOURCE"
    )"

    test -n "$expr" ||
        return 1

    expr="$(
        printf '%s\n' "$expr" |
        sed 's/[uUlL]//g'
    )"

    case "$expr" in
        *[!0-9\ \(\)\<\>\+\-\*\/]*)
            return 1
            ;;
    esac

    value="$((expr))"

    test "$value" -gt 0 ||
        return 1

    printf '%s\n' "$value"
}

test ! -e "$A2_LOCK" ||
    not_evaluated "A2_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$A2_STAGE" ||
    not_evaluated "A2_STAGE_ALREADY_EXISTS"

rm -rf "$PREFLIGHT"
mkdir -p "$CANDIDATE" "$EVIDENCE"

section "0. LOCAL TOOLCHAIN"

require_cmd awk AWK
require_cmd grep GREP
require_cmd sed SED
require_cmd sort SORT
require_cmd uniq UNIQ
require_cmd find FIND
require_cmd xargs XARGS
require_cmd sha256sum SHA256SUM
require_cmd wc WC
require_cmd cp CP
require_cmd mkdir MKDIR
require_cmd rm RM
require_cmd cat CAT
require_cmd jq JQ

section "1. FROZEN YODA SOURCE + BINARY"

test -x "$YODA" ||
    not_evaluated "YODA_BINARY_MISSING"

test -f "$YODA_SOURCE" ||
    not_evaluated "YODA_SOURCE_MISSING"

ACTUAL_YODA_SHA256="$(sha "$YODA")"
ACTUAL_SOURCE_SHA256="$(sha "$YODA_SOURCE")"

echo "EXPECTED_YODA_SHA256=$EXPECTED_YODA_SHA256"
echo "ACTUAL_YODA_SHA256=$ACTUAL_YODA_SHA256"

echo "EXPECTED_YODA_SOURCE_SHA256=$EXPECTED_YODA_SOURCE_SHA256"
echo "ACTUAL_YODA_SOURCE_SHA256=$ACTUAL_SOURCE_SHA256"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    not_evaluated "YODA_BINARY_IDENTITY_MISMATCH"

test "$ACTUAL_SOURCE_SHA256" = "$EXPECTED_YODA_SOURCE_SHA256" ||
    not_evaluated "YODA_SOURCE_IDENTITY_MISMATCH"

TERMS_SLOTS="$(extract_numeric_define YODA_TERMS_SLOTS)" ||
    not_evaluated "YODA_TERMS_SLOTS_DISCOVERY_FAILURE"

TERM_MAX="$(extract_numeric_define YODA_TERM_MAX)" ||
    not_evaluated "YODA_TERM_MAX_DISCOVERY_FAILURE"

echo "YODA_TERMS_SLOTS=$TERMS_SLOTS"
echo "YODA_TERM_MAX=$TERM_MAX"

grep -F "terms table capacity exhausted" "$YODA_SOURCE" >/dev/null ||
    not_evaluated "YODA_CAPACITY_FAILURE_SITE_NOT_FOUND"

grep -F "terms_index_text(" "$YODA_SOURCE" >/dev/null ||
    not_evaluated "YODA_TERMS_INDEXER_NOT_FOUND"

echo "YODA_CAPACITY_SOURCE_AUTHORITY=PASS"

section "2. A0 + A1 AUTHORITY"

A0_LOCK="$ROOT/.stage-a0-r1-freeze-started"

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

test -f "$A1_LOCK" ||
    not_evaluated "A1_LOCK_MISSING"

test "$(sha "$A1_LOCK")" = "$EXPECTED_A1_LOCK_SHA256" ||
    not_evaluated "A1_LOCK_IDENTITY_MISMATCH"

test -f "$A1/evidence/SHA256SUMS" ||
    not_evaluated "A1_MANIFEST_MISSING"

test "$(sha "$A1/evidence/SHA256SUMS")" = "$EXPECTED_A1_MANIFEST_SHA256" ||
    not_evaluated "A1_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A1"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A1_EVIDENCE_INTEGRITY_FAILURE"

echo "A0_AUTHORITY=PASS"
echo "A1_AUTHORITY=PASS"

section "3. A1 SCIENTIFIC RESULT AUTHORITY"

test -f "$A1/results/overall-result.json" ||
    not_evaluated "A1_OVERALL_RESULT_MISSING"

test -f "$A1/results/trajectory-A-lineage.ndjson" ||
    not_evaluated "A1_LINEAGE_A_MISSING"

test -f "$A1/results/trajectory-B-lineage.ndjson" ||
    not_evaluated "A1_LINEAGE_B_MISSING"

test -f "$A1/results/trajectory-A-result.json" ||
    not_evaluated "A1_OUTCOME_A_MISSING"

test -f "$A1/results/trajectory-B-result.json" ||
    not_evaluated "A1_OUTCOME_B_MISSING"

test "$(sha "$A1/results/trajectory-A-lineage.ndjson")" = "$EXPECTED_LINEAGE_A_SHA256" ||
    not_evaluated "A1_LINEAGE_A_IDENTITY_MISMATCH"

test "$(sha "$A1/results/trajectory-B-lineage.ndjson")" = "$EXPECTED_LINEAGE_B_SHA256" ||
    not_evaluated "A1_LINEAGE_B_IDENTITY_MISMATCH"

jq -e \
    --arg db "$EXPECTED_FINAL_DB_HASH" '
    .scientific_pass == true
    and .trajectory_A.final_reward == 1.0
    and .trajectory_B.final_reward == 1.0
    and .trajectory_A.db_reward == 1.0
    and .trajectory_B.db_reward == 1.0
    and .trajectory_A.communicate_reward == 1.0
    and .trajectory_B.communicate_reward == 1.0
    and .trajectory_A.db_match == true
    and .trajectory_B.db_match == true
    and .trajectory_A.tool_error_count == 0
    and .trajectory_B.tool_error_count == 0
    and .trajectory_A.live_agent_db_hash == $db
    and .trajectory_B.live_agent_db_hash == $db
    and .trajectory_A.lineage_sha256 != .trajectory_B.lineage_sha256
' "$A1/results/overall-result.json" >/dev/null ||
    not_evaluated "A1_SCIENTIFIC_RESULT_MISMATCH"

echo "A1_OUTCOME_EQUIVALENCE_AUTHORITY=PASS"
echo "A1_DERIVATION_DISTINCTNESS_AUTHORITY=PASS"

section "4. MATERIALIZE MINIMAL REPLAY-COMPLETE CANDIDATE"

cp "$A0/task/selected-task.json" \
    "$CANDIDATE/task-7.json"

cp "$A1/results/trajectory-A-lineage.ndjson" \
    "$CANDIDATE/derivation-A.ndjson"

cp "$A1/results/trajectory-B-lineage.ndjson" \
    "$CANDIDATE/derivation-B.ndjson"

cp "$A1/results/trajectory-A-result.json" \
    "$CANDIDATE/outcome-A.json"

cp "$A1/results/trajectory-B-result.json" \
    "$CANDIDATE/outcome-B.json"

cp "$A1/results/overall-result.json" \
    "$CANDIDATE/outcome-equivalence.json"

cp "$A0/contracts/execution-contract.tsv" \
    "$CANDIDATE/execution-contract.tsv"

cp "$A0/contracts/communication.txt" \
    "$CANDIDATE/communication.txt"

cp "$A1/evidence/summary.tsv" \
    "$CANDIDATE/a1-summary.tsv"

cat > "$CANDIDATE/tau2-authority.tsv" <<'EOF'
field	value
repository	sierra-research/tau2-bench
release_tag	v1.0.1
release_commit	fc0055dc4e0a316c3f83133267fbd6faaa770992
evaluation_type	ALL
strict_replay	TRUE
airline_environment_blob	e1cabffe7ed4ad895904aa5248319dd307e77a97
evaluator_blob	76c95a83e9049d70a5570b93989797c0626974b6
evaluator_env_blob	a2e0a1a07cffd9394cc462376799289b1e9fbedd
evaluator_communicate_blob	1bac18fd8830304894da767d2e6b7efe6e779e89
EOF

cat > "$CANDIDATE/object-map.tsv" <<'EOF'
key	file	type
benchmark/task/7	task-7.json	benchmark-task
derivation/A	derivation-A.ndjson	tool-derivation
derivation/B	derivation-B.ndjson	tool-derivation
outcome/A	outcome-A.json	external-outcome
outcome/B	outcome-B.json	external-outcome
outcome/equivalence	outcome-equivalence.json	outcome-equivalence
contract/execution	execution-contract.tsv	execution-contract
contract/communication	communication.txt	communication-contract
authority/tau2-v1.0.1	tau2-authority.tsv	external-authority
evidence/A1-R1	a1-summary.tsv	scientific-evidence
EOF

cat > "$CANDIDATE/relation-map.tsv" <<'EOF'
from	relation	to
derivation/A	derivation-of	benchmark/task/7
derivation/B	derivation-of	benchmark/task/7
derivation/B	alternative-to	derivation/A
derivation/A	governed-by	contract/execution
derivation/B	governed-by	contract/execution
contract/execution	uses	contract/communication
outcome/A	produced-by	derivation/A
outcome/B	produced-by	derivation/B
outcome/A	judged-by	authority/tau2-v1.0.1
outcome/B	judged-by	authority/tau2-v1.0.1
outcome/equivalence	compares	outcome/A
outcome/equivalence	compares	outcome/B
outcome/equivalence	supported-by	evidence/A1-R1
benchmark/task/7	judged-by	authority/tau2-v1.0.1
EOF

OBJECT_COUNT="$(
    awk 'NR > 1 && NF {count++} END {print count+0}' \
        "$CANDIDATE/object-map.tsv"
)"

RELATION_COUNT="$(
    awk 'NR > 1 && NF {count++} END {print count+0}' \
        "$CANDIDATE/relation-map.tsv"
)"

test "$OBJECT_COUNT" -eq 10 ||
    not_evaluated "A2_CANDIDATE_OBJECT_COUNT_MISMATCH"

test "$RELATION_COUNT" -eq 14 ||
    not_evaluated "A2_CANDIDATE_RELATION_COUNT_MISMATCH"

echo "CANDIDATE_OBJECT_COUNT=$OBJECT_COUNT"
echo "CANDIDATE_RELATION_COUNT=$RELATION_COUNT"
echo "MINIMAL_REPLAY_COMPLETE_CANDIDATE=MATERIALIZED"

section "5. CANDIDATE IDENTITY + SIZE"

(
    cd "$CANDIDATE"

    find . \
        -maxdepth 1 \
        -type f \
        ! -name SHA256SUMS \
        -print |
    LC_ALL=C sort |
    sed 's#^\./##' |
    xargs sha256sum > SHA256SUMS
)

CANDIDATE_MANIFEST_SHA256="$(sha "$CANDIDATE/SHA256SUMS")"

CANDIDATE_BYTES="$(
    awk '
        NR > 1 {
            file=$2
            print file
        }
    ' "$CANDIDATE/object-map.tsv" |
    while IFS= read -r file
    do
        wc -c < "$CANDIDATE/$file"
    done |
    awk '{sum += $1} END {print sum+0}'
)"

MAX_OBJECT_BYTES=0
MAX_OBJECT_FILE=""

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    bytes="$(wc -c < "$CANDIDATE/$file" | awk '{print $1}')"

    if test "$bytes" -gt "$MAX_OBJECT_BYTES"
    then
        MAX_OBJECT_BYTES="$bytes"
        MAX_OBJECT_FILE="$file"
    fi
done < "$CANDIDATE/object-map.tsv"

echo "CANDIDATE_MANIFEST_SHA256=$CANDIDATE_MANIFEST_SHA256"
echo "CANDIDATE_VALUE_BYTES=$CANDIDATE_BYTES"
echo "MAX_OBJECT_FILE=$MAX_OBJECT_FILE"
echo "MAX_OBJECT_BYTES=$MAX_OBJECT_BYTES"

section "6. CONSERVATIVE TERM CAPACITY UPPER BOUND"

TOKENS_RAW="$PREFLIGHT/tokens.raw"

: > "$TOKENS_RAW"

cat "$CANDIDATE/object-map.tsv" >> "$TOKENS_RAW"
cat "$CANDIDATE/relation-map.tsv" >> "$TOKENS_RAW"

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    printf '%s\n' "$key" >> "$TOKENS_RAW"
    printf '%s\n' "$type" >> "$TOKENS_RAW"
    printf 'case %s revision A2-R1\n' "$CASE" >> "$TOKENS_RAW"

    cat "$CANDIDATE/$file" >> "$TOKENS_RAW"
done < "$CANDIDATE/object-map.tsv"

while IFS="$(printf '\t')" read -r from relation to
do
    test "$from" = "from" && continue

    printf '%s %s %s case %s revision A2-R1\n' \
        "$from" \
        "$relation" \
        "$to" \
        "$CASE" \
        >> "$TOKENS_RAW"
done < "$CANDIDATE/relation-map.tsv"

awk '
    {
        line=tolower($0)
        gsub(/[^[:alnum:]_-]+/, " ", line)

        n=split(line, a, /[[:space:]]+/)

        for (i=1; i<=n; i++) {
            if (a[i] != "")
                print a[i]
        }
    }
' "$TOKENS_RAW" |
LC_ALL=C sort -u \
> "$EVIDENCE/conservative-unique-terms.txt"

TERM_UPPER_BOUND="$(
    wc -l < "$EVIDENCE/conservative-unique-terms.txt" |
    awk '{print $1}'
)"

LOAD_BPS="$(
    awk \
        -v used="$TERM_UPPER_BOUND" \
        -v slots="$TERMS_SLOTS" '
        BEGIN {
            if (slots == 0) {
                print 10000
                exit
            }

            printf "%d\n", (used * 10000) / slots
        }
    '
)"

echo "YODA_TERMS_SLOTS=$TERMS_SLOTS"
echo "CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND=$TERM_UPPER_BOUND"
echo "CONSERVATIVE_TERM_LOAD_BPS=$LOAD_BPS"
echo "CAPACITY_SAFETY_LIMIT_BPS=2500"

if test "$TERM_UPPER_BOUND" -ge "$TERMS_SLOTS"
then
    not_ready "CANDIDATE_TERM_UPPER_BOUND_EXCEEDS_YODA_TERMS_CAPACITY"
fi

if test "$LOAD_BPS" -gt 2500
then
    not_ready "CANDIDATE_TERM_LOAD_EXCEEDS_25_PERCENT_SAFETY_LIMIT"
fi

echo "TERM_CAPACITY_MARGIN=PASS"

section "7. REPLAY COMPLETENESS STATIC AUDIT"

test -s "$CANDIDATE/task-7.json" ||
    not_evaluated "REPLAY_TASK_MISSING"

test -s "$CANDIDATE/derivation-A.ndjson" ||
    not_evaluated "REPLAY_DERIVATION_A_MISSING"

test -s "$CANDIDATE/derivation-B.ndjson" ||
    not_evaluated "REPLAY_DERIVATION_B_MISSING"

test -s "$CANDIDATE/execution-contract.tsv" ||
    not_evaluated "REPLAY_EXECUTION_CONTRACT_MISSING"

test -s "$CANDIDATE/communication.txt" ||
    not_evaluated "REPLAY_COMMUNICATION_MISSING"

test -s "$CANDIDATE/tau2-authority.tsv" ||
    not_evaluated "REPLAY_EXTERNAL_AUTHORITY_MISSING"

test -s "$CANDIDATE/outcome-equivalence.json" ||
    not_evaluated "REPLAY_REFERENCE_OUTCOME_MISSING"

echo "TASK_RECOVERY_INPUT=PASS"
echo "DERIVATION_A_RECOVERY_INPUT=PASS"
echo "DERIVATION_B_RECOVERY_INPUT=PASS"
echo "EXECUTION_CONTRACT_RECOVERY_INPUT=PASS"
echo "COMMUNICATION_RECOVERY_INPUT=PASS"
echo "EXTERNAL_AUTHORITY_RECOVERY_INPUT=PASS"
echo "REFERENCE_OUTCOME_RECOVERY_INPUT=PASS"
echo "REPLAY_COMPLETENESS_STATIC_AUDIT=PASS"

section "8. FREEZE PREFLIGHT EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
YODA_SHA256	$ACTUAL_YODA_SHA256
YODA_SOURCE_SHA256	$ACTUAL_SOURCE_SHA256
YODA_TERMS_SLOTS	$TERMS_SLOTS
YODA_TERM_MAX	$TERM_MAX
A0_LOCK_SHA256	$EXPECTED_A0_LOCK_SHA256
A0_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
A1_LOCK_SHA256	$EXPECTED_A1_LOCK_SHA256
A1_MANIFEST_SHA256	$EXPECTED_A1_MANIFEST_SHA256
FINAL_DB_HASH	$EXPECTED_FINAL_DB_HASH
LINEAGE_A_SHA256	$EXPECTED_LINEAGE_A_SHA256
LINEAGE_B_SHA256	$EXPECTED_LINEAGE_B_SHA256
CANDIDATE_OBJECT_COUNT	$OBJECT_COUNT
CANDIDATE_RELATION_COUNT	$RELATION_COUNT
CANDIDATE_MANIFEST_SHA256	$CANDIDATE_MANIFEST_SHA256
CANDIDATE_VALUE_BYTES	$CANDIDATE_BYTES
MAX_OBJECT_FILE	$MAX_OBJECT_FILE
MAX_OBJECT_BYTES	$MAX_OBJECT_BYTES
CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND	$TERM_UPPER_BOUND
CONSERVATIVE_TERM_LOAD_BPS	$LOAD_BPS
CAPACITY_SAFETY_LIMIT_BPS	2500
TERM_CAPACITY_MARGIN	PASS
REPLAY_COMPLETENESS_STATIC_AUDIT	PASS
A2_EXECUTION_LOCK_CONSUMED	NO
YODA_STORE_CREATED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/a2-r0-capacity-preflight.sh"

(
    cd "$PREFLIGHT"

    find candidate evidence \
        -type f \
        ! -name PRECHECK-SHA256SUMS \
        ! -name PRECHECK-SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/PRECHECK-SHA256SUMS

    sha256sum -c evidence/PRECHECK-SHA256SUMS \
        > evidence/PRECHECK-SHA256SUMS.check
)

PREFLIGHT_MANIFEST_SHA256="$(
    sha "$EVIDENCE/PRECHECK-SHA256SUMS"
)"

echo "A2_R0_EVIDENCE_INTEGRITY=PASS"
echo "A2_R0_EVIDENCE_MANIFEST_SHA256=$PREFLIGHT_MANIFEST_SHA256"

section "9. PREFLIGHT VERDICT"

test ! -e "$A2_LOCK" ||
    not_evaluated "A2_EXECUTION_LOCK_UNEXPECTEDLY_CONSUMED"

test ! -e "$A2_STAGE" ||
    not_evaluated "A2_STAGE_UNEXPECTEDLY_CREATED"

echo "A2_R0_CAPACITY_PREFLIGHT=PASS"
echo "CANDIDATE_BUNDLE=FROZEN"
echo "TERM_CAPACITY_MARGIN=PASS"
echo "REPLAY_COMPLETENESS_STATIC_AUDIT=PASS"

echo "A2_EXECUTION_LOCK=ABSENT"
echo "A2_STAGE=ABSENT"
echo "YODA_STORE_CREATED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A2_R1_YODA_DUAL_DERIVATION_LINEAGE"
