#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
REVISION="A5-BATCH-LOCK-DIAGNOSTIC-001"

PROJECT="$HOME/cmu/yoda_agent_c23"
ROOT="$HOME/cmu/$CASE"

CONTROL="$PROJECT/yoda_seeker_agent"
PROJECT_FRONTIER="$PROJECT/frontier.tsv"

R1="$ROOT/a4-r1-candidate-build"
CANDIDATE="$R1/candidate/yoda_seeker_agent"

R2="$ROOT/a4-r2-controlled-performance"
R2_MANIFEST="$R2/evidence/SHA256SUMS"

A3="$ROOT/a3-lock-instrumentation"
ANALYZER="$A3/evidence/a3-trace-analyzer.awk"

PREP="$ROOT/.a5-batch-lock-prep"
STAGE="$ROOT/a5-batch-lock-diagnostic"
EVIDENCE="$STAGE/evidence"
RUNS="$STAGE/runs"
RAW="$STAGE/raw"
BASELINE="$STAGE/frontier.canonical-100.tsv"
LOCK="$ROOT/.a5-batch-lock-diagnostic-started"

EXPECTED_CONTROL_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_CANDIDATE_SHA256="0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_TASK_IDENTITY_SHA256="525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28"
EXPECTED_R2_MANIFEST_SHA256="a35f380aa7f53e798700cd74a29d2f4a277cace5ff843196de1abccc3de2bfcc"
EXPECTED_ANALYZER_SHA256="cfc81aa6df07533865e44c7ec4cc1bffcf15dfda922bc553533db66e4e1534d9"
EXPECTED_STRACE_VERSION="strace -- version 6.13"

REPETITIONS=4

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
    echo "A5_BATCH_LOCK_DIAGNOSTIC=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A5_EXECUTION_LOCK_CONSUMED=NO"
    echo "MEASURED_SCENARIOS=0"
    exit 1
}

postlock_fail()
{
    echo
    echo "A5_BATCH_LOCK_DIAGNOSTIC=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A5_EXECUTION_LOCK_CONSUMED=YES"
    echo "A5_RERUN=NO"
    exit 2
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        prelock_fail "MISSING_COMMAND_$1"
}

for cmd in \
    strace sha256sum awk grep sort cp rm mkdir wc date find xargs pgrep head
do
    require_cmd "$cmd"
done

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A5 BATCH LOCK DIAGNOSTIC"
echo " CONTROL VS BATCH-4 UNDER STRACE"
echo " 4 REPETITIONS PER ARM / WORKER COUNT"
echo "============================================================"

section "0. PRE-EXECUTION AUTHORITIES"

test -x "$CONTROL" ||
    prelock_fail "CONTROL_BINARY_MISSING"

test -x "$CANDIDATE" ||
    prelock_fail "CANDIDATE_BINARY_MISSING"

test -f "$PROJECT_FRONTIER" ||
    prelock_fail "PROJECT_FRONTIER_MISSING"

test -f "$R2_MANIFEST" ||
    prelock_fail "R2_MANIFEST_MISSING"

test -f "$ANALYZER" ||
    prelock_fail "A3_ANALYZER_MISSING"

test ! -e "$LOCK" ||
    prelock_fail "A5_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_fail "A5_STAGE_ALREADY_EXISTS"

ACTUAL_CONTROL_SHA256="$(sha "$CONTROL")"
ACTUAL_CANDIDATE_SHA256="$(sha "$CANDIDATE")"
ACTUAL_FRONTIER_SHA256="$(sha "$PROJECT_FRONTIER")"
ACTUAL_R2_MANIFEST_SHA256="$(sha "$R2_MANIFEST")"
ACTUAL_ANALYZER_SHA256="$(sha "$ANALYZER")"
ACTUAL_STRACE_VERSION="$(strace -V 2>&1 | head -n 1)"

echo "EXPECTED_CONTROL_SHA256=$EXPECTED_CONTROL_SHA256"
echo "ACTUAL_CONTROL_SHA256=$ACTUAL_CONTROL_SHA256"
echo "EXPECTED_CANDIDATE_SHA256=$EXPECTED_CANDIDATE_SHA256"
echo "ACTUAL_CANDIDATE_SHA256=$ACTUAL_CANDIDATE_SHA256"
echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER_SHA256"
echo "EXPECTED_R2_MANIFEST_SHA256=$EXPECTED_R2_MANIFEST_SHA256"
echo "ACTUAL_R2_MANIFEST_SHA256=$ACTUAL_R2_MANIFEST_SHA256"
echo "EXPECTED_ANALYZER_SHA256=$EXPECTED_ANALYZER_SHA256"
echo "ACTUAL_ANALYZER_SHA256=$ACTUAL_ANALYZER_SHA256"
echo "EXPECTED_STRACE_VERSION=$EXPECTED_STRACE_VERSION"
echo "ACTUAL_STRACE_VERSION=$ACTUAL_STRACE_VERSION"

test "$ACTUAL_CONTROL_SHA256" = "$EXPECTED_CONTROL_SHA256" ||
    prelock_fail "CONTROL_BINARY_IDENTITY_MISMATCH"

test "$ACTUAL_CANDIDATE_SHA256" = "$EXPECTED_CANDIDATE_SHA256" ||
    prelock_fail "CANDIDATE_BINARY_IDENTITY_MISMATCH"

test "$ACTUAL_FRONTIER_SHA256" = "$EXPECTED_FRONTIER_SHA256" ||
    prelock_fail "PROJECT_FRONTIER_IDENTITY_MISMATCH"

test "$ACTUAL_R2_MANIFEST_SHA256" = "$EXPECTED_R2_MANIFEST_SHA256" ||
    prelock_fail "R2_MANIFEST_IDENTITY_MISMATCH"

test "$ACTUAL_ANALYZER_SHA256" = "$EXPECTED_ANALYZER_SHA256" ||
    prelock_fail "A3_ANALYZER_IDENTITY_MISMATCH"

test "$ACTUAL_STRACE_VERSION" = "$EXPECTED_STRACE_VERSION" ||
    prelock_fail "STRACE_VERSION_DRIFT"

if pgrep -x yoda_seeker_agent >/dev/null 2>&1
then
    prelock_fail "PREEXISTING_AGENT_PROCESS"
fi

rm -rf "$PREP"
mkdir -p "$PREP"

cp "$PROJECT_FRONTIER" "$PREP/frontier.tsv" ||
    prelock_fail "PREP_FRONTIER_COPY_FAILURE"

awk -F '\t' '{print $1 "\t" $2}' "$PREP/frontier.tsv" \
    > "$PREP/task-identities.tsv"

ACTUAL_TASK_IDENTITY_SHA256="$(sha "$PREP/task-identities.tsv")"

echo "EXPECTED_TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256"
echo "ACTUAL_TASK_IDENTITY_SHA256=$ACTUAL_TASK_IDENTITY_SHA256"

test "$ACTUAL_TASK_IDENTITY_SHA256" = "$EXPECTED_TASK_IDENTITY_SHA256" ||
    prelock_fail "TASK_IDENTITY_MISMATCH"

LINES="$(wc -l < "$PREP/frontier.tsv" | awk '{print $1}')"
QUEUED="$(grep -c "$(printf '\tQUEUED\t')" "$PREP/frontier.tsv" || true)"

test "$LINES" -eq 100 ||
    prelock_fail "BASELINE_LINE_COUNT_MISMATCH"

test "$QUEUED" -eq 100 ||
    prelock_fail "BASELINE_QUEUED_COUNT_MISMATCH"

echo "CONTROL_AUTHORITY=PASS"
echo "CANDIDATE_AUTHORITY=PASS"
echo "FRONTIER_AUTHORITY=PASS"
echo "R2_AUTHORITY=PASS"
echo "ANALYZER_AUTHORITY=PASS"
echo "STRACE_AUTHORITY=PASS"
echo "PREEXISTING_AGENT_PROCESS=NO"

section "1. ONE-EXECUTION DIAGNOSTIC GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
CONTROL_SHA256=$EXPECTED_CONTROL_SHA256
CANDIDATE_SHA256=$EXPECTED_CANDIDATE_SHA256
FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256
R2_MANIFEST_SHA256=$EXPECTED_R2_MANIFEST_SHA256
ANALYZER_SHA256=$EXPECTED_ANALYZER_SHA256
STRACE_VERSION=$EXPECTED_STRACE_VERSION
ARMS=CONTROL,CANDIDATE
WORKERS=1,4,8,16
REPETITIONS_PER_ARM_PER_WORKER=$REPETITIONS
MEASURED_SCENARIOS=32
EXECUTION_POLICY=ONE_EXECUTION
EOF

test -f "$LOCK" ||
    prelock_fail "A5_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A5_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A5_EXECUTION_GATE=PASS"

mkdir -p "$EVIDENCE" "$RUNS" "$RAW" ||
    postlock_fail "A5_STAGE_CREATION_FAILURE"

cp "$PREP/frontier.tsv" "$BASELINE" ||
    postlock_fail "BASELINE_MATERIALIZATION_FAILURE"

cp "$PREP/task-identities.tsv" "$EVIDENCE/task-identities.tsv" ||
    postlock_fail "TASK_IDENTITY_MATERIALIZATION_FAILURE"

cp "$ANALYZER" "$EVIDENCE/a3-trace-analyzer.awk" ||
    postlock_fail "ANALYZER_MATERIALIZATION_FAILURE"

cp "$LOCK" "$EVIDENCE/execution-lock.txt" ||
    postlock_fail "LOCK_MATERIALIZATION_FAILURE"

test "$(sha "$BASELINE")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "BASELINE_IDENTITY_MISMATCH"

run_workers_traced()
{
    binary="$1"
    workers="$2"
    dir="$3"

    pids=""
    w=1

    while test "$w" -le "$workers"
    do
        (
            cd "$dir" || exit 1
            seq=0

            while grep -q "$(printf '\tQUEUED\t')" frontier.tsv 2>/dev/null
            do
                seq=$((seq + 1))
                trace="$(printf 'trace-w%02d-i%04d.log' "$w" "$seq")"

                strace \
                    -qq \
                    -ttt \
                    -T \
                    -e trace=flock,rename,renameat,renameat2 \
                    -o "$trace" \
                    "$binary" "$w" \
                    >/dev/null \
                    2>>"worker-$w.stderr.log" ||
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

validate_frontier()
{
    frontier_file="$1"
    label="$2"

    lines="$(wc -l < "$frontier_file" | awk '{print $1}')"
    processing="$(grep -c "$(printf '\tPROCESSING\t')" "$frontier_file" || true)"
    queued="$(grep -c "$(printf '\tQUEUED\t')" "$frontier_file" || true)"
    bad_fields="$(awk -F '\t' 'NF != 5 {n++} END {print n+0}' "$frontier_file")"
    bad_state="$(awk -F '\t' '$3 != "PROCESSING" {n++} END {print n+0}' "$frontier_file")"
    bad_owner="$(awk -F '\t' '$4 !~ /^seeker_[0-9]+$/ {n++} END {print n+0}' "$frontier_file")"

    identity="$(
        awk -F '\t' '{print $1 "\t" $2}' "$frontier_file" |
        sha256sum |
        awk '{print $1}'
    )"

    gh="$(grep -c "$(printf '\tgithub_repository\t')" "$frontier_file" || true)"
    genomics="$(grep -c "$(printf '\tgenomics_fasta\t')" "$frontier_file" || true)"
    rss="$(grep -c "$(printf '\trss_feed\t')" "$frontier_file" || true)"
    market="$(grep -c "$(printf '\tmarket_financial\t')" "$frontier_file" || true)"
    paper="$(grep -c "$(printf '\tscientific_paper\t')" "$frontier_file" || true)"

    test "$lines" -eq 100 ||
        postlock_fail "$label"_LINE_COUNT_MISMATCH

    test "$processing" -eq 100 ||
        postlock_fail "$label"_PROCESSING_COUNT_MISMATCH

    test "$queued" -eq 0 ||
        postlock_fail "$label"_QUEUED_REMAINS

    test "$bad_fields" -eq 0 ||
        postlock_fail "$label"_BAD_FIELD_COUNT

    test "$bad_state" -eq 0 ||
        postlock_fail "$label"_BAD_STATE_COUNT

    test "$bad_owner" -eq 0 ||
        postlock_fail "$label"_BAD_OWNER_COUNT

    test "$identity" = "$EXPECTED_TASK_IDENTITY_SHA256" ||
        postlock_fail "$label"_TASK_IDENTITY_MISMATCH

    test "$gh" -eq 20 &&
    test "$genomics" -eq 20 &&
    test "$rss" -eq 20 &&
    test "$market" -eq 20 &&
    test "$paper" -eq 20 ||
        postlock_fail "$label"_BIOME_DISTRIBUTION_MISMATCH
}

run_scenario()
{
    arm="$1"
    workers="$2"
    round="$3"
    worker_position="$4"
    arm_order="$5"

    if test "$arm" = "CONTROL"
    then
        binary="$CONTROL"
        key="control"
    else
        binary="$CANDIDATE"
        key="candidate"
    fi

    label="$(printf 'r%02d-p%d-a%d-%02dw-%s' \
        "$round" "$worker_position" "$arm_order" "$workers" "$key")"

    dir="$RUNS/$label"

    mkdir -p "$dir" ||
        postlock_fail "RUN_DIR_CREATION_FAILURE_$label"

    cp "$BASELINE" "$dir/frontier.tsv" ||
        postlock_fail "RUN_BASELINE_COPY_FAILURE_$label"

    test "$(sha "$dir/frontier.tsv")" = "$EXPECTED_FRONTIER_SHA256" ||
        postlock_fail "RUN_INPUT_IDENTITY_MISMATCH_$label"

    start_ns="$(date +%s%N)"

    run_workers_traced "$binary" "$workers" "$dir" ||
        postlock_fail "TRACED_AGENT_EXECUTION_FAILURE_$label"

    end_ns="$(date +%s%N)"
    elapsed_ns=$((end_ns - start_ns))

    elapsed_s="$(
        awk -v ns="$elapsed_ns" 'BEGIN {printf "%.6f", ns/1000000000.0}'
    )"

    validate_frontier "$dir/frontier.tsv" "$label"

    awk -f "$ANALYZER" "$dir"/trace-*.log > "$dir/attempts.tsv" ||
        postlock_fail "TRACE_ANALYSIS_FAILURE_$label"

    attempts="$(awk -F '\t' 'NR>1 {n++} END {print n+0}' "$dir/attempts.tsv")"
    invalid="$(awk -F '\t' 'NR>1 && $2!=1 {n++} END {print n+0}' "$dir/attempts.tsv")"
    useful="$(awk -F '\t' 'NR>1 && $3==1 {n++} END {print n+0}' "$dir/attempts.tsv")"

    test "$attempts" -gt 0 ||
        postlock_fail "NO_TRACE_ATTEMPTS_$label"

    test "$invalid" -eq 0 ||
        postlock_fail "INVALID_TRACE_ROWS_$label"

    futile=$((attempts - useful))

    all_wait_sum="$(
        awk -F '\t' 'NR>1 {s+=$4} END {printf "%.3f", s+0}' "$dir/attempts.tsv"
    )"

    all_critical_sum="$(
        awk -F '\t' 'NR>1 {s+=$5} END {printf "%.3f", s+0}' "$dir/attempts.tsv"
    )"

    share="$(
        awk -v w="$all_wait_sum" -v c="$all_critical_sum" '
        BEGIN {
            d=w+c
            if (d <= 0)
                printf "0.000"
            else
                printf "%.3f", 100.0*w/d
        }'
    )"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$round" "$worker_position" "$arm_order" "$workers" "$arm" \
        "$attempts" "$useful" "$futile" "$all_wait_sum" \
        "$all_critical_sum" "$share" "$elapsed_s" \
        >> "$RAW/scenarios.tsv"

    printf '%s\n' "$useful" \
        >> "$RAW/$key-${workers}w-useful.txt"

    printf '%s\n' "$futile" \
        >> "$RAW/$key-${workers}w-futile.txt"

    printf '%s\n' "$all_wait_sum" \
        >> "$RAW/$key-${workers}w-wait-sum.txt"

    printf '%s\n' "$share" \
        >> "$RAW/$key-${workers}w-share.txt"

    echo "RUN=$label ARM=$arm WORKERS=$workers ATTEMPTS=$attempts USEFUL=$useful FUTILE=$futile ALL_LOCK_WAIT_SUM_US=$all_wait_sum ALL_LOCK_WAIT_SHARE_PCT=$share DIAGNOSTIC_ELAPSED_S=$elapsed_s"
}

printf '%s\n' \
    "round	worker_position	arm_order	workers	arm	total_attempts	useful_attempts	futile_attempts	all_lock_wait_sum_us	all_critical_sum_us	all_lock_wait_share_pct	diagnostic_elapsed_s" \
    > "$RAW/scenarios.tsv"

section "2. 32 MEASURED DIAGNOSTIC SCENARIOS"

round=1

while test "$round" -le "$REPETITIONS"
do
    pattern=$(( (round - 1) % 4 ))

    case "$pattern" in
        0) worker_sequence="1 4 16 8" ;;
        1) worker_sequence="4 8 1 16" ;;
        2) worker_sequence="8 16 4 1" ;;
        3) worker_sequence="16 1 8 4" ;;
    esac

    if test $((round % 2)) -eq 1
    then
        arm_sequence="CONTROL CANDIDATE"
    else
        arm_sequence="CANDIDATE CONTROL"
    fi

    worker_position=1

    for workers in $worker_sequence
    do
        arm_order=1

        for arm in $arm_sequence
        do
            run_scenario "$arm" "$workers" "$round" "$worker_position" "$arm_order"
            arm_order=$((arm_order + 1))
        done

        worker_position=$((worker_position + 1))
    done

    round=$((round + 1))
done

section "3. AGGREGATE DIAGNOSTIC STATISTICS"

printf '%s\n' \
    "arm	workers	n	median_useful	median_futile	median_wait_sum_us	median_wait_share_pct" \
    > "$STAGE/statistics.tsv"

median_file()
{
    source="$1"
    sorted="$2"

    sort -n "$source" > "$sorted"

    n="$(wc -l < "$sorted" | awk '{print $1}')"

    test "$n" -eq "$REPETITIONS" ||
        postlock_fail "REPETITION_COUNT_MISMATCH"

    awk '
    { a[NR]=$1 }
    END {
        if (NR % 2 == 1)
            printf "%.3f", a[(NR+1)/2]
        else
            printf "%.3f", (a[NR/2]+a[NR/2+1])/2.0
    }' "$sorted"
}

for arm in CONTROL CANDIDATE
do
    if test "$arm" = "CONTROL"
    then
        key="control"
    else
        key="candidate"
    fi

    for workers in 1 4 8 16
    do
        mu="$(median_file "$RAW/$key-${workers}w-useful.txt" "$RAW/$key-${workers}w-useful.sorted.txt")"
        mf="$(median_file "$RAW/$key-${workers}w-futile.txt" "$RAW/$key-${workers}w-futile.sorted.txt")"
        mw="$(median_file "$RAW/$key-${workers}w-wait-sum.txt" "$RAW/$key-${workers}w-wait-sum.sorted.txt")"
        ms="$(median_file "$RAW/$key-${workers}w-share.txt" "$RAW/$key-${workers}w-share.sorted.txt")"

        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$arm" "$workers" "$REPETITIONS" "$mu" "$mf" "$mw" "$ms" \
            >> "$STAGE/statistics.tsv"

        echo "ARM=$arm WORKERS=$workers MEDIAN_USEFUL=$mu MEDIAN_FUTILE=$mf MEDIAN_WAIT_SUM_US=$mw MEDIAN_WAIT_SHARE_PCT=$ms"
    done
done

stat_of()
{
    arm="$1"
    workers="$2"
    col="$3"

    awk -F '\t' -v a="$arm" -v w="$workers" -v c="$col" \
        '$1==a && $2==w {print $c}' \
        "$STAGE/statistics.tsv"
}

CW8="$(stat_of CONTROL 8 6)"
CW16="$(stat_of CONTROL 16 6)"
NW8="$(stat_of CANDIDATE 8 6)"
NW16="$(stat_of CANDIDATE 16 6)"

CS8="$(stat_of CONTROL 8 7)"
CS16="$(stat_of CONTROL 16 7)"
NS8="$(stat_of CANDIDATE 8 7)"
NS16="$(stat_of CANDIDATE 16 7)"

CONTROL_USEFUL_EXACT="$(
    awk -F '\t' '
    NR>1 && $5=="CONTROL" {
        n++
        if ($7 != 100)
            bad++
    }
    END {
        print (n==16 && bad==0 ? "PASS" : "FAIL")
    }' "$RAW/scenarios.tsv"
)"

CANDIDATE_USEFUL_EXACT="$(
    awk -F '\t' '
    NR>1 && $5=="CANDIDATE" {
        n++
        if ($7 != 25)
            bad++
    }
    END {
        print (n==16 && bad==0 ? "PASS" : "FAIL")
    }' "$RAW/scenarios.tsv"
)"

WAIT8="$(
    awk -v n="$NW8" -v c="$CW8" \
        'BEGIN {print (n<=c*0.50 ? "PASS" : "FAIL")}'
)"

WAIT16="$(
    awk -v n="$NW16" -v c="$CW16" \
        'BEGIN {print (n<=c*0.50 ? "PASS" : "FAIL")}'
)"

SHARE8="$(
    awk -v n="$NS8" -v c="$CS8" \
        'BEGIN {print (n<=c-20.0 ? "PASS" : "FAIL")}'
)"

SHARE16="$(
    awk -v n="$NS16" -v c="$CS16" \
        'BEGIN {print (n<=c-20.0 ? "PASS" : "FAIL")}'
)"

RATIO_WAIT8="$(
    awk -v n="$NW8" -v c="$CW8" \
        'BEGIN {if (c==0) print "INF"; else printf "%.3f", n/c}'
)"

RATIO_WAIT16="$(
    awk -v n="$NW16" -v c="$CW16" \
        'BEGIN {if (c==0) print "INF"; else printf "%.3f", n/c}'
)"

DELTA_SHARE8="$(
    awk -v n="$NS8" -v c="$CS8" \
        'BEGIN {printf "%.3f", n-c}'
)"

DELTA_SHARE16="$(
    awk -v n="$NS16" -v c="$CS16" \
        'BEGIN {printf "%.3f", n-c}'
)"

if test "$CONTROL_USEFUL_EXACT" = PASS &&
   test "$CANDIDATE_USEFUL_EXACT" = PASS &&
   test "$WAIT8" = PASS &&
   test "$WAIT16" = PASS &&
   test "$SHARE8" = PASS &&
   test "$SHARE16" = PASS
then
    MECHANISM="SUPPORTED"
    NEXT_GATE="A6_CASE_HOMOLOGATION"
else
    MECHANISM="NOT_SUPPORTED"
    NEXT_GATE="MECHANISM_REASSESSMENT"
fi

echo
echo "CONTROL_USEFUL_ATTEMPTS_EXACT_100_ALL=$CONTROL_USEFUL_EXACT"
echo "CANDIDATE_USEFUL_ATTEMPTS_EXACT_25_ALL=$CANDIDATE_USEFUL_EXACT"

echo "CONTROL_MEDIAN_WAIT_SUM_8W_US=$CW8"
echo "CANDIDATE_MEDIAN_WAIT_SUM_8W_US=$NW8"
echo "WAIT_SUM_8W_CANDIDATE_VS_CONTROL_RATIO=$RATIO_WAIT8"

echo "CONTROL_MEDIAN_WAIT_SUM_16W_US=$CW16"
echo "CANDIDATE_MEDIAN_WAIT_SUM_16W_US=$NW16"
echo "WAIT_SUM_16W_CANDIDATE_VS_CONTROL_RATIO=$RATIO_WAIT16"

echo "CONTROL_MEDIAN_WAIT_SHARE_8W_PCT=$CS8"
echo "CANDIDATE_MEDIAN_WAIT_SHARE_8W_PCT=$NS8"
echo "WAIT_SHARE_8W_DELTA_PP=$DELTA_SHARE8"

echo "CONTROL_MEDIAN_WAIT_SHARE_16W_PCT=$CS16"
echo "CANDIDATE_MEDIAN_WAIT_SHARE_16W_PCT=$NS16"
echo "WAIT_SHARE_16W_DELTA_PP=$DELTA_SHARE16"

echo "CRITERION_CONTROL_USEFUL_100_ALL=$CONTROL_USEFUL_EXACT"
echo "CRITERION_CANDIDATE_USEFUL_25_ALL=$CANDIDATE_USEFUL_EXACT"
echo "CRITERION_8W_WAIT_SUM_LE_50PCT_CONTROL=$WAIT8"
echo "CRITERION_16W_WAIT_SUM_LE_50PCT_CONTROL=$WAIT16"
echo "CRITERION_8W_WAIT_SHARE_MINUS_20PP=$SHARE8"
echo "CRITERION_16W_WAIT_SHARE_MINUS_20PP=$SHARE16"

echo "A5_BATCH_LOCK_MECHANISM=$MECHANISM"

section "4. AUTHORITY IMMUTABILITY"

test "$(sha "$CONTROL")" = "$EXPECTED_CONTROL_SHA256" ||
    postlock_fail "CONTROL_BINARY_MUTATED"

test "$(sha "$CANDIDATE")" = "$EXPECTED_CANDIDATE_SHA256" ||
    postlock_fail "CANDIDATE_BINARY_MUTATED"

test "$(sha "$PROJECT_FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "PROJECT_FRONTIER_MUTATED"

test "$(sha "$R2_MANIFEST")" = "$EXPECTED_R2_MANIFEST_SHA256" ||
    postlock_fail "R2_MANIFEST_MUTATED"

test "$(sha "$ANALYZER")" = "$EXPECTED_ANALYZER_SHA256" ||
    postlock_fail "ANALYZER_MUTATED"

echo "CONTROL_BINARY_MUTATED=NO"
echo "CANDIDATE_BINARY_MUTATED=NO"
echo "PROJECT_FRONTIER_MUTATED=NO"
echo "R2_MANIFEST_MUTATED=NO"
echo "ANALYZER_MUTATED=NO"

section "5. FREEZE A5 EVIDENCE"

cp "$0" "$EVIDENCE/a5-batch-lock-diagnostic-harness.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
CONTROL_SHA256	$EXPECTED_CONTROL_SHA256
CANDIDATE_SHA256	$EXPECTED_CANDIDATE_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256	$EXPECTED_TASK_IDENTITY_SHA256
R2_MANIFEST_SHA256	$EXPECTED_R2_MANIFEST_SHA256
ANALYZER_SHA256	$EXPECTED_ANALYZER_SHA256
STRACE_VERSION	$EXPECTED_STRACE_VERSION
REPETITIONS_PER_ARM_PER_WORKER	$REPETITIONS
MEASURED_SCENARIOS	32
CONTROL_USEFUL_ATTEMPTS_EXACT_100_ALL	$CONTROL_USEFUL_EXACT
CANDIDATE_USEFUL_ATTEMPTS_EXACT_25_ALL	$CANDIDATE_USEFUL_EXACT
CONTROL_MEDIAN_WAIT_SUM_8W_US	$CW8
CANDIDATE_MEDIAN_WAIT_SUM_8W_US	$NW8
WAIT_SUM_8W_CANDIDATE_VS_CONTROL_RATIO	$RATIO_WAIT8
CONTROL_MEDIAN_WAIT_SUM_16W_US	$CW16
CANDIDATE_MEDIAN_WAIT_SUM_16W_US	$NW16
WAIT_SUM_16W_CANDIDATE_VS_CONTROL_RATIO	$RATIO_WAIT16
CONTROL_MEDIAN_WAIT_SHARE_8W_PCT	$CS8
CANDIDATE_MEDIAN_WAIT_SHARE_8W_PCT	$NS8
WAIT_SHARE_8W_DELTA_PP	$DELTA_SHARE8
CONTROL_MEDIAN_WAIT_SHARE_16W_PCT	$CS16
CANDIDATE_MEDIAN_WAIT_SHARE_16W_PCT	$NS16
WAIT_SHARE_16W_DELTA_PP	$DELTA_SHARE16
CRITERION_CONTROL_USEFUL_100_ALL	$CONTROL_USEFUL_EXACT
CRITERION_CANDIDATE_USEFUL_25_ALL	$CANDIDATE_USEFUL_EXACT
CRITERION_8W_WAIT_SUM_LE_50PCT_CONTROL	$WAIT8
CRITERION_16W_WAIT_SUM_LE_50PCT_CONTROL	$WAIT16
CRITERION_8W_WAIT_SHARE_MINUS_20PP	$SHARE8
CRITERION_16W_WAIT_SHARE_MINUS_20PP	$SHARE16
A5_BATCH_LOCK_MECHANISM	$MECHANISM
A5_THROUGHPUT_ROLE	DIAGNOSTIC_ONLY
A5_RERUN	NO
NEXT_GATE	$NEXT_GATE
EOF

(
    cd "$STAGE" || exit 1

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
) || postlock_fail "A5_EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A5_EVIDENCE_INTEGRITY=PASS"
echo "A5_EVIDENCE_MANIFEST_SHA256=$MANIFEST_SHA256"

section "6. A5 VERDICT"

echo "A5_BATCH_LOCK_DIAGNOSTIC=PASS"
echo "A5_BATCH_LOCK_MECHANISM=$MECHANISM"
echo "A5_THROUGHPUT_ROLE=DIAGNOSTIC_ONLY"
echo "MEASURED_SCENARIOS=32"
echo "A5_RERUN=NO"
echo "NEXT_GATE=$NEXT_GATE"

rm -rf "$PREP" || true
exit 0
