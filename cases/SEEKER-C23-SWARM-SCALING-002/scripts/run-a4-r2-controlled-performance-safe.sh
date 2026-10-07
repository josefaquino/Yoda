#!/usr/bin/env bash
set -u
set -o pipefail

ROOT="$HOME/cmu/SEEKER-C23-SWARM-SCALING-002"

SCRIPT="$HOME/cmu/seeker-c23-swarm-scaling-002-a4-r2-controlled-performance.sh"
CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a4-r2-controlled-performance-console.log"

LOCK="$ROOT/.a4-r2-controlled-performance-started"
STAGE="$ROOT/a4-r2-controlled-performance"

CONTROL="$HOME/cmu/yoda_agent_c23/yoda_seeker_agent"
CANDIDATE="$ROOT/a4-r1-candidate-build/candidate/yoda_seeker_agent"
FRONTIER="$HOME/cmu/yoda_agent_c23/frontier.tsv"

EXPECTED_SCRIPT_SHA256="608ba71751191d77af6049a5f81c8f030e7b3607bd347e397eb73d17907f12fc"
EXPECTED_CONTROL_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_CANDIDATE_SHA256="0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/80c370dfcc354b5b7318b3a3bd1ad5ca251bb6d3/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a4-r2-controlled-performance.sh"

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A4-R2 CONTROLLED PERFORMANCE"
echo " CONTROL VS BATCH-4 CANDIDATE"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A4_R2_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A4_R2_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 21
fi

for spec in     "$CONTROL|$EXPECTED_CONTROL_SHA256|CONTROL"     "$CANDIDATE|$EXPECTED_CANDIDATE_SHA256|CANDIDATE"     "$FRONTIER|$EXPECTED_FRONTIER_SHA256|FRONTIER"
do
    path="$(printf '%s' "$spec" | awk -F '|' '{print $1}')"
    expected="$(printf '%s' "$spec" | awk -F '|' '{print $2}')"
    label="$(printf '%s' "$spec" | awk -F '|' '{print $3}')"

    if test ! -f "$path"
    then
        echo "${label}_FILE=MISSING"
        echo "EXECUTION=ABORTED"
        exit 22
    fi

    actual="$(sha256sum "$path" | awk '{print $1}')"

    echo "EXPECTED_${label}_SHA256=$expected"
    echo "ACTUAL_${label}_SHA256=$actual"

    if test "$actual" != "$expected"
    then
        echo "${label}_IDENTITY=FAIL"
        echo "EXECUTION=ABORTED"
        exit 23
    fi

    echo "${label}_IDENTITY=PASS"
done

rm -f "$SCRIPT"

curl -fsSL "$URL" -o "$SCRIPT" || {
    echo "FETCH=FAIL"
    exit 24
}

chmod +x "$SCRIPT"

bash -n "$SCRIPT" || {
    echo "BASH_PARSE=FAIL"
    exit 25
}

echo "BASH_PARSE=PASS"

ACTUAL_SCRIPT_SHA256="$(
    sha256sum "$SCRIPT" |
    awk '{print $1}'
)"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED_SCRIPT_SHA256"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL_SCRIPT_SHA256"

if test "$ACTUAL_SCRIPT_SHA256" != "$EXPECTED_SCRIPT_SHA256"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 26
fi

echo "SCRIPT_IDENTITY=PASS"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A4-R2 POST-RUN"
echo "============================================================"

echo "A4_R2_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A4_R2_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
else
    echo "A4_R2_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/statistics.tsv"
then
    echo
    echo "=== A4-R2 STATISTICS ==="
    cat "$STAGE/statistics.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A4-R2 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo
    echo "=== A4-R2 EVIDENCE ==="
    sha256sum "$STAGE/evidence/SHA256SUMS"
fi

echo
echo "TERMINAL_STILL_ALIVE=YES"

exit "$RUN_RC"
