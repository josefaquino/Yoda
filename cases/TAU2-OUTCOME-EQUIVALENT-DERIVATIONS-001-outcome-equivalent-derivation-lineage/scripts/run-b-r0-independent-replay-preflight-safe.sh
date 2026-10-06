#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-b-r0-independent-replay-preflight.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-b-r0-independent-replay-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
B_LOCK="$ROOT/.stage-b-r1-execution-started"
B_STAGE="$ROOT/stage-b-r1"
WORK="$ROOT/b-r0-independent-replay-preflight"

EXPECTED_SCRIPT_SHA256="88a0676f33912a3ad0fa288e76dbfdcf237e29265aeac6078bb0c91918472bde"
SCRIPT_COMMIT="7af0ad93f3573cf284791d027ecce631ead78b0e"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/07-b-r0-independent-replay-preflight.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " B-R0 INDEPENDENT REPLAY PREFLIGHT"
echo " READ ONLY YODA / NO REPLAY"
echo "============================================================"

if test -e "$B_LOCK"
then
    echo "B_EXECUTION_LOCK=EXISTS"
    echo "PREFLIGHT=ABORTED"
    exit 20
fi

if test -e "$B_STAGE"
then
    echo "B_STAGE=EXISTS"
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
echo "B_EXECUTION_LOCK=ABSENT"
echo "B_STAGE=ABSENT"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " B-R0 PREFLIGHT POST-RUN"
echo "============================================================"

echo "B_R0_PREFLIGHT_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -e "$B_LOCK"
then
    echo "B_EXECUTION_LOCK=UNEXPECTEDLY_CONSUMED"
    exit 25
fi

echo "B_EXECUTION_LOCK=ABSENT"

if test -e "$B_STAGE"
then
    echo "B_STAGE=UNEXPECTEDLY_CREATED"
    exit 26
fi

echo "B_STAGE=ABSENT"

if test -f "$WORK/evidence/SHA256SUMS"
then
    echo "B_R0_MANIFEST=FOUND"
    sha256sum "$WORK/evidence/SHA256SUMS"
fi

if test -f "$WORK/evidence/summary.tsv"
then
    echo
    echo "=== B-R0 SUMMARY ==="
    cat "$WORK/evidence/summary.tsv"
fi

if test "$RUN_RC" -eq 0
then
    echo "B_R0_PREFLIGHT_WRAPPER=PASS"
else
    echo "B_R0_PREFLIGHT_WRAPPER=NOT_EVALUATED"
fi

echo "INDEPENDENT_REPLAY_EXECUTED=NO"
echo "EXTERNAL_JUDGE_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

echo
echo "SAFE_PREFLIGHT_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
