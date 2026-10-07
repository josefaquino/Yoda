#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
ROOT="$HOME/cmu/$CASE"

SCRIPT="$HOME/cmu/seeker-c23-swarm-scaling-002-a3-lock-instrumentation-r2.sh"
CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a3-lock-instrumentation-r2-console.log"

LOCK="$ROOT/.a3-lock-instrumentation-execution-started"
STAGE="$ROOT/a3-lock-instrumentation"

EXPECTED_SCRIPT_SHA256="95b8bd1b67d40298d155ff0b2f07edc57c92673dce3060d829c4340d9bcbbbca"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_PREFLIGHT_CONSOLE_SHA256="14cf13fcd2b794c1ba70ec0d7eeaf77ec54fa52c9a950e8d8264e5bc7cbf9d1a"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/56014e7e9aa3ce722cf4a1a971f97fde656f69af/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a3-lock-instrumentation.sh"

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A3 LOCK INSTRUMENTATION R2"
echo " PRELOCK ANALYZER SMOKE CORRECTED"
echo " ONE EXECUTION ONLY"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A3_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A3_STAGE=EXISTS"
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

PREFLIGHT_CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a3-lock-preflight-console.log"

if test ! -f "$PREFLIGHT_CONSOLE"
then
    echo "A3_PREFLIGHT_CONSOLE=MISSING"
    echo "EXECUTION=ABORTED"
    exit 23
fi

ACTUAL_PREFLIGHT="$(
    sha256sum "$PREFLIGHT_CONSOLE" |
    awk '{print $1}'
)"

echo "EXPECTED_PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256"
echo "ACTUAL_PREFLIGHT_CONSOLE_SHA256=$ACTUAL_PREFLIGHT"

if test "$ACTUAL_PREFLIGHT" != "$EXPECTED_PREFLIGHT_CONSOLE_SHA256"
then
    echo "A3_PREFLIGHT_IDENTITY=FAIL"
    echo "EXECUTION=ABORTED"
    exit 24
fi

grep -F "A3_LOCK_INSTRUMENTATION_PREFLIGHT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null || {
    echo "A3_PREFLIGHT_RESULT=FAIL"
    echo "EXECUTION=ABORTED"
    exit 25
}

echo "A3_PREFLIGHT_AUTHORITY=PASS"

rm -f "$SCRIPT"

curl -fsSL "$URL" -o "$SCRIPT" || {
    echo "FETCH=FAIL"
    exit 26
}

chmod +x "$SCRIPT"

bash -n "$SCRIPT" || {
    echo "BASH_PARSE=FAIL"
    exit 27
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
    exit 28
fi

echo "SCRIPT_IDENTITY=PASS"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A3 R2 POST-RUN"
echo "============================================================"

echo "A3_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A3_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
else
    echo "A3_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/raw/scenario-summary.tsv"
then
    echo
    echo "=== A3 SCENARIO SUMMARY ==="
    cat "$STAGE/raw/scenario-summary.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A3 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo
    echo "=== A3 EVIDENCE ==="
    sha256sum "$STAGE/evidence/SHA256SUMS"
fi

echo
echo "TERMINAL_STILL_ALIVE=YES"

exit "$RUN_RC"
