#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
REVISION="B-R1"

ROOT="$HOME/cmu/$CASE"
A2="$ROOT/stage-a2-r1"
STORE="$A2/yoda-store"

STAGE="$ROOT/stage-b-r1"
RECOVERED="$STAGE/recovered-from-yoda"
REPLAY="$STAGE/replay"
EVIDENCE="$STAGE/evidence"

LOCK="$ROOT/.stage-b-r1-execution-started"
A2_LOCK="$ROOT/.stage-a2-r1-execution-started"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"

EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

EXPECTED_A2_SCRIPT_SHA256="191adf5544895bb11973836f73434c00944c5e0cb075b5c1f321acb69c397fe5"
EXPECTED_A2_CONSOLE_SHA256="aeb58ae1c671c4e439bf0d67685c420897daa37db0107b3a271b77f395ef0a94"
EXPECTED_A2_LOCK_SHA256="c57ed4f850cb9c42691b8168e913762b86aae56bbc965c4d38c525d742a173d3"
EXPECTED_A2_MANIFEST_SHA256="5429ff7d771a575e9640f7d2d723daaebb084d934d2c31c26020f03be3419da5"
EXPECTED_DATA_YODA_SHA256="fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e"
EXPECTED_DATA_YODA_BYTES="24851"

EXPECTED_SNAPSHOT_A_SHA256="10ce61f2bd18d1f32191a91c317759a87ca11b993f22f630818c56a96bef9410"
EXPECTED_SNAPSHOT_B_SHA256="d1688f9b362c84018f9fc093e8a6f7b985e56e3965bdb9bf8d2bdffa3af39a34"
EXPECTED_SNAPSHOT_C_SHA256="b0604231b66c6d24ef7e640bb5cf423ed138984a69342eff0f2585ac446006c2"

EXPECTED_CONTRACT_SHA256="8516bb27a0099995ee09c4900d26477a8ff142e3e9aa6c4b496f94b21b6d09be"
EXPECTED_AUTHORITY_1_SOURCE_SHA256="29b82504373f54bb225f76be2bfd0c9e2d439268da6c7e90442a7eeb820c6573"
EXPECTED_AUTHORITY_2_SOURCE_SHA256="c48b6fe73b1ea327397b68476de9a29d8f87f5a9c0d3303b529c64757b2e6fc8"
EXPECTED_CANONICAL_RESULTS_SHA256="bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba"

A2_SCRIPT="$HOME/cmu/market-regime-lineage-001-stage-a2-r1.sh"
A2_CONSOLE="$HOME/cmu/market-regime-lineage-001-stage-a2-r1-console.log"

KEY_SNAP_A="market/snapshot/A"
KEY_SNAP_B="market/snapshot/B"
KEY_SNAP_C="market/snapshot/C"
KEY_CONTRACT="market/contract/regime-v2"
KEY_AUTH_1="market/authority/c11-v2"
KEY_AUTH_2="market/authority/awk-v2"
KEY_EVAL_1="market/evaluation/c11-v2"
KEY_EVAL_2="market/evaluation/awk-v2"
KEY_CANONICAL="market/evaluation/canonical-v2"

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

not_evaluated()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_B=NOT_EVALUATED"
    echo "B_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A2_WRITES=ZERO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

fail()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_B=FAIL"
    echo "B_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A2_WRITES=ZERO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

require_cmd()
{
    cmd="$1"
    label="$2"

    if command -v "$cmd" >/dev/null 2>&1
    then
        echo "$label=PASS"
    else
        echo "$label=FAIL"
        not_evaluated "TOOLCHAIN_DRIFT"
    fi
}

recover()
{
    key="$1"
    file="$2"

    "$YODA" -d "$STORE" get "$key" > "$file" ||
        not_evaluated "YODA_RECOVERY_INPUT_UNAVAILABLE"
}

test ! -e "$LOCK" ||
    not_evaluated "B_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "B_STAGE_ALREADY_EXISTS"

section "0. FROZEN A2 AUTHORITY"

for pair in     "cc:CC"     "awk:AWK"     "sha256sum:SHA256SUM"     "cmp:CMP"     "diff:DIFF"     "grep:GREP"     "wc:WC"     "find:FIND"     "sort:SORT"     "xargs:XARGS"
do
    cmd="${pair%%:*}"
    label="${pair#*:}"
    require_cmd "$cmd" "$label"
done

test -x "$YODA" ||
    not_evaluated "YODA_BINARY_MISSING"

ACTUAL_YODA_SHA256="$(sha "$YODA")"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    not_evaluated "YODA_IDENTITY_MISMATCH"

test -f "$A2_SCRIPT" ||
    not_evaluated "A2_EXECUTED_SCRIPT_MISSING"

test -f "$A2_CONSOLE" ||
    not_evaluated "A2_CONSOLE_MISSING"

test -f "$A2_LOCK" ||
    not_evaluated "A2_EXECUTION_LOCK_MISSING"

test -f "$A2/evidence/SHA256SUMS" ||
    not_evaluated "A2_EVIDENCE_MANIFEST_MISSING"

test -f "$STORE/data.yoda" ||
    not_evaluated "A2_YODA_STATE_MISSING"

test "$(sha "$A2_SCRIPT")" = "$EXPECTED_A2_SCRIPT_SHA256" ||
    not_evaluated "A2_SCRIPT_IDENTITY_MISMATCH"

test "$(sha "$A2_CONSOLE")" = "$EXPECTED_A2_CONSOLE_SHA256" ||
    not_evaluated "A2_CONSOLE_IDENTITY_MISMATCH"

test "$(sha "$A2_LOCK")" = "$EXPECTED_A2_LOCK_SHA256" ||
    not_evaluated "A2_LOCK_IDENTITY_MISMATCH"

test "$(sha "$A2/evidence/SHA256SUMS")" = "$EXPECTED_A2_MANIFEST_SHA256" ||
    not_evaluated "A2_EVIDENCE_MANIFEST_IDENTITY_MISMATCH"

test "$(sha "$STORE/data.yoda")" = "$EXPECTED_DATA_YODA_SHA256" ||
    not_evaluated "A2_YODA_STATE_IDENTITY_MISMATCH"

test "$(wc -c < "$STORE/data.yoda" | tr -d ' ')" = "$EXPECTED_DATA_YODA_BYTES" ||
    not_evaluated "A2_YODA_STATE_SIZE_MISMATCH"

(
    cd "$A2"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A2_EVIDENCE_INTEGRITY_FAILURE"

"$YODA" -d "$STORE" verify > /dev/null 2>&1 ||
    not_evaluated "A2_YODA_VERIFY_FAILURE"

DATA_YODA_SHA256_BEFORE="$(sha "$STORE/data.yoda")"

echo "YODA_AUTHORITY=PASS"
echo "A2_EVIDENCE_AUTHORITY=PASS"
echo "A2_YODA_STATE_AUTHORITY=PASS"
echo "DATA_YODA_SHA256_BEFORE=$DATA_YODA_SHA256_BEFORE"

section "1. RECOVER REPLAY INPUTS FROM YODA ONLY"

mkdir -p "$RECOVERED" "$REPLAY" "$EVIDENCE"

recover "$KEY_SNAP_A" "$RECOVERED/snapshot-A.tsv"
recover "$KEY_SNAP_B" "$RECOVERED/snapshot-B.tsv"
recover "$KEY_SNAP_C" "$RECOVERED/snapshot-C.tsv"

recover "$KEY_CONTRACT" "$RECOVERED/classification-contract-v2.txt"
recover "$KEY_AUTH_1" "$RECOVERED/authority-1-c11-v2.c"
recover "$KEY_AUTH_2" "$RECOVERED/authority-2-posix-v2.awk"

recover "$KEY_EVAL_1" "$RECOVERED/original-authority-1-results.tsv"
recover "$KEY_EVAL_2" "$RECOVERED/original-authority-2-results.tsv"
recover "$KEY_CANONICAL" "$RECOVERED/original-canonical-results.tsv"

echo "REPLAY_INPUT_SOURCE=YODA_GET_ONLY"

section "2. RECOVERED INPUT IDENTITIES"

test "$(sha "$RECOVERED/snapshot-A.tsv")" = "$EXPECTED_SNAPSHOT_A_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/snapshot-B.tsv")" = "$EXPECTED_SNAPSHOT_B_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/snapshot-C.tsv")" = "$EXPECTED_SNAPSHOT_C_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/classification-contract-v2.txt")" = "$EXPECTED_CONTRACT_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/authority-1-c11-v2.c")" = "$EXPECTED_AUTHORITY_1_SOURCE_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/authority-2-posix-v2.awk")" = "$EXPECTED_AUTHORITY_2_SOURCE_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/original-authority-1-results.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/original-authority-2-results.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

test "$(sha "$RECOVERED/original-canonical-results.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "RECOVERED_INPUT_IDENTITY_MISMATCH"

cmp -s     "$RECOVERED/original-authority-1-results.tsv"     "$RECOVERED/original-authority-2-results.tsv" ||
    not_evaluated "RECOVERED_ORIGINAL_EVIDENCE_DIVERGENCE"

cmp -s     "$RECOVERED/original-authority-1-results.tsv"     "$RECOVERED/original-canonical-results.tsv" ||
    not_evaluated "RECOVERED_ORIGINAL_EVIDENCE_DIVERGENCE"

echo "RECOVERED_SNAPSHOT_IDENTITIES=PASS"
echo "RECOVERED_CLASSIFICATION_CONTRACT_IDENTITY=PASS"
echo "RECOVERED_AUTHORITY_SOURCE_IDENTITIES=PASS"
echo "RECOVERED_ORIGINAL_EVALUATION_IDENTITIES=PASS"
echo "RECOVERED_ORIGINAL_AUTHORITY_EQUIVALENCE=PASS"

section "3. COMPILE RECOVERED C11 AUTHORITY BEFORE REPLAY GATE"

cc     -std=c11     -O2     -Wall     -Wextra     -Werror     "$RECOVERED/authority-1-c11-v2.c"     -o "$REPLAY/authority-1-c11-v2" ||
    not_evaluated "TOOLCHAIN_DRIFT"

REPLAY_AUTHORITY_1_BINARY_SHA256="$(sha "$REPLAY/authority-1-c11-v2")"

echo "RECOVERED_AUTHORITY_1_COMPILE=PASS"
echo "REPLAY_AUTHORITY_1_BINARY_SHA256=$REPLAY_AUTHORITY_1_BINARY_SHA256"

section "4. ONE-EXECUTION REPLAY GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
YODA_SHA256=$ACTUAL_YODA_SHA256
A2_EVIDENCE_MANIFEST_SHA256=$EXPECTED_A2_MANIFEST_SHA256
DATA_YODA_SHA256=$EXPECTED_DATA_YODA_SHA256
CANONICAL_RESULTS_SHA256=$EXPECTED_CANONICAL_RESULTS_SHA256
RECOVERED_AUTHORITY_1_SOURCE_SHA256=$EXPECTED_AUTHORITY_1_SOURCE_SHA256
RECOVERED_AUTHORITY_2_SOURCE_SHA256=$EXPECTED_AUTHORITY_2_SOURCE_SHA256
REPLAY_AUTHORITY_1_BINARY_SHA256=$REPLAY_AUTHORITY_1_BINARY_SHA256
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_REPLAY_CLASSIFICATION=YES
EOF

cp "$LOCK" "$EVIDENCE/execution-started.txt"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "EXECUTION_GATE=PASS"

section "5. REPLAY AUTHORITY 1 FROM YODA-RECOVERED C11 SOURCE"

HEADER="$(printf 'state\tevaluation_date\tdgs10_scaled5\tnfci_scaled5\tvixcls_scaled5\trate_flag\tnfci_flag\tvix_flag\tscore\tclassification')"
printf '%s\n' "$HEADER" > "$REPLAY/replay-authority-1.tsv"

for state in A B C
do
    set +e
    "$REPLAY/authority-1-c11-v2"         "$state"         "$RECOVERED/snapshot-$state.tsv"         >> "$REPLAY/replay-authority-1.tsv"
    rc=$?
    set -e

    echo "REPLAY_AUTHORITY_1_STATE_${state}_RC=$rc"

    test "$rc" -eq 0 ||
        fail "INDEPENDENT_REPLAY_FAILURE"
done

test "$(wc -l < "$REPLAY/replay-authority-1.tsv" | tr -d ' ')" = "4" ||
    fail "INDEPENDENT_REPLAY_FAILURE"

echo "REPLAY_AUTHORITY_1=PASS"
echo "REPLAY_AUTHORITY_1_RESULTS_SHA256=$(sha "$REPLAY/replay-authority-1.tsv")"

section "6. REPLAY AUTHORITY 2 FROM YODA-RECOVERED AWK SOURCE"

printf '%s\n' "$HEADER" > "$REPLAY/replay-authority-2.tsv"

for state in A B C
do
    set +e
    awk         -v state="$state"         -f "$RECOVERED/authority-2-posix-v2.awk"         "$RECOVERED/snapshot-$state.tsv"         >> "$REPLAY/replay-authority-2.tsv"
    rc=$?
    set -e

    echo "REPLAY_AUTHORITY_2_STATE_${state}_RC=$rc"

    test "$rc" -eq 0 ||
        fail "INDEPENDENT_REPLAY_FAILURE"
done

test "$(wc -l < "$REPLAY/replay-authority-2.tsv" | tr -d ' ')" = "4" ||
    fail "INDEPENDENT_REPLAY_FAILURE"

echo "REPLAY_AUTHORITY_2=PASS"
echo "REPLAY_AUTHORITY_2_RESULTS_SHA256=$(sha "$REPLAY/replay-authority-2.tsv")"

section "7. INDEPENDENT REPLAY EQUIVALENCE"

if ! cmp -s     "$REPLAY/replay-authority-1.tsv"     "$REPLAY/replay-authority-2.tsv"
then
    diff -u         "$REPLAY/replay-authority-1.tsv"         "$REPLAY/replay-authority-2.tsv"         > "$EVIDENCE/replay-authority-divergence.diff" || true

    fail "INDEPENDENT_REPLAY_FAILURE"
fi

if ! cmp -s     "$REPLAY/replay-authority-1.tsv"     "$RECOVERED/original-canonical-results.tsv"
then
    diff -u         "$RECOVERED/original-canonical-results.tsv"         "$REPLAY/replay-authority-1.tsv"         > "$EVIDENCE/replay-vs-original-authority-1.diff" || true

    fail "INDEPENDENT_REPLAY_FAILURE"
fi

if ! cmp -s     "$REPLAY/replay-authority-2.tsv"     "$RECOVERED/original-canonical-results.tsv"
then
    diff -u         "$RECOVERED/original-canonical-results.tsv"         "$REPLAY/replay-authority-2.tsv"         > "$EVIDENCE/replay-vs-original-authority-2.diff" || true

    fail "INDEPENDENT_REPLAY_FAILURE"
fi

REPLAY_CANONICAL_SHA256="$(sha "$REPLAY/replay-authority-1.tsv")"

test "$REPLAY_CANONICAL_SHA256" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    fail "INDEPENDENT_REPLAY_FAILURE"

echo "REPLAY_AUTHORITY_EQUIVALENCE=PASS"
echo "REPLAY_VS_ORIGINAL_AUTHORITY_1=PASS"
echo "REPLAY_VS_ORIGINAL_AUTHORITY_2=PASS"
echo "REPLAY_VS_ORIGINAL_CANONICAL=PASS"
echo "REPLAY_CANONICAL_SHA256=$REPLAY_CANONICAL_SHA256"

section "8. REPLAYED DECISION STATES"

cat "$REPLAY/replay-authority-1.tsv"

grep -F "$(printf 'A\t2025-04-25\t432000\t-43077\t2484000\t1\t0\t1\t2\tSTRESSED')"     "$REPLAY/replay-authority-1.tsv" >/dev/null ||
    fail "INDEPENDENT_REPLAY_FAILURE"

grep -F "$(printf 'B\t2025-08-29\t422000\t-56025\t1536000\t1\t0\t0\t1\tFRAGILE')"     "$REPLAY/replay-authority-1.tsv" >/dev/null ||
    fail "INDEPENDENT_REPLAY_FAILURE"

grep -F "$(printf 'C\t2025-12-26\t417000\t-54911\t1360000\t1\t0\t0\t1\tFRAGILE')"     "$REPLAY/replay-authority-1.tsv" >/dev/null ||
    fail "INDEPENDENT_REPLAY_FAILURE"

echo "STATE_A_INDEPENDENT_REPLAY=PASS"
echo "STATE_B_INDEPENDENT_REPLAY=PASS"
echo "STATE_C_INDEPENDENT_REPLAY=PASS"

section "9. YODA STATE IMMUTABILITY"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-post-replay-verify.txt" 2>&1 ||
    fail "YODA_PERSISTENCE_FAILURE"

DATA_YODA_SHA256_AFTER="$(sha "$STORE/data.yoda")"
DATA_YODA_BYTES_AFTER="$(wc -c < "$STORE/data.yoda" | tr -d ' ')"

echo "DATA_YODA_SHA256_AFTER=$DATA_YODA_SHA256_AFTER"
echo "DATA_YODA_BYTES_AFTER=$DATA_YODA_BYTES_AFTER"

test "$DATA_YODA_SHA256_AFTER" = "$DATA_YODA_SHA256_BEFORE" ||
    fail "YODA_PERSISTENCE_FAILURE"

test "$DATA_YODA_BYTES_AFTER" = "$EXPECTED_DATA_YODA_BYTES" ||
    fail "YODA_PERSISTENCE_FAILURE"

test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "YODA_IDENTITY_MISMATCH"

echo "DATA_YODA_IDENTITY_UNCHANGED=PASS"
echo "YODA_BINARY_IDENTITY_UNCHANGED=PASS"
echo "YODA_WRITES=ZERO"

section "10. FREEZE B-R1 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
YODA_SHA256	$ACTUAL_YODA_SHA256
A2_EVIDENCE_MANIFEST_SHA256	$EXPECTED_A2_MANIFEST_SHA256
DATA_YODA_SHA256_BEFORE	$DATA_YODA_SHA256_BEFORE
DATA_YODA_SHA256_AFTER	$DATA_YODA_SHA256_AFTER
RECOVERED_SNAPSHOT_A_SHA256	$(sha "$RECOVERED/snapshot-A.tsv")
RECOVERED_SNAPSHOT_B_SHA256	$(sha "$RECOVERED/snapshot-B.tsv")
RECOVERED_SNAPSHOT_C_SHA256	$(sha "$RECOVERED/snapshot-C.tsv")
RECOVERED_CONTRACT_SHA256	$(sha "$RECOVERED/classification-contract-v2.txt")
RECOVERED_AUTHORITY_1_SOURCE_SHA256	$(sha "$RECOVERED/authority-1-c11-v2.c")
RECOVERED_AUTHORITY_2_SOURCE_SHA256	$(sha "$RECOVERED/authority-2-posix-v2.awk")
RECOVERED_ORIGINAL_CANONICAL_SHA256	$(sha "$RECOVERED/original-canonical-results.tsv")
REPLAY_AUTHORITY_1_BINARY_SHA256	$REPLAY_AUTHORITY_1_BINARY_SHA256
REPLAY_AUTHORITY_1_RESULTS_SHA256	$(sha "$REPLAY/replay-authority-1.tsv")
REPLAY_AUTHORITY_2_RESULTS_SHA256	$(sha "$REPLAY/replay-authority-2.tsv")
REPLAY_AUTHORITY_EQUIVALENCE	PASS
REPLAY_VS_ORIGINAL_AUTHORITY_1	PASS
REPLAY_VS_ORIGINAL_AUTHORITY_2	PASS
REPLAY_VS_ORIGINAL_CANONICAL	PASS
STATE_A_INDEPENDENT_REPLAY	PASS
STATE_B_INDEPENDENT_REPLAY	PASS
STATE_C_INDEPENDENT_REPLAY	PASS
DATA_YODA_IDENTITY_UNCHANGED	PASS
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-b-r1-script.sh"
cp "$REPLAY/replay-authority-1.tsv" "$EVIDENCE/replay-authority-1.tsv"
cp "$REPLAY/replay-authority-2.tsv" "$EVIDENCE/replay-authority-2.tsv"
cp "$RECOVERED/original-canonical-results.tsv" "$EVIDENCE/original-canonical-results.tsv"

(
    cd "$STAGE"

    find evidence recovered-from-yoda replay         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS         > evidence/SHA256SUMS.check
) || fail "B_EVIDENCE_INTEGRITY_FAILURE"

B_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "B_EVIDENCE_INTEGRITY=PASS"
echo "B_EVIDENCE_MANIFEST_SHA256=$B_MANIFEST_SHA256"

section "11. B-R1 HOMOLOGATION"

echo "MARKET_REGIME_LINEAGE_001_STAGE_B=PASS"
echo "B_REVISION=$REVISION"

echo "REPLAY_INPUT_SOURCE=YODA_GET_ONLY"
echo "RECOVERED_AUTHORITY_1_COMPILE=PASS"
echo "REPLAY_AUTHORITY_1=PASS"
echo "REPLAY_AUTHORITY_2=PASS"

echo "REPLAY_AUTHORITY_EQUIVALENCE=PASS"
echo "REPLAY_VS_ORIGINAL_AUTHORITY_1=PASS"
echo "REPLAY_VS_ORIGINAL_AUTHORITY_2=PASS"
echo "REPLAY_VS_ORIGINAL_CANONICAL=PASS"

echo "STATE_A_INDEPENDENT_REPLAY=PASS"
echo "STATE_B_INDEPENDENT_REPLAY=PASS"
echo "STATE_C_INDEPENDENT_REPLAY=PASS"

echo "INDEPENDENT_CLASSIFICATION_REPLAY=PASS"
echo "DATA_YODA_IDENTITY_UNCHANGED=PASS"
echo "B_EVIDENCE_INTEGRITY=PASS"

echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=CASE_FINAL_HOMOLOGATION"
