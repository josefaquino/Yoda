#!/usr/bin/env bash
set -u
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"

SCRIPT="$HOME/cmu/market-regime-lineage-001-stage-a2-r1.sh"
CONSOLE="$HOME/cmu/market-regime-lineage-001-stage-a2-r1-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a2-r1-execution-started"
STAGE="$ROOT/stage-a2-r1"

EXPECTED="191adf5544895bb11973836f73434c00944c5e0cb075b5c1f321acb69c397fe5"
SCRIPT_COMMIT="5f3a2e6f071cdc98fea4021121bc995cdfa16139"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/MARKET-REGIME-LINEAGE-001-decision-lineage/scripts/04-a2-yoda-decision-lineage.sh"

echo "============================================================"
echo " A2-R1 SAFE LAUNCHER"
echo " YODA DECISION LINEAGE / CHILD SHELL"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A2_R1_EXECUTION_LOCK=EXISTS"
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
echo "A2_R1_EXECUTION_LOCK=ABSENT"

"$SCRIPT" 2>&1 | tee "$CONSOLE"
RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A2-R1 POST-RUN"
echo "============================================================"

echo "A2_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A2_R1_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "A2_R1_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "A2_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "A2_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A2 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

if test -f "$STAGE/yoda-store/data.yoda"
then
    echo
    echo "=== DATA.YODA ==="
    sha256sum "$STAGE/yoda-store/data.yoda"
    wc -c "$STAGE/yoda-store/data.yoda"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"
exit "$RUN_RC"
