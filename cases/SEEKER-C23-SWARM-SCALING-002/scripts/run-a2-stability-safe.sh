#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
ROOT="$HOME/cmu/$CASE"

SCRIPT="$HOME/cmu/seeker-c23-swarm-scaling-002-a2-stability.sh"
CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a2-stability-console.log"

LOCK="$ROOT/.a2-stability-execution-started"
STAGE="$ROOT/a2-stability"

EXPECTED_SCRIPT_SHA256="f4c18cebf14d556d5a1206cf0aa9295d00c64eb7e58f33caff367753e6d801e1"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/1e7a75dca976032f3ef08fb28ffeffe3eb6c885f/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a2-stability.sh"

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A2 STABILITY SAFE LAUNCHER"
echo " 32 REPETITIONS PER WORKER COUNT"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A2_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A2_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

ACTUAL_FRONTIER="$(
    sha256sum "$HOME/cmu/yoda_agent_c23/frontier.tsv" |
    awk '{print $1}'
)"

echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER"

if test "$ACTUAL_FRONTIER" != "$EXPECTED_FRONTIER_SHA256"
then
    echo "FRONTIER_IDENTITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 22
fi

echo "FRONTIER_IDENTITY=PASS"

rm -f "$SCRIPT"

curl -fsSL "$URL" -o "$SCRIPT" || {
    echo "FETCH=FAIL"
    exit 23
}

chmod +x "$SCRIPT"

bash -n "$SCRIPT" || {
    echo "BASH_PARSE=FAIL"
    exit 24
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
    exit 25
fi

echo "SCRIPT_IDENTITY=PASS"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A2 POST-RUN"
echo "============================================================"

echo "A2_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A2_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
fi

if test -f "$STAGE/statistics.tsv"
then
    echo
    echo "=== A2 STATISTICS ==="
    cat "$STAGE/statistics.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A2 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo
    echo "=== A2 EVIDENCE ==="
    sha256sum "$STAGE/evidence/SHA256SUMS"
fi

echo
echo "TERMINAL_STILL_ALIVE=YES"

exit "$RUN_RC"
