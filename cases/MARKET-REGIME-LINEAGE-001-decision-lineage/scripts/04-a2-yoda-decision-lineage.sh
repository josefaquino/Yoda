#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
REVISION="A2-R1"

ROOT="$HOME/cmu/$CASE"
A0="$ROOT/stage-a0-r1"
A1="$ROOT/stage-a1-r2"

STAGE="$ROOT/stage-a2-r1"
PREP="$ROOT/.stage-a2-r1-preflight"
STORE="$STAGE/yoda-store"
OBJECTS="$STAGE/objects"
RECOVERED="$STAGE/recovered"
EVIDENCE="$STAGE/evidence"

EXECUTION_LOCK="$ROOT/.stage-a2-r1-execution-started"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

EXPECTED_A0_MANIFEST_SHA256="0440ffea6e2377fa6843f972f35d127f44727f114c2d91ae94039ff1ca4a78c8"
EXPECTED_A1_MANIFEST_SHA256="dc68f1634085ada042ab384e684e8ddbd812e7c29ab83c21d066837502c25a0a"
EXPECTED_A1_LOCK_SHA256="0ab6a6388c2e4a5c5aa568e51bc79b829205cd622f86769018decc3c406e1d2c"
EXPECTED_A1_SCRIPT_SHA256="52cb38c29a8e584e74b35cdf60a0bcf8b956b22e91a0e8a7875c2ccf9265480d"
EXPECTED_A1_CONSOLE_SHA256="696bedcb20be81e724fff77c8c7845ada1bcff22085ec82c87b969d139b4e9a7"
EXPECTED_CANONICAL_RESULTS_SHA256="bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba"

EXPECTED_SNAPSHOT_A_SHA256="10ce61f2bd18d1f32191a91c317759a87ca11b993f22f630818c56a96bef9410"
EXPECTED_SNAPSHOT_B_SHA256="d1688f9b362c84018f9fc093e8a6f7b985e56e3965bdb9bf8d2bdffa3af39a34"
EXPECTED_SNAPSHOT_C_SHA256="b0604231b66c6d24ef7e640bb5cf423ed138984a69342eff0f2585ac446006c2"

EXPECTED_CONTRACT_SHA256="8516bb27a0099995ee09c4900d26477a8ff142e3e9aa6c4b496f94b21b6d09be"
EXPECTED_AUTHORITY_1_SOURCE_SHA256="29b82504373f54bb225f76be2bfd0c9e2d439268da6c7e90442a7eeb820c6573"
EXPECTED_AUTHORITY_2_SOURCE_SHA256="c48b6fe73b1ea327397b68476de9a29d8f87f5a9c0d3303b529c64757b2e6fc8"

EXPECTED_DECISION_A_SHA256="a5a20d8dd1f51da8fea6ddfde282539317ae74098c22426be4b9150e7997a3e7"
EXPECTED_DECISION_B_SHA256="5c3a3e6f506a05a2314f168a5658792ac743f1e0af37a163955fd3bb0276f60a"
EXPECTED_DECISION_C_SHA256="8b82f8a0f7f5679b0929a0fa523910c28011b81d0e66e9558a881d369113f439"
EXPECTED_TRANSITION_AB_SHA256="5c4a8d29f7dd5b7fa651b12150faf591383383c550d2d5cfba33df3064bbab24"
EXPECTED_TRANSITION_BC_SHA256="4d50c515b4c5e9422717a5110f9dc24c9759fb1cf6797bfb9b9b31f3c26da777"

OBJECT_COMMIT="42f179308dcc6d4a68c4d2a700ed034633f994d1"
OBJECT_RAW_BASE="https://raw.githubusercontent.com/josefaquino/Yoda/$OBJECT_COMMIT/cases/MARKET-REGIME-LINEAGE-001-decision-lineage/objects/decision-lineage-v1"

A1_SCRIPT="$HOME/cmu/market-regime-lineage-001-stage-a1-r2.sh"
A1_CONSOLE="$HOME/cmu/market-regime-lineage-001-stage-a1-r2-console.log"
A1_LOCK="$ROOT/.stage-a1-r2-execution-started"

KEY_SNAP_A="market/snapshot/A"
KEY_SNAP_B="market/snapshot/B"
KEY_SNAP_C="market/snapshot/C"

KEY_DEC_A="market/decision/A"
KEY_DEC_B="market/decision/B"
KEY_DEC_C="market/decision/C"

KEY_TRANS_AB="market/transition/A-to-B"
KEY_TRANS_BC="market/transition/B-to-C"

KEY_CONTRACT="market/contract/regime-v2"
KEY_AUTH_1="market/authority/c11-v2"
KEY_AUTH_2="market/authority/awk-v2"

KEY_EVAL_1="market/evaluation/c11-v2"
KEY_EVAL_2="market/evaluation/awk-v2"
KEY_CANONICAL="market/evaluation/canonical-v2"

KEY_A0_SUMMARY="evidence/market/A0-summary"
KEY_A0_MANIFEST="evidence/market/A0-manifest"
KEY_A1_SUMMARY="evidence/market/A1-R2-summary"
KEY_A1_MANIFEST="evidence/market/A1-R2-manifest"

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
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A2=NOT_EVALUATED"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "CLASSIFICATION_EXECUTED=NO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

fail()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A2=FAIL"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "CLASSIFICATION_EXECUTED=NO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

put_file()
{
    key="$1"
    file="$2"
    shift 2

    "$YODA" -d "$STORE" put "$key" "$@" < "$file" >/dev/null
}

link()
{
    from="$1"
    relation="$2"
    to="$3"

    "$YODA" -d "$STORE" link         "$from"         "$relation"         "$to"         case="$CASE"         revision="$REVISION"         >/dev/null
}

recover_cmp()
{
    key="$1"
    source="$2"
    target="$3"

    "$YODA" -d "$STORE" get "$key" > "$target" ||
        fail "BYTE_EXACT_RECOVERY_FAILURE"

    cmp -s "$source" "$target" ||
        fail "BYTE_EXACT_RECOVERY_FAILURE"
}

test ! -e "$EXECUTION_LOCK" ||
    not_evaluated "A2_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "A2_STAGE_ALREADY_EXISTS"

rm -rf "$PREP"
mkdir -p "$PREP"

section "0. FROZEN YODA + A0 + A1-R2 AUTHORITIES"

for cmd in curl sha256sum awk grep cmp wc find sort xargs
do
    command -v "$cmd" >/dev/null 2>&1 ||
        not_evaluated "TOOLCHAIN_DRIFT"
done

test -x "$YODA" ||
    not_evaluated "YODA_BINARY_MISSING"

ACTUAL_YODA_SHA256="$(sha "$YODA")"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    not_evaluated "YODA_IDENTITY_MISMATCH"

test -f "$A0/evidence/SHA256SUMS" ||
    not_evaluated "A0_EVIDENCE_MISSING"

test -f "$A1/evidence/SHA256SUMS" ||
    not_evaluated "A1_R2_EVIDENCE_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    not_evaluated "A0_EVIDENCE_IDENTITY_MISMATCH"

test "$(sha "$A1/evidence/SHA256SUMS")" = "$EXPECTED_A1_MANIFEST_SHA256" ||
    not_evaluated "A1_R2_EVIDENCE_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

(
    cd "$A1"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A1_R2_EVIDENCE_INTEGRITY_FAILURE"

test -f "$A1_SCRIPT" ||
    not_evaluated "A1_R2_EXECUTED_SCRIPT_MISSING"

test -f "$A1_CONSOLE" ||
    not_evaluated "A1_R2_CONSOLE_MISSING"

test -f "$A1_LOCK" ||
    not_evaluated "A1_R2_EXECUTION_LOCK_MISSING"

test "$(sha "$A1_SCRIPT")" = "$EXPECTED_A1_SCRIPT_SHA256" ||
    not_evaluated "A1_R2_EXECUTED_SCRIPT_IDENTITY_MISMATCH"

test "$(sha "$A1_CONSOLE")" = "$EXPECTED_A1_CONSOLE_SHA256" ||
    not_evaluated "A1_R2_CONSOLE_IDENTITY_MISMATCH"

test "$(sha "$A1_LOCK")" = "$EXPECTED_A1_LOCK_SHA256" ||
    not_evaluated "A1_R2_LOCK_IDENTITY_MISMATCH"

test "$(sha "$A1/results/canonical-results-v2.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "A1_R2_CANONICAL_RESULTS_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-A.tsv")" = "$EXPECTED_SNAPSHOT_A_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-B.tsv")" = "$EXPECTED_SNAPSHOT_B_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-C.tsv")" = "$EXPECTED_SNAPSHOT_C_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

grep -F "$(printf 'A\t2025-04-25\t432000\t-43077\t2484000\t1\t0\t1\t2\tSTRESSED')"     "$A1/results/canonical-results-v2.tsv" >/dev/null ||
    not_evaluated "A1_R2_CANONICAL_RESULT_MISMATCH"

grep -F "$(printf 'B\t2025-08-29\t422000\t-56025\t1536000\t1\t0\t0\t1\tFRAGILE')"     "$A1/results/canonical-results-v2.tsv" >/dev/null ||
    not_evaluated "A1_R2_CANONICAL_RESULT_MISMATCH"

grep -F "$(printf 'C\t2025-12-26\t417000\t-54911\t1360000\t1\t0\t0\t1\tFRAGILE')"     "$A1/results/canonical-results-v2.tsv" >/dev/null ||
    not_evaluated "A1_R2_CANONICAL_RESULT_MISMATCH"

echo "YODA_AUTHORITY=PASS"
echo "A0_EVIDENCE_AUTHORITY=PASS"
echo "A1_R2_EVIDENCE_AUTHORITY=PASS"
echo "A1_R2_CANONICAL_RESULTS_AUTHORITY=PASS"

section "1. MATERIALIZE PRE-REGISTERED DECISION OBJECTS"

for name in     decision-state-A.tsv     decision-state-B.tsv     decision-state-C.tsv     transition-A-to-B.tsv     transition-B-to-C.tsv
do
    curl -fsSL "$OBJECT_RAW_BASE/$name" -o "$PREP/$name" ||
        not_evaluated "PRE_REGISTERED_OBJECT_FETCH_FAILURE"
done

test "$(sha "$PREP/decision-state-A.tsv")" = "$EXPECTED_DECISION_A_SHA256" ||
    not_evaluated "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"

test "$(sha "$PREP/decision-state-B.tsv")" = "$EXPECTED_DECISION_B_SHA256" ||
    not_evaluated "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"

test "$(sha "$PREP/decision-state-C.tsv")" = "$EXPECTED_DECISION_C_SHA256" ||
    not_evaluated "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"

test "$(sha "$PREP/transition-A-to-B.tsv")" = "$EXPECTED_TRANSITION_AB_SHA256" ||
    not_evaluated "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"

test "$(sha "$PREP/transition-B-to-C.tsv")" = "$EXPECTED_TRANSITION_BC_SHA256" ||
    not_evaluated "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"

grep -F "$(printf 'A\tB\tSTRESSED\tFRAGILE\tYES')"     "$PREP/transition-A-to-B.tsv" >/dev/null ||
    not_evaluated "TRANSITION_OBJECT_MISMATCH"

grep -F "$(printf 'B\tC\tFRAGILE\tFRAGILE\tNO')"     "$PREP/transition-B-to-C.tsv" >/dev/null ||
    not_evaluated "TRANSITION_OBJECT_MISMATCH"

echo "DECISION_STATE_OBJECTS=FROZEN"
echo "TRANSITION_OBJECTS=FROZEN"
echo "OBJECT_COMMIT=$OBJECT_COMMIT"

section "2. MATERIALIZE COMPLETE A2 INPUT SET"

mkdir -p "$PREP/objects"

cp "$A0/snapshots/state-A.tsv" "$PREP/objects/snapshot-A.tsv"
cp "$A0/snapshots/state-B.tsv" "$PREP/objects/snapshot-B.tsv"
cp "$A0/snapshots/state-C.tsv" "$PREP/objects/snapshot-C.tsv"

cp "$PREP/decision-state-A.tsv" "$PREP/objects/decision-A.tsv"
cp "$PREP/decision-state-B.tsv" "$PREP/objects/decision-B.tsv"
cp "$PREP/decision-state-C.tsv" "$PREP/objects/decision-C.tsv"

cp "$PREP/transition-A-to-B.tsv" "$PREP/objects/transition-A-to-B.tsv"
cp "$PREP/transition-B-to-C.tsv" "$PREP/objects/transition-B-to-C.tsv"

cp "$A1/classification-contract-v2.txt" "$PREP/objects/classification-contract-v2.txt"
cp "$A1/authorities/authority-1-c11-v2.c" "$PREP/objects/authority-1-c11-v2.c"
cp "$A1/authorities/authority-2-posix-v2.awk" "$PREP/objects/authority-2-posix-v2.awk"

cp "$A1/results/authority-1-v2.tsv" "$PREP/objects/authority-1-results.tsv"
cp "$A1/results/authority-2-v2.tsv" "$PREP/objects/authority-2-results.tsv"
cp "$A1/results/canonical-results-v2.tsv" "$PREP/objects/canonical-results.tsv"

cp "$A0/evidence/summary.tsv" "$PREP/objects/a0-summary.tsv"
cp "$A0/evidence/SHA256SUMS" "$PREP/objects/a0-manifest.sha256"
cp "$A1/evidence/summary.tsv" "$PREP/objects/a1-r2-summary.tsv"
cp "$A1/evidence/SHA256SUMS" "$PREP/objects/a1-r2-manifest.sha256"

test "$(sha "$PREP/objects/classification-contract-v2.txt")" = "$EXPECTED_CONTRACT_SHA256" ||
    not_evaluated "CLASSIFICATION_CONTRACT_IDENTITY_MISMATCH"

test "$(sha "$PREP/objects/authority-1-c11-v2.c")" = "$EXPECTED_AUTHORITY_1_SOURCE_SHA256" ||
    not_evaluated "AUTHORITY_1_IDENTITY_MISMATCH"

test "$(sha "$PREP/objects/authority-2-posix-v2.awk")" = "$EXPECTED_AUTHORITY_2_SOURCE_SHA256" ||
    not_evaluated "AUTHORITY_2_IDENTITY_MISMATCH"

test "$(sha "$PREP/objects/authority-1-results.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "AUTHORITY_1_RESULTS_IDENTITY_MISMATCH"

test "$(sha "$PREP/objects/authority-2-results.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "AUTHORITY_2_RESULTS_IDENTITY_MISMATCH"

test "$(sha "$PREP/objects/canonical-results.tsv")" = "$EXPECTED_CANONICAL_RESULTS_SHA256" ||
    not_evaluated "CANONICAL_RESULTS_IDENTITY_MISMATCH"

OBJECT_COUNT=18

echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "A2_INPUT_SET=PASS"
echo "CLASSIFICATION_EXECUTED=NO"

section "3. ONE-EXECUTION GATE"

cat > "$EXECUTION_LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
YODA_SHA256=$ACTUAL_YODA_SHA256
A0_EVIDENCE_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
A1_R2_EVIDENCE_MANIFEST_SHA256=$EXPECTED_A1_MANIFEST_SHA256
CANONICAL_RESULTS_V2_SHA256=$EXPECTED_CANONICAL_RESULTS_SHA256
OBJECT_COUNT=$OBJECT_COUNT
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_YODA_WRITE=YES
EOF

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$EXECUTION_LOCK")"
echo "EXECUTION_GATE=PASS"

mkdir -p "$OBJECTS" "$RECOVERED" "$EVIDENCE"
cp "$PREP/objects/"* "$OBJECTS/"
rm -rf "$PREP"

section "4. INITIALIZE FRESH YODA STORE"

"$YODA" init "$STORE" >/dev/null ||
    fail "YODA_PERSISTENCE_FAILURE"

echo "YODA_INIT=PASS"

section "5. STORE DECISION LINEAGE OBJECTS"

put_file "$KEY_SNAP_A" "$OBJECTS/snapshot-A.tsv"     type=market-snapshot state=A evaluation_date=2025-04-25

put_file "$KEY_SNAP_B" "$OBJECTS/snapshot-B.tsv"     type=market-snapshot state=B evaluation_date=2025-08-29

put_file "$KEY_SNAP_C" "$OBJECTS/snapshot-C.tsv"     type=market-snapshot state=C evaluation_date=2025-12-26

put_file "$KEY_DEC_A" "$OBJECTS/decision-A.tsv"     type=decision-state state=A classification=STRESSED score=2

put_file "$KEY_DEC_B" "$OBJECTS/decision-B.tsv"     type=decision-state state=B classification=FRAGILE score=1

put_file "$KEY_DEC_C" "$OBJECTS/decision-C.tsv"     type=decision-state state=C classification=FRAGILE score=1

put_file "$KEY_TRANS_AB" "$OBJECTS/transition-A-to-B.tsv"     type=decision-transition from=A to=B classification_changed=YES

put_file "$KEY_TRANS_BC" "$OBJECTS/transition-B-to-C.tsv"     type=decision-transition from=B to=C classification_changed=NO evidence_changed=YES

put_file "$KEY_CONTRACT" "$OBJECTS/classification-contract-v2.txt"     type=classification-contract version=v2 scale=100000

put_file "$KEY_AUTH_1" "$OBJECTS/authority-1-c11-v2.c"     type=classification-authority implementation=C11 version=v2

put_file "$KEY_AUTH_2" "$OBJECTS/authority-2-posix-v2.awk"     type=classification-authority implementation=POSIX_AWK version=v2

put_file "$KEY_EVAL_1" "$OBJECTS/authority-1-results.tsv"     type=evaluation-evidence authority=C11 result=PASS

put_file "$KEY_EVAL_2" "$OBJECTS/authority-2-results.tsv"     type=evaluation-evidence authority=POSIX_AWK result=PASS

put_file "$KEY_CANONICAL" "$OBJECTS/canonical-results.tsv"     type=canonical-decision-evidence result=PASS

put_file "$KEY_A0_SUMMARY" "$OBJECTS/a0-summary.tsv"     type=source-authority stage=A0

put_file "$KEY_A0_MANIFEST" "$OBJECTS/a0-manifest.sha256"     type=evidence-authority stage=A0 manifest="$EXPECTED_A0_MANIFEST_SHA256"

put_file "$KEY_A1_SUMMARY" "$OBJECTS/a1-r2-summary.tsv"     type=classification-authority-summary stage=A1-R2

put_file "$KEY_A1_MANIFEST" "$OBJECTS/a1-r2-manifest.sha256"     type=evidence-authority stage=A1-R2 manifest="$EXPECTED_A1_MANIFEST_SHA256"

echo "YODA_OBJECT_INGEST=PASS"
echo "OBJECT_COUNT=$OBJECT_COUNT"

section "6. CREATE DECISION LINEAGE RELATIONS"

link "$KEY_DEC_A" derived-from "$KEY_SNAP_A"
link "$KEY_DEC_B" derived-from "$KEY_SNAP_B"
link "$KEY_DEC_C" derived-from "$KEY_SNAP_C"

link "$KEY_DEC_A" classified-by "$KEY_CONTRACT"
link "$KEY_DEC_B" classified-by "$KEY_CONTRACT"
link "$KEY_DEC_C" classified-by "$KEY_CONTRACT"

link "$KEY_DEC_A" has-evidence "$KEY_CANONICAL"
link "$KEY_DEC_B" has-evidence "$KEY_CANONICAL"
link "$KEY_DEC_C" has-evidence "$KEY_CANONICAL"

link "$KEY_CANONICAL" supported-by "$KEY_EVAL_1"
link "$KEY_CANONICAL" supported-by "$KEY_EVAL_2"

link "$KEY_EVAL_1" evaluated-by "$KEY_AUTH_1"
link "$KEY_EVAL_2" evaluated-by "$KEY_AUTH_2"

link "$KEY_EVAL_1" has-evidence "$KEY_A1_SUMMARY"
link "$KEY_EVAL_2" has-evidence "$KEY_A1_SUMMARY"

link "$KEY_CANONICAL" has-evidence "$KEY_A1_MANIFEST"

link "$KEY_SNAP_A" has-evidence "$KEY_A0_SUMMARY"
link "$KEY_SNAP_B" has-evidence "$KEY_A0_SUMMARY"
link "$KEY_SNAP_C" has-evidence "$KEY_A0_SUMMARY"

link "$KEY_A0_SUMMARY" has-evidence "$KEY_A0_MANIFEST"
link "$KEY_A1_SUMMARY" has-evidence "$KEY_A1_MANIFEST"

link "$KEY_DEC_B" supersedes "$KEY_DEC_A"
link "$KEY_DEC_C" supersedes "$KEY_DEC_B"

link "$KEY_DEC_B" transition-evidence "$KEY_TRANS_AB"
link "$KEY_DEC_C" transition-evidence "$KEY_TRANS_BC"

link "$KEY_TRANS_AB" from-state "$KEY_DEC_A"
link "$KEY_TRANS_AB" to-state "$KEY_DEC_B"
link "$KEY_TRANS_BC" from-state "$KEY_DEC_B"
link "$KEY_TRANS_BC" to-state "$KEY_DEC_C"

link "$KEY_TRANS_AB" has-evidence "$KEY_A1_SUMMARY"
link "$KEY_TRANS_BC" has-evidence "$KEY_A1_SUMMARY"

LINK_COUNT=31

echo "LINK_COUNT=$LINK_COUNT"
echo "DECISION_LINEAGE_RELATIONS=PASS"

section "7. VERIFY YODA STORE"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-verify.txt" 2>&1 ||
    fail "YODA_PERSISTENCE_FAILURE"

echo "YODA_VERIFY=PASS"

section "8. BYTE-EXACT RECOVERY"

recover_cmp "$KEY_SNAP_A" "$OBJECTS/snapshot-A.tsv" "$RECOVERED/snapshot-A.tsv"
recover_cmp "$KEY_SNAP_B" "$OBJECTS/snapshot-B.tsv" "$RECOVERED/snapshot-B.tsv"
recover_cmp "$KEY_SNAP_C" "$OBJECTS/snapshot-C.tsv" "$RECOVERED/snapshot-C.tsv"

recover_cmp "$KEY_DEC_A" "$OBJECTS/decision-A.tsv" "$RECOVERED/decision-A.tsv"
recover_cmp "$KEY_DEC_B" "$OBJECTS/decision-B.tsv" "$RECOVERED/decision-B.tsv"
recover_cmp "$KEY_DEC_C" "$OBJECTS/decision-C.tsv" "$RECOVERED/decision-C.tsv"

recover_cmp "$KEY_TRANS_AB" "$OBJECTS/transition-A-to-B.tsv" "$RECOVERED/transition-A-to-B.tsv"
recover_cmp "$KEY_TRANS_BC" "$OBJECTS/transition-B-to-C.tsv" "$RECOVERED/transition-B-to-C.tsv"

recover_cmp "$KEY_CONTRACT" "$OBJECTS/classification-contract-v2.txt" "$RECOVERED/classification-contract-v2.txt"
recover_cmp "$KEY_AUTH_1" "$OBJECTS/authority-1-c11-v2.c" "$RECOVERED/authority-1-c11-v2.c"
recover_cmp "$KEY_AUTH_2" "$OBJECTS/authority-2-posix-v2.awk" "$RECOVERED/authority-2-posix-v2.awk"

recover_cmp "$KEY_EVAL_1" "$OBJECTS/authority-1-results.tsv" "$RECOVERED/authority-1-results.tsv"
recover_cmp "$KEY_EVAL_2" "$OBJECTS/authority-2-results.tsv" "$RECOVERED/authority-2-results.tsv"
recover_cmp "$KEY_CANONICAL" "$OBJECTS/canonical-results.tsv" "$RECOVERED/canonical-results.tsv"

recover_cmp "$KEY_A0_SUMMARY" "$OBJECTS/a0-summary.tsv" "$RECOVERED/a0-summary.tsv"
recover_cmp "$KEY_A0_MANIFEST" "$OBJECTS/a0-manifest.sha256" "$RECOVERED/a0-manifest.sha256"
recover_cmp "$KEY_A1_SUMMARY" "$OBJECTS/a1-r2-summary.tsv" "$RECOVERED/a1-r2-summary.tsv"
recover_cmp "$KEY_A1_MANIFEST" "$OBJECTS/a1-r2-manifest.sha256" "$RECOVERED/a1-r2-manifest.sha256"

echo "SNAPSHOT_RECOVERY=PASS"
echo "DECISION_STATE_RECOVERY=PASS"
echo "TRANSITION_EVIDENCE_RECOVERY=PASS"
echo "CLASSIFICATION_CONTRACT_RECOVERY=PASS"
echo "AUTHORITY_SOURCE_RECOVERY=PASS"
echo "EVALUATION_EVIDENCE_RECOVERY=PASS"
echo "SOURCE_AUTHORITY_RECOVERY=PASS"
echo "EVIDENCE_MANIFEST_RECOVERY=PASS"
echo "BYTE_EXACT_RECOVERY=PASS"

section "9. RELATION RECOVERY VIA YODA LOG"

TAB="$(printf '\t')"

"$YODA" -d "$STORE" log "$KEY_DEC_A" > "$EVIDENCE/log-decision-A.txt"
"$YODA" -d "$STORE" log "$KEY_DEC_B" > "$EVIDENCE/log-decision-B.txt"
"$YODA" -d "$STORE" log "$KEY_DEC_C" > "$EVIDENCE/log-decision-C.txt"
"$YODA" -d "$STORE" log "$KEY_CANONICAL" > "$EVIDENCE/log-canonical.txt"
"$YODA" -d "$STORE" log "$KEY_EVAL_1" > "$EVIDENCE/log-eval-1.txt"
"$YODA" -d "$STORE" log "$KEY_EVAL_2" > "$EVIDENCE/log-eval-2.txt"
"$YODA" -d "$STORE" log "$KEY_TRANS_AB" > "$EVIDENCE/log-transition-AB.txt"
"$YODA" -d "$STORE" log "$KEY_TRANS_BC" > "$EVIDENCE/log-transition-BC.txt"

grep -F "derived-from${TAB}${KEY_SNAP_A}" "$EVIDENCE/log-decision-A.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "derived-from${TAB}${KEY_SNAP_B}" "$EVIDENCE/log-decision-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "derived-from${TAB}${KEY_SNAP_C}" "$EVIDENCE/log-decision-C.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "classified-by${TAB}${KEY_CONTRACT}" "$EVIDENCE/log-decision-A.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "classified-by${TAB}${KEY_CONTRACT}" "$EVIDENCE/log-decision-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "classified-by${TAB}${KEY_CONTRACT}" "$EVIDENCE/log-decision-C.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supersedes${TAB}${KEY_DEC_A}" "$EVIDENCE/log-decision-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supersedes${TAB}${KEY_DEC_B}" "$EVIDENCE/log-decision-C.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "transition-evidence${TAB}${KEY_TRANS_AB}" "$EVIDENCE/log-decision-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "transition-evidence${TAB}${KEY_TRANS_BC}" "$EVIDENCE/log-decision-C.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supported-by${TAB}${KEY_EVAL_1}" "$EVIDENCE/log-canonical.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supported-by${TAB}${KEY_EVAL_2}" "$EVIDENCE/log-canonical.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "evaluated-by${TAB}${KEY_AUTH_1}" "$EVIDENCE/log-eval-1.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "evaluated-by${TAB}${KEY_AUTH_2}" "$EVIDENCE/log-eval-2.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "from-state${TAB}${KEY_DEC_A}" "$EVIDENCE/log-transition-AB.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "to-state${TAB}${KEY_DEC_B}" "$EVIDENCE/log-transition-AB.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "from-state${TAB}${KEY_DEC_B}" "$EVIDENCE/log-transition-BC.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "to-state${TAB}${KEY_DEC_C}" "$EVIDENCE/log-transition-BC.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

echo "DERIVED_FROM_RELATION_RECOVERY=PASS"
echo "CLASSIFIED_BY_RELATION_RECOVERY=PASS"
echo "SUPERSEDES_RELATION_RECOVERY=PASS"
echo "TRANSITION_EVIDENCE_RELATION_RECOVERY=PASS"
echo "AUTHORITY_RELATION_RECOVERY=PASS"
echo "DECISION_LINEAGE_RELATION_RECOVERY=PASS"

section "10. DECISION LINEAGE SEMANTIC RECOVERY"

grep -F "$(printf 'A\t2025-04-25')" "$RECOVERED/decision-A.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf '\t2\tSTRESSED\t')" "$RECOVERED/decision-A.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf 'B\t2025-08-29')" "$RECOVERED/decision-B.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf '\t1\tFRAGILE\t')" "$RECOVERED/decision-B.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf 'C\t2025-12-26')" "$RECOVERED/decision-C.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf '\t1\tFRAGILE\t')" "$RECOVERED/decision-C.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf 'A\tB\tSTRESSED\tFRAGILE\tYES')"     "$RECOVERED/transition-A-to-B.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf 'B\tC\tFRAGILE\tFRAGILE\tNO')"     "$RECOVERED/transition-B-to-C.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

grep -F "$(printf '\tYES')" "$RECOVERED/transition-B-to-C.tsv" >/dev/null ||
    fail "BYTE_EXACT_RECOVERY_FAILURE"

echo "STATE_A_DECISION_RECOVERY=PASS"
echo "STATE_B_DECISION_RECOVERY=PASS"
echo "STATE_C_DECISION_RECOVERY=PASS"
echo "A_TO_B_CLASSIFICATION_CHANGE_RECOVERY=PASS"
echo "B_TO_C_STABLE_CLASSIFICATION_RECOVERY=PASS"
echo "B_TO_C_CHANGED_EVIDENCE_RECOVERY=PASS"
echo "DECISION_LINEAGE_SEMANTICS=PASS"

section "11. FINAL VERIFY + FREEZE YODA STATE"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-final-verify.txt" 2>&1 ||
    fail "YODA_PERSISTENCE_FAILURE"

test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "YODA_IDENTITY_MISMATCH"

DATA_YODA="$STORE/data.yoda"

test -f "$DATA_YODA" ||
    fail "YODA_PERSISTENCE_FAILURE"

DATA_YODA_SHA256="$(sha "$DATA_YODA")"
DATA_YODA_BYTES="$(wc -c < "$DATA_YODA" | tr -d ' ')"

echo "FINAL_YODA_VERIFY=PASS"
echo "YODA_BINARY_IDENTITY_UNCHANGED=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "DATA_YODA_BYTES=$DATA_YODA_BYTES"

section "12. SUMMARY"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
YODA_SHA256	$ACTUAL_YODA_SHA256
A0_EVIDENCE_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
A1_R2_EVIDENCE_MANIFEST_SHA256	$EXPECTED_A1_MANIFEST_SHA256
CANONICAL_RESULTS_V2_SHA256	$EXPECTED_CANONICAL_RESULTS_SHA256
OBJECT_COUNT	$OBJECT_COUNT
LINK_COUNT	$LINK_COUNT
SNAPSHOT_RECOVERY	PASS
DECISION_STATE_RECOVERY	PASS
TRANSITION_EVIDENCE_RECOVERY	PASS
CLASSIFICATION_CONTRACT_RECOVERY	PASS
AUTHORITY_SOURCE_RECOVERY	PASS
EVALUATION_EVIDENCE_RECOVERY	PASS
BYTE_EXACT_RECOVERY	PASS
DERIVED_FROM_RELATION_RECOVERY	PASS
CLASSIFIED_BY_RELATION_RECOVERY	PASS
SUPERSEDES_RELATION_RECOVERY	PASS
TRANSITION_EVIDENCE_RELATION_RECOVERY	PASS
AUTHORITY_RELATION_RECOVERY	PASS
DECISION_LINEAGE_RELATION_RECOVERY	PASS
STATE_A_CLASSIFICATION	STRESSED
STATE_B_CLASSIFICATION	FRAGILE
STATE_C_CLASSIFICATION	FRAGILE
A_TO_B_CLASSIFICATION_CHANGED	YES
B_TO_C_CLASSIFICATION_CHANGED	NO
B_TO_C_UNDERLYING_EVIDENCE_CHANGED	YES
DECISION_LINEAGE_SEMANTICS	PASS
FINAL_YODA_VERIFY	PASS
DATA_YODA_SHA256	$DATA_YODA_SHA256
DATA_YODA_BYTES	$DATA_YODA_BYTES
CLASSIFICATION_EXECUTED	NO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

section "13. FREEZE A2 EVIDENCE"

cp "$0" "$EVIDENCE/stage-a2-r1-script.sh"
cp "$EXECUTION_LOCK" "$EVIDENCE/execution-started.txt"

(
    cd "$STAGE"

    find evidence objects recovered yoda-store         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS         > evidence/SHA256SUMS.check
) || fail "A2_EVIDENCE_INTEGRITY_FAILURE"

A2_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A2_EVIDENCE_INTEGRITY=PASS"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"

section "14. A2 HOMOLOGATION"

echo "MARKET_REGIME_LINEAGE_001_STAGE_A2=PASS"
echo "A2_REVISION=$REVISION"
echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "LINK_COUNT=$LINK_COUNT"
echo "BYTE_EXACT_RECOVERY=PASS"
echo "DECISION_LINEAGE_RELATION_RECOVERY=PASS"
echo "DECISION_LINEAGE_SEMANTICS=PASS"
echo "A_TO_B_CLASSIFICATION_CHANGE_RECOVERY=PASS"
echo "B_TO_C_STABLE_CLASSIFICATION_RECOVERY=PASS"
echo "B_TO_C_CHANGED_EVIDENCE_RECOVERY=PASS"
echo "FINAL_YODA_VERIFY=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"
echo "CLASSIFICATION_EXECUTED=NO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=B_INDEPENDENT_CLASSIFICATION_REPLAY"
