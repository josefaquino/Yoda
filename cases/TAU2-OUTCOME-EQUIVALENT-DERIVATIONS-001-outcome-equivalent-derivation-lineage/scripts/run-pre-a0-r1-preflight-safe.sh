#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-preflight.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-pre-a0-r1-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.pre-a0-r1-selection-started"
STAGE="$ROOT/pre-a0-r1"

EXPECTED_SCRIPT_SHA256="0eee8dd57e21cf989127fc2e3980a0c65bb7fb7bb6f6ef277901695f071a5776"
SCRIPT_COMMIT="2c92bd4913b6376f79945b5340ba718f3305b809"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/00-pre-a0-r1-preflight.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " PRE-A0-R1 PREFLIGHT"
echo " CAPABILITY ONLY / NO REAL TASK SELECTION"
echo "============================================================"

if test -e "$LOCK"
then
    echo "PRE_A0_R1_SELECTION_LOCK=EXISTS"
    echo "PREFLIGHT=ABORTED"
    exit 20
fi

if test -e "$STAGE"
then
    echo "PRE_A0_R1_STAGE=EXISTS"
    echo "PREFLIGHT=ABORTED"
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

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " PRE-A0-R1 PREFLIGHT STATUS"
echo "============================================================"

echo "PRE_A0_R1_PREFLIGHT_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -e "$LOCK"
then
    echo "PRE_A0_R1_SELECTION_LOCK=UNEXPECTEDLY_CONSUMED"
    exit 25
fi

echo "PRE_A0_R1_SELECTION_LOCK=ABSENT"

if test -e "$STAGE"
then
    echo "PRE_A0_R1_STAGE=UNEXPECTEDLY_CREATED"
    exit 26
fi

echo "PRE_A0_R1_STAGE=ABSENT"

if test "$RUN_RC" -eq 0
then
    echo "PRE_A0_R1_PREFLIGHT_WRAPPER=PASS"
else
    echo "PRE_A0_R1_PREFLIGHT_WRAPPER=NOT_EVALUATED"
fi

echo "REAL_TASK_SELECTION_EXECUTED=NO"
echo "FINAL_TASK_SELECTED=NO"
echo "TRAJECTORY_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "YODA_WRITES=ZERO"

echo
echo "SAFE_PREFLIGHT_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
