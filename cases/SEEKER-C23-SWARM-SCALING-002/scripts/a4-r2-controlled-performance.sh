#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
REVISION="A4-R2-CONTROLLED-PERFORMANCE-001"

PROJECT="$HOME/cmu/yoda_agent_c23"
ROOT="$HOME/cmu/$CASE"

CONTROL="$PROJECT/yoda_seeker_agent"
PROJECT_FRONTIER="$PROJECT/frontier.tsv"

R1="$ROOT/a4-r1-candidate-build"
CANDIDATE="$R1/candidate/yoda_seeker_agent"
R1_MANIFEST="$R1/evidence/SHA256SUMS"

PREP="$ROOT/.a4-r2-prep"
STAGE="$ROOT/a4-r2-controlled-performance"
EVIDENCE="$STAGE/evidence"
RUNS="$STAGE/runs"
RAW="$STAGE/raw"
BASELINE="$STAGE/frontier.canonical-100.tsv"
LOCK="$ROOT/.a4-r2-controlled-performance-started"

EXPECTED_CONTROL_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_CANDIDATE_SHA256="0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_TASK_IDENTITY_SHA256="525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28"
EXPECTED_R1_MANIFEST_SHA256="9c6a75e473295009978d3f5e1d5972d26eee1a434d8df61e58568e7a159a8c46"

REPETITIONS=16

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
    echo "A4_R2_CONTROLLED_PERFORMANCE=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A4_R2_EXECUTION_LOCK_CONSUMED=NO"
    echo "MEASURED_SCENARIOS=0"
    exit 1
}

postlock_fail()
{
    echo
    echo "A4_R2_CONTROLLED_PERFORMANCE=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A4_R2_EXECUTION_LOCK_CONSUMED=YES"
    echo "A4_R2_RERUN=NO"
    exit 2
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        prelock_fail "MISSING_COMMAND_$1"
}

for cmd in sha256sum awk grep sort cp rm mkdir wc date find xargs pgrep
do
    require_cmd "$cmd"
done

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A4-R2 CONTROLLED PERFORMANCE"
echo " CONTROL VS BATCH-4 CANDIDATE"
echo " 16 REPETITIONS PER ARM / WORKER COUNT"
echo "============================================================"

section "0. PRE-EXECUTION AUTHORITIES"

test -x "$CONTROL" ||
    prelock_fail "CONTROL_BINARY_MISSING"

test -x "$CANDIDATE" ||
    prelock_fail "CANDIDATE_BINARY_MISSING"

test -f "$PROJECT_FRONTIER" ||
    prelock_fail "PROJECT_FRONTIER_MISSING"

test -f "$R1_MANIFEST" ||
    prelock_fail "R1_MANIFEST_MISSING"

test ! -e "$LOCK" ||
    prelock_fail "A4_R2_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_fail "A4_R2_STAGE_ALREADY_EXISTS"

ACTUAL_CONTROL_SHA256="$(sha "$CONTROL")"
ACTUAL_CANDIDATE_SHA256="$(sha "$CANDIDATE")"
ACTUAL_FRONTIER_SHA256="$(sha "$PROJECT_FRONTIER")"
ACTUAL_R1_MANIFEST_SHA256="$(sha "$R1_MANIFEST")"

echo "EXPECTED_CONTROL_SHA256=$EXPECTED_CONTROL_SHA256"
echo "ACTUAL_CONTROL_SHA256=$ACTUAL_CONTROL_SHA256"
echo "EXPECTED_CANDIDATE_SHA256=$EXPECTED_CANDIDATE_SHA256"
echo "ACTUAL_CANDIDATE_SHA256=$ACTUAL_CANDIDATE_SHA256"
echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER_SHA256"
echo "EXPECTED_R1_MANIFEST_SHA256=$EXPECTED_R1_MANIFEST_SHA256"
echo "ACTUAL_R1_MANIFEST_SHA256=$ACTUAL_R1_MANIFEST_SHA256"

test "$ACTUAL_CONTROL_SHA256" = "$EXPECTED_CONTROL_SHA256" ||
    prelock_fail "CONTROL_BINARY_IDENTITY_MISMATCH"

test "$ACTUAL_CANDIDATE_SHA256" = "$EXPECTED_CANDIDATE_SHA256" ||
    prelock_fail "CANDIDATE_BINARY_IDENTITY_MISMATCH"

test "$ACTUAL_FRONTIER_SHA256" = "$EXPECTED_FRONTIER_SHA256" ||
    prelock_fail "PROJECT_FRONTIER_IDENTITY_MISMATCH"

test "$ACTUAL_R1_MANIFEST_SHA256" = "$EXPECTED_R1_MANIFEST_SHA256" ||
    prelock_fail "R1_MANIFEST_IDENTITY_MISMATCH"

if pgrep -x yoda_seeker_agent >/dev/null 2>&1
then
    prelock_fail "PREEXISTING_AGENT_PROCESS"
fi

rm -rf "$PREP"
mkdir -p "$PREP"

cp "$PROJECT_FRONTIER" "$PREP/frontier.tsv" ||
    prelock_fail "PREP_FRONTIER_COPY_FAILURE"

awk -F '\t' '{print $1 "\t" $2}' "$PREP/frontier.tsv" > "$PREP/task-identities.tsv"

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
echo "R1_AUTHORITY=PASS"
echo "PREEXISTING_AGENT_PROCESS=NO"

section "1. ONE-EXECUTION PERFORMANCE GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
CONTROL_SHA256=$EXPECTED_CONTROL_SHA256
CANDIDATE_SHA256=$EXPECTED_CANDIDATE_SHA256
FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256
R1_MANIFEST_SHA256=$EXPECTED_R1_MANIFEST_SHA256
ARMS=CONTROL,CANDIDATE
WORKERS=1,4,8,16
REPETITIONS_PER_ARM_PER_WORKER=$REPETITIONS
MEASURED_SCENARIOS=128
WARMUPS=8
EXECUTION_POLICY=ONE_EXECUTION
EOF

test -f "$LOCK" ||
    prelock_fail "A4_R2_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A4_R2_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A4_R2_EXECUTION_GATE=PASS"

mkdir -p "$EVIDENCE" "$RUNS" "$RAW" ||
    postlock_fail "A4_R2_STAGE_CREATION_FAILURE"

cp "$PREP/frontier.tsv" "$BASELINE" ||
    postlock_fail "BASELINE_MATERIALIZATION_FAILURE"

cp "$PREP/task-identities.tsv" "$EVIDENCE/task-identities.tsv" ||
    postlock_fail "TASK_IDENTITY_MATERIALIZATION_FAILURE"

cp "$LOCK" "$EVIDENCE/execution-lock.txt" ||
    postlock_fail "LOCK_MATERIALIZATION_FAILURE"

test "$(sha "$BASELINE")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "BASELINE_IDENTITY_MISMATCH"

run_workers()
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

            while grep -q "$(printf '\tQUEUED\t')" frontier.tsv 2>/dev/null
            do
                "$binary" "$w" >/dev/null 2>>"worker-$w.stderr.log" || exit 1
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
        postlock_fail "${label}_LINE_COUNT_MISMATCH"

    test "$processing" -eq 100 ||
        postlock_fail "${label}_PROCESSING_COUNT_MISMATCH"

    test "$queued" -eq 0 ||
        postlock_fail "${label}_QUEUED_REMAINS"

    test "$bad_fields" -eq 0 ||
        postlock_fail "${label}_BAD_FIELD_COUNT"

    test "$bad_state" -eq 0 ||
        postlock_fail "${label}_BAD_STATE_COUNT"

    test "$bad_owner" -eq 0 ||
        postlock_fail "${label}_BAD_OWNER_COUNT"

    test "$identity" = "$EXPECTED_TASK_IDENTITY_SHA256" ||
        postlock_fail "${label}_TASK_IDENTITY_MISMATCH"

    test "$gh" -eq 20 &&
    test "$genomics" -eq 20 &&
    test "$rss" -eq 20 &&
    test "$market" -eq 20 &&
    test "$paper" -eq 20 ||
        postlock_fail "${label}_BIOME_DISTRIBUTION_MISMATCH"
}

run_scenario()
{
    arm="$1"
    workers="$2"
    round="$3"
    worker_position="$4"
    arm_order="$5"
    measured="$6"

    if test "$arm" = "CONTROL"
    then
        binary="$CONTROL"
        arm_key="control"
    else
        binary="$CANDIDATE"
        arm_key="candidate"
    fi

    if test "$measured" = "YES"
    then
        label="$(printf 'r%02d-p%d-a%d-%02dw-%s' "$round" "$worker_position" "$arm_order" "$workers" "$arm_key")"
    else
        label="$(printf 'warmup-%02dw-%s' "$workers" "$arm_key")"
    fi

    dir="$RUNS/$label"

    mkdir -p "$dir" ||
        postlock_fail "RUN_DIR_CREATION_FAILURE_$label"

    cp "$BASELINE" "$dir/frontier.tsv" ||
        postlock_fail "RUN_BASELINE_COPY_FAILURE_$label"

    test "$(sha "$dir/frontier.tsv")" = "$EXPECTED_FRONTIER_SHA256" ||
        postlock_fail "RUN_INPUT_IDENTITY_MISMATCH_$label"

    start_ns="$(date +%s%N)"

    run_workers "$binary" "$workers" "$dir" ||
        postlock_fail "AGENT_EXECUTION_FAILURE_$label"

    end_ns="$(date +%s%N)"
    elapsed_ns=$((end_ns - start_ns))

    elapsed_s="$(
        awk -v ns="$elapsed_ns" 'BEGIN {printf "%.6f", ns/1000000000.0}'
    )"

    tps="$(
        awk -v s="$elapsed_s" 'BEGIN {printf "%.6f", 100.0/s}'
    )"

    validate_frontier "$dir/frontier.tsv" "$label"

    echo "RUN=$label ARM=$arm WORKERS=$workers ELAPSED_S=$elapsed_s TPS=$tps"

    if test "$measured" = "YES"
    then
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$round" "$worker_position" "$arm_order" "$workers" \
            "$arm" "$elapsed_s" "$tps" "$label" \
            >> "$RAW/all-runs.tsv"

        printf '%s\n' "$tps" >> "$RAW/$arm_key-${workers}w-tps.txt"
    fi
}

section "2. WARMUPS -- EXCLUDED FROM STATISTICS"

for workers in 1 4 16 8
do
    run_scenario CONTROL "$workers" 0 0 1 NO
    run_scenario CANDIDATE "$workers" 0 0 2 NO
done

printf '%s\n' \
    "round	worker_position	arm_order	workers	arm	elapsed_s	throughput_tps	label" \
    > "$RAW/all-runs.tsv"

rm -f "$RAW"/control-*w-tps.txt "$RAW"/candidate-*w-tps.txt

section "3. 128 MEASURED SCENARIOS"

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
            run_scenario "$arm" "$workers" "$round" "$worker_position" "$arm_order" YES
            arm_order=$((arm_order + 1))
        done

        worker_position=$((worker_position + 1))
    done

    round=$((round + 1))
done

section "4. STATISTICAL SUMMARY"

printf '%s\n' \
    "arm	workers	n	min_tps	median_tps	mean_tps	p95_tps	max_tps	sd_tps" \
    > "$STAGE/statistics.tsv"

summarize()
{
    arm="$1"
    workers="$2"

    if test "$arm" = "CONTROL"
    then
        key="control"
    else
        key="candidate"
    fi

    source="$RAW/$key-${workers}w-tps.txt"
    sorted="$RAW/$key-${workers}w-tps.sorted.txt"

    sort -n "$source" > "$sorted"

    n="$(wc -l < "$sorted" | awk '{print $1}')"

    test "$n" -eq "$REPETITIONS" ||
        postlock_fail "REPETITION_COUNT_MISMATCH_${arm}_${workers}W"

    min="$(awk 'NR==1 {print; exit}' "$sorted")"
    max="$(awk 'END {print}' "$sorted")"

    median="$(
        awk '
        { a[NR]=$1 }
        END {
            if (NR % 2 == 1)
                printf "%.6f", a[(NR+1)/2]
            else
                printf "%.6f", (a[NR/2]+a[NR/2+1])/2.0
        }' "$sorted"
    )"

    mean="$(awk '{s+=$1} END {printf "%.6f", s/NR}' "$sorted")"

    p95="$(
        awk '
        { a[NR]=$1 }
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

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$arm" "$workers" "$n" "$min" "$median" "$mean" "$p95" "$max" "$sd" \
        >> "$STAGE/statistics.tsv"

    echo "ARM=$arm WORKERS=$workers N=$n MIN_TPS=$min MEDIAN_TPS=$median MEAN_TPS=$mean P95_TPS=$p95 MAX_TPS=$max SD_TPS=$sd"
}

for arm in CONTROL CANDIDATE
do
    for workers in 1 4 8 16
    do
        summarize "$arm" "$workers"
    done
done

median_of()
{
    arm="$1"
    workers="$2"

    awk -F '\t' -v a="$arm" -v w="$workers" \
        '$1==a && $2==w {print $5}' \
        "$STAGE/statistics.tsv"
}

C1_M="$(median_of CONTROL 1)"
C4_M="$(median_of CONTROL 4)"
C8_M="$(median_of CONTROL 8)"
C16_M="$(median_of CONTROL 16)"

N1_M="$(median_of CANDIDATE 1)"
N4_M="$(median_of CANDIDATE 4)"
N8_M="$(median_of CANDIDATE 8)"
N16_M="$(median_of CANDIDATE 16)"

delta_pct()
{
    candidate="$1"
    control="$2"

    awk -v n="$candidate" -v c="$control" \
        'BEGIN {printf "%.3f", 100.0*(n-c)/c}'
}

D1="$(delta_pct "$N1_M" "$C1_M")"
D4="$(delta_pct "$N4_M" "$C4_M")"
D8="$(delta_pct "$N8_M" "$C8_M")"
D16="$(delta_pct "$N16_M" "$C16_M")"

CRIT1="$(
    awk -v n="$N1_M" -v c="$C1_M" \
        'BEGIN {print (n>=c*0.90 ? "PASS" : "FAIL")}'
)"

CRIT4="$(
    awk -v n="$N4_M" -v c="$C4_M" \
        'BEGIN {print (n>=c*0.95 ? "PASS" : "FAIL")}'
)"

CRIT8="$(
    awk -v n="$N8_M" -v c="$C8_M" \
        'BEGIN {print (n>=c*1.20 ? "PASS" : "FAIL")}'
)"

CRIT16="$(
    awk -v n="$N16_M" -v c="$C16_M" \
        'BEGIN {print (n>=c*1.20 ? "PASS" : "FAIL")}'
)"

if test "$CRIT1" = PASS &&
   test "$CRIT4" = PASS &&
   test "$CRIT8" = PASS &&
   test "$CRIT16" = PASS
then
    PERFORMANCE="SUPPORTED"
    NEXT_GATE="A5_BATCH_LOCK_DIAGNOSTIC"
else
    PERFORMANCE="NOT_SUPPORTED"
    NEXT_GATE="BATCHED_RESERVATION_REASSESSMENT"
fi

echo
echo "CONTROL_MEDIAN_1W_TPS=$C1_M"
echo "CONTROL_MEDIAN_4W_TPS=$C4_M"
echo "CONTROL_MEDIAN_8W_TPS=$C8_M"
echo "CONTROL_MEDIAN_16W_TPS=$C16_M"

echo "CANDIDATE_MEDIAN_1W_TPS=$N1_M"
echo "CANDIDATE_MEDIAN_4W_TPS=$N4_M"
echo "CANDIDATE_MEDIAN_8W_TPS=$N8_M"
echo "CANDIDATE_MEDIAN_16W_TPS=$N16_M"

echo "DELTA_1W_PCT=$D1"
echo "DELTA_4W_PCT=$D4"
echo "DELTA_8W_PCT=$D8"
echo "DELTA_16W_PCT=$D16"

echo "CRITERION_1W_GE_CONTROL_MINUS_10PCT=$CRIT1"
echo "CRITERION_4W_GE_CONTROL_MINUS_5PCT=$CRIT4"
echo "CRITERION_8W_GE_CONTROL_PLUS_20PCT=$CRIT8"
echo "CRITERION_16W_GE_CONTROL_PLUS_20PCT=$CRIT16"

echo "BATCHED_RESERVATION_PERFORMANCE=$PERFORMANCE"

section "5. AUTHORITY IMMUTABILITY"

test "$(sha "$CONTROL")" = "$EXPECTED_CONTROL_SHA256" ||
    postlock_fail "CONTROL_BINARY_MUTATED"

test "$(sha "$CANDIDATE")" = "$EXPECTED_CANDIDATE_SHA256" ||
    postlock_fail "CANDIDATE_BINARY_MUTATED"

test "$(sha "$PROJECT_FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "PROJECT_FRONTIER_MUTATED"

test "$(sha "$R1_MANIFEST")" = "$EXPECTED_R1_MANIFEST_SHA256" ||
    postlock_fail "R1_MANIFEST_MUTATED"

echo "CONTROL_BINARY_MUTATED=NO"
echo "CANDIDATE_BINARY_MUTATED=NO"
echo "PROJECT_FRONTIER_MUTATED=NO"
echo "R1_MANIFEST_MUTATED=NO"

section "6. FREEZE R2 EVIDENCE"

cp "$0" "$EVIDENCE/a4-r2-controlled-performance-harness.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
CONTROL_SHA256	$EXPECTED_CONTROL_SHA256
CANDIDATE_SHA256	$EXPECTED_CANDIDATE_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256	$EXPECTED_TASK_IDENTITY_SHA256
R1_MANIFEST_SHA256	$EXPECTED_R1_MANIFEST_SHA256
REPETITIONS_PER_ARM_PER_WORKER	$REPETITIONS
MEASURED_SCENARIOS	128
CONTROL_MEDIAN_1W_TPS	$C1_M
CONTROL_MEDIAN_4W_TPS	$C4_M
CONTROL_MEDIAN_8W_TPS	$C8_M
CONTROL_MEDIAN_16W_TPS	$C16_M
CANDIDATE_MEDIAN_1W_TPS	$N1_M
CANDIDATE_MEDIAN_4W_TPS	$N4_M
CANDIDATE_MEDIAN_8W_TPS	$N8_M
CANDIDATE_MEDIAN_16W_TPS	$N16_M
DELTA_1W_PCT	$D1
DELTA_4W_PCT	$D4
DELTA_8W_PCT	$D8
DELTA_16W_PCT	$D16
CRITERION_1W_GE_CONTROL_MINUS_10PCT	$CRIT1
CRITERION_4W_GE_CONTROL_MINUS_5PCT	$CRIT4
CRITERION_8W_GE_CONTROL_PLUS_20PCT	$CRIT8
CRITERION_16W_GE_CONTROL_PLUS_20PCT	$CRIT16
BATCHED_RESERVATION_PERFORMANCE	$PERFORMANCE
BATCH_SIZE	4
SHARDING_CHANGE	NO
FRONTIER_SCHEMA_CHANGE	NO
KYBER_CHANGE	NO
YODA_CHANGE	NO
A4_R2_RERUN	NO
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
) || postlock_fail "R2_EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A4_R2_EVIDENCE_INTEGRITY=PASS"
echo "A4_R2_EVIDENCE_MANIFEST_SHA256=$MANIFEST_SHA256"

section "7. A4-R2 VERDICT"

echo "A4_R2_CONTROLLED_PERFORMANCE=PASS"
echo "BATCHED_RESERVATION_PERFORMANCE=$PERFORMANCE"
echo "BATCH_SIZE=4"
echo "MEASURED_SCENARIOS=128"
echo "A4_R2_RERUN=NO"
echo "NEXT_GATE=$NEXT_GATE"

rm -rf "$PREP" || true
exit 0
