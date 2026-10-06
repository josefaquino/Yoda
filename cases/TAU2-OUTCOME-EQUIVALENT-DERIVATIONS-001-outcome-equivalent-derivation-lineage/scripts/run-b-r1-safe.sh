#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-stage-b-r1.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-b-r1-console.log"
B0_CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-b-r0-independent-replay-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-b-r1-execution-started"
STAGE="$ROOT/stage-b-r1"

EXPECTED_SCRIPT_SHA256="ba37163f6c443f5aad03c95ba51ce5d091326d86ec30855940e6c0816b279903"
EXPECTED_B0_CONSOLE_SHA256="b35aa7052c76dd76fd44c587b5bb0ad302e3788fe8a2a919f9c11325ed8c6a2e"
SCRIPT_COMMIT="f028fc72cef7ccee5f096ab170ace4c676556e90"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/08-b-r1-independent-dual-derivation-replay.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " B-R1 INDEPENDENT DUAL DERIVATION REPLAY"
echo " ONE EXECUTION ONLY"
echo "============================================================"

if test -e "$LOCK"
then
    echo "B_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution policy already consumed"
    exit 20
fi

if test -e "$STAGE"
then
    echo "B_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

if test ! -f "$B0_CONSOLE"
then
    echo "B_R0_PREFLIGHT_CONSOLE=MISSING"
    echo "EXECUTION=ABORTED"
    exit 22
fi

ACTUAL_B0="$(
    sha256sum "$B0_CONSOLE" |
    awk '{print $1}'
)"

echo "EXPECTED_B0_CONSOLE_SHA256=$EXPECTED_B0_CONSOLE_SHA256"
echo "ACTUAL_B0_CONSOLE_SHA256=$ACTUAL_B0"

if test "$ACTUAL_B0" != "$EXPECTED_B0_CONSOLE_SHA256"
then
    echo "B_R0_PREFLIGHT_IDENTITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 23
fi

grep -F "B_R0_INDEPENDENT_REPLAY_PREFLIGHT=PASS" "$B0_CONSOLE" >/dev/null ||
{
    echo "B_R0_PREFLIGHT_RESULT=FAIL"
    echo "EXECUTION=ABORTED"
    exit 24
}

grep -F "INDEPENDENT_IMPLEMENTATION_BOUNDARY=PASS" "$B0_CONSOLE" >/dev/null ||
{
    echo "B_R0_INDEPENDENCE_BOUNDARY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 25
}

grep -F "YODA_STORE_MUTATED=NO" "$B0_CONSOLE" >/dev/null ||
{
    echo "B_R0_YODA_BOUNDARY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 26
}

echo "B_R0_PREFLIGHT_AUTHORITY=PASS"
echo "B_EXECUTION_LOCK=ABSENT"
echo "B_STAGE=ABSENT"

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
echo " B-R1 POST-RUN"
echo "============================================================"

echo "B_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "B_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "B_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "B_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "B_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/results/overall-replay.json"
then
    echo
    echo "=== B OVERALL REPLAY ==="
    jq . "$STAGE/results/overall-replay.json"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== B SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
