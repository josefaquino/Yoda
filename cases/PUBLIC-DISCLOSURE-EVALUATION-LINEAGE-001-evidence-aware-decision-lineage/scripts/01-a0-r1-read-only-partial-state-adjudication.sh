#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
ROOT="$HOME/cmu/$CASE"
STAGE="$ROOT/stage-a0-r1"
LOCK="$ROOT/.stage-a0-r1-execution-started"

SELECTION="$STAGE/selection/selection.tsv"
CANONICAL="$STAGE/canonical/canonical-facts.tsv"
EVIDENCE="$STAGE/evidence"
RAW="$STAGE/raw/selected"

EXPECTED_LOCK_SHA256="95143c814b061a68e0857eb508f7b0324bf3eabe755d872c72bc4c257f404b0f"
EXPECTED_SELECTION_SHA256="3bff9ec5b957231543e1c9c6d45dc0d026cf2bd1113660a39056d7ffc25dc85f"

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

section "0. GOVERNANCE"

echo "DIAGNOSTIC_MODE=READ_ONLY"
echo "NETWORK_REQUESTS=ZERO"
echo "PARSER_EXECUTED=NO"
echo "CLASSIFICATION_EXECUTED=NO"
echo "YODA_WRITES=ZERO"
echo "A0_R1_RERUN=NO"

test -f "$LOCK"

ACTUAL_LOCK_SHA256="$(sha "$LOCK")"

echo "A0_R1_EXECUTION_LOCK=CONSUMED"
echo "EXPECTED_LOCK_SHA256=$EXPECTED_LOCK_SHA256"
echo "ACTUAL_LOCK_SHA256=$ACTUAL_LOCK_SHA256"

if test "$ACTUAL_LOCK_SHA256" = "$EXPECTED_LOCK_SHA256"
then
    echo "A0_R1_LOCK_IDENTITY=PASS"
else
    echo "A0_R1_LOCK_IDENTITY=FAIL"
fi

section "1. FROZEN SELECTION"

if test -f "$SELECTION"
then
    echo "SELECTION=FOUND"
    echo "SELECTION_SHA256=$(sha "$SELECTION")"
    echo "SELECTION_LINES=$(wc -l < "$SELECTION" | tr -d ' ')"

    if test "$(sha "$SELECTION")" = "$EXPECTED_SELECTION_SHA256"
    then
        echo "SELECTION_IDENTITY=PASS"
    else
        echo "SELECTION_IDENTITY=FAIL"
    fi

    cat "$SELECTION"
else
    echo "SELECTION=NOT_FOUND"
fi

section "2. PARTIAL CANONICAL OUTPUT"

if test -f "$CANONICAL"
then
    echo "CANONICAL_PARTIAL=FOUND"
    echo "CANONICAL_PARTIAL_SHA256=$(sha "$CANONICAL")"
    echo "CANONICAL_PARTIAL_LINES=$(wc -l < "$CANONICAL" | tr -d ' ')"

    nl -ba "$CANONICAL"

    FIRST_LINE="$(sed -n '1p' "$CANONICAL")"
    SECOND_LINE="$(sed -n '2p' "$CANONICAL")"

    if test "$FIRST_LINE" = "PARSER_STATUS=PASS"
    then
        echo "DIAGNOSTIC_PREAMBLE=CONFIRMED"
    else
        echo "DIAGNOSTIC_PREAMBLE=NOT_CONFIRMED"
    fi

    EXPECTED_HEADER="$(printf 'state\taccession\tform\tconcept\tunit\tstart\tend\tvalue_raw')"

    if test "$SECOND_LINE" = "$EXPECTED_HEADER"
    then
        echo "CANONICAL_HEADER_AFTER_PREAMBLE=PASS"
    else
        echo "CANONICAL_HEADER_AFTER_PREAMBLE=FAIL"
    fi

    echo "CANONICAL_PAYLOAD_LINES_AFTER_PREAMBLE=$(tail -n +2 "$CANONICAL" | wc -l | tr -d ' ')"
    echo "CANONICAL_PAYLOAD_SHA256=$(tail -n +2 "$CANONICAL" | sha256sum | awk '{print $1}')"
else
    echo "CANONICAL_PARTIAL=NOT_FOUND"
fi

section "3. SELECTED RAW ARTIFACTS"

for name in \
    submissions-current.json \
    history-files.txt \
    submissions-all-filings.tsv \
    companyfacts.json \
    original-index.htm \
    amendment-index.htm \
    original-submission.txt \
    amendment-submission.txt
do
    file="$RAW/$name"

    if test -f "$file"
    then
        echo "FILE_FOUND=$name"
        echo "FILE_SHA256=$(sha "$file")"
        echo "FILE_BYTES=$(wc -c < "$file" | tr -d ' ')"
    else
        echo "FILE_NOT_FOUND=$name"
    fi
done

if test -d "$RAW/history"
then
    echo "HISTORY_DIRECTORY=FOUND"
    echo "HISTORY_FILE_COUNT=$(find "$RAW/history" -type f | wc -l | tr -d ' ')"
else
    echo "HISTORY_DIRECTORY=NOT_FOUND"
fi

if test -d "$RAW/concept-checks"
then
    echo "CONCEPT_CHECK_DIRECTORY=FOUND"
    echo "CONCEPT_CHECK_FILE_COUNT=$(find "$RAW/concept-checks" -type f | wc -l | tr -d ' ')"
else
    echo "CONCEPT_CHECK_DIRECTORY=NOT_FOUND"
fi

section "4. PARTIAL EVIDENCE"

for file in \
    "$EVIDENCE/candidate-scan.tsv" \
    "$EVIDENCE/summary.tsv" \
    "$EVIDENCE/SHA256SUMS" \
    "$EVIDENCE/SHA256SUMS.check"
do
    base_name="$(basename "$file")"
    if test -f "$file"
    then
        echo "EVIDENCE_FOUND=$base_name"
        echo "EVIDENCE_SHA256=$(sha "$file")"
        echo "EVIDENCE_LINES=$(wc -l < "$file" | tr -d ' ')"
    else
        echo "EVIDENCE_NOT_FOUND=$base_name"
    fi
done

section "5. ROOT-CAUSE ADJUDICATION"

CANONICAL_LINES="0"
PAYLOAD_LINES="0"
PREAMBLE="NO"
HEADER="NO"

if test -f "$CANONICAL"
then
    CANONICAL_LINES="$(wc -l < "$CANONICAL" | tr -d ' ')"
    PAYLOAD_LINES="$(tail -n +2 "$CANONICAL" | wc -l | tr -d ' ')"

    if test "$(sed -n '1p' "$CANONICAL")" = "PARSER_STATUS=PASS"
    then
        PREAMBLE="YES"
    fi

    if test "$(sed -n '2p' "$CANONICAL")" = "$(printf 'state\taccession\tform\tconcept\tunit\tstart\tend\tvalue_raw')"
    then
        HEADER="YES"
    fi
fi

if test "$CANONICAL_LINES" = "4" &&
   test "$PAYLOAD_LINES" = "3" &&
   test "$PREAMBLE" = "YES" &&
   test "$HEADER" = "YES"
then
    echo "ROOT_CAUSE_SIGNAL=REVEAL_MODE_DIAGNOSTIC_PREAMBLE_VIOLATES_CANONICAL_OUTPUT_SHAPE"
    echo "CANONICAL_PAYLOAD_RECOVERABLE_WITHOUT_RESELECTION=YES"
else
    echo "ROOT_CAUSE_SIGNAL=INCONCLUSIVE"
    echo "CANONICAL_PAYLOAD_RECOVERABLE_WITHOUT_RESELECTION=UNKNOWN"
fi

echo "SELECTED_TUPLE_RESELECTION=FORBIDDEN"
echo "A0_R1_RERUN=NO"
echo "READ_ONLY_ADJUDICATION=COMPLETE"
