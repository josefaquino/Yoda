#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-selection-r2.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-selection-r2-console.log"
PREFLIGHT_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.pre-a0-r1-selection-started"
STAGE="$ROOT/pre-a0-r1"

EXPECTED_SCRIPT_SHA256="f4fdf16ffd8523ae7e79e9a1ba7444c7d90a37609a545c6f9f991de2f34cc8af"
EXPECTED_PREFLIGHT_CONSOLE_SHA256="fdb2578012c50478978744434da03d0c29cc241ebe71dd7b5ea04ab9098c0e08"
SCRIPT_COMMIT="26a59335a4fe4ee79e15825db22b8ddd1ece6960"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/01-pre-a0-r1-deterministic-task-selection.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " PRE-A0-R1 DETERMINISTIC TASK SELECTION"
echo " SAFE LAUNCHER R2"
echo " ONE EXECUTION / NO TRAJECTORY EXECUTION"
echo "============================================================"

if test -e "$LOCK"
then
    echo "PRE_A0_R1_SELECTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution policy already consumed"
    exit 20
fi

if test -e "$STAGE"
then
    echo "PRE_A0_R1_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

if test ! -f "$PREFLIGHT_CONSOLE"
then
    echo "PRE_A0_PREFLIGHT_CONSOLE=MISSING"
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
    echo "PRE_A0_PREFLIGHT_IDENTITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 23
fi

grep -F "PRE_A0_PREFLIGHT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "PRE_A0_PREFLIGHT_RESULT=FAIL"
    echo "EXECUTION=ABORTED"
    exit 24
}

grep -F "SELECTOR_SELF_TEST=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "PRE_A0_PREFLIGHT_SELECTOR_AUTHORITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 25
}

grep -F "REAL_TASK_SELECTION_EXECUTED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "PRE_A0_PREFLIGHT_BOUNDARY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 26
}

grep -F "FINAL_TASK_SELECTED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
{
    echo "PRE_A0_PREFLIGHT_BOUNDARY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 27
}

echo "PRE_A0_PREFLIGHT_AUTHORITY=PASS"
echo "PRE_A0_R1_SELECTION_LOCK=ABSENT"
echo "PRE_A0_R1_STAGE=ABSENT"

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 28
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 29
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
    exit 30
fi

echo "SCRIPT_IDENTITY=PASS"

"$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " PRE-A0-R1 R2 POST-RUN"
echo "============================================================"

echo "PRE_A0_R1_R2_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "PRE_A0_R1_SELECTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "PRE_A0_R1_SELECTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "PRE_A0_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "PRE_A0_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/selection/selection.tsv"
then
    echo
    echo "=== PRE-A0 SELECTION ==="
    cat "$STAGE/selection/selection.tsv"
fi

if test -f "$STAGE/selection/transformation.tsv"
then
    echo
    echo "=== PRE-A0 TRANSFORMATION ==="
    cat "$STAGE/selection/transformation.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== PRE-A0 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
