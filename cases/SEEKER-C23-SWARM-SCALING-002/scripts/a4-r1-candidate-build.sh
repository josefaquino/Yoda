#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
REVISION="A4-R1-CANDIDATE-BUILD-001"

PROJECT="$HOME/cmu/yoda_agent_c23"
ROOT="$HOME/cmu/$CASE"

R0="$ROOT/a4-r0-source-authority"
R0_EVIDENCE="$R0/evidence"
R0_MANIFEST="$R0_EVIDENCE/SHA256SUMS"

PREP="$ROOT/.a4-r1-prep"
STAGE="$ROOT/a4-r1-candidate-build"
EVIDENCE="$STAGE/evidence"
CANDIDATE="$STAGE/candidate"
RUNS="$STAGE/runs"
LOCK="$ROOT/.a4-r1-candidate-validation-started"

CONTROL_AGENT="$PROJECT/yoda_seeker_agent"
FRONTIER="$PROJECT/frontier.tsv"

EXPECTED_CONTROL_AGENT_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_TASK_IDENTITY_SHA256="525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28"
EXPECTED_R0_MANIFEST_SHA256="5a832d57b39ed3f94a680261914e6de6adde4ce25cc61801160729a544081cd3"

EXPECTED_MAIN_SHA256="c30255eb14fedc7bbc5efa4443f882a6dcda17f2c3a4acdd26b7dec6193469a5"
EXPECTED_DRIVER_C_SHA256="573da1ad4b19b398d656acf3f2999406523da724241cbc80d80ff8fe895d38a3"
EXPECTED_DRIVER_H_SHA256="c6a76672936ebdbb537434da77330d157a9d9436af91e2a7ca002f801bd8f20a"
EXPECTED_MAKEFILE_SHA256="9c3b0744acecd84fc9dd6c632134b7aa2acfb14e256e295b9f20adee3d5eca69"

PATCH_URL="https://raw.githubusercontent.com/josefaquino/Yoda/44773ff69d282955901a8c083416137d8f9c1eae/cases/SEEKER-C23-SWARM-SCALING-002/patches/a4-batched-reservation-size4.patch"
EXPECTED_PATCH_SHA256="046a55cf0000110030c32bf0f3a81016d9c57fa17d4a49925714876a2f0aa3d4"

EXPECTED_CANDIDATE_MAIN_SHA256="b1b2e856a77203273cf479c60b3f732bca8cf22ff91e3e55a8cb98fd8caedaa8"
EXPECTED_CANDIDATE_DRIVER_C_SHA256="d0a83c6cbcb2fd34b3b1601d1c13e016ca76fa686141e93000d00945024b0497"
EXPECTED_CANDIDATE_DRIVER_H_SHA256="0856b61bf64a50d1ce5c49baab3f55b0e62005aeb35b28f643537c439b83eba1"
EXPECTED_CANDIDATE_BINARY_SHA256="0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f"

BATCH_SIZE=4

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
    echo "A4_R1_CANDIDATE_BUILD=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A4_R1_EXECUTION_LOCK_CONSUMED=NO"
    echo "CANDIDATE_EXECUTED=NO"
    exit 1
}

postlock_fail()
{
    echo
    echo "A4_R1_CANDIDATE_BUILD=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "A4_R1_EXECUTION_LOCK_CONSUMED=YES"
    echo "A4_R1_RERUN=NO"
    exit 2
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        prelock_fail "MISSING_COMMAND_$1"
}

for cmd in \
    curl patch sha256sum awk grep sort cmp cp rm mkdir wc make gcc file find xargs pgrep
do
    require_cmd "$cmd"
done

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A4-R1 BATCHED RESERVATION CANDIDATE"
echo " BATCH_SIZE=4"
echo " BUILD + SEMANTIC VALIDATION ONLY"
echo "============================================================"

section "0. FROZEN AUTHORITIES"

test -x "$CONTROL_AGENT" ||
    prelock_fail "CONTROL_AGENT_MISSING"

test -f "$FRONTIER" ||
    prelock_fail "FRONTIER_MISSING"

test -f "$R0_MANIFEST" ||
    prelock_fail "R0_MANIFEST_MISSING"

test ! -e "$LOCK" ||
    prelock_fail "A4_R1_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    prelock_fail "A4_R1_STAGE_ALREADY_EXISTS"

test "$(sha "$CONTROL_AGENT")" = "$EXPECTED_CONTROL_AGENT_SHA256" ||
    prelock_fail "CONTROL_AGENT_IDENTITY_MISMATCH"

test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    prelock_fail "FRONTIER_IDENTITY_MISMATCH"

test "$(sha "$R0_MANIFEST")" = "$EXPECTED_R0_MANIFEST_SHA256" ||
    prelock_fail "R0_MANIFEST_IDENTITY_MISMATCH"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile
do
    test -f "$R0_EVIDENCE/$f" ||
        prelock_fail "R0_SOURCE_MISSING_$f"
done

test "$(sha "$R0_EVIDENCE/main.c")" = "$EXPECTED_MAIN_SHA256" ||
    prelock_fail "R0_MAIN_IDENTITY_MISMATCH"

test "$(sha "$R0_EVIDENCE/yoda_agent_driver.c")" = "$EXPECTED_DRIVER_C_SHA256" ||
    prelock_fail "R0_DRIVER_C_IDENTITY_MISMATCH"

test "$(sha "$R0_EVIDENCE/yoda_agent_driver.h")" = "$EXPECTED_DRIVER_H_SHA256" ||
    prelock_fail "R0_DRIVER_H_IDENTITY_MISMATCH"

test "$(sha "$R0_EVIDENCE/Makefile")" = "$EXPECTED_MAKEFILE_SHA256" ||
    prelock_fail "R0_MAKEFILE_IDENTITY_MISMATCH"

if pgrep -x yoda_seeker_agent >/dev/null 2>&1
then
    prelock_fail "PREEXISTING_AGENT_PROCESS"
fi

echo "CONTROL_AUTHORITIES=PASS"
echo "R0_SOURCE_AUTHORITY=PASS"
echo "PREEXISTING_AGENT_PROCESS=NO"

section "1. MATERIALIZE CANDIDATE PRELOCK"

rm -rf "$PREP"
mkdir -p "$PREP/candidate"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile
do
    cp "$R0_EVIDENCE/$f" "$PREP/candidate/$f" ||
        prelock_fail "CANDIDATE_SOURCE_COPY_FAILURE_$f"
done

curl -fsSL "$PATCH_URL" -o "$PREP/a4-batched-reservation-size4.patch" ||
    prelock_fail "PATCH_FETCH_FAILURE"

ACTUAL_PATCH_SHA256="$(sha "$PREP/a4-batched-reservation-size4.patch")"

echo "EXPECTED_PATCH_SHA256=$EXPECTED_PATCH_SHA256"
echo "ACTUAL_PATCH_SHA256=$ACTUAL_PATCH_SHA256"

test "$ACTUAL_PATCH_SHA256" = "$EXPECTED_PATCH_SHA256" ||
    prelock_fail "PATCH_IDENTITY_MISMATCH"

(
    cd "$PREP/candidate" || exit 1
    patch -p1 --batch < "$PREP/a4-batched-reservation-size4.patch"
) > "$PREP/patch.log" 2>&1

PATCH_RC=$?

cat "$PREP/patch.log"

test "$PATCH_RC" -eq 0 ||
    prelock_fail "PATCH_APPLICATION_FAILURE"

test "$(sha "$PREP/candidate/main.c")" = "$EXPECTED_CANDIDATE_MAIN_SHA256" ||
    prelock_fail "CANDIDATE_MAIN_IDENTITY_MISMATCH"

test "$(sha "$PREP/candidate/yoda_agent_driver.c")" = "$EXPECTED_CANDIDATE_DRIVER_C_SHA256" ||
    prelock_fail "CANDIDATE_DRIVER_C_IDENTITY_MISMATCH"

test "$(sha "$PREP/candidate/yoda_agent_driver.h")" = "$EXPECTED_CANDIDATE_DRIVER_H_SHA256" ||
    prelock_fail "CANDIDATE_DRIVER_H_IDENTITY_MISMATCH"

test "$(sha "$PREP/candidate/Makefile")" = "$EXPECTED_MAKEFILE_SHA256" ||
    prelock_fail "CANDIDATE_MAKEFILE_CHANGED"

grep -F "constexpr size_t YODA_AGENT_BATCH_SIZE = 4;" \
    "$PREP/candidate/yoda_agent_driver.h" >/dev/null ||
    prelock_fail "BATCH_SIZE_CONSTANT_MISSING"

grep -F "yoda_agent_reserve_tasks(" \
    "$PREP/candidate/yoda_agent_driver.c" >/dev/null ||
    prelock_fail "BATCH_RESERVATION_IMPLEMENTATION_MISSING"

echo "PATCH_APPLICATION=PASS"
echo "BATCH_SIZE=$BATCH_SIZE"
echo "MAKEFILE_CHANGE=NO"

section "2. BUILD CANDIDATE PRELOCK"

(
    cd "$PREP/candidate" || exit 1
    make clean >/dev/null 2>&1 || true
    make
) > "$PREP/build.log" 2>&1

BUILD_RC=$?

cat "$PREP/build.log"

test "$BUILD_RC" -eq 0 ||
    prelock_fail "CANDIDATE_BUILD_FAILURE"

test -x "$PREP/candidate/yoda_seeker_agent" ||
    prelock_fail "CANDIDATE_BINARY_MISSING"

ACTUAL_CANDIDATE_BINARY_SHA256="$(sha "$PREP/candidate/yoda_seeker_agent")"

echo "EXPECTED_CANDIDATE_BINARY_SHA256=$EXPECTED_CANDIDATE_BINARY_SHA256"
echo "ACTUAL_CANDIDATE_BINARY_SHA256=$ACTUAL_CANDIDATE_BINARY_SHA256"

test "$ACTUAL_CANDIDATE_BINARY_SHA256" = "$EXPECTED_CANDIDATE_BINARY_SHA256" ||
    prelock_fail "CANDIDATE_BINARY_IDENTITY_MISMATCH"

file "$PREP/candidate/yoda_seeker_agent"

echo "CANDIDATE_BUILD=PASS"
echo "CANDIDATE_EXECUTED=NO"

section "3. ONE-EXECUTION SEMANTIC GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
CONTROL_AGENT_SHA256=$EXPECTED_CONTROL_AGENT_SHA256
FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256=$EXPECTED_TASK_IDENTITY_SHA256
R0_MANIFEST_SHA256=$EXPECTED_R0_MANIFEST_SHA256
PATCH_SHA256=$EXPECTED_PATCH_SHA256
CANDIDATE_BINARY_SHA256=$EXPECTED_CANDIDATE_BINARY_SHA256
BATCH_SIZE=$BATCH_SIZE
EXECUTION_POLICY=ONE_EXECUTION
EOF

test -f "$LOCK" ||
    prelock_fail "A4_R1_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A4_R1_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A4_R1_EXECUTION_GATE=PASS"

mkdir -p "$EVIDENCE" "$CANDIDATE" "$RUNS" ||
    postlock_fail "A4_R1_STAGE_CREATION_FAILURE"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile yoda_seeker_agent
do
    cp "$PREP/candidate/$f" "$CANDIDATE/$f" ||
        postlock_fail "CANDIDATE_FREEZE_FAILURE_$f"
done

cp "$PREP/a4-batched-reservation-size4.patch" "$EVIDENCE/" ||
    postlock_fail "PATCH_FREEZE_FAILURE"

cp "$PREP/patch.log" "$EVIDENCE/" ||
    postlock_fail "PATCH_LOG_FREEZE_FAILURE"

cp "$PREP/build.log" "$EVIDENCE/" ||
    postlock_fail "BUILD_LOG_FREEZE_FAILURE"

cp "$LOCK" "$EVIDENCE/execution-lock.txt" ||
    postlock_fail "LOCK_FREEZE_FAILURE"

task_identity_sha()
{
    awk -F '\t' '{print $1 "\t" $2}' "$1" |
    sha256sum |
    awk '{print $1}'
}

validate_final_frontier()
{
    frontier_file="$1"
    label="$2"

    lines="$(wc -l < "$frontier_file" | awk '{print $1}')"
    queued="$(grep -c "$(printf '\tQUEUED\t')" "$frontier_file" || true)"
    processing="$(grep -c "$(printf '\tPROCESSING\t')" "$frontier_file" || true)"
    bad_fields="$(awk -F '\t' 'NF != 5 {bad++} END {print bad+0}' "$frontier_file")"
    bad_state="$(awk -F '\t' '$3 != "PROCESSING" {bad++} END {print bad+0}' "$frontier_file")"
    bad_owner="$(awk -F '\t' '$4 !~ /^seeker_[0-9]+$/ {bad++} END {print bad+0}' "$frontier_file")"
    identity="$(task_identity_sha "$frontier_file")"

    gh="$(grep -c "$(printf '\tgithub_repository\t')" "$frontier_file" || true)"
    genomics="$(grep -c "$(printf '\tgenomics_fasta\t')" "$frontier_file" || true)"
    rss="$(grep -c "$(printf '\trss_feed\t')" "$frontier_file" || true)"
    market="$(grep -c "$(printf '\tmarket_financial\t')" "$frontier_file" || true)"
    paper="$(grep -c "$(printf '\tscientific_paper\t')" "$frontier_file" || true)"

    echo "$label"_LINES="$lines"
    echo "$label"_PROCESSING="$processing"
    echo "$label"_QUEUED="$queued"
    echo "$label"_BAD_FIELDS="$bad_fields"
    echo "$label"_BAD_STATE="$bad_state"
    echo "$label"_BAD_OWNER="$bad_owner"
    echo "$label"_TASK_IDENTITY_SHA256="$identity"

    test "$lines" -eq 100 ||
        postlock_fail "$label"_LINE_COUNT_MISMATCH

    test "$processing" -eq 100 ||
        postlock_fail "$label"_PROCESSING_COUNT_MISMATCH

    test "$queued" -eq 0 ||
        postlock_fail "$label"_QUEUED_REMAINS

    test "$bad_fields" -eq 0 ||
        postlock_fail "$label"_SCHEMA_MISMATCH

    test "$bad_state" -eq 0 ||
        postlock_fail "$label"_STATE_MISMATCH

    test "$bad_owner" -eq 0 ||
        postlock_fail "$label"_OWNER_MISMATCH

    test "$identity" = "$EXPECTED_TASK_IDENTITY_SHA256" ||
        postlock_fail "$label"_TASK_IDENTITY_MISMATCH

    test "$gh" -eq 20 &&
    test "$genomics" -eq 20 &&
    test "$rss" -eq 20 &&
    test "$market" -eq 20 &&
    test "$paper" -eq 20 ||
        postlock_fail "$label"_BIOME_DISTRIBUTION_MISMATCH
}

section "4. SERIAL BATCH-CARDINALITY VALIDATION"

SERIAL="$RUNS/serial-1w"
mkdir -p "$SERIAL"

cp "$FRONTIER" "$SERIAL/frontier.tsv" ||
    postlock_fail "SERIAL_FRONTIER_COPY_FAILURE"

test "$(sha "$SERIAL/frontier.tsv")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "SERIAL_INPUT_IDENTITY_MISMATCH"

serial_invocations=0

while grep -q "$(printf '\tQUEUED\t')" "$SERIAL/frontier.tsv"
do
    (
        cd "$SERIAL" || exit 1
        "$CANDIDATE/yoda_seeker_agent" 1
    ) >> "$SERIAL/stdout.log" 2>> "$SERIAL/stderr.log" ||
        postlock_fail "SERIAL_CANDIDATE_EXECUTION_FAILURE"

    serial_invocations=$((serial_invocations + 1))

    test "$serial_invocations" -le 25 ||
        postlock_fail "SERIAL_INVOCATION_COUNT_EXCEEDED_25"
done

echo "SERIAL_USEFUL_INVOCATIONS=$serial_invocations"

test "$serial_invocations" -eq 25 ||
    postlock_fail "SERIAL_BATCH_CARDINALITY_MISMATCH"

validate_final_frontier "$SERIAL/frontier.tsv" "SERIAL"

echo "SERIAL_BATCH_CARDINALITY=PASS"
echo "EXPECTED_TASKS_PER_USEFUL_INVOCATION=4"

section "5. 16-WORKER CONCURRENCY SEMANTIC VALIDATION"

CONCURRENT="$RUNS/concurrent-16w"
mkdir -p "$CONCURRENT"

cp "$FRONTIER" "$CONCURRENT/frontier.tsv" ||
    postlock_fail "CONCURRENT_FRONTIER_COPY_FAILURE"

test "$(sha "$CONCURRENT/frontier.tsv")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "CONCURRENT_INPUT_IDENTITY_MISMATCH"

pids=""
w=1

while test "$w" -le 16
do
    (
        while grep -q "$(printf '\tQUEUED\t')" "$CONCURRENT/frontier.tsv" 2>/dev/null
        do
            (
                cd "$CONCURRENT" || exit 1
                "$CANDIDATE/yoda_seeker_agent" "$w"
            ) >> "$CONCURRENT/worker-$w.stdout.log" \
              2>> "$CONCURRENT/worker-$w.stderr.log" || exit 1
        done
    ) &

    pids="$pids $!"
    w=$((w + 1))
done

worker_failure=0

for pid in $pids
do
    wait "$pid" || worker_failure=1
done

test "$worker_failure" -eq 0 ||
    postlock_fail "CONCURRENT_WORKER_FAILURE"

validate_final_frontier "$CONCURRENT/frontier.tsv" "CONCURRENT_16W"

UNIQUE_OWNERS="$(
    awk -F '\t' '{print $4}' "$CONCURRENT/frontier.tsv" |
    sort -u |
    wc -l |
    awk '{print $1}'
)"

echo "CONCURRENT_16W_UNIQUE_OWNERS=$UNIQUE_OWNERS"
echo "CONCURRENT_16W_SEMANTICS=PASS"

section "6. CONTROL PROJECT IMMUTABILITY"

test "$(sha "$CONTROL_AGENT")" = "$EXPECTED_CONTROL_AGENT_SHA256" ||
    postlock_fail "CONTROL_AGENT_MUTATED"

test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    postlock_fail "PROJECT_FRONTIER_MUTATED"

test "$(sha "$PROJECT/main.c")" = "$EXPECTED_MAIN_SHA256" ||
    postlock_fail "PROJECT_MAIN_MUTATED"

test "$(sha "$PROJECT/yoda_agent_driver.c")" = "$EXPECTED_DRIVER_C_SHA256" ||
    postlock_fail "PROJECT_DRIVER_C_MUTATED"

test "$(sha "$PROJECT/yoda_agent_driver.h")" = "$EXPECTED_DRIVER_H_SHA256" ||
    postlock_fail "PROJECT_DRIVER_H_MUTATED"

test "$(sha "$PROJECT/Makefile")" = "$EXPECTED_MAKEFILE_SHA256" ||
    postlock_fail "PROJECT_MAKEFILE_MUTATED"

echo "CONTROL_PROJECT_MUTATED=NO"
echo "CONTROL_FRONTIER_MUTATED=NO"

section "7. FREEZE R1 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
CONTROL_AGENT_SHA256	$EXPECTED_CONTROL_AGENT_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
TASK_IDENTITY_SHA256	$EXPECTED_TASK_IDENTITY_SHA256
R0_MANIFEST_SHA256	$EXPECTED_R0_MANIFEST_SHA256
PATCH_SHA256	$EXPECTED_PATCH_SHA256
BATCH_SIZE	$BATCH_SIZE
CANDIDATE_MAIN_SHA256	$EXPECTED_CANDIDATE_MAIN_SHA256
CANDIDATE_DRIVER_C_SHA256	$EXPECTED_CANDIDATE_DRIVER_C_SHA256
CANDIDATE_DRIVER_H_SHA256	$EXPECTED_CANDIDATE_DRIVER_H_SHA256
CANDIDATE_BINARY_SHA256	$EXPECTED_CANDIDATE_BINARY_SHA256
SERIAL_USEFUL_INVOCATIONS	$serial_invocations
SERIAL_BATCH_CARDINALITY	PASS
CONCURRENT_16W_SEMANTICS	PASS
CONCURRENT_16W_UNIQUE_OWNERS	$UNIQUE_OWNERS
CONTROL_PROJECT_MUTATED	NO
CONTROL_FRONTIER_MUTATED	NO
SHARDING_CHANGE	NO
FRONTIER_SCHEMA_CHANGE	NO
KYBER_CHANGE	NO
YODA_CHANGE	NO
A4_R1_RERUN	NO
NEXT_GATE	A4_R2_CONTROLLED_PERFORMANCE
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
) || postlock_fail "R1_EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A4_R1_EVIDENCE_INTEGRITY=PASS"
echo "A4_R1_EVIDENCE_MANIFEST_SHA256=$MANIFEST_SHA256"

section "8. A4-R1 VERDICT"

echo "A4_R1_CANDIDATE_BUILD=PASS"
echo "BATCH_SIZE=$BATCH_SIZE"
echo "CANDIDATE_BINARY_SHA256=$EXPECTED_CANDIDATE_BINARY_SHA256"
echo "SERIAL_BATCH_CARDINALITY=PASS"
echo "CONCURRENT_16W_SEMANTICS=PASS"
echo "CONTROL_PROJECT_MUTATED=NO"
echo "PERFORMANCE_CONCLUSION=NONE"
echo "A4_R1_RERUN=NO"
echo "NEXT_GATE=A4_R2_CONTROLLED_PERFORMANCE"

rm -rf "$PREP" || true
exit 0
