#!/usr/bin/env bash
set -u
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
SCRIPT="$HOME/cmu/market-regime-lineage-001-stage-a1-r1.sh"
CONSOLE="$HOME/cmu/market-regime-lineage-001-stage-a1-r1-console.log"
LOCK="$HOME/cmu/$CASE/.stage-a1-r1-execution-started"
STAGE="$HOME/cmu/$CASE/stage-a1-r1"

EXPECTED="0c891fb1565f42e01943c13def49473b9e515a66653b0f88a479ca065b89a440"
URL="https://raw.githubusercontent.com/josefaquino/Yoda/18acde5284ead728d0ed528730cbf5aecdead0a9/cases/MARKET-REGIME-LINEAGE-001-decision-lineage/scripts/02-a1-deterministic-classification-authority.sh"

echo "============================================================"
echo " A1-R1 SAFE LAUNCHER"
echo " CHILD-SHELL EXECUTION / TERMINAL-SAFE"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A1_R1_EXECUTION_LOCK=EXISTS"
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
echo "A1_R1_EXECUTION_LOCK=ABSENT"

"$SCRIPT" 2>&1 | tee "$CONSOLE"
RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A1-R1 POST-RUN"
echo "============================================================"
echo "A1_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A1_R1_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "A1_R1_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "A1_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "A1_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/results/canonical-results.tsv"
then
    echo
    echo "=== CANONICAL RESULTS ==="
    cat "$STAGE/results/canonical-results.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A1 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"
exit "$RUN_RC"
