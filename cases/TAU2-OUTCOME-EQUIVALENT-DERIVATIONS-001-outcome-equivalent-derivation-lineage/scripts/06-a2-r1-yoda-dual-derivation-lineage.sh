#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
REVISION="A2-R1"

ROOT="$HOME/cmu/$CASE"

PREFLIGHT="$ROOT/a2-r0-capacity-preflight"
CANDIDATE="$PREFLIGHT/candidate"
PREFLIGHT_EVIDENCE="$PREFLIGHT/evidence"
PREFLIGHT_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a2-r0-capacity-preflight-console.log"

STAGE="$ROOT/stage-a2-r1"
STORE="$STAGE/yoda-store"
OBJECTS="$STAGE/objects"
MAPS="$STAGE/maps"
RECOVERED="$STAGE/recovered"
RELATION_LOGS="$STAGE/relation-logs"
EVIDENCE="$STAGE/evidence"

EXECUTION_LOCK="$ROOT/.stage-a2-r1-execution-started"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
YODA_SOURCE="/home/jose/YodaCore-015-FROZEN/product/yoda.c"

EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"
EXPECTED_YODA_SOURCE_SHA256="cac855eaeabddbf27b6ffbc344de479d625956555118e6fbcb178668361fdf14"

EXPECTED_PREFLIGHT_CONSOLE_SHA256="0f7461f13b8fe6091e13b1b1697b87aa474bc379b7431e96102ac5db08b01839"
EXPECTED_PREFLIGHT_MANIFEST_SHA256="dfe8940f16f282f2d9ccf2c764d970ba5ff670138c1e5f53f72ecba54680a5aa"
EXPECTED_CANDIDATE_MANIFEST_SHA256="036d95475aa5cff87a8dc5b36f9fed8cfe7b018db9c8a51c0c2770023db3e5ec"

EXPECTED_A0_LOCK_SHA256="e051f5b80216a0c99005043ec90f95ca452c9f82ef677a525e2b4a9be1426449"
EXPECTED_A0_MANIFEST_SHA256="333301ea6e61dfb6de91831eb51c9a956b5d18b006a3c3d9be518bf96b2da7bc"
EXPECTED_A1_LOCK_SHA256="e047439babba668a4bfa9a408e6a58afb926e7ca0e029f4526ace064611cfa2d"
EXPECTED_A1_MANIFEST_SHA256="d9ff35821c0b69d642a42e2653b8841c919e62477e9d0867bb0556af12edb0fd"

EXPECTED_FINAL_DB_HASH="0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7"
EXPECTED_LINEAGE_A_SHA256="965417ca555dd70eff7d39e822326305b1e81b9e16864dcd7a92b43197d5d36b"
EXPECTED_LINEAGE_B_SHA256="1933529e5aa2902bd83a45d90f2692e07f0c3ef00ac4442db98ffdd114ae8340"

EXPECTED_OBJECT_COUNT=10
EXPECTED_RELATION_COUNT=14
EXPECTED_TERM_UPPER_BOUND=372
EXPECTED_TERM_LOAD_BPS=908
EXPECTED_CAPACITY_LIMIT_BPS=2500

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
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A2=NOT_EVALUATED"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A2_EXECUTION_LOCK_CONSUMED=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

freeze_manifest()
{
    (
        cd "$STAGE"

        find evidence maps objects recovered relation-logs yoda-store \
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
A2_R1_RERUN	NO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

    freeze_manifest || true

    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A2=NOT_EVALUATED"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$failure"
    echo "A2_EXECUTION_LOCK_CONSUMED=YES"
    echo "A2_R1_RERUN=NO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"

    if test -f "$EVIDENCE/SHA256SUMS"
    then
        echo "A2_EVIDENCE_MANIFEST_SHA256=$(sha "$EVIDENCE/SHA256SUMS")"
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
A2_R1_RERUN	NO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

    freeze_manifest || true

    echo
    echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A2=FAIL"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$failure"
    echo "A2_EXECUTION_LOCK_CONSUMED=YES"
    echo "A2_R1_RERUN=NO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"

    if test -f "$EVIDENCE/SHA256SUMS"
    then
        echo "A2_EVIDENCE_MANIFEST_SHA256=$(sha "$EVIDENCE/SHA256SUMS")"
    fi

    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        prelock_not_evaluated "LOCAL_TOOLCHAIN_MISSING_$2"

    echo "$2=PASS"
}

summary_value()
{
    key="$1"

    awk -F '\t' -v key="$key" '
        $1 == key {
            print $2
            exit
        }
    ' "$PREFLIGHT_EVIDENCE/summary.tsv"
}

put_file()
{
    key="$1"
    file="$2"
    type="$3"

    "$YODA" -d "$STORE" put \
        "$key" \
        type="$type" \
        case="$CASE" \
        revision="$REVISION" \
        < "$file" \
        >/dev/null
}

link_relation()
{
    from="$1"
    relation="$2"
    to="$3"

    "$YODA" -d "$STORE" link \
        "$from" \
        "$relation" \
        "$to" \
        case="$CASE" \
        revision="$REVISION" \
        >/dev/null
}

test ! -e "$EXECUTION_LOCK" ||
    prelock_not_evaluated "A2_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_not_evaluated "A2_STAGE_ALREADY_EXISTS"

section "0. LOCAL TOOLCHAIN"

require_cmd awk AWK
require_cmd grep GREP
require_cmd sed SED
require_cmd sort SORT
require_cmd find FIND
require_cmd xargs XARGS
require_cmd sha256sum SHA256SUM
require_cmd cmp CMP
require_cmd wc WC
require_cmd cp CP
require_cmd mkdir MKDIR
require_cmd cat CAT
require_cmd jq JQ

section "1. FROZEN YODA AUTHORITY"

test -x "$YODA" ||
    prelock_not_evaluated "YODA_BINARY_MISSING"

test -f "$YODA_SOURCE" ||
    prelock_not_evaluated "YODA_SOURCE_MISSING"

ACTUAL_YODA_SHA256="$(sha "$YODA")"
ACTUAL_YODA_SOURCE_SHA256="$(sha "$YODA_SOURCE")"

echo "EXPECTED_YODA_SHA256=$EXPECTED_YODA_SHA256"
echo "ACTUAL_YODA_SHA256=$ACTUAL_YODA_SHA256"

echo "EXPECTED_YODA_SOURCE_SHA256=$EXPECTED_YODA_SOURCE_SHA256"
echo "ACTUAL_YODA_SOURCE_SHA256=$ACTUAL_YODA_SOURCE_SHA256"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    prelock_not_evaluated "YODA_BINARY_IDENTITY_MISMATCH"

test "$ACTUAL_YODA_SOURCE_SHA256" = "$EXPECTED_YODA_SOURCE_SHA256" ||
    prelock_not_evaluated "YODA_SOURCE_IDENTITY_MISMATCH"

echo "YODA_AUTHORITY=PASS"

section "2. A2-R0 CAPACITY PREFLIGHT AUTHORITY"

test -f "$PREFLIGHT_CONSOLE" ||
    prelock_not_evaluated "A2_R0_CONSOLE_MISSING"

test "$(sha "$PREFLIGHT_CONSOLE")" = "$EXPECTED_PREFLIGHT_CONSOLE_SHA256" ||
    prelock_not_evaluated "A2_R0_CONSOLE_IDENTITY_MISMATCH"

test -f "$PREFLIGHT_EVIDENCE/PRECHECK-SHA256SUMS" ||
    prelock_not_evaluated "A2_R0_MANIFEST_MISSING"

test "$(sha "$PREFLIGHT_EVIDENCE/PRECHECK-SHA256SUMS")" = "$EXPECTED_PREFLIGHT_MANIFEST_SHA256" ||
    prelock_not_evaluated "A2_R0_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$PREFLIGHT"
    sha256sum -c evidence/PRECHECK-SHA256SUMS >/dev/null
) || prelock_not_evaluated "A2_R0_EVIDENCE_INTEGRITY_FAILURE"

test -f "$CANDIDATE/SHA256SUMS" ||
    prelock_not_evaluated "A2_CANDIDATE_MANIFEST_MISSING"

test "$(sha "$CANDIDATE/SHA256SUMS")" = "$EXPECTED_CANDIDATE_MANIFEST_SHA256" ||
    prelock_not_evaluated "A2_CANDIDATE_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$CANDIDATE"
    sha256sum -c SHA256SUMS >/dev/null
) || prelock_not_evaluated "A2_CANDIDATE_INTEGRITY_FAILURE"

grep -F "A2_R0_CAPACITY_PREFLIGHT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_not_evaluated "A2_R0_PASS_AUTHORITY_MISSING"

grep -F "YODA_WRITES=ZERO" "$PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_not_evaluated "A2_R0_WRITE_BOUNDARY_MISSING"

echo "A2_R0_PREFLIGHT_AUTHORITY=PASS"
echo "CANDIDATE_BUNDLE_AUTHORITY=PASS"

section "3. CAPACITY CONTRACT AUTHORITY"

test "$(summary_value YODA_TERMS_SLOTS)" = "4096" ||
    prelock_not_evaluated "YODA_TERMS_CAPACITY_MISMATCH"

test "$(summary_value CANDIDATE_OBJECT_COUNT)" = "$EXPECTED_OBJECT_COUNT" ||
    prelock_not_evaluated "CANDIDATE_OBJECT_COUNT_MISMATCH"

test "$(summary_value CANDIDATE_RELATION_COUNT)" = "$EXPECTED_RELATION_COUNT" ||
    prelock_not_evaluated "CANDIDATE_RELATION_COUNT_MISMATCH"

test "$(summary_value CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND)" = "$EXPECTED_TERM_UPPER_BOUND" ||
    prelock_not_evaluated "TERM_UPPER_BOUND_MISMATCH"

test "$(summary_value CONSERVATIVE_TERM_LOAD_BPS)" = "$EXPECTED_TERM_LOAD_BPS" ||
    prelock_not_evaluated "TERM_LOAD_MISMATCH"

test "$(summary_value CAPACITY_SAFETY_LIMIT_BPS)" = "$EXPECTED_CAPACITY_LIMIT_BPS" ||
    prelock_not_evaluated "CAPACITY_LIMIT_MISMATCH"

test "$(summary_value TERM_CAPACITY_MARGIN)" = "PASS" ||
    prelock_not_evaluated "TERM_CAPACITY_MARGIN_NOT_PASS"

test "$(summary_value REPLAY_COMPLETENESS_STATIC_AUDIT)" = "PASS" ||
    prelock_not_evaluated "REPLAY_COMPLETENESS_AUTHORITY_NOT_PASS"

echo "YODA_TERMS_SLOTS=4096"
echo "CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND=$EXPECTED_TERM_UPPER_BOUND"
echo "CONSERVATIVE_TERM_LOAD_BPS=$EXPECTED_TERM_LOAD_BPS"
echo "CAPACITY_SAFETY_LIMIT_BPS=$EXPECTED_CAPACITY_LIMIT_BPS"
echo "TERM_CAPACITY_MARGIN=PASS"
echo "REPLAY_COMPLETENESS_STATIC_AUDIT=PASS"

section "4. A0 + A1 SCIENTIFIC AUTHORITY"

A0_LOCK="$ROOT/.stage-a0-r1-freeze-started"
A1_LOCK="$ROOT/.stage-a1-r1-execution-started"
A0_MANIFEST="$ROOT/stage-a0-r1/evidence/SHA256SUMS"
A1_MANIFEST="$ROOT/stage-a1-r1/evidence/SHA256SUMS"

test -f "$A0_LOCK" ||
    prelock_not_evaluated "A0_LOCK_MISSING"

test "$(sha "$A0_LOCK")" = "$EXPECTED_A0_LOCK_SHA256" ||
    prelock_not_evaluated "A0_LOCK_IDENTITY_MISMATCH"

test -f "$A0_MANIFEST" ||
    prelock_not_evaluated "A0_MANIFEST_MISSING"

test "$(sha "$A0_MANIFEST")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    prelock_not_evaluated "A0_MANIFEST_IDENTITY_MISMATCH"

test -f "$A1_LOCK" ||
    prelock_not_evaluated "A1_LOCK_MISSING"

test "$(sha "$A1_LOCK")" = "$EXPECTED_A1_LOCK_SHA256" ||
    prelock_not_evaluated "A1_LOCK_IDENTITY_MISMATCH"

test -f "$A1_MANIFEST" ||
    prelock_not_evaluated "A1_MANIFEST_MISSING"

test "$(sha "$A1_MANIFEST")" = "$EXPECTED_A1_MANIFEST_SHA256" ||
    prelock_not_evaluated "A1_MANIFEST_IDENTITY_MISMATCH"

test "$(sha "$CANDIDATE/derivation-A.ndjson")" = "$EXPECTED_LINEAGE_A_SHA256" ||
    prelock_not_evaluated "LINEAGE_A_IDENTITY_MISMATCH"

test "$(sha "$CANDIDATE/derivation-B.ndjson")" = "$EXPECTED_LINEAGE_B_SHA256" ||
    prelock_not_evaluated "LINEAGE_B_IDENTITY_MISMATCH"

jq -e \
    --arg db "$EXPECTED_FINAL_DB_HASH" '
    .scientific_pass == true
    and .trajectory_A.live_agent_db_hash == $db
    and .trajectory_B.live_agent_db_hash == $db
    and .trajectory_A.lineage_sha256 != .trajectory_B.lineage_sha256
' "$CANDIDATE/outcome-equivalence.json" >/dev/null ||
    prelock_not_evaluated "A1_OUTCOME_EQUIVALENCE_MISMATCH"

echo "A0_AUTHORITY=PASS"
echo "A1_AUTHORITY=PASS"
echo "OUTCOME_EQUIVALENCE_AUTHORITY=PASS"
echo "DERIVATION_DISTINCTNESS_AUTHORITY=PASS"

section "5. EXACT CANDIDATE MAP"

OBJECT_COUNT="$(
    awk -F '\t' '
        NR > 1 && NF {
            count++
        }
        END {
            print count+0
        }
    ' "$CANDIDATE/object-map.tsv"
)"

RELATION_COUNT="$(
    awk -F '\t' '
        NR > 1 && NF {
            count++
        }
        END {
            print count+0
        }
    ' "$CANDIDATE/relation-map.tsv"
)"

test "$OBJECT_COUNT" -eq "$EXPECTED_OBJECT_COUNT" ||
    prelock_not_evaluated "OBJECT_MAP_COUNT_MISMATCH"

test "$RELATION_COUNT" -eq "$EXPECTED_RELATION_COUNT" ||
    prelock_not_evaluated "RELATION_MAP_COUNT_MISMATCH"

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    test -n "$key" ||
        prelock_not_evaluated "OBJECT_MAP_EMPTY_KEY"

    test -n "$file" ||
        prelock_not_evaluated "OBJECT_MAP_EMPTY_FILE"

    test -n "$type" ||
        prelock_not_evaluated "OBJECT_MAP_EMPTY_TYPE"

    test -f "$CANDIDATE/$file" ||
        prelock_not_evaluated "OBJECT_MAP_SOURCE_MISSING"

done < "$CANDIDATE/object-map.tsv"

while IFS="$(printf '\t')" read -r from relation to
do
    test "$from" = "from" && continue

    test -n "$from" ||
        prelock_not_evaluated "RELATION_MAP_EMPTY_FROM"

    test -n "$relation" ||
        prelock_not_evaluated "RELATION_MAP_EMPTY_RELATION"

    test -n "$to" ||
        prelock_not_evaluated "RELATION_MAP_EMPTY_TO"

done < "$CANDIDATE/relation-map.tsv"

echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "RELATION_COUNT=$RELATION_COUNT"
echo "EXACT_CANDIDATE_MAP=PASS"

section "6. ONE-EXECUTION SCIENTIFIC GATE"

cat > "$EXECUTION_LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
YODA_SHA256=$ACTUAL_YODA_SHA256
YODA_SOURCE_SHA256=$ACTUAL_YODA_SOURCE_SHA256
A2_R0_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256
A2_R0_EVIDENCE_MANIFEST_SHA256=$EXPECTED_PREFLIGHT_MANIFEST_SHA256
CANDIDATE_MANIFEST_SHA256=$EXPECTED_CANDIDATE_MANIFEST_SHA256
A0_LOCK_SHA256=$EXPECTED_A0_LOCK_SHA256
A0_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
A1_LOCK_SHA256=$EXPECTED_A1_LOCK_SHA256
A1_MANIFEST_SHA256=$EXPECTED_A1_MANIFEST_SHA256
OBJECT_COUNT=$OBJECT_COUNT
RELATION_COUNT=$RELATION_COUNT
CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND=$EXPECTED_TERM_UPPER_BOUND
CONSERVATIVE_TERM_LOAD_BPS=$EXPECTED_TERM_LOAD_BPS
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_YODA_WRITE=YES
EOF

test -f "$EXECUTION_LOCK" ||
    prelock_not_evaluated "A2_EXECUTION_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A2_EXECUTION_LOCK_SHA256=$(sha "$EXECUTION_LOCK")"
echo "A2_EXECUTION_GATE=PASS"

mkdir -p \
    "$OBJECTS" \
    "$MAPS" \
    "$RECOVERED" \
    "$RELATION_LOGS" \
    "$EVIDENCE" ||
    postlock_not_evaluated "A2_STAGE_MATERIALIZATION_FAILURE"

cp "$CANDIDATE/object-map.tsv" "$MAPS/object-map.tsv" ||
    postlock_not_evaluated "A2_STAGE_MATERIALIZATION_FAILURE"

cp "$CANDIDATE/relation-map.tsv" "$MAPS/relation-map.tsv" ||
    postlock_not_evaluated "A2_STAGE_MATERIALIZATION_FAILURE"

cp "$CANDIDATE/SHA256SUMS" "$EVIDENCE/candidate-SHA256SUMS" ||
    postlock_not_evaluated "A2_STAGE_MATERIALIZATION_FAILURE"

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    cp "$CANDIDATE/$file" "$OBJECTS/$file" ||
        postlock_not_evaluated "A2_STAGE_MATERIALIZATION_FAILURE"

done < "$CANDIDATE/object-map.tsv"

section "7. INITIALIZE FRESH YODA STORE"

"$YODA" init "$STORE" >/dev/null ||
    fail "YODA_INIT_FAILURE"

echo "YODA_INIT=PASS"

section "8. STORE EXACT 10-OBJECT CANDIDATE"

INGESTED=0

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    put_file \
        "$key" \
        "$OBJECTS/$file" \
        "$type" ||
        fail "YODA_OBJECT_PERSISTENCE_FAILURE"

    INGESTED=$((INGESTED + 1))

done < "$MAPS/object-map.tsv"

test "$INGESTED" -eq "$EXPECTED_OBJECT_COUNT" ||
    fail "YODA_OBJECT_COUNT_MISMATCH"

echo "YODA_OBJECT_INGEST=PASS"
echo "OBJECT_COUNT=$INGESTED"

section "9. CREATE EXACT 14-RELATION LINEAGE"

LINKED=0

while IFS="$(printf '\t')" read -r from relation to
do
    test "$from" = "from" && continue

    link_relation \
        "$from" \
        "$relation" \
        "$to" ||
        fail "YODA_RELATION_PERSISTENCE_FAILURE"

    LINKED=$((LINKED + 1))

done < "$MAPS/relation-map.tsv"

test "$LINKED" -eq "$EXPECTED_RELATION_COUNT" ||
    fail "YODA_RELATION_COUNT_MISMATCH"

echo "YODA_RELATION_INGEST=PASS"
echo "RELATION_COUNT=$LINKED"

section "10. VERIFY YODA STORE"

"$YODA" -d "$STORE" verify \
    > "$EVIDENCE/yoda-verify.txt" \
    2>&1 ||
    fail "YODA_VERIFY_FAILURE"

echo "YODA_VERIFY=PASS"

section "11. BYTE-EXACT OBJECT RECOVERY"

RECOVERED_COUNT=0

while IFS="$(printf '\t')" read -r key file type
do
    test "$key" = "key" && continue

    "$YODA" -d "$STORE" get "$key" \
        > "$RECOVERED/$file" ||
        fail "YODA_OBJECT_RECOVERY_FAILURE"

    cmp -s \
        "$OBJECTS/$file" \
        "$RECOVERED/$file" ||
        fail "YODA_BYTE_EXACT_RECOVERY_FAILURE"

    RECOVERED_COUNT=$((RECOVERED_COUNT + 1))

done < "$MAPS/object-map.tsv"

test "$RECOVERED_COUNT" -eq "$EXPECTED_OBJECT_COUNT" ||
    fail "YODA_RECOVERY_COUNT_MISMATCH"

test "$(sha "$RECOVERED/derivation-A.ndjson")" = "$EXPECTED_LINEAGE_A_SHA256" ||
    fail "RECOVERED_LINEAGE_A_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/derivation-B.ndjson")" = "$EXPECTED_LINEAGE_B_SHA256" ||
    fail "RECOVERED_LINEAGE_B_IDENTITY_MISMATCH"

echo "BYTE_EXACT_OBJECT_RECOVERY=PASS"
echo "RECOVERED_OBJECT_COUNT=$RECOVERED_COUNT"
echo "DERIVATION_A_RECOVERY=PASS"
echo "DERIVATION_B_RECOVERY=PASS"

section "12. COMPLETE RELATION RECOVERY"

TAB="$(printf '\t')"
RELATION_RECOVERED_COUNT=0
RELATION_ORDINAL=0

while IFS="$(printf '\t')" read -r from relation to
do
    test "$from" = "from" && continue

    RELATION_ORDINAL=$((RELATION_ORDINAL + 1))

    log_file="$RELATION_LOGS/relation-$RELATION_ORDINAL.log"

    "$YODA" -d "$STORE" log "$from" \
        > "$log_file" ||
        fail "YODA_RELATION_LOG_FAILURE"

    grep -F "$relation$TAB$to" "$log_file" \
        >/dev/null ||
        fail "YODA_RELATION_RECOVERY_FAILURE"

    RELATION_RECOVERED_COUNT=$((RELATION_RECOVERED_COUNT + 1))

done < "$MAPS/relation-map.tsv"

test "$RELATION_RECOVERED_COUNT" -eq "$EXPECTED_RELATION_COUNT" ||
    fail "YODA_RELATION_RECOVERY_COUNT_MISMATCH"

echo "RELATION_RECOVERY=PASS"
echo "RECOVERED_RELATION_COUNT=$RELATION_RECOVERED_COUNT"

section "13. RECOVER DUAL-DERIVATION SEMANTICS"

"$YODA" -d "$STORE" log "derivation/A" \
    > "$EVIDENCE/log-derivation-A.txt" ||
    fail "YODA_SEMANTIC_RECOVERY_FAILURE"

"$YODA" -d "$STORE" log "derivation/B" \
    > "$EVIDENCE/log-derivation-B.txt" ||
    fail "YODA_SEMANTIC_RECOVERY_FAILURE"

"$YODA" -d "$STORE" log "outcome/A" \
    > "$EVIDENCE/log-outcome-A.txt" ||
    fail "YODA_SEMANTIC_RECOVERY_FAILURE"

"$YODA" -d "$STORE" log "outcome/B" \
    > "$EVIDENCE/log-outcome-B.txt" ||
    fail "YODA_SEMANTIC_RECOVERY_FAILURE"

"$YODA" -d "$STORE" log "outcome/equivalence" \
    > "$EVIDENCE/log-outcome-equivalence.txt" ||
    fail "YODA_SEMANTIC_RECOVERY_FAILURE"

grep -F "$(printf 'derivation-of\tbenchmark/task/7')" \
    "$EVIDENCE/log-derivation-A.txt" >/dev/null ||
    fail "DERIVATION_A_TASK_RELATION_MISSING"

grep -F "$(printf 'derivation-of\tbenchmark/task/7')" \
    "$EVIDENCE/log-derivation-B.txt" >/dev/null ||
    fail "DERIVATION_B_TASK_RELATION_MISSING"

grep -F "$(printf 'alternative-to\tderivation/A')" \
    "$EVIDENCE/log-derivation-B.txt" >/dev/null ||
    fail "ALTERNATIVE_RELATION_MISSING"

grep -F "$(printf 'produced-by\tderivation/A')" \
    "$EVIDENCE/log-outcome-A.txt" >/dev/null ||
    fail "OUTCOME_A_DERIVATION_RELATION_MISSING"

grep -F "$(printf 'produced-by\tderivation/B')" \
    "$EVIDENCE/log-outcome-B.txt" >/dev/null ||
    fail "OUTCOME_B_DERIVATION_RELATION_MISSING"

grep -F "$(printf 'compares\toutcome/A')" \
    "$EVIDENCE/log-outcome-equivalence.txt" >/dev/null ||
    fail "OUTCOME_EQUIVALENCE_A_RELATION_MISSING"

grep -F "$(printf 'compares\toutcome/B')" \
    "$EVIDENCE/log-outcome-equivalence.txt" >/dev/null ||
    fail "OUTCOME_EQUIVALENCE_B_RELATION_MISSING"

jq -e \
    --arg db "$EXPECTED_FINAL_DB_HASH" '
    .scientific_pass == true
    and .trajectory_A.final_reward == 1.0
    and .trajectory_B.final_reward == 1.0
    and .trajectory_A.live_agent_db_hash == $db
    and .trajectory_B.live_agent_db_hash == $db
    and .trajectory_A.lineage_sha256 != .trajectory_B.lineage_sha256
' "$RECOVERED/outcome-equivalence.json" >/dev/null ||
    fail "RECOVERED_OUTCOME_EQUIVALENCE_SEMANTICS_MISMATCH"

echo "DERIVATION_A_TASK_LINEAGE=PASS"
echo "DERIVATION_B_TASK_LINEAGE=PASS"
echo "ALTERNATIVE_DERIVATION_RELATION=PASS"
echo "OUTCOME_A_DERIVATION_LINEAGE=PASS"
echo "OUTCOME_B_DERIVATION_LINEAGE=PASS"
echo "OUTCOME_EQUIVALENCE_RELATIONS=PASS"
echo "OUTCOME_EQUIVALENCE_SEMANTICS=PASS"
echo "DUAL_DERIVATION_LINEAGE_RECOVERY=PASS"

section "14. FINAL VERIFY + FROZEN STORE IDENTITY"

"$YODA" -d "$STORE" verify \
    > "$EVIDENCE/yoda-final-verify.txt" \
    2>&1 ||
    fail "FINAL_YODA_VERIFY_FAILURE"

test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "YODA_BINARY_IDENTITY_CHANGED"

test "$(sha "$YODA_SOURCE")" = "$EXPECTED_YODA_SOURCE_SHA256" ||
    fail "YODA_SOURCE_IDENTITY_CHANGED"

DATA_YODA="$STORE/data.yoda"

test -f "$DATA_YODA" ||
    fail "DATA_YODA_MISSING"

DATA_YODA_SHA256="$(sha "$DATA_YODA")"
DATA_YODA_BYTES="$(
    wc -c < "$DATA_YODA" |
    awk '{print $1}'
)"

echo "FINAL_YODA_VERIFY=PASS"
echo "YODA_BINARY_IDENTITY_UNCHANGED=PASS"
echo "YODA_SOURCE_IDENTITY_UNCHANGED=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "DATA_YODA_BYTES=$DATA_YODA_BYTES"

section "15. FREEZE A2 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
YODA_SHA256	$ACTUAL_YODA_SHA256
YODA_SOURCE_SHA256	$ACTUAL_YODA_SOURCE_SHA256
A2_R0_CONSOLE_SHA256	$EXPECTED_PREFLIGHT_CONSOLE_SHA256
A2_R0_EVIDENCE_MANIFEST_SHA256	$EXPECTED_PREFLIGHT_MANIFEST_SHA256
CANDIDATE_MANIFEST_SHA256	$EXPECTED_CANDIDATE_MANIFEST_SHA256
A0_LOCK_SHA256	$EXPECTED_A0_LOCK_SHA256
A0_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
A1_LOCK_SHA256	$EXPECTED_A1_LOCK_SHA256
A1_MANIFEST_SHA256	$EXPECTED_A1_MANIFEST_SHA256
OBJECT_COUNT	$INGESTED
RELATION_COUNT	$LINKED
RECOVERED_OBJECT_COUNT	$RECOVERED_COUNT
RECOVERED_RELATION_COUNT	$RELATION_RECOVERED_COUNT
CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND	$EXPECTED_TERM_UPPER_BOUND
CONSERVATIVE_TERM_LOAD_BPS	$EXPECTED_TERM_LOAD_BPS
FINAL_DB_HASH	$EXPECTED_FINAL_DB_HASH
LINEAGE_A_SHA256	$EXPECTED_LINEAGE_A_SHA256
LINEAGE_B_SHA256	$EXPECTED_LINEAGE_B_SHA256
BYTE_EXACT_OBJECT_RECOVERY	PASS
RELATION_RECOVERY	PASS
DUAL_DERIVATION_LINEAGE_RECOVERY	PASS
OUTCOME_EQUIVALENCE_SEMANTICS	PASS
FINAL_YODA_VERIFY	PASS
DATA_YODA_SHA256	$DATA_YODA_SHA256
DATA_YODA_BYTES	$DATA_YODA_BYTES
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-a2-r1-script.sh" ||
    postlock_not_evaluated "A2_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$EXECUTION_LOCK" "$EVIDENCE/execution-started.txt" ||
    postlock_not_evaluated "A2_EVIDENCE_MATERIALIZATION_FAILURE"

freeze_manifest ||
    postlock_not_evaluated "A2_EVIDENCE_INTEGRITY_FAILURE"

A2_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A2_EVIDENCE_INTEGRITY=PASS"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"

section "16. A2 HOMOLOGATION"

echo "TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A2=PASS"
echo "A2_REVISION=$REVISION"
echo "OBJECT_COUNT=$INGESTED"
echo "RELATION_COUNT=$LINKED"
echo "BYTE_EXACT_OBJECT_RECOVERY=PASS"
echo "RELATION_RECOVERY=PASS"
echo "DERIVATION_A_RECOVERY=PASS"
echo "DERIVATION_B_RECOVERY=PASS"
echo "OUTCOME_EQUIVALENCE_RECOVERY=PASS"
echo "DUAL_DERIVATION_LINEAGE_RECOVERY=PASS"
echo "FINAL_YODA_VERIFY=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=B_INDEPENDENT_DUAL_DERIVATION_REPLAY"
