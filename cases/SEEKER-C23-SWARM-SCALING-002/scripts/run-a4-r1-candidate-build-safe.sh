#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT="$HOME/cmu/seeker-c23-swarm-scaling-002-a4-r1-candidate-build.sh"
CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a4-r1-candidate-build-console.log"

EXPECTED_SCRIPT_SHA256="b0440bf4a93e5945e7722802a81c3a188bfe46d99a29051367d32273b945c0e8"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/5faa1de81b2de1cd84b23f028c9376e194f26d8b/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a4-r1-candidate-build.sh"

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A4-R1 CANDIDATE BUILD"
echo " BATCH_SIZE=4"
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
echo " A4-R1 POST-RUN"
echo "============================================================"

echo "A4_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

ROOT="$HOME/cmu/SEEKER-C23-SWARM-SCALING-002"
LOCK="$ROOT/.a4-r1-candidate-validation-started"
STAGE="$ROOT/a4-r1-candidate-build"

if test -f "$LOCK"
then
    echo "A4_R1_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
else
    echo "A4_R1_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A4-R1 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo
    echo "=== A4-R1 EVIDENCE ==="
    sha256sum "$STAGE/evidence/SHA256SUMS"
fi

echo
echo "TERMINAL_STILL_ALIVE=YES"

exit "$RUN_RC"
