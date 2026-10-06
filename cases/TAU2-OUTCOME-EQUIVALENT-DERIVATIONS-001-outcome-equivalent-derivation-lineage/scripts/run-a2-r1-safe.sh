#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-stage-a2-r1.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a2-r1-console.log"
PREFLIGHT_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a2-r0-capacity-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a2-r1-execution-started"
STAGE="$ROOT/stage-a2-r1"

EXPECTED_SCRIPT_SHA256="e59f554ea4df9d3b4e4d9637f8411ec08c06cb72c30cb7028babdc895bb8fd0d"
EXPECTED_PREFLIGHT_CONSOLE_SHA256="0f7461f13b8fe6091e13b1b1697b87aa474bc379b7431e96102ac5db08b01839"
SCRIPT_COMMIT="078f59c52ddc2fcd703787ae48329d63d51cd0b6"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/06-a2-r1-yoda-dual-derivation-lineage.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " A2-R1 YODA DUAL DERIVATION LINEAGE"
echo " ONE EXECUTION ONLY"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A2_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution policy already consumed"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A2_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

if test ! -f "$PREFLIGHT_CONSOLE"
then
    echo "A2_R0_PREFLIGHT_CONSOLE=MISSING"
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
    echo "A2_R0_PREFLIGHT_IDENTITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 23
fi

grep -F "A2_R0_CAPACITY_PREFLIGHT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "A2_R0_PREFLIGHT_RESULT=FAIL"
    echo "EXECUTION=ABORTED"
    exit 24
}

grep -F "TERM_CAPACITY_MARGIN=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "A2_R0_CAPACITY_MARGIN=FAIL"
    echo "EXECUTION=ABORTED"
    exit 25
}

grep -F "YODA_WRITES=ZERO" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "A2_R0_WRITE_BOUNDARY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 26
}

echo "A2_R0_PREFLIGHT_AUTHORITY=PASS"
echo "A2_EXECUTION_LOCK=ABSENT"
echo "A2_STAGE=ABSENT"

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
    echo "A2_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "A2_EXECUTION_LOCK=NOT_CONSUMED"
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
