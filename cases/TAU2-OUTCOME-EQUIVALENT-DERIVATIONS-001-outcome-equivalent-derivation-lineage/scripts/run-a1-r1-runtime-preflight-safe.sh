#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a1-r1-runtime-preflight.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a1-r1-runtime-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
A1_LOCK="$ROOT/.stage-a1-r1-execution-started"
A1_STAGE="$ROOT/stage-a1-r1"

EXPECTED_SCRIPT_SHA256="1e8878262a6d4f025ef9007e52d36c93b057b65313c3d91fc99a07e72d41f779"
SCRIPT_COMMIT="79d568716217a776057b854c3ebad320a474cc74"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/03-a1-r1-runtime-preflight.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " A1-R1 RUNTIME PREFLIGHT"
echo " NO TRAJECTORY / NO JUDGE / NO A1 LOCK"
echo "============================================================"

if test -e "$A1_LOCK"
then
    echo "A1_EXECUTION_LOCK=EXISTS"
    echo "PREFLIGHT=ABORTED"
    exit 20
fi

if test -e "$A1_STAGE"
then
    echo "A1_STAGE=EXISTS"
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
echo "A1_EXECUTION_LOCK=ABSENT"
echo "A1_STAGE=ABSENT"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A1-R1 PREFLIGHT POST-RUN"
echo "============================================================"

echo "A1_R1_PREFLIGHT_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -e "$A1_LOCK"
then
    echo "A1_EXECUTION_LOCK=UNEXPECTEDLY_CONSUMED"
    exit 25
fi

echo "A1_EXECUTION_LOCK=ABSENT"

if test -e "$A1_STAGE"
then
    echo "A1_STAGE=UNEXPECTEDLY_CREATED"
    exit 26
fi

echo "A1_STAGE=ABSENT"

if test "$RUN_RC" -eq 0
then
    echo "A1_R1_PREFLIGHT_WRAPPER=PASS"
else
    echo "A1_R1_PREFLIGHT_WRAPPER=NOT_EVALUATED"
fi

echo "TRAJECTORY_A_EXECUTED=NO"
echo "TRAJECTORY_B_EXECUTED=NO"
echo "EXTERNAL_JUDGE_EXECUTED=NO"
echo "MODEL_ENDPOINT_CALLED=NO"
echo "YODA_WRITES=ZERO"

echo
echo "SAFE_PREFLIGHT_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
