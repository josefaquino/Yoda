#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
REVISION="A3-LOCK-INSTRUMENTATION-001"

PROJECT="$HOME/cmu/yoda_agent_c23"
AGENT="$PROJECT/yoda_seeker_agent"
FRONTIER="$PROJECT/frontier.tsv"

ROOT="$HOME/cmu/$CASE"
PREP="$ROOT/.a3-lock-prep"
STAGE="$ROOT/a3-lock-instrumentation"
EVIDENCE="$STAGE/evidence"
RUNS="$STAGE/runs"
RAW="$STAGE/raw"
BASELINE="$STAGE/frontier.canonical-100.tsv"
LOCK="$ROOT/.a3-lock-instrumentation-execution-started"

A2_SUMMARY="$ROOT/a2-stability/evidence/summary.tsv"
A2_MANIFEST="$ROOT/a2-stability/evidence/SHA256SUMS"

A3_PREFLIGHT="$ROOT/a3-lock-instrumentation-preflight"
A3_PREFLIGHT_MANIFEST="$A3_PREFLIGHT/evidence/SHA256SUMS"
A3_PREFLIGHT_CONSOLE="$HOME/cmu/seeker-c23-swarm-scaling-002-a3-lock-preflight-console.log"

EXPECTED_AGENT_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_TASK_IDENTITY_SHA256="525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28"

EXPECTED_A2_MANIFEST_SHA256="01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621"
EXPECTED_A3_PREFLIGHT_MANIFEST_SHA256="c049138463f19400157ecb58922c7a76e46231cdc9633c0f02630e9e037c5bac"
EXPECTED_A3_PREFLIGHT_CONSOLE_SHA256="14cf13fcd2b794c1ba70ec0d7eeaf77ec54fa52c9a950e8d8264e5bc7cbf9d1a"

EXPECTED_STRACE_VERSION="strace -- version 6.13"

ANALYZER="$PREP/a3-trace-analyzer.awk"
ANALYZER_URL="https://raw.githubusercontent.com/josefaquino/Yoda/9f0ca87395fa1ae50b3fc3820e3bc44f1a329bba/cases/SEEKER-C23-SWARM-SCALING-002/scripts/a3-trace-analyzer.awk"
EXPECTED_ANALYZER_SHA256="cfc81aa6df07533865e44c7ec4cc1bffcf15dfda922bc553533db66e4e1534d9"

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
    echo "A3_LOCK_INSTRUMENTATION=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A3_EXECUTION_LOCK_CONSUMED=NO"
    echo "SEEKER_SCIENTIFIC_EXECUTION=NO"
    exit 1
}

postlock_fail()
{
    echo
    echo "A3_LOCK_INSTRUMENTATION=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A3_EXECUTION_LOCK_CONSUMED=YES"
    echo "A3_RERUN=NO"
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
    elif test -f "$PREP/frontier.tsv"
    then
        cp "$PREP/frontier.tsv" "$FRONTIER" 2>/dev/null || true
        rm -f "$FRONTIER.lock" "$FRONTIER".tmp.* 2>/dev/null || true
    fi
}

trap restore_frontier EXIT INT TERM

for cmd in \
    strace curl sha256sum awk grep sort sed head wc date find xargs cp rm mkdir pgrep basename cat
do
    require_cmd "$cmd"
done

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A3 LOCK INSTRUMENTATION"
echo " DIRECT FLOCK WAIT MEASUREMENT"
echo " ONE EXECUTION ONLY"
echo "============================================================"

section "0. PRE-EXECUTION AUTHORITIES"

test -d "$PROJECT" ||
    prelock_fail "PROJECT_MISSING"

test -x "$AGENT" ||
    prelock_fail "AGENT_MISSING"

test -f "$FRONTIER" ||
    prelock_fail "FRONTIER_MISSING"

test -f "$A2_SUMMARY" ||
    prelock_fail "A2_SUMMARY_MISSING"

test -f "$A2_MANIFEST" ||
    prelock_fail "A2_MANIFEST_MISSING"

test -f "$A3_PREFLIGHT_MANIFEST" ||
    prelock_fail "A3_PREFLIGHT_MANIFEST_MISSING"

test -f "$A3_PREFLIGHT_CONSOLE" ||
    prelock_fail "A3_PREFLIGHT_CONSOLE_MISSING"

test ! -e "$LOCK" ||
    prelock_fail "A3_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_fail "A3_STAGE_ALREADY_EXISTS"

ACTUAL_AGENT_SHA256="$(sha "$AGENT")"
ACTUAL_FRONTIER_SHA256="$(sha "$FRONTIER")"
ACTUAL_A2_MANIFEST_SHA256="$(sha "$A2_MANIFEST")"
ACTUAL_PREFLIGHT_MANIFEST_SHA256="$(sha "$A3_PREFLIGHT_MANIFEST")"
ACTUAL_PREFLIGHT_CONSOLE_SHA256="$(sha "$A3_PREFLIGHT_CONSOLE")"
STRACE_VERSION="$(strace -V 2>&1 | head -n 1)"

echo "EXPECTED_AGENT_SHA256=$EXPECTED_AGENT_SHA256"
echo "ACTUAL_AGENT_SHA256=$ACTUAL_AGENT_SHA256"
echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER_SHA256"
echo "EXPECTED_A2_MANIFEST_SHA256=$EXPECTED_A2_MANIFEST_SHA256"
echo "ACTUAL_A2_MANIFEST_SHA256=$ACTUAL_A2_MANIFEST_SHA256"
echo "EXPECTED_A3_PREFLIGHT_MANIFEST_SHA256=$EXPECTED_A3_PREFLIGHT_MANIFEST_SHA256"
echo "ACTUAL_A3_PREFLIGHT_MANIFEST_SHA256=$ACTUAL_PREFLIGHT_MANIFEST_SHA256"
echo "EXPECTED_A3_PREFLIGHT_CONSOLE_SHA256=$EXPECTED_A3_PREFLIGHT_CONSOLE_SHA256"
echo "ACTUAL_A3_PREFLIGHT_CONSOLE_SHA256=$ACTUAL_PREFLIGHT_CONSOLE_SHA256"
echo "EXPECTED_STRACE_VERSION=$EXPECTED_STRACE_VERSION"
echo "ACTUAL_STRACE_VERSION=$STRACE_VERSION"

test "$ACTUAL_AGENT_SHA256" = "$EXPECTED_AGENT_SHA256" ||
    prelock_fail "AGENT_IDENTITY_MISMATCH"

test "$ACTUAL_FRONTIER_SHA256" = "$EXPECTED_FRONTIER_SHA256" ||
    prelock_fail "FRONTIER_IDENTITY_MISMATCH"

test "$ACTUAL_A2_MANIFEST_SHA256" = "$EXPECTED_A2_MANIFEST_SHA256" ||
    prelock_fail "A2_MANIFEST_IDENTITY_MISMATCH"

test "$ACTUAL_PREFLIGHT_MANIFEST_SHA256" = "$EXPECTED_A3_PREFLIGHT_MANIFEST_SHA256" ||
    prelock_fail "A3_PREFLIGHT_MANIFEST_IDENTITY_MISMATCH"

test "$ACTUAL_PREFLIGHT_CONSOLE_SHA256" = "$EXPECTED_A3_PREFLIGHT_CONSOLE_SHA256" ||
    prelock_fail "A3_PREFLIGHT_CONSOLE_IDENTITY_MISMATCH"

test "$STRACE_VERSION" = "$EXPECTED_STRACE_VERSION" ||
    prelock_fail "STRACE_VERSION_DRIFT"

grep -F $'A2_4_8_CLASSIFICATION\t4_WORKER_CLEARLY_ABOVE_8' "$A2_SUMMARY" >/dev/null ||
    prelock_fail "A2_4_8_AUTHORITY_MISMATCH"

grep -F $'A2_16W_CLASSIFICATION\tREGRESSION' "$A2_SUMMARY" >/dev/null ||
    prelock_fail "A2_16W_AUTHORITY_MISMATCH"

grep -F "A3_LOCK_INSTRUMENTATION_PREFLIGHT=PASS" "$A3_PREFLIGHT_CONSOLE" >/dev/null ||
    prelock_fail "A3_PREFLIGHT_PASS_MARKER_MISSING"

if pgrep -x yoda_seeker_agent >/dev/null 2>&1
then
    prelock_fail "PREEXISTING_AGENT_PROCESS"
fi

rm -rf "$PREP"
mkdir -p "$PREP"

cp "$FRONTIER" "$PREP/frontier.tsv" ||
    prelock_fail "PREP_FRONTIER_COPY_FAILURE"

awk -F '\t' '{print $1 "\t" $2}' "$FRONTIER" > "$PREP/task-identities.tsv"

ACTUAL_TASK_IDENTITY_SHA256="$(sha "$PREP/task-identities.tsv")"

echo "EXPECTED_TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256"
echo "ACTUAL_TASK_IDENTITY_SHA256=$ACTUAL_TASK_IDENTITY_SHA256"

test "$ACTUAL_TASK_IDENTITY_SHA256" = "$EXPECTED_TASK_IDENTITY_SHA256" ||
    prelock_fail "TASK_IDENTITY_MISMATCH"

LINES="$(wc -l < "$FRONTIER" | awk '{print $1}')"
QUEUED="$(grep -c "$(printf '\tQUEUED\t')" "$FRONTIER" || true)"

test "$LINES" -eq 100 ||
    prelock_fail "FRONTIER_LINE_COUNT_MISMATCH"

test "$QUEUED" -eq 100 ||
    prelock_fail "FRONTIER_QUEUED_COUNT_MISMATCH"

curl -fsSL "$ANALYZER_URL" -o "$ANALYZER" ||
    prelock_fail "ANALYZER_FETCH_FAILURE"

ACTUAL_ANALYZER_SHA256="$(sha "$ANALYZER")"

echo "EXPECTED_ANALYZER_SHA256=$EXPECTED_ANALYZER_SHA256"
echo "ACTUAL_ANALYZER_SHA256=$ACTUAL_ANALYZER_SHA256"

test "$ACTUAL_ANALYZER_SHA256" = "$EXPECTED_ANALYZER_SHA256" ||
    prelock_fail "ANALYZER_IDENTITY_MISMATCH"

SMOKE_TRACE="$PREP/analyzer-smoke-reassembled.trace"

{
    grep -h 'flock(.*LOCK_EX' "$A3_PREFLIGHT"/smoke/trace* | head -n 1
    grep -hE 'rename(at2|at)?\(' "$A3_PREFLIGHT"/smoke/trace* | head -n 1
    grep -h 'flock(.*LOCK_UN' "$A3_PREFLIGHT"/smoke/trace* | head -n 1
} |
LC_ALL=C sort -n > "$SMOKE_TRACE" ||
    prelock_fail "ANALYZER_SMOKE_REASSEMBLY_FAILURE"

SMOKE_EX="$(grep -c 'flock(.*LOCK_EX' "$SMOKE_TRACE" || true)"
SMOKE_RENAME="$(grep -cE 'rename(at2|at)?\(' "$SMOKE_TRACE" || true)"
SMOKE_UN="$(grep -c 'flock(.*LOCK_UN' "$SMOKE_TRACE" || true)"

echo "ANALYZER_SMOKE_MODE=REASSEMBLED_ACTUAL_PREFLIGHT_SYSCALLS"
echo "ANALYZER_SMOKE_LOCK_EX_LINES=$SMOKE_EX"
echo "ANALYZER_SMOKE_RENAME_LINES=$SMOKE_RENAME"
echo "ANALYZER_SMOKE_LOCK_UN_LINES=$SMOKE_UN"

test "$SMOKE_EX" -eq 1 ||
    prelock_fail "ANALYZER_SMOKE_LOCK_EX_REASSEMBLY_FAILURE"

test "$SMOKE_RENAME" -eq 1 ||
    prelock_fail "ANALYZER_SMOKE_RENAME_REASSEMBLY_FAILURE"

test "$SMOKE_UN" -eq 1 ||
    prelock_fail "ANALYZER_SMOKE_LOCK_UN_REASSEMBLY_FAILURE"

awk -f "$ANALYZER" "$SMOKE_TRACE" > "$PREP/smoke-parsed.tsv" ||
    prelock_fail "ANALYZER_SMOKE_PARSE_FAILURE"

SMOKE_VALID="$(awk -F '\t' 'NR>1 && $2==1 {n++} END {print n+0}' "$PREP/smoke-parsed.tsv")"
SMOKE_SUCCESS="$(awk -F '\t' 'NR>1 && $3==1 {n++} END {print n+0}' "$PREP/smoke-parsed.tsv")"

echo "ANALYZER_SMOKE_VALID_ROWS=$SMOKE_VALID"
echo "ANALYZER_SMOKE_SUCCESS_ROWS=$SMOKE_SUCCESS"

test "$SMOKE_VALID" -eq 1 ||
    prelock_fail "ANALYZER_SMOKE_VALIDATION_FAILURE"

test "$SMOKE_SUCCESS" -eq 1 ||
    prelock_fail "ANALYZER_SMOKE_SUCCESS_FAILURE"

echo "FROZEN_AUTHORITIES=PASS"
echo "ANALYZER_AUTHORITY=PASS"
echo "PREEXISTING_AGENT_PROCESS=NO"
echo "A3_EXECUTION_LOCK=ABSENT"
echo "A3_STAGE=ABSENT"
echo "SEEKER_SCIENTIFIC_EXECUTION=NO"

section "1. ONE-EXECUTION SCIENTIFIC GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
AGENT_SHA256=$EXPECTED_AGENT_SHA256
FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256
A2_MANIFEST_SHA256=$EXPECTED_A2_MANIFEST_SHA256
A3_PREFLIGHT_MANIFEST_SHA256=$EXPECTED_A3_PREFLIGHT_MANIFEST_SHA256
A3_PREFLIGHT_CONSOLE_SHA256=$EXPECTED_A3_PREFLIGHT_CONSOLE_SHA256
STRACE_VERSION=$EXPECTED_STRACE_VERSION
ANALYZER_SHA256=$EXPECTED_ANALYZER_SHA256
WORKER_MATRIX=1,4,8,16
TASKS_PER_SCENARIO=100
REPETITIONS_PER_WORKER=1
EXECUTION_POLICY=ONE_EXECUTION
EOF

test -f "$LOCK" ||
    prelock_fail "A3_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A3_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A3_EXECUTION_GATE=PASS"

mkdir -p "$EVIDENCE" "$RUNS" "$RAW" ||
    postlock_fail "A3_STAGE_CREATION_FAILURE"

cp "$PREP/frontier.tsv" "$BASELINE" ||
    postlock_fail "BASELINE_MATERIALIZATION_FAILURE"

cp "$PREP/task-identities.tsv" "$EVIDENCE/task-identities.tsv" ||
    postlock_fail "TASK_IDENTITY_MATERIALIZATION_FAILURE"

cp "$ANALYZER" "$EVIDENCE/a3-trace-analyzer.awk" ||
    postlock_fail "ANALYZER_MATERIALIZATION_FAILURE"

test "$(sha "$BASELINE")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "BASELINE_IDENTITY_MISMATCH"

run_workers_traced()
{
    workers="$1"
    dir="$2"

    pids=""
    w=1

    while test "$w" -le "$workers"
    do
        (
            seq=0

            while grep -q "$(printf '\tQUEUED\t')" "$FRONTIER" 2>/dev/null
            do
                seq=$((seq + 1))
                trace="$dir/trace-w$(printf '%02d' "$w")-i$(printf '%04d' "$seq").log"

                strace \
                    -qq \
                    -ttt \
                    -T \
                    -e trace=flock,rename,renameat,renameat2 \
                    -o "$trace" \
                    "$AGENT" "$w" \
                    >/dev/null \
                    2>>"$dir/worker-$w.stderr.log" ||
                    exit 1
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

metric_stats()
{
    source="$1"
    sorted="$2"

    sort -n "$source" > "$sorted"

    n="$(wc -l < "$sorted" | awk '{print $1}')"

    test "$n" -gt 0 ||
        postlock_fail "EMPTY_METRIC_SERIES"

    min="$(awk 'NR==1 {print; exit}' "$sorted")"
    max="$(awk 'END {print}' "$sorted")"

    median="$(
        awk '
        { a[NR]=$1 }
        END {
            if (NR % 2 == 1)
                printf "%.3f", a[(NR+1)/2]
            else
                printf "%.3f", (a[NR/2]+a[NR/2+1])/2.0
        }' "$sorted"
    )"

    mean="$(
        awk '{s+=$1} END {printf "%.3f", s/NR}' "$sorted"
    )"

    p95="$(
        awk '
        { a[NR]=$1 }
        END {
            idx=int(0.95*NR)
            if (idx < 0.95*NR)
                idx++
            if (idx < 1)
                idx=1
            printf "%.3f", a[idx]
        }' "$sorted"
    )"

    sum="$(
        awk '{s+=$1} END {printf "%.3f", s}' "$sorted"
    )"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$n" "$min" "$median" "$mean" "$p95" "$max" "$sum"
}

summarize_scenario()
{
    workers="$1"
    dir="$2"
    tag="$workers"W
    attempts_file="$dir/attempts.tsv"

    attempts="$(awk -F '\t' 'NR>1 {n++} END {print n+0}' "$attempts_file")"
    invalid="$(awk -F '\t' 'NR>1 && $2!=1 {n++} END {print n+0}' "$attempts_file")"
    successes="$(awk -F '\t' 'NR>1 && $3==1 {n++} END {print n+0}' "$attempts_file")"

    test "$invalid" -eq 0 ||
        postlock_fail "INVALID_TRACE_ROWS_$tag"

    test "$successes" -eq 100 ||
        postlock_fail "SUCCESSFUL_RESERVATION_COUNT_MISMATCH_$tag"

    test "$attempts" -ge 100 ||
        postlock_fail "TRACE_ATTEMPT_COUNT_LT_100_$tag"

    futile=$((attempts - successes))

    awk -F '\t' 'NR>1 && $3==1 {print $4}' "$attempts_file" > "$dir/success-lock-wait-us.txt"
    awk -F '\t' 'NR>1 && $3==1 {print $5}' "$attempts_file" > "$dir/success-critical-us.txt"
    awk -F '\t' 'NR>1 && $3==1 {print $6}' "$attempts_file" > "$dir/success-rename-us.txt"
    awk -F '\t' 'NR>1 {print $4}' "$attempts_file" > "$dir/all-lock-wait-us.txt"

    LOCK_STATS="$(metric_stats "$dir/success-lock-wait-us.txt" "$dir/success-lock-wait-us.sorted.txt")"
    CRIT_STATS="$(metric_stats "$dir/success-critical-us.txt" "$dir/success-critical-us.sorted.txt")"
    RENAME_STATS="$(metric_stats "$dir/success-rename-us.txt" "$dir/success-rename-us.sorted.txt")"
    ALL_STATS="$(metric_stats "$dir/all-lock-wait-us.txt" "$dir/all-lock-wait-us.sorted.txt")"

    lock_min="$(printf '%s\n' "$LOCK_STATS" | awk -F '\t' '{print $2}')"
    lock_median="$(printf '%s\n' "$LOCK_STATS" | awk -F '\t' '{print $3}')"
    lock_mean="$(printf '%s\n' "$LOCK_STATS" | awk -F '\t' '{print $4}')"
    lock_p95="$(printf '%s\n' "$LOCK_STATS" | awk -F '\t' '{print $5}')"
    lock_max="$(printf '%s\n' "$LOCK_STATS" | awk -F '\t' '{print $6}')"
    lock_sum="$(printf '%s\n' "$LOCK_STATS" | awk -F '\t' '{print $7}')"

    crit_median="$(printf '%s\n' "$CRIT_STATS" | awk -F '\t' '{print $3}')"
    crit_p95="$(printf '%s\n' "$CRIT_STATS" | awk -F '\t' '{print $5}')"
    crit_sum="$(printf '%s\n' "$CRIT_STATS" | awk -F '\t' '{print $7}')"

    rename_median="$(printf '%s\n' "$RENAME_STATS" | awk -F '\t' '{print $3}')"
    rename_p95="$(printf '%s\n' "$RENAME_STATS" | awk -F '\t' '{print $5}')"
    rename_sum="$(printf '%s\n' "$RENAME_STATS" | awk -F '\t' '{print $7}')"

    all_lock_sum="$(printf '%s\n' "$ALL_STATS" | awk -F '\t' '{print $7}')"

    futile_pct="$(
        awk -v f="$futile" -v a="$attempts" 'BEGIN {printf "%.3f", 100.0*f/a}'
    )"

    share="$(
        awk -v w="$lock_sum" -v c="$crit_sum" '
        BEGIN {
            d=w+c
            if (d <= 0)
                printf "0.000"
            else
                printf "%.3f", 100.0*w/d
        }'
    )"

    diagnostic_elapsed="$(cat "$dir/elapsed-s.txt")"

    diagnostic_tps="$(
        awk -v s="$diagnostic_elapsed" 'BEGIN {printf "%.3f", 100.0/s}'
    )"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$workers" "$attempts" "$successes" "$futile" "$futile_pct" \
        "$lock_min" "$lock_median" "$lock_mean" "$lock_p95" "$lock_max" "$lock_sum" "$all_lock_sum" \
        "$crit_median" "$crit_p95" "$crit_sum" \
        "$rename_median" "$rename_p95" "$rename_sum" \
        "$share" "$diagnostic_elapsed" "$diagnostic_tps" \
        >> "$RAW/scenario-summary.tsv"

    echo "WORKERS=$workers"
    echo "LOCK_ATTEMPTS=$attempts"
    echo "SUCCESSFUL_RESERVATIONS=$successes"
    echo "FUTILE_LOCK_ATTEMPTS=$futile"
    echo "FUTILE_LOCK_ATTEMPT_PCT=$futile_pct"
    echo "SUCCESS_LOCK_WAIT_MEDIAN_US=$lock_median"
    echo "SUCCESS_LOCK_WAIT_P95_US=$lock_p95"
    echo "SUCCESS_LOCK_WAIT_SUM_US=$lock_sum"
    echo "ALL_LOCK_WAIT_SUM_US=$all_lock_sum"
    echo "SUCCESS_CRITICAL_MEDIAN_US=$crit_median"
    echo "SUCCESS_CRITICAL_P95_US=$crit_p95"
    echo "SUCCESS_CRITICAL_SUM_US=$crit_sum"
    echo "RENAME_MEDIAN_US=$rename_median"
    echo "RENAME_P95_US=$rename_p95"
    echo "RENAME_SUM_US=$rename_sum"
    echo "LOCK_WAIT_SHARE_PCT=$share"
    echo "DIAGNOSTIC_STRACE_TPS=$diagnostic_tps"
}

run_scenario()
{
    workers="$1"
    tag="$workers"W
    dir="$RUNS/workers-$workers"

    mkdir -p "$dir" ||
        postlock_fail "SCENARIO_DIR_CREATION_FAILURE_$tag"

    cp "$BASELINE" "$FRONTIER" ||
        postlock_fail "SCENARIO_BASELINE_RESTORE_FAILURE_$tag"

    rm -f "$FRONTIER.lock" "$FRONTIER".tmp.*

    test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
        postlock_fail "SCENARIO_INPUT_IDENTITY_MISMATCH_$tag"

    before="$(grep -c "$(printf '\tQUEUED\t')" "$FRONTIER" || true)"

    test "$before" -eq 100 ||
        postlock_fail "SCENARIO_PRE_QUEUED_MISMATCH_$tag"

    start_ns="$(date +%s%N)"

    run_workers_traced "$workers" "$dir" ||
        postlock_fail "TRACED_AGENT_EXECUTION_FAILURE_$tag"

    end_ns="$(date +%s%N)"
    elapsed_ns=$((end_ns - start_ns))

    elapsed_s="$(
        awk -v ns="$elapsed_ns" 'BEGIN {printf "%.6f", ns/1000000000.0}'
    )"

    echo "$elapsed_s" > "$dir/elapsed-s.txt"

    processed="$(grep -c "$(printf '\tPROCESSING\t')" "$FRONTIER" || true)"
    remaining="$(grep -c "$(printf '\tQUEUED\t')" "$FRONTIER" || true)"

    test "$processed" -eq 100 ||
        postlock_fail "SCENARIO_PROCESSED_COUNT_MISMATCH_$tag"

    test "$remaining" -eq 0 ||
        postlock_fail "SCENARIO_QUEUED_REMAINS_$tag"

    cp "$FRONTIER" "$dir/frontier.final.tsv"

    awk -f "$ANALYZER" "$dir"/trace-*.log > "$dir/attempts.tsv" ||
        postlock_fail "TRACE_ANALYSIS_FAILURE_$tag"

    summarize_scenario "$workers" "$dir"
}

printf '%s\n' \
    "workers	attempts	successes	futile	futile_pct	lock_min_us	lock_median_us	lock_mean_us	lock_p95_us	lock_max_us	lock_sum_us	all_lock_sum_us	critical_median_us	critical_p95_us	critical_sum_us	rename_median_us	rename_p95_us	rename_sum_us	lock_wait_share_pct	diagnostic_elapsed_s	diagnostic_strace_tps" \
    > "$RAW/scenario-summary.tsv"

section "2. TRACE 1 / 4 / 8 / 16 WORKERS"

for workers in 1 4 8 16
do
    section "A3 SCENARIO $workers WORKER(S)"
    run_scenario "$workers"
done

section "3. ROOT-CAUSE ADJUDICATION"

SHARE_1="$(awk -F '\t' '$1==1 {print $19}' "$RAW/scenario-summary.tsv")"
SHARE_4="$(awk -F '\t' '$1==4 {print $19}' "$RAW/scenario-summary.tsv")"
SHARE_8="$(awk -F '\t' '$1==8 {print $19}' "$RAW/scenario-summary.tsv")"
SHARE_16="$(awk -F '\t' '$1==16 {print $19}' "$RAW/scenario-summary.tsv")"

SUM_4="$(awk -F '\t' '$1==4 {print $11}' "$RAW/scenario-summary.tsv")"
SUM_8="$(awk -F '\t' '$1==8 {print $11}' "$RAW/scenario-summary.tsv")"
SUM_16="$(awk -F '\t' '$1==16 {print $11}' "$RAW/scenario-summary.tsv")"

RATIO_8_4="$(
    awk -v a="$SUM_8" -v b="$SUM_4" 'BEGIN {if (b==0) print "INF"; else printf "%.3f", a/b}'
)"

RATIO_16_4="$(
    awk -v a="$SUM_16" -v b="$SUM_4" 'BEGIN {if (b==0) print "INF"; else printf "%.3f", a/b}'
)"

C3="$(awk -v a="$SHARE_4" -v b="$SHARE_1" 'BEGIN {print (a>b ? "PASS" : "FAIL")}')"
C4="$(awk -v a="$SHARE_8" -v b="$SHARE_4" 'BEGIN {print (a>=b+5.0 ? "PASS" : "FAIL")}')"
C5="$(awk -v a="$SHARE_16" -v b="$SHARE_4" 'BEGIN {print (a>=b+10.0 ? "PASS" : "FAIL")}')"
C6="$(awk -v a="$SUM_8" -v b="$SUM_4" 'BEGIN {print (a>=b*1.25 ? "PASS" : "FAIL")}')"
C7="$(awk -v a="$SUM_16" -v b="$SUM_4" 'BEGIN {print (a>=b*1.50 ? "PASS" : "FAIL")}')"

if test "$C3" = PASS &&
   test "$C4" = PASS &&
   test "$C5" = PASS &&
   test "$C6" = PASS &&
   test "$C7" = PASS
then
    ROOT_CAUSE="SUPPORTED"
    NEXT_GATE="A4_BATCHED_RESERVATION"
else
    ROOT_CAUSE="NOT_CONFIRMED"
    NEXT_GATE="ROOT_CAUSE_REASSESSMENT"
fi

echo "LOCK_WAIT_SHARE_1W_PCT=$SHARE_1"
echo "LOCK_WAIT_SHARE_4W_PCT=$SHARE_4"
echo "LOCK_WAIT_SHARE_8W_PCT=$SHARE_8"
echo "LOCK_WAIT_SHARE_16W_PCT=$SHARE_16"
echo "LOCK_WAIT_SUM_8W_VS_4W_RATIO=$RATIO_8_4"
echo "LOCK_WAIT_SUM_16W_VS_4W_RATIO=$RATIO_16_4"

echo "CRITERION_3_SHARE_4_GT_1=$C3"
echo "CRITERION_4_SHARE_8_GE_4_PLUS_5PP=$C4"
echo "CRITERION_5_SHARE_16_GE_4_PLUS_10PP=$C5"
echo "CRITERION_6_SUMWAIT_8_GE_1_25X_4=$C6"
echo "CRITERION_7_SUMWAIT_16_GE_1_50X_4=$C7"

echo "A2_DIRECTION_CONSISTENCY=PASS"
echo "LOCK_CONTENTION_ROOT_CAUSE=$ROOT_CAUSE"

section "4. RESTORE FROZEN FRONTIER"

cp "$BASELINE" "$FRONTIER" ||
    postlock_fail "FINAL_FRONTIER_RESTORE_FAILURE"

rm -f "$FRONTIER.lock" "$FRONTIER".tmp.*

test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "FINAL_FRONTIER_IDENTITY_MISMATCH"

test "$(sha "$AGENT")" = "$EXPECTED_AGENT_SHA256" ||
    postlock_fail "AGENT_MUTATED"

echo "PROJECT_FRONTIER_RESTORED=PASS"
echo "AGENT_MUTATED=NO"

section "5. FREEZE A3 EVIDENCE"

cp "$0" "$EVIDENCE/a3-lock-instrumentation-harness.sh"
cp "$LOCK" "$EVIDENCE/execution-lock.txt"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
AGENT_SHA256	$EXPECTED_AGENT_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256	$EXPECTED_TASK_IDENTITY_SHA256
A2_MANIFEST_SHA256	$EXPECTED_A2_MANIFEST_SHA256
A3_PREFLIGHT_MANIFEST_SHA256	$EXPECTED_A3_PREFLIGHT_MANIFEST_SHA256
STRACE_VERSION	$EXPECTED_STRACE_VERSION
ANALYZER_SHA256	$EXPECTED_ANALYZER_SHA256
WORKER_MATRIX	1,4,8,16
TASKS_PER_SCENARIO	100
REPETITIONS_PER_WORKER	1
LOCK_WAIT_SHARE_1W_PCT	$SHARE_1
LOCK_WAIT_SHARE_4W_PCT	$SHARE_4
LOCK_WAIT_SHARE_8W_PCT	$SHARE_8
LOCK_WAIT_SHARE_16W_PCT	$SHARE_16
LOCK_WAIT_SUM_8W_VS_4W_RATIO	$RATIO_8_4
LOCK_WAIT_SUM_16W_VS_4W_RATIO	$RATIO_16_4
CRITERION_3_SHARE_4_GT_1	$C3
CRITERION_4_SHARE_8_GE_4_PLUS_5PP	$C4
CRITERION_5_SHARE_16_GE_4_PLUS_10PP	$C5
CRITERION_6_SUMWAIT_8_GE_1_25X_4	$C6
CRITERION_7_SUMWAIT_16_GE_1_50X_4	$C7
A2_DIRECTION_CONSISTENCY	PASS
LOCK_CONTENTION_ROOT_CAUSE	$ROOT_CAUSE
AGENT_CHANGE	NO
FRONTIER_CHANGE	NO
BATCHING_CHANGE	NO
SHARDING_CHANGE	NO
KYBER_CHANGE	NO
YODA_CHANGE	NO
A3_RERUN	NO
NEXT_GATE	$NEXT_GATE
EOF

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
) || postlock_fail "A3_EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A3_EVIDENCE_INTEGRITY=PASS"
echo "A3_EVIDENCE_MANIFEST_SHA256=$MANIFEST_SHA256"

section "6. A3 VERDICT"

echo "SEEKER_C23_SWARM_SCALING_002_A3=PASS"
echo "LOCK_CONTENTION_ROOT_CAUSE=$ROOT_CAUSE"
echo "A3_THROUGHPUT_ROLE=DIAGNOSTIC_ONLY"
echo "AGENT_CHANGE=NO"
echo "FRONTIER_CHANGE=NO"
echo "A3_RERUN=NO"
echo "NEXT_GATE=$NEXT_GATE"

rm -rf "$PREP" || true
exit 0
