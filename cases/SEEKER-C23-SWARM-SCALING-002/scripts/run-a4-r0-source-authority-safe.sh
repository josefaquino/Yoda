#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT="$HOME/cmu/seeker-c23-swarm-scaling-002-a4-r0-source-authority.sh"
CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a4-r0-source-authority-console.log"

EXPECTED_SCRIPT_SHA256="b4cb68fa5c7fc723e847ebebbb3c9cbff298c6482317f06fb2d1587b9dd8272e"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/6496f0ec7db4c3760ee758a42fef5bd5ed055171/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a4-r0-source-authority.sh"

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A4-R0 SOURCE AUTHORITY"
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
echo " A4-R0 POST-RUN"
echo "============================================================"

echo "A4_R0_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

echo
echo "TERMINAL_STILL_ALIVE=YES"

exit "$RUN_RC"
