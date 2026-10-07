#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
REVISION="A2-STABILITY-001"

PROJECT="$HOME/cmu/yoda_agent_c23"
AGENT="$PROJECT/yoda_seeker_agent"
FRONTIER="$PROJECT/frontier.tsv"

ROOT="$HOME/cmu/$CASE"
STAGE="$ROOT/a2-stability"
EVIDENCE="$STAGE/evidence"
RUNS="$STAGE/runs"
RAW="$STAGE/raw"

BASELINE="$STAGE/frontier.canonical-100.tsv"
LOCK="$ROOT/.a2-stability-execution-started"

EXPECTED_AGENT_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_TASK_IDENTITY_SHA256="525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28"

REPETITIONS=32
EFFECT_THRESHOLD_PCT="5.0"

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

prelock_fail()
{
    echo
    echo "A2_STABILITY=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A2_EXECUTION_LOCK_CONSUMED=NO"
    exit 1
}

postlock_fail()
{
    echo
    echo "A2_STABILITY=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A2_EXECUTION_LOCK_CONSUMED=YES"
    echo "A2_RERUN=NO"
    exit 2
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        prelock_fail "MISSING_COMMAND_$1"
}

restore_frontier()
{
    if test -f "$BASELINE"
    then
        cp "$BASELINE" "$FRONTIER" 2>/dev/null || true
        rm -f "$FRONTIER.lock" "$FRONTIER".tmp.* 2>/dev/null || true
    fi
}

trap restore_frontier EXIT

for cmd in \
    sha256sum awk grep sort cmp cp rm mkdir wc date find xargs pgrep
 do
    require_cmd "$cmd"
 done

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A2 STABILITY"
echo " 32 REPETITIONS PER WORKER COUNT"
echo " NO ENGINEERING CHANGE"
echo "============================================================"

section "0. PRE-EXECUTION AUTHORITIES"

test -d "$PROJECT" ||
    prelock_fail "PROJECT_MISSING"

test -x "$AGENT" ||
    prelock_fail "AGENT_MISSING"

test -f "$FRONTIER" ||
    prelock_fail "FRONTIER_MISSING"

test ! -e "$LOCK" ||
    prelock_fail "A2_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_fail "A2_STAGE_ALREADY_EXISTS"

ACTUAL_AGENT_SHA256="$(sha "$AGENT")"
ACTUAL_FRONTIER_SHA256="$(sha "$FRONTIER")"

echo "EXPECTED_AGENT_SHA256=$EXPECTED_AGENT_SHA256"
echo "ACTUAL_AGENT_SHA256=$ACTUAL_AGENT_SHA256"

test "$ACTUAL_AGENT_SHA256" = "$EXPECTED_AGENT_SHA256" ||
    prelock_fail "AGENT_IDENTITY_MISMATCH"

echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER_SHA256"

test "$ACTUAL_FRONTIER_SHA256" = "$EXPECTED_FRONTIER_SHA256" ||
    prelock_fail "FRONTIER_IDENTITY_MISMATCH"

if pgrep -x yoda_seeker_agent >/dev/null 2>&1
then
    prelock_fail "PREEXISTING_AGENT_PROCESS"
fi

ACTUAL_TASK_IDENTITY_SHA256="$(
    awk -F '\t' '{print $1 "\t" $2}' "$FRONTIER" |
    sha256sum |
    awk '{print $1}'
)"

echo "EXPECTED_TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256"
echo "ACTUAL_TASK_IDENTITY_SHA256=$ACTUAL_TASK_IDENTITY_SHA256"

test "$ACTUAL_TASK_IDENTITY_SHA256" = "$EXPECTED_TASK_IDENTITY_SHA256" ||
    prelock_fail "TASK_IDENTITY_MISMATCH"

LINES="$(wc -l < "$FRONTIER" | awk '{print $1}')"
QUEUED="$(grep -c "$(printf '\tQUEUED\t')" "$FRONTIER" || true)"

test "$LINES" -eq 100 ||
    prelock_fail "BASELINE_LINE_COUNT_MISMATCH"

test "$QUEUED" -eq 100 ||
    prelock_fail "BASELINE_QUEUED_COUNT_MISMATCH"

echo "AGENT_AUTHORITY=PASS"
echo "FRONTIER_AUTHORITY=PASS"
echo "TASK_IDENTITY_AUTHORITY=PASS"
echo "PREEXISTING_AGENT_PROCESS=NO"

section "1. FREEZE EXECUTION POLICY"

cat > "$LOCK" <<LOCK_EOF
CASE=$CASE
REVISION=$REVISION
AGENT_SHA256=$EXPECTED_AGENT_SHA256
FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256
REPETITIONS_PER_WORKER=$REPETITIONS
WORKER_MATRIX=1,4,8,16
ORDER_DESIGN=WILLIAMS_BALANCED_4_SEQUENCE
ENGINEERING_CHANGE=NO
EXECUTION_POLICY=ONE_EXECUTION
LOCK_EOF

test -f "$LOCK" ||
    prelock_fail "LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A2_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A2_EXECUTION_GATE=PASS"

mkdir -p "$EVIDENCE" "$RUNS" "$RAW" ||
    postlock_fail "STAGE_CREATION_FAILURE"

cp "$FRONTIER" "$BASELINE" ||
    postlock_fail "BASELINE_COPY_FAILURE"

test "$(sha "$BASELINE")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "BASELINE_COPY_IDENTITY_MISMATCH"

awk -F '\t' '{print $1 "\t" $2}' "$BASELINE" \
    > "$EVIDENCE/task-identities.tsv"

run_workers()
{
    workers="$1"
    logdir="$2"

    pids=""
    w=1

    while test "$w" -le "$workers"
    do
        (
            while grep -q "$(printf '\tQUEUED\t')" "$FRONTIER" 2>/dev/null
            do
                "$AGENT" "$w" >/dev/null 2>>"$logdir/worker-$w.stderr.log" || exit 1
            done
        ) &

        pids="$pids $!"
        w=$((w + 1))
    done

    failed=0

    for pid in $pids
    do
        wait "$pid" || failed=1
    done

    test "$failed" -eq 0
}

run_scenario()
{
    label="$1"
    workers="$2"
    round="$3"
    position="$4"

    dir="$RUNS/$label"
    mkdir -p "$dir" ||
        postlock_fail "RUN_DIRECTORY_CREATION_FAILURE"

    cp "$BASELINE" "$FRONTIER" ||
        postlock_fail "BASELINE_RESTORE_FAILURE"

    rm -f "$FRONTIER.lock" "$FRONTIER".tmp.*

    test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
        postlock_fail "SCENARIO_INPUT_IDENTITY_MISMATCH"

    before_queued="$(grep -c "$(printf '\tQUEUED\t')" "$FRONTIER" || true)"

    test "$before_queued" -eq 100 ||
        postlock_fail "SCENARIO_PRE_QUEUED_COUNT_MISMATCH"

    start_ns="$(date +%s%N)"

    run_workers "$workers" "$dir" ||
        postlock_fail "AGENT_EXECUTION_FAILURE"

    end_ns="$(date +%s%N)"

    elapsed_ns=$((end_ns - start_ns))

    elapsed_s="$(
        awk -v ns="$elapsed_ns" 'BEGIN {printf "%.6f", ns/1000000000.0}'
    )"

    processed="$(grep -c "$(printf '\tPROCESSING\t')" "$FRONTIER" || true)"
    remaining="$(grep -c "$(printf '\tQUEUED\t')" "$FRONTIER" || true)"

    test "$processed" -eq 100 ||
        postlock_fail "SCENARIO_PROCESSED_COUNT_MISMATCH"

    test "$remaining" -eq 0 ||
        postlock_fail "SCENARIO_QUEUED_REMAINS"

    tps="$(
        awk -v s="$elapsed_s" 'BEGIN {printf "%.6f", 100.0/s}'
    )"

    cp "$FRONTIER" "$dir/frontier.final.tsv"

    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$round" "$position" "$workers" "$elapsed_s" "$tps" "$label" \
        >> "$RAW/all-runs.tsv"

    printf '%s\n' "$tps" >> "$RAW/tps-$workers.txt"

    echo "RUN=$label ROUND=$round POSITION=$position WORKERS=$workers ELAPSED_S=$elapsed_s TPS=$tps"
}

section "2. WARMUP â EXCLUDED FROM STATISTICS"

: > "$RAW/all-runs.tsv"

for workers in 1 4 16 8
 do
    run_scenario "warmup-${workers}w" "$workers" 0 0
 done

rm -f "$RAW"/tps-*.txt

printf '%s\n' \
    "round\tposition\tworkers\telapsed_s\tthroughput_tps\tlabel" \
    > "$RAW/all-runs.tsv"

section "3. 128 MEASURED SCENARIOS"

round=1

while test "$round" -le "$REPETITIONS"
 do
    pattern=$(( (round - 1) % 4 ))

    case "$pattern" in
        0) sequence="1 4 16 8" ;;
        1) sequence="4 8 1 16" ;;
        2) sequence="8 16 4 1" ;;
        3) sequence="16 1 8 4" ;;
    esac

    position=1

    for workers in $sequence
    do
        label="$(printf 'r%02d-p%d-%02dw' "$round" "$position" "$workers")"
        run_scenario "$label" "$workers" "$round" "$position"
        position=$((position + 1))
    done

    round=$((round + 1))
 done

section "4. STATISTICAL SUMMARY"

printf '%s\n' \
    "workers\tn\tmin_tps\tmedian_tps\tmean_tps\tp95_tps\tmax_tps\tsd_tps" \
    > "$STAGE/statistics.tsv"

summarize()
{
    workers="$1"
    source="$RAW/tps-$workers.txt"
    sorted="$RAW/tps-$workers.sorted.txt"

    sort -n "$source" > "$sorted"

    n="$(wc -l < "$sorted" | awk '{print $1}')"

    test "$n" -eq "$REPETITIONS" ||
        postlock_fail "REPETITION_COUNT_MISMATCH_${workers}W"

    min="$(awk 'NR==1 {print; exit}' "$sorted")"
    max="$(awk 'END {print}' "$sorted")"

    median="$(
        awk '
        {
            a[NR]=$1
        }
        END {
            if (NR % 2 == 1)
                printf "%.6f", a[(NR+1)/2]
            else
                printf "%.6f", (a[NR/2] + a[NR/2+1]) / 2.0
        }' "$sorted"
    )"

    mean="$(
        awk '{s+=$1} END {printf "%.6f", s/NR}' "$sorted"
    )"

    p95="$(
        awk '
        {
            a[NR]=$1
        }
        END {
            idx=int(0.95*NR)
            if (idx < 0.95*NR)
                idx++
            if (idx < 1)
                idx=1
            printf "%.6f", a[idx]
        }' "$sorted"
    )"

    sd="$(
        awk '
        {
            a[NR]=$1
            s+=$1
        }
        END {
            mean=s/NR
            ss=0
            for (i=1; i<=NR; i++)
                ss+=(a[i]-mean)^2
            if (NR > 1)
                printf "%.6f", sqrt(ss/(NR-1))
            else
                printf "0.000000"
        }' "$sorted"
    )"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$workers" "$n" "$min" "$median" "$mean" "$p95" "$max" "$sd" \
        >> "$STAGE/statistics.tsv"

    echo "WORKERS=$workers N=$n MIN_TPS=$min MEDIAN_TPS=$median MEAN_TPS=$mean P95_TPS=$p95 MAX_TPS=$max SD_TPS=$sd"
}

for workers in 1 4 8 16
 do
    summarize "$workers"
 done

MEDIAN_1="$(awk -F '\t' '$1==1 {print $4}' "$STAGE/statistics.tsv")"
MEDIAN_4="$(awk -F '\t' '$1==4 {print $4}' "$STAGE/statistics.tsv")"
MEDIAN_8="$(awk -F '\t' '$1==8 {print $4}' "$STAGE/statistics.tsv")"
MEDIAN_16="$(awk -F '\t' '$1==16 {print $4}' "$STAGE/statistics.tsv")"

DELTA_8_VS_4_PCT="$(
    awk -v a="$MEDIAN_8" -v b="$MEDIAN_4" \
        'BEGIN {printf "%.3f", 100.0*(a-b)/b}'
)"

CLASS_4_8="$(
    awk \
        -v m4="$MEDIAN_4" \
        -v m8="$MEDIAN_8" \
        -v t="$EFFECT_THRESHOLD_PCT" '
    BEGIN {
        if (m8 >= m4*(1+t/100.0))
            print "8_WORKER_CLEARLY_ABOVE_4"
        else if (m4 >= m8*(1+t/100.0))
            print "4_WORKER_CLEARLY_ABOVE_8"
        else
            print "4_8_PLATEAU"
    }'
)"

BEST_4_8="$(
    awk -v a="$MEDIAN_4" -v b="$MEDIAN_8" \
        'BEGIN {print (a>b ? a : b)}'
)"

REGRESSION_16="$(
    awk \
        -v m16="$MEDIAN_16" \
        -v best="$BEST_4_8" \
        -v t="$EFFECT_THRESHOLD_PCT" '
    BEGIN {
        if (m16 < best*(1-t/100.0))
            print "REGRESSION"
        else
            print "NOT_RESOLVED"
    }'
)"

SPEEDUP_4="$(
    awk -v a="$MEDIAN_4" -v b="$MEDIAN_1" 'BEGIN {printf "%.3f", a/b}'
)"
SPEEDUP_8="$(
    awk -v a="$MEDIAN_8" -v b="$MEDIAN_1" 'BEGIN {printf "%.3f", a/b}'
)"
SPEEDUP_16="$(
    awk -v a="$MEDIAN_16" -v b="$MEDIAN_1" 'BEGIN {printf "%.3f", a/b}'
)"

echo
echo "MEDIAN_1W_TPS=$MEDIAN_1"
echo "MEDIAN_4W_TPS=$MEDIAN_4"
echo "MEDIAN_8W_TPS=$MEDIAN_8"
echo "MEDIAN_16W_TPS=$MEDIAN_16"

echo "MEDIAN_SPEEDUP_4W=${SPEEDUP_4}x"
echo "MEDIAN_SPEEDUP_8W=${SPEEDUP_8}x"
echo "MEDIAN_SPEEDUP_16W=${SPEEDUP_16}x"

echo "MEDIAN_8W_VS_4W_DELTA_PCT=$DELTA_8_VS_4_PCT"
echo "A2_4_8_CLASSIFICATION=$CLASS_4_8"
echo "A2_16W_CLASSIFICATION=$REGRESSION_16"

section "5. RESTORE FROZEN FRONTIER"

cp "$BASELINE" "$FRONTIER" ||
    postlock_fail "FINAL_FRONTIER_RESTORE_FAILURE"

rm -f "$FRONTIER.lock" "$FRONTIER".tmp.*

test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "FINAL_FRONTIER_IDENTITY_MISMATCH"

echo "PROJECT_FRONTIER_RESTORED=PASS"

section "6. FREEZE EVIDENCE"

cp "$0" "$EVIDENCE/a2-stability-harness.sh"
cp "$LOCK" "$EVIDENCE/execution-lock.txt"

cat > "$EVIDENCE/summary.tsv" <<SUMMARY_EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
AGENT_SHA256	$EXPECTED_AGENT_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256	$EXPECTED_TASK_IDENTITY_SHA256
REPETITIONS_PER_WORKER	$REPETITIONS
MEASURED_SCENARIOS	128
ORDER_DESIGN	WILLIAMS_BALANCED_4_SEQUENCE
MEDIAN_1W_TPS	$MEDIAN_1
MEDIAN_4W_TPS	$MEDIAN_4
MEDIAN_8W_TPS	$MEDIAN_8
MEDIAN_16W_TPS	$MEDIAN_16
MEDIAN_SPEEDUP_4W	$SPEEDUP_4
MEDIAN_SPEEDUP_8W	$SPEEDUP_8
MEDIAN_SPEEDUP_16W	$SPEEDUP_16
MEDIAN_8W_VS_4W_DELTA_PCT	$DELTA_8_VS_4_PCT
A2_4_8_CLASSIFICATION	$CLASS_4_8
A2_16W_CLASSIFICATION	$REGRESSION_16
EFFECT_THRESHOLD_PCT	$EFFECT_THRESHOLD_PCT
ENGINEERING_CHANGE	NO
LOCK_CONTENTION_ROOT_CAUSE	NOT_MEASURED_IN_A2
SUMMARY_EOF

(
    cd "$STAGE"

    find . \
        -type f \
        ! -path './evidence/SHA256SUMS' \
        ! -path './evidence/SHA256SUMS.check' \
        -print |
    LC_ALL=C sort |
    sed 's#^\./##' |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
) || postlock_fail "EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "EVIDENCE_INTEGRITY=PASS"
echo "A2_EVIDENCE_MANIFEST_SHA256=$MANIFEST_SHA256"

section "7. A2 VERDICT"

echo "SEEKER_C23_SWARM_SCALING_002_A2=PASS"
echo "REPETITIONS_PER_WORKER=$REPETITIONS"
echo "MEASURED_SCENARIOS=128"
echo "A2_4_8_CLASSIFICATION=$CLASS_4_8"
echo "A2_16W_CLASSIFICATION=$REGRESSION_16"
echo "LOCK_CONTENTION_ROOT_CAUSE=NOT_MEASURED_IN_A2"
echo "ENGINEERING_CHANGE=NO"
echo "A2_RERUN=NO"
echo "NEXT_GATE=A3_LOCK_INSTRUMENTATION"

exit 0
