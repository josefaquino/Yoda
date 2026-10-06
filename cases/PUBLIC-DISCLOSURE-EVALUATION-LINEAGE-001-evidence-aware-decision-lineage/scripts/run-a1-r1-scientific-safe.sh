#!/usr/bin/env bash
set -u
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-stage-a1-r1.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a1-r1-console.log"
PREFLIGHT_CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a1-r1-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a1-r1-execution-started"
STAGE="$ROOT/stage-a1-r1"

EXPECTED_SCRIPT_SHA256="21d337571abfe2546afc2364f899bcc7e73fa52a265904d336f21c1420526560"
EXPECTED_PREFLIGHT_CONSOLE_SHA256="a584144d3a6555ba62cf01d3ab27df98ad1c806ea1fa1692f7f245e5e3c4f544"
SCRIPT_COMMIT="5bca0cf2d3c74ca8e28ad169ab51ce23d11915f0"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/02-a1-r1-scientific.sh"

echo "============================================================"
echo " A1-R1 SAFE SCIENTIFIC EXECUTION"
echo " DUAL DETERMINISTIC EVALUATION AUTHORITY"
echo " ONE EXECUTION ONLY"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A1_R1_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution policy already consumed"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A1_R1_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

if test ! -f "$PREFLIGHT_CONSOLE"
then
    echo "A1_R1_PREFLIGHT_CONSOLE=MISSING"
    echo "EXECUTION=ABORTED"
    exit 22
fi

ACTUAL_PREFLIGHT="$(
    sha256sum "$PREFLIGHT_CONSOLE" |
    awk '{print $1}'
)"

echo "EXPECTED_PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256"
echo "ACTUAL_PREFLIGHT_CONSOLE_SHA256=$ACTUAL_PREFLIGHT"

if test "$ACTUAL_PREFLIGHT" != "$EXPECTED_PREFLIGHT_CONSOLE_SHA256"
then
    echo "A1_R1_PREFLIGHT_IDENTITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 23
fi

grep -F "A1_R1_PRE_EXECUTION_AUDIT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "A1_R1_PREFLIGHT_RESULT=FAIL"
    echo "EXECUTION=ABORTED"
    exit 24
}

grep -F "SYNTHETIC_AUTHORITY_EQUIVALENCE=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "A1_R1_PREFLIGHT_RESULT=FAIL"
    echo "EXECUTION=ABORTED"
    exit 25
}

grep -F "SCIENTIFIC_EXECUTION_STARTED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "A1_R1_PREFLIGHT_BOUNDARY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 26
}

echo "A1_R1_PREFLIGHT_AUTHORITY=PASS"

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 27
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 28
fi

echo "BASH_PARSE=PASS"

ACTUAL_SCRIPT="$(
    sha256sum "$SCRIPT" |
    awk '{print $1}'
)"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED_SCRIPT_SHA256"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL_SCRIPT"

if test "$ACTUAL_SCRIPT" != "$EXPECTED_SCRIPT_SHA256"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 29
fi

echo "SCRIPT_IDENTITY=PASS"
echo "A1_R1_EXECUTION_LOCK=ABSENT"
echo "A1_R1_STAGE=ABSENT"

"$SCRIPT" 2>&1 |
tee "$CONSOLE"

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

if test -f "$STAGE/results/canonical-evaluation.tsv"
then
    echo
    echo "=== A1 CANONICAL EVALUATION ==="
    cat "$STAGE/results/canonical-evaluation.tsv"
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
