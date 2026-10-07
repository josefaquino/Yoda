#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT="$HOME/cmu/seeker-c23-swarm-scaling-002-a3-lock-preflight.sh"
CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a3-lock-preflight-console.log"

EXPECTED_SCRIPT_SHA256="e06427d870d028df210507dc131a9e8c3035adc3a26d0e602d6eba4049289b88"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/142a4ec03dcd2fddd25a6dde1824a437fae1a07e/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a3-lock-instrumentation-preflight.sh"

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A3 LOCK INSTRUMENTATION PREFLIGHT"
echo "============================================================"

rm -f "$SCRIPT"

curl -fsSL "$URL" -o "$SCRIPT" || {
    echo "FETCH=FAIL"
    exit 20
}

chmod +x "$SCRIPT"

bash -n "$SCRIPT" || {
    echo "BASH_PARSE=FAIL"
    exit 21
}

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
    exit 22
fi

echo "SCRIPT_IDENTITY=PASS"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A3 PREFLIGHT POST-RUN"
echo "============================================================"

echo "A3_PREFLIGHT_RUN_RC=$RUN_RC"
sha256sum "$SCRIPT" "$CONSOLE"

echo
echo "TERMINAL_STILL_ALIVE=YES"

exit "$RUN_RC"
