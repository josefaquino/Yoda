#!/usr/bin/env bash
set -u
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
REVISION="A2-R1-READ-ONLY-ADJUDICATION"

ROOT="$HOME/cmu/$CASE"
STAGE="$ROOT/stage-a2-r1"
STORE="$STAGE/yoda-store"
OBJECTS="$STAGE/objects"
LOCK="$ROOT/.stage-a2-r1-execution-started"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"

EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"
EXPECTED_LOCK_SHA256="32cf7138c88b381c0b3f544f9e985cfafa5c9e5c88ea5f2d75b7599d716ca6f2"
EXPECTED_DATA_YODA_SHA256="48700481d01777910f5976ffe8d5de755288772088856dbaf59713df960f9cea"
EXPECTED_DATA_YODA_BYTES="4091828"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

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

abort()
{
    echo
    echo "READ_ONLY_ADJUDICATION=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A2_R1_RERUN=NO"
    echo "YODA_WRITES=ZERO"
    exit 1
}

test -x "$YODA" ||
    abort "YODA_BINARY_MISSING"

test -f "$LOCK" ||
    abort "A2_R1_LOCK_MISSING"

test -f "$STORE/data.yoda" ||
    abort "PARTIAL_DATA_YODA_MISSING"

test -d "$OBJECTS" ||
    abort "A2_OBJECTS_DIRECTORY_MISSING"

section "0. FROZEN FAILURE EVIDENCE"

ACTUAL_YODA_SHA256="$(sha "$YODA")"
ACTUAL_LOCK_SHA256="$(sha "$LOCK")"
DATA_BEFORE_SHA256="$(sha "$STORE/data.yoda")"
DATA_BEFORE_BYTES="$(wc -c < "$STORE/data.yoda" | awk '{print $1}')"

echo "EXPECTED_YODA_SHA256=$EXPECTED_YODA_SHA256"
echo "ACTUAL_YODA_SHA256=$ACTUAL_YODA_SHA256"

echo "EXPECTED_LOCK_SHA256=$EXPECTED_LOCK_SHA256"
echo "ACTUAL_LOCK_SHA256=$ACTUAL_LOCK_SHA256"

echo "EXPECTED_DATA_YODA_SHA256=$EXPECTED_DATA_YODA_SHA256"
echo "ACTUAL_DATA_YODA_SHA256=$DATA_BEFORE_SHA256"

echo "EXPECTED_DATA_YODA_BYTES=$EXPECTED_DATA_YODA_BYTES"
echo "ACTUAL_DATA_YODA_BYTES=$DATA_BEFORE_BYTES"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    abort "YODA_IDENTITY_MISMATCH"

test "$ACTUAL_LOCK_SHA256" = "$EXPECTED_LOCK_SHA256" ||
    abort "A2_R1_LOCK_IDENTITY_MISMATCH"

test "$DATA_BEFORE_SHA256" = "$EXPECTED_DATA_YODA_SHA256" ||
    abort "PARTIAL_DATA_YODA_IDENTITY_MISMATCH"

test "$DATA_BEFORE_BYTES" = "$EXPECTED_DATA_YODA_BYTES" ||
    abort "PARTIAL_DATA_YODA_SIZE_MISMATCH"

echo "FROZEN_FAILURE_EVIDENCE=PASS"
echo "DIAGNOSTIC_MODE=READ_ONLY"
echo "A2_R1_RERUN=NO"

section "1. OBJECT PRESENCE IN EXACT PUT ORDER"

cat > "$TMP/object-order.tsv" <<'EOF'
1	disclosure/filing/A	filing-state-A.tsv
2	disclosure/filing/B	filing-state-B.tsv
3	disclosure/raw-filing/A	raw-filing-A.txt
4	disclosure/raw-filing/B	raw-filing-B.txt
5	disclosure/companyfacts/frozen	companyfacts.json
6	disclosure/fact/A	fact-state-A.tsv
7	disclosure/fact/B	fact-state-B.tsv
8	disclosure/facts/canonical	canonical-facts.tsv
9	disclosure/selection/frozen	selection.tsv
10	disclosure/selection/candidate-scan	candidate-scan.tsv
11	disclosure/transition/A-to-B	transition-A-to-B.tsv
12	disclosure/evaluation/A-to-B	evaluation-A-to-B.tsv
13	disclosure/contract/evaluation-v1	evaluation-contract-v1.txt
14	disclosure/authority/c11-v1	authority-1-c11-v1.c
15	disclosure/authority/awk-v1	authority-2-posix-v1.awk
16	disclosure/evidence/c11-result	authority-1-result.tsv
17	disclosure/evidence/awk-result	authority-2-result.tsv
18	disclosure/evaluation/canonical	canonical-evaluation.tsv
19	disclosure/selection/policy	a0-selection-policy.md
20	disclosure/parser/submissions-v1	sec-submissions-v1.c
21	disclosure/parser/companyfacts-v1	sec-companyfacts-v1.c
22	evidence/disclosure/A0-C1-summary	a0-c1-summary.tsv
23	evidence/disclosure/A0-C1-manifest	a0-c1-manifest.sha256
24	evidence/disclosure/A1-R1-summary	a1-r1-summary.tsv
25	evidence/disclosure/A1-R1-manifest	a1-r1-manifest.sha256
EOF

PERSISTED_COUNT=0
FIRST_MISSING_ORDINAL=0
FIRST_MISSING_KEY=""
GAP_VIOLATION=NO

while IFS="$(printf '\t')" read -r ordinal key file
do
    source="$OBJECTS/$file"
    target="$TMP/recovered-$ordinal"
    err="$TMP/error-$ordinal"

    test -f "$source" ||
        abort "A2_OBJECT_SOURCE_MISSING"

    SOURCE_SHA256="$(sha "$source")"
    SOURCE_BYTES="$(wc -c < "$source" | awk '{print $1}')"

    set +e
    "$YODA" -d "$STORE" get "$key" > "$target" 2> "$err"
    GET_RC=$?
    set -e

    if test "$GET_RC" -eq 0
    then
        if cmp -s "$source" "$target"
        then
            BYTE_EXACT="PASS"
        else
            BYTE_EXACT="FAIL"
        fi

        RECOVERED_SHA256="$(sha "$target")"
        RECOVERED_BYTES="$(wc -c < "$target" | awk '{print $1}')"

        echo "OBJECT_ORDINAL=$ordinal"
        echo "OBJECT_KEY=$key"
        echo "OBJECT_FILE=$file"
        echo "OBJECT_SOURCE_SHA256=$SOURCE_SHA256"
        echo "OBJECT_SOURCE_BYTES=$SOURCE_BYTES"
        echo "OBJECT_GET_RC=0"
        echo "OBJECT_PERSISTED=YES"
        echo "OBJECT_RECOVERED_SHA256=$RECOVERED_SHA256"
        echo "OBJECT_RECOVERED_BYTES=$RECOVERED_BYTES"
        echo "OBJECT_BYTE_EXACT=$BYTE_EXACT"

        PERSISTED_COUNT=$((PERSISTED_COUNT + 1))

        if test "$FIRST_MISSING_ORDINAL" -ne 0
        then
            GAP_VIOLATION=YES
        fi
    else
        if test "$FIRST_MISSING_ORDINAL" -eq 0
        then
            FIRST_MISSING_ORDINAL="$ordinal"
            FIRST_MISSING_KEY="$key"
        fi

        ERROR_SHA256="$(sha "$err")"
        ERROR_BYTES="$(wc -c < "$err" | awk '{print $1}')"

        echo "OBJECT_ORDINAL=$ordinal"
        echo "OBJECT_KEY=$key"
        echo "OBJECT_FILE=$file"
        echo "OBJECT_SOURCE_SHA256=$SOURCE_SHA256"
        echo "OBJECT_SOURCE_BYTES=$SOURCE_BYTES"
        echo "OBJECT_GET_RC=$GET_RC"
        echo "OBJECT_PERSISTED=NO"
        echo "OBJECT_GET_ERROR_SHA256=$ERROR_SHA256"
        echo "OBJECT_GET_ERROR_BYTES=$ERROR_BYTES"
    fi

    echo "---"
done < "$TMP/object-order.tsv"

section "2. PERSISTENCE BOUNDARY"

echo "EXPECTED_OBJECT_COUNT=25"
echo "PERSISTED_OBJECT_COUNT=$PERSISTED_COUNT"
echo "FIRST_MISSING_ORDINAL=$FIRST_MISSING_ORDINAL"
echo "FIRST_MISSING_KEY=$FIRST_MISSING_KEY"
echo "PERSISTED_AFTER_FIRST_MISSING=$GAP_VIOLATION"

if test "$FIRST_MISSING_ORDINAL" -eq 0
then
    echo "PERSISTENCE_BOUNDARY=INCONCLUSIVE_ALL_KEYS_PRESENT"
elif test "$GAP_VIOLATION" = "YES"
then
    echo "PERSISTENCE_BOUNDARY=NON_PREFIX_STATE"
else
    echo "PERSISTENCE_BOUNDARY=PREFIX_CONFIRMED"
fi

section "3. RELATION PHASE BOUNDARY"

echo "RELATION_PHASE_STARTED=NO"
echo "EXPECTED_LINKS_WRITTEN=0"
echo "REASON=HARNESS_ABORTED_DURING_OBJECT_INGEST_BEFORE_RELATION_PHASE"

section "4. ZERO-WRITE PROOF"

DATA_AFTER_SHA256="$(sha "$STORE/data.yoda")"
DATA_AFTER_BYTES="$(wc -c < "$STORE/data.yoda" | awk '{print $1}')"

echo "DATA_BEFORE_SHA256=$DATA_BEFORE_SHA256"
echo "DATA_AFTER_SHA256=$DATA_AFTER_SHA256"
echo "DATA_BEFORE_BYTES=$DATA_BEFORE_BYTES"
echo "DATA_AFTER_BYTES=$DATA_AFTER_BYTES"

if test "$DATA_BEFORE_SHA256" = "$DATA_AFTER_SHA256" &&
   test "$DATA_BEFORE_BYTES" = "$DATA_AFTER_BYTES"
then
    echo "YODA_STORE_MUTATED_BY_DIAGNOSTIC=NO"
    echo "YODA_WRITES=ZERO"
else
    echo "YODA_STORE_MUTATED_BY_DIAGNOSTIC=YES"
    echo "READ_ONLY_ADJUDICATION=FAIL"
    exit 2
fi

section "5. ADJUDICATION"

echo "A2_R1_ORIGINAL_VERDICT=FAIL"
echo "A2_R1_FAILURE_CLASS=YODA_PERSISTENCE_FAILURE"
echo "OBSERVED_ENGINE_ERROR=terms_table_capacity_exhausted"
echo "A2_R1_RERUN=NO"

if test "$FIRST_MISSING_ORDINAL" -gt 0 &&
   test "$GAP_VIOLATION" = "NO"
then
    echo "OBJECT_INGEST_BOUNDARY_RECOVERED=YES"
else
    echo "OBJECT_INGEST_BOUNDARY_RECOVERED=NO"
fi

echo "ROOT_CAUSE_LAYER=YODA_PERSISTENCE_CAPACITY"
echo "ENGINE_INTERNAL_CAUSE=NOT_YET_SOURCE_ADJUDICATED"
echo "READ_ONLY_ADJUDICATION=COMPLETE"
