#!/usr/bin/env bash
set -u
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-stage-a2-r1.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a2-r1-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a2-r1-execution-started"
STAGE="$ROOT/stage-a2-r1"

EXPECTED_SCRIPT_SHA256="b47d6349131755fde45a3004ce08f58508b1831bf48237f6cc1af18929934dac"
SCRIPT_COMMIT="3326d26c8866691c742aedefdf0a4c7010b0cc99"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/03-a2-yoda-evaluation-lineage.sh"

echo "============================================================"
echo " A2-R1 SAFE SCIENTIFIC EXECUTION"
echo " YODA EVALUATION LINEAGE"
echo " ONE EXECUTION ONLY"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A2_R1_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution policy already consumed"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A2_R1_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 22
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 23
fi

echo "BASH_PARSE=PASS"

ACTUAL="$(
    sha256sum "$SCRIPT" |
    awk '{print $1}'
)"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED_SCRIPT_SHA256"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL"

if test "$ACTUAL" != "$EXPECTED_SCRIPT_SHA256"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 24
fi

echo "SCRIPT_IDENTITY=PASS"
echo "A2_R1_EXECUTION_LOCK=ABSENT"
echo "A2_R1_STAGE=ABSENT"

"$SCRIPT" 2>&1 |
tee "$CONSOLE"

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
    echo "=== A2 YODA STORE ==="
    sha256sum "$STAGE/yoda-store/data.yoda"
    wc -c "$STAGE/yoda-store/data.yoda"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
