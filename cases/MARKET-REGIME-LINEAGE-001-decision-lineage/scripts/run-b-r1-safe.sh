#!/usr/bin/env bash
set -u
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"

SCRIPT="$HOME/cmu/market-regime-lineage-001-stage-b-r1.sh"
CONSOLE="$HOME/cmu/market-regime-lineage-001-stage-b-r1-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-b-r1-execution-started"
STAGE="$ROOT/stage-b-r1"

EXPECTED="0013ed5e832d52436704010c20d43bd7a62a09cfa4b2a354d45f977e0cd24361"
SCRIPT_COMMIT="9fd4c05d2553e0dc2632e5b3373e64d6780efa55"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/MARKET-REGIME-LINEAGE-001-decision-lineage/scripts/05-b-r1-independent-classification-replay.sh"

echo "============================================================"
echo " B-R1 SAFE LAUNCHER"
echo " INDEPENDENT CLASSIFICATION REPLAY / CHILD SHELL"
echo "============================================================"

if test -e "$LOCK"
then
    echo "B_R1_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution policy already consumed"
    exit 20
fi

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 21
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 22
fi

echo "BASH_PARSE=PASS"

ACTUAL="$(sha256sum "$SCRIPT" | awk '{print $1}')"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL"

if test "$ACTUAL" != "$EXPECTED"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 23
fi

echo "SCRIPT_IDENTITY=PASS"
echo "B_R1_EXECUTION_LOCK=ABSENT"

"$SCRIPT" 2>&1 | tee "$CONSOLE"
RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " B-R1 POST-RUN"
echo "============================================================"

echo "B_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "B_R1_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "B_R1_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "B_R1_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "B_R1_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/replay/replay-authority-1.tsv"
then
    echo
    echo "=== REPLAY AUTHORITY 1 ==="
    cat "$STAGE/replay/replay-authority-1.tsv"
fi

if test -f "$STAGE/replay/replay-authority-2.tsv"
then
    echo
    echo "=== REPLAY AUTHORITY 2 ==="
    cat "$STAGE/replay/replay-authority-2.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== B-R1 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"
exit "$RUN_RC"
