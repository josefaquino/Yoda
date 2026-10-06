#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
ROOT="$HOME/cmu/$CASE"
A0="$ROOT/stage-a0-r1"
A1="$ROOT/stage-a1-r1"
LOCK="$ROOT/.stage-a1-r1-execution-started"

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
echo "AUTHORITY_1_EXECUTED=NO"
echo "AUTHORITY_2_EXECUTED=NO"
echo "CLASSIFICATION_COMPUTED=NO"
echo "YODA_WRITES=ZERO"

if test -f "$LOCK"
then
    echo "A1_R1_EXECUTION_LOCK=CONSUMED"
    echo "A1_R1_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
else
    echo "A1_R1_EXECUTION_LOCK=ABSENT"
fi

section "1. A0 SNAPSHOT IDENTITIES"

for state in A B C
do
    f="$A0/snapshots/state-$state.tsv"

    if test -f "$f"
    then
        echo "STATE_\${state}_SNAPSHOT=FOUND"
        echo "STATE_\${state}_SNAPSHOT_SHA256=$(sha "$f")"
        echo "STATE_\${state}_SNAPSHOT_LINES=$(wc -l < "$f" | tr -d ' ')"
    else
        echo "STATE_\${state}_SNAPSHOT=NOT_FOUND"
    fi
done

section "2. SNAPSHOT CONTENT"

for state in A B C
do
    f="$A0/snapshots/state-$state.tsv"

    echo "--- STATE $state ---"
    if test -f "$f"
    then
        nl -ba "$f"
    fi
done

section "3. HEADER AND FIELD SHAPE"

EXPECTED_HEADER="$(printf 'evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits')"

for state in A B C
do
    f="$A0/snapshots/state-$state.tsv"

    header="$(sed -n '1p' "$f" | tr -d '\r\n')"

    if test "$header" = "$EXPECTED_HEADER"
    then
        echo "STATE_\${state}_HEADER=PASS"
    else
        echo "STATE_\${state}_HEADER=FAIL"
    fi

    awk -F '\t' -v state="$state" '
        NR > 1 {
            printf "STATE_%s_ROW_%d_FIELDS=%d\n", state, NR - 1, NF
        }
    ' "$f"
done

section "4. VALUE FORMAT ONLY - NO THRESHOLD COMPARISON"

for state in A B C
do
    f="$A0/snapshots/state-$state.tsv"

    awk -F '\t' -v state="$state" '
        NR > 1 {
            raw = $5
            s = raw
            if (substr(s,1,1) == "+" || substr(s,1,1) == "-")
                s = substr(s,2)
            n = split(s, parts, ".")
            frac = (n == 2 ? length(parts[2]) : 0)
            numeric_shape = (s ~ /^[0-9]+([.][0-9]+)?$/ ? "PASS" : "FAIL")
            fixed4_contract = (numeric_shape == "PASS" && frac <= 4 ? "PASS" : "FAIL")
            printf "STATE_%s_SERIES_%s_RAW_VALUE=%s\n", state, $2, raw
            printf "STATE_%s_SERIES_%s_FRACTION_DIGITS=%d\n", state, $2, frac
            printf "STATE_%s_SERIES_%s_NUMERIC_SHAPE=%s\n", state, $2, numeric_shape
            printf "STATE_%s_SERIES_%s_FIXED4_INPUT_CONTRACT=%s\n", state, $2, fixed4_contract
        }
    ' "$f"
done

section "5. SERIES AND UNIT CONTRACT ONLY"

for state in A B C
do
    f="$A0/snapshots/state-$state.tsv"

    awk -F '\t' -v state="$state" '
        NR > 1 {
            status = "PASS"
            if ($2 == "DGS10" && $6 != "percent")
                status = "FAIL"
            else if (($2 == "NFCI" || $2 == "VIXCLS") && $6 != "index")
                status = "FAIL"
            else if ($2 != "DGS10" && $2 != "NFCI" && $2 != "VIXCLS")
                status = "FAIL"
            printf "STATE_%s_SERIES_%s_UNIT_CONTRACT=%s\n", state, $2, status
        }
    ' "$f"
done

section "6. PARTIAL A1 ARTIFACTS"

for f in \
    "$A1/results/authority-1.tsv" \
    "$A1/results/authority-2.tsv" \
    "$A1/results/canonical-results.tsv" \
    "$A1/evidence/summary.tsv" \
    "$A1/evidence/SHA256SUMS"
do
    if test -f "$f"
    then
        echo "FILE_FOUND=$f"
        echo "FILE_SHA256=$(sha "$f")"
        echo "FILE_LINES=$(wc -l < "$f" | tr -d ' ')"
        cat "$f"
    else
        echo "FILE_NOT_FOUND=$f"
    fi
done

section "7. AUTHORITY 1 ARTIFACT IDENTITY"

if test -f "$A1/authorities/authority-1-c11.c"
then
    echo "AUTHORITY_1_SOURCE_SHA256=$(sha "$A1/authorities/authority-1-c11.c")"
fi

if test -f "$A1/authorities/authority-1-c11"
then
    echo "AUTHORITY_1_BINARY_SHA256=$(sha "$A1/authorities/authority-1-c11")"
fi

section "8. ROOT-CAUSE SIGNAL"

OUTSIDE_FIXED4="$(
    for state in A B C
    do
        awk -F '\t' '
            NR > 1 {
                s = $5
                if (substr(s,1,1) == "+" || substr(s,1,1) == "-")
                    s = substr(s,2)
                n = split(s, p, ".")
                frac = (n == 2 ? length(p[2]) : 0)
                if (s !~ /^[0-9]+([.][0-9]+)?$/ || frac > 4)
                    bad++
            }
            END { print bad + 0 }
        ' "$A0/snapshots/state-$state.tsv"
    done |
    awk '{ total += $1 } END { print total + 0 }'
)"

echo "FIXED4_INPUT_CONTRACT_VIOLATION_COUNT=$OUTSIDE_FIXED4"

if test "$OUTSIDE_FIXED4" -gt 0
then
    echo "ROOT_CAUSE_SIGNAL=FROZEN_INPUT_PRECISION_OUTSIDE_AUTHORITY_1_FIXED4_PARSER"
else
    echo "ROOT_CAUSE_SIGNAL=FIXED4_INPUT_CONTRACT_NOT_DISPROVEN"
fi

echo "A1_R1_RERUN=NO"
echo "READ_ONLY_ROOT_CAUSE_DIAGNOSTIC=COMPLETE"
