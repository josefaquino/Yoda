#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
REVISION="A2-R1"

ROOT="$HOME/cmu/$CASE"
A0="$ROOT/stage-a0-c1"
A1="$ROOT/stage-a1-r1"

STAGE="$ROOT/stage-a2-r1"
PREP="$ROOT/.stage-a2-r1-preflight"
STORE="$STAGE/yoda-store"
OBJECTS="$STAGE/objects"
RECOVERED="$STAGE/recovered"
EVIDENCE="$STAGE/evidence"

EXECUTION_LOCK="$ROOT/.stage-a2-r1-execution-started"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

A0_LOCK="$ROOT/.stage-a0-c1-execution-started"
A1_LOCK="$ROOT/.stage-a1-r1-execution-started"

EXPECTED_A0_LOCK_SHA256="7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2"
EXPECTED_A0_MANIFEST_SHA256="40499e4c4545974f3ed106d72cc5da356bdbadc8a4478f0a152e6d4f454c84cb"
EXPECTED_A1_LOCK_SHA256="85e493177e75aad351a45fcf9c5fb4aa2bf731dae483350aa10dc7a61cb31c0e"
EXPECTED_A1_MANIFEST_SHA256="6b5f0093426dac4b8a4603fbaf12f1859e0fb60e2eb09386a63ba8a49d425cc7"

A1_SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-stage-a1-r1.sh"
A1_CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a1-r1-console.log"

EXPECTED_A1_SCRIPT_SHA256="21d337571abfe2546afc2364f899bcc7e73fa52a265904d336f21c1420526560"
EXPECTED_A1_CONSOLE_SHA256="60f2e8fc9b38d4a7ffd0fb1e5c9fe15d61337cbe6c3b5846d9413b64c5d1dd34"
EXPECTED_CANONICAL_FACTS_SHA256="0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d"
EXPECTED_CANONICAL_EVALUATION_SHA256="906cb399db9bd91730506ec6f89242f5f88c921e543f09a5ffdc54e05a956bcb"
EXPECTED_CONTRACT_SHA256="ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd"
EXPECTED_C11_SOURCE_SHA256="9f41bda1c4e5a082cb739362f36030be047e00edef727518e7f74c161098fad0"
EXPECTED_AWK_SOURCE_SHA256="8b88216d22e6435319c73ec91dd3968cb453539c1a9effa1460bd9930fe0da91"

EXPECTED_FIL_A_SHA256="89223aafaf87a2bfbb82cf4d747100c7bfb27db05b1375729fb1b07f1b1936a3"
EXPECTED_FIL_B_SHA256="de199efb1b4b60e165ea65eed194b60672062f7238b1591641749da8a2ac0e4d"
EXPECTED_FACT_A_SHA256="56a76b46d98e31dfa239688822d982643ca04f6afdaf6043f84f832d732296a8"
EXPECTED_FACT_B_SHA256="cba3183da39bdde93bdc72636078d2f20096007efe487d6ee8834c719ced4851"
EXPECTED_EVAL_DESC_SHA256="96a346233886ab6c669e1902798022b612fd0fbd987fba650c88b8e3deaa6241"
EXPECTED_TRANSITION_SHA256="384c15ee2e7ec606f375b285a376c7dec68829fa9e254709409a129f1e9a9190"

OBJECT_COMMIT="0dbe9151c078e466f00d4d01b60c7448de46195f"
OBJECT_RAW_BASE="https://raw.githubusercontent.com/josefaquino/Yoda/$OBJECT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/objects/evaluation-lineage-v1"

KEY_FIL_A="disclosure/filing/A"
KEY_FIL_B="disclosure/filing/B"
KEY_RAW_A="disclosure/raw-filing/A"
KEY_RAW_B="disclosure/raw-filing/B"
KEY_COMPANYFACTS="disclosure/companyfacts/frozen"
KEY_FACT_A="disclosure/fact/A"
KEY_FACT_B="disclosure/fact/B"
KEY_CAN_FACTS="disclosure/facts/canonical"
KEY_SELECTION="disclosure/selection/frozen"
KEY_CAND_SCAN="disclosure/selection/candidate-scan"
KEY_TRANSITION="disclosure/transition/A-to-B"
KEY_EVAL_DESC="disclosure/evaluation/A-to-B"
KEY_CONTRACT="disclosure/contract/evaluation-v1"
KEY_C11_SRC="disclosure/authority/c11-v1"
KEY_AWK_SRC="disclosure/authority/awk-v1"
KEY_C11_RESULT="disclosure/evidence/c11-result"
KEY_AWK_RESULT="disclosure/evidence/awk-result"
KEY_CAN_EVAL="disclosure/evaluation/canonical"
KEY_POLICY="disclosure/selection/policy"
KEY_SUB_PARSER="disclosure/parser/submissions-v1"
KEY_CF_PARSER="disclosure/parser/companyfacts-v1"
KEY_A0_SUMMARY="evidence/disclosure/A0-C1-summary"
KEY_A0_MANIFEST="evidence/disclosure/A0-C1-manifest"
KEY_A1_SUMMARY="evidence/disclosure/A1-R1-summary"
KEY_A1_MANIFEST="evidence/disclosure/A1-R1-manifest"

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
    echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A2=NOT_EVALUATED"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "SEC_FETCHES=ZERO"
    echo "CLASSIFICATION_EXECUTED=NO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

fail()
{
    echo
    echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A2=FAIL"
    echo "A2_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A2_R1_RERUN=NO"
    echo "SEC_FETCHES=ZERO"
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

    "$YODA" -d "$STORE" put "$key" "$@" < "$file" >/dev/null ||
        fail "YODA_PERSISTENCE_FAILURE"
}

link()
{
    from="$1"
    relation="$2"
    to="$3"

    "$YODA" -d "$STORE" link \
        "$from" \
        "$relation" \
        "$to" \
        case="$CASE" \
        revision="$REVISION" \
        >/dev/null ||
        fail "YODA_RELATION_PERSISTENCE_FAILURE"
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

verify_identity()
{
    file="$1"
    expected="$2"
    failure="$3"

    test -f "$file" ||
        not_evaluated "$failure"

    test "$(sha "$file")" = "$expected" ||
        not_evaluated "$failure"
}

prep_copy()
{
    cp "$1" "$2" ||
        not_evaluated "A2_INPUT_MATERIALIZATION_FAILURE"
}

test ! -e "$EXECUTION_LOCK" ||
    not_evaluated "A2_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "A2_STAGE_ALREADY_EXISTS"

rm -rf "$PREP" ||
    not_evaluated "A2_PREFLIGHT_WORKSPACE_FAILURE"

mkdir -p "$PREP/objects" ||
    not_evaluated "A2_PREFLIGHT_WORKSPACE_FAILURE"

section "0. TOOLCHAIN + FROZEN YODA"

for cmd in curl sha256sum awk grep cmp wc find sort xargs cp mkdir rm cat
do
    command -v "$cmd" >/dev/null 2>&1 ||
        not_evaluated "TOOLCHAIN_DRIFT"
done

test -x "$YODA" ||
    not_evaluated "YODA_BINARY_MISSING"

ACTUAL_YODA_SHA256="$(sha "$YODA")"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    not_evaluated "YODA_IDENTITY_MISMATCH"

echo "YODA_AUTHORITY=PASS"
echo "YODA_SHA256=$ACTUAL_YODA_SHA256"

section "1. A0 + A1 AUTHORITY"

verify_identity "$A0_LOCK" "$EXPECTED_A0_LOCK_SHA256" "A0_C1_LOCK_IDENTITY_MISMATCH"
verify_identity "$A1_LOCK" "$EXPECTED_A1_LOCK_SHA256" "A1_R1_LOCK_IDENTITY_MISMATCH"

verify_identity "$A0/evidence/SHA256SUMS" "$EXPECTED_A0_MANIFEST_SHA256" "A0_C1_MANIFEST_IDENTITY_MISMATCH"
verify_identity "$A1/evidence/SHA256SUMS" "$EXPECTED_A1_MANIFEST_SHA256" "A1_R1_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0_C1_EVIDENCE_INTEGRITY_FAILURE"

(
    cd "$A1"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A1_R1_EVIDENCE_INTEGRITY_FAILURE"

verify_identity "$A1_SCRIPT" "$EXPECTED_A1_SCRIPT_SHA256" "A1_R1_SCRIPT_IDENTITY_MISMATCH"
verify_identity "$A1_CONSOLE" "$EXPECTED_A1_CONSOLE_SHA256" "A1_R1_CONSOLE_IDENTITY_MISMATCH"

verify_identity "$A0/canonical/canonical-facts.tsv" "$EXPECTED_CANONICAL_FACTS_SHA256" "A0_CANONICAL_FACTS_IDENTITY_MISMATCH"
verify_identity "$A1/results/canonical-evaluation.tsv" "$EXPECTED_CANONICAL_EVALUATION_SHA256" "A1_CANONICAL_EVALUATION_IDENTITY_MISMATCH"
verify_identity "$A1/contracts/evaluation-contract-v1.txt" "$EXPECTED_CONTRACT_SHA256" "EVALUATION_CONTRACT_IDENTITY_MISMATCH"
verify_identity "$A1/authorities/authority-1-c11-v1.c" "$EXPECTED_C11_SOURCE_SHA256" "C11_SOURCE_IDENTITY_MISMATCH"
verify_identity "$A1/authorities/authority-2-posix-v1.awk" "$EXPECTED_AWK_SOURCE_SHA256" "AWK_SOURCE_IDENTITY_MISMATCH"

grep -F "$(printf 'PUBLIC-DISCLOSURE-EVALUATION-V1\tAssets\tUSD\t-\t2024-06-30\t3314177\t3314177\t0\t0\t3314177\t100\tUNCHANGED')" \
    "$A1/results/canonical-evaluation.tsv" >/dev/null ||
    not_evaluated "A1_CANONICAL_EVALUATION_CONTENT_MISMATCH"

echo "A0_C1_AUTHORITY=PASS"
echo "A1_R1_AUTHORITY=PASS"
echo "A1_CANONICAL_EVALUATION_AUTHORITY=PASS"

section "2. FETCH + VERIFY PRE-REGISTERED SEMANTIC OBJECTS"

for name in \
    filing-state-A.tsv \
    filing-state-B.tsv \
    fact-state-A.tsv \
    fact-state-B.tsv \
    evaluation-A-to-B.tsv \
    transition-A-to-B.tsv
do
    curl -fsSL "$OBJECT_RAW_BASE/$name" -o "$PREP/objects/$name" ||
        not_evaluated "PRE_REGISTERED_OBJECT_FETCH_FAILURE"
done

verify_identity "$PREP/objects/filing-state-A.tsv" "$EXPECTED_FIL_A_SHA256" "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"
verify_identity "$PREP/objects/filing-state-B.tsv" "$EXPECTED_FIL_B_SHA256" "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"
verify_identity "$PREP/objects/fact-state-A.tsv" "$EXPECTED_FACT_A_SHA256" "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"
verify_identity "$PREP/objects/fact-state-B.tsv" "$EXPECTED_FACT_B_SHA256" "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"
verify_identity "$PREP/objects/evaluation-A-to-B.tsv" "$EXPECTED_EVAL_DESC_SHA256" "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"
verify_identity "$PREP/objects/transition-A-to-B.tsv" "$EXPECTED_TRANSITION_SHA256" "PRE_REGISTERED_OBJECT_IDENTITY_MISMATCH"

grep -F "$(printf 'A\tB\tYES\tNO\tUNCHANGED')" \
    "$PREP/objects/transition-A-to-B.tsv" >/dev/null ||
    not_evaluated "TRANSITION_OBJECT_MISMATCH"

grep -F "$(printf 'A\tB\tPUBLIC-DISCLOSURE-EVALUATION-V1\tAssets\tUSD\t-\t2024-06-30\t3314177\t3314177\t0\t3314177\t100\tUNCHANGED')" \
    "$PREP/objects/evaluation-A-to-B.tsv" >/dev/null ||
    not_evaluated "EVALUATION_OBJECT_MISMATCH"

echo "SEMANTIC_OBJECTS=FROZEN"
echo "OBJECT_COMMIT=$OBJECT_COMMIT"

section "3. MATERIALIZE COMPLETE A2 INPUT SET"

prep_copy "$A0/raw/original-submission.txt" "$PREP/objects/raw-filing-A.txt"
prep_copy "$A0/raw/amendment-submission.txt" "$PREP/objects/raw-filing-B.txt"
prep_copy "$A0/raw/companyfacts.json" "$PREP/objects/companyfacts.json"

prep_copy "$A0/canonical/canonical-facts.tsv" "$PREP/objects/canonical-facts.tsv"
prep_copy "$A0/selection/selection.tsv" "$PREP/objects/selection.tsv"
prep_copy "$A0/evidence/candidate-scan.tsv" "$PREP/objects/candidate-scan.tsv"

prep_copy "$A1/contracts/evaluation-contract-v1.txt" "$PREP/objects/evaluation-contract-v1.txt"
prep_copy "$A1/authorities/authority-1-c11-v1.c" "$PREP/objects/authority-1-c11-v1.c"
prep_copy "$A1/authorities/authority-2-posix-v1.awk" "$PREP/objects/authority-2-posix-v1.awk"
prep_copy "$A1/results/authority-1.tsv" "$PREP/objects/authority-1-result.tsv"
prep_copy "$A1/results/authority-2.tsv" "$PREP/objects/authority-2-result.tsv"
prep_copy "$A1/results/canonical-evaluation.tsv" "$PREP/objects/canonical-evaluation.tsv"

prep_copy "$A0/contracts/A0-DESIGN-AND-SELECTION-POLICY.md" "$PREP/objects/a0-selection-policy.md"
prep_copy "$A0/parsers/sec-submissions-v1.c" "$PREP/objects/sec-submissions-v1.c"
prep_copy "$A0/parsers/sec-companyfacts-v1.c" "$PREP/objects/sec-companyfacts-v1.c"

prep_copy "$A0/evidence/summary.tsv" "$PREP/objects/a0-c1-summary.tsv"
prep_copy "$A0/evidence/SHA256SUMS" "$PREP/objects/a0-c1-manifest.sha256"
prep_copy "$A1/evidence/summary.tsv" "$PREP/objects/a1-r1-summary.tsv"
prep_copy "$A1/evidence/SHA256SUMS" "$PREP/objects/a1-r1-manifest.sha256"

OBJECT_COUNT="$(find "$PREP/objects" -type f | wc -l | awk '{print $1}')"

test "$OBJECT_COUNT" = "25" ||
    not_evaluated "A2_OBJECT_COUNT_MISMATCH"

echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "A2_INPUT_SET=PASS"
echo "SEC_FETCHES=ZERO"
echo "CLASSIFICATION_EXECUTED=NO"

section "4. ONE-EXECUTION GATE"

cat > "$EXECUTION_LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
YODA_SHA256=$ACTUAL_YODA_SHA256
A0_C1_LOCK_SHA256=$EXPECTED_A0_LOCK_SHA256
A0_C1_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
A1_R1_LOCK_SHA256=$EXPECTED_A1_LOCK_SHA256
A1_R1_MANIFEST_SHA256=$EXPECTED_A1_MANIFEST_SHA256
CANONICAL_FACTS_SHA256=$EXPECTED_CANONICAL_FACTS_SHA256
CANONICAL_EVALUATION_SHA256=$EXPECTED_CANONICAL_EVALUATION_SHA256
OBJECT_COUNT=$OBJECT_COUNT
EXPECTED_LINK_COUNT=35
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_YODA_WRITE=YES
EOF

test -f "$EXECUTION_LOCK" ||
    not_evaluated "A2_LOCK_CREATION_FAILURE"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$EXECUTION_LOCK")"
echo "EXECUTION_GATE=PASS"

mkdir -p "$OBJECTS" "$RECOVERED" "$EVIDENCE" ||
    fail "A2_STAGE_MATERIALIZATION_FAILURE"

cp "$PREP/objects/"* "$OBJECTS/" ||
    fail "A2_STAGE_MATERIALIZATION_FAILURE"

rm -rf "$PREP" || true

section "5. INITIALIZE FRESH YODA STORE"

"$YODA" init "$STORE" >/dev/null ||
    fail "YODA_PERSISTENCE_FAILURE"

echo "YODA_INIT=PASS"

section "6. STORE EVALUATION LINEAGE OBJECTS"

put_file "$KEY_FIL_A" "$OBJECTS/filing-state-A.tsv" type=filing-state state=A role=original
put_file "$KEY_FIL_B" "$OBJECTS/filing-state-B.tsv" type=filing-state state=B role=amendment

put_file "$KEY_RAW_A" "$OBJECTS/raw-filing-A.txt" type=raw-sec-filing state=A
put_file "$KEY_RAW_B" "$OBJECTS/raw-filing-B.txt" type=raw-sec-filing state=B

put_file "$KEY_COMPANYFACTS" "$OBJECTS/companyfacts.json" type=sec-companyfacts frozen=YES

put_file "$KEY_FACT_A" "$OBJECTS/fact-state-A.tsv" type=structured-fact state=A concept=Assets
put_file "$KEY_FACT_B" "$OBJECTS/fact-state-B.tsv" type=structured-fact state=B concept=Assets

put_file "$KEY_CAN_FACTS" "$OBJECTS/canonical-facts.tsv" type=canonical-facts result=PASS
put_file "$KEY_SELECTION" "$OBJECTS/selection.tsv" type=frozen-selection ordinal=1
put_file "$KEY_CAND_SCAN" "$OBJECTS/candidate-scan.tsv" type=selection-evidence result=PASS

put_file "$KEY_TRANSITION" "$OBJECTS/transition-A-to-B.tsv" type=disclosure-transition from=A to=B
put_file "$KEY_EVAL_DESC" "$OBJECTS/evaluation-A-to-B.tsv" type=evaluation-descriptor classification=UNCHANGED

put_file "$KEY_CONTRACT" "$OBJECTS/evaluation-contract-v1.txt" type=evaluation-contract version=v1

put_file "$KEY_C11_SRC" "$OBJECTS/authority-1-c11-v1.c" type=evaluation-authority implementation=C11
put_file "$KEY_AWK_SRC" "$OBJECTS/authority-2-posix-v1.awk" type=evaluation-authority implementation=POSIX_AWK

put_file "$KEY_C11_RESULT" "$OBJECTS/authority-1-result.tsv" type=evaluation-evidence authority=C11 result=PASS
put_file "$KEY_AWK_RESULT" "$OBJECTS/authority-2-result.tsv" type=evaluation-evidence authority=POSIX_AWK result=PASS
put_file "$KEY_CAN_EVAL" "$OBJECTS/canonical-evaluation.tsv" type=canonical-evaluation classification=UNCHANGED

put_file "$KEY_POLICY" "$OBJECTS/a0-selection-policy.md" type=selection-policy stage=A0
put_file "$KEY_SUB_PARSER" "$OBJECTS/sec-submissions-v1.c" type=selection-parser source=submissions
put_file "$KEY_CF_PARSER" "$OBJECTS/sec-companyfacts-v1.c" type=selection-parser source=companyfacts

put_file "$KEY_A0_SUMMARY" "$OBJECTS/a0-c1-summary.tsv" type=evidence-summary stage=A0-C1
put_file "$KEY_A0_MANIFEST" "$OBJECTS/a0-c1-manifest.sha256" type=evidence-manifest stage=A0-C1
put_file "$KEY_A1_SUMMARY" "$OBJECTS/a1-r1-summary.tsv" type=evidence-summary stage=A1-R1
put_file "$KEY_A1_MANIFEST" "$OBJECTS/a1-r1-manifest.sha256" type=evidence-manifest stage=A1-R1

echo "YODA_OBJECT_INGEST=PASS"
echo "OBJECT_COUNT=$OBJECT_COUNT"

section "7. CREATE EVALUATION LINEAGE RELATIONS"

link "$KEY_FIL_B" supersedes "$KEY_FIL_A"

link "$KEY_FIL_A" has-evidence "$KEY_RAW_A"
link "$KEY_FIL_B" has-evidence "$KEY_RAW_B"

link "$KEY_FACT_A" reported-in "$KEY_FIL_A"
link "$KEY_FACT_B" reported-in "$KEY_FIL_B"

link "$KEY_FACT_A" extracted-from "$KEY_COMPANYFACTS"
link "$KEY_FACT_B" extracted-from "$KEY_COMPANYFACTS"

link "$KEY_COMPANYFACTS" parsed-by "$KEY_CF_PARSER"

link "$KEY_SELECTION" selected-by "$KEY_POLICY"
link "$KEY_SELECTION" has-evidence "$KEY_CAND_SCAN"
link "$KEY_SELECTION" resolved-to "$KEY_FIL_A"
link "$KEY_SELECTION" resolved-to "$KEY_FIL_B"
link "$KEY_SELECTION" resolved-to "$KEY_FACT_A"
link "$KEY_SELECTION" resolved-to "$KEY_FACT_B"
link "$KEY_SELECTION" parsed-by "$KEY_SUB_PARSER"
link "$KEY_SELECTION" parsed-by "$KEY_CF_PARSER"

link "$KEY_CAN_FACTS" composed-from "$KEY_FACT_A"
link "$KEY_CAN_FACTS" composed-from "$KEY_FACT_B"

link "$KEY_TRANSITION" from-state "$KEY_FACT_A"
link "$KEY_TRANSITION" to-state "$KEY_FACT_B"
link "$KEY_TRANSITION" has-evaluation "$KEY_EVAL_DESC"

link "$KEY_EVAL_DESC" compares "$KEY_FACT_A"
link "$KEY_EVAL_DESC" compares "$KEY_FACT_B"
link "$KEY_EVAL_DESC" evaluated-by "$KEY_CONTRACT"
link "$KEY_EVAL_DESC" supported-by "$KEY_CAN_EVAL"

link "$KEY_CAN_EVAL" supported-by "$KEY_C11_RESULT"
link "$KEY_CAN_EVAL" supported-by "$KEY_AWK_RESULT"

link "$KEY_C11_RESULT" evaluated-by "$KEY_C11_SRC"
link "$KEY_AWK_RESULT" evaluated-by "$KEY_AWK_SRC"

link "$KEY_A0_SUMMARY" has-evidence "$KEY_A0_MANIFEST"
link "$KEY_A1_SUMMARY" has-evidence "$KEY_A1_MANIFEST"

link "$KEY_FIL_A" has-evidence "$KEY_A0_SUMMARY"
link "$KEY_FIL_B" has-evidence "$KEY_A0_SUMMARY"
link "$KEY_CAN_FACTS" has-evidence "$KEY_A0_SUMMARY"
link "$KEY_EVAL_DESC" has-evidence "$KEY_A1_SUMMARY"

LINK_COUNT=35

echo "LINK_COUNT=$LINK_COUNT"
echo "EVALUATION_LINEAGE_RELATIONS=PASS"

section "8. VERIFY YODA STORE"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-verify.txt" 2>&1 ||
    fail "YODA_PERSISTENCE_FAILURE"

echo "YODA_VERIFY=PASS"

section "9. BYTE-EXACT RECOVERY"

recover_cmp "$KEY_FIL_A" "$OBJECTS/filing-state-A.tsv" "$RECOVERED/filing-state-A.tsv"
recover_cmp "$KEY_FIL_B" "$OBJECTS/filing-state-B.tsv" "$RECOVERED/filing-state-B.tsv"
recover_cmp "$KEY_RAW_A" "$OBJECTS/raw-filing-A.txt" "$RECOVERED/raw-filing-A.txt"
recover_cmp "$KEY_RAW_B" "$OBJECTS/raw-filing-B.txt" "$RECOVERED/raw-filing-B.txt"
recover_cmp "$KEY_COMPANYFACTS" "$OBJECTS/companyfacts.json" "$RECOVERED/companyfacts.json"
recover_cmp "$KEY_FACT_A" "$OBJECTS/fact-state-A.tsv" "$RECOVERED/fact-state-A.tsv"
recover_cmp "$KEY_FACT_B" "$OBJECTS/fact-state-B.tsv" "$RECOVERED/fact-state-B.tsv"
recover_cmp "$KEY_CAN_FACTS" "$OBJECTS/canonical-facts.tsv" "$RECOVERED/canonical-facts.tsv"
recover_cmp "$KEY_SELECTION" "$OBJECTS/selection.tsv" "$RECOVERED/selection.tsv"
recover_cmp "$KEY_CAND_SCAN" "$OBJECTS/candidate-scan.tsv" "$RECOVERED/candidate-scan.tsv"
recover_cmp "$KEY_TRANSITION" "$OBJECTS/transition-A-to-B.tsv" "$RECOVERED/transition-A-to-B.tsv"
recover_cmp "$KEY_EVAL_DESC" "$OBJECTS/evaluation-A-to-B.tsv" "$RECOVERED/evaluation-A-to-B.tsv"
recover_cmp "$KEY_CONTRACT" "$OBJECTS/evaluation-contract-v1.txt" "$RECOVERED/evaluation-contract-v1.txt"
recover_cmp "$KEY_C11_SRC" "$OBJECTS/authority-1-c11-v1.c" "$RECOVERED/authority-1-c11-v1.c"
recover_cmp "$KEY_AWK_SRC" "$OBJECTS/authority-2-posix-v1.awk" "$RECOVERED/authority-2-posix-v1.awk"
recover_cmp "$KEY_C11_RESULT" "$OBJECTS/authority-1-result.tsv" "$RECOVERED/authority-1-result.tsv"
recover_cmp "$KEY_AWK_RESULT" "$OBJECTS/authority-2-result.tsv" "$RECOVERED/authority-2-result.tsv"
recover_cmp "$KEY_CAN_EVAL" "$OBJECTS/canonical-evaluation.tsv" "$RECOVERED/canonical-evaluation.tsv"
recover_cmp "$KEY_POLICY" "$OBJECTS/a0-selection-policy.md" "$RECOVERED/a0-selection-policy.md"
recover_cmp "$KEY_SUB_PARSER" "$OBJECTS/sec-submissions-v1.c" "$RECOVERED/sec-submissions-v1.c"
recover_cmp "$KEY_CF_PARSER" "$OBJECTS/sec-companyfacts-v1.c" "$RECOVERED/sec-companyfacts-v1.c"
recover_cmp "$KEY_A0_SUMMARY" "$OBJECTS/a0-c1-summary.tsv" "$RECOVERED/a0-c1-summary.tsv"
recover_cmp "$KEY_A0_MANIFEST" "$OBJECTS/a0-c1-manifest.sha256" "$RECOVERED/a0-c1-manifest.sha256"
recover_cmp "$KEY_A1_SUMMARY" "$OBJECTS/a1-r1-summary.tsv" "$RECOVERED/a1-r1-summary.tsv"
recover_cmp "$KEY_A1_MANIFEST" "$OBJECTS/a1-r1-manifest.sha256" "$RECOVERED/a1-r1-manifest.sha256"

echo "BYTE_EXACT_RECOVERY=PASS"
echo "FILING_RECOVERY=PASS"
echo "RAW_DISCLOSURE_RECOVERY=PASS"
echo "FACT_RECOVERY=PASS"
echo "SELECTION_EVIDENCE_RECOVERY=PASS"
echo "EVALUATION_RECOVERY=PASS"
echo "AUTHORITY_SOURCE_RECOVERY=PASS"
echo "AUTHORITY_RESULT_RECOVERY=PASS"
echo "EVIDENCE_MANIFEST_RECOVERY=PASS"

section "10. RELATION RECOVERY VIA YODA LOG"

TAB="$(printf '\t')"

"$YODA" -d "$STORE" log "$KEY_FIL_A" > "$EVIDENCE/log-filing-A.txt"
"$YODA" -d "$STORE" log "$KEY_FIL_B" > "$EVIDENCE/log-filing-B.txt"
"$YODA" -d "$STORE" log "$KEY_FACT_A" > "$EVIDENCE/log-fact-A.txt"
"$YODA" -d "$STORE" log "$KEY_FACT_B" > "$EVIDENCE/log-fact-B.txt"
"$YODA" -d "$STORE" log "$KEY_COMPANYFACTS" > "$EVIDENCE/log-companyfacts.txt"
"$YODA" -d "$STORE" log "$KEY_SELECTION" > "$EVIDENCE/log-selection.txt"
"$YODA" -d "$STORE" log "$KEY_CAN_FACTS" > "$EVIDENCE/log-canonical-facts.txt"
"$YODA" -d "$STORE" log "$KEY_TRANSITION" > "$EVIDENCE/log-transition.txt"
"$YODA" -d "$STORE" log "$KEY_EVAL_DESC" > "$EVIDENCE/log-evaluation.txt"
"$YODA" -d "$STORE" log "$KEY_CAN_EVAL" > "$EVIDENCE/log-canonical-evaluation.txt"
"$YODA" -d "$STORE" log "$KEY_C11_RESULT" > "$EVIDENCE/log-c11-result.txt"
"$YODA" -d "$STORE" log "$KEY_AWK_RESULT" > "$EVIDENCE/log-awk-result.txt"

grep -F "supersedes$TAB$KEY_FIL_A" "$EVIDENCE/log-filing-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "reported-in$TAB$KEY_FIL_A" "$EVIDENCE/log-fact-A.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "reported-in$TAB$KEY_FIL_B" "$EVIDENCE/log-fact-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "extracted-from$TAB$KEY_COMPANYFACTS" "$EVIDENCE/log-fact-A.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "extracted-from$TAB$KEY_COMPANYFACTS" "$EVIDENCE/log-fact-B.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "parsed-by$TAB$KEY_CF_PARSER" "$EVIDENCE/log-companyfacts.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "selected-by$TAB$KEY_POLICY" "$EVIDENCE/log-selection.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "has-evidence$TAB$KEY_CAND_SCAN" "$EVIDENCE/log-selection.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "resolved-to$TAB$KEY_FIL_A" "$EVIDENCE/log-selection.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "resolved-to$TAB$KEY_FIL_B" "$EVIDENCE/log-selection.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "resolved-to$TAB$KEY_FACT_A" "$EVIDENCE/log-selection.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "resolved-to$TAB$KEY_FACT_B" "$EVIDENCE/log-selection.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "composed-from$TAB$KEY_FACT_A" "$EVIDENCE/log-canonical-facts.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "composed-from$TAB$KEY_FACT_B" "$EVIDENCE/log-canonical-facts.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "from-state$TAB$KEY_FACT_A" "$EVIDENCE/log-transition.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "to-state$TAB$KEY_FACT_B" "$EVIDENCE/log-transition.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "has-evaluation$TAB$KEY_EVAL_DESC" "$EVIDENCE/log-transition.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "compares$TAB$KEY_FACT_A" "$EVIDENCE/log-evaluation.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "compares$TAB$KEY_FACT_B" "$EVIDENCE/log-evaluation.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "evaluated-by$TAB$KEY_CONTRACT" "$EVIDENCE/log-evaluation.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supported-by$TAB$KEY_CAN_EVAL" "$EVIDENCE/log-evaluation.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supported-by$TAB$KEY_C11_RESULT" "$EVIDENCE/log-canonical-evaluation.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "supported-by$TAB$KEY_AWK_RESULT" "$EVIDENCE/log-canonical-evaluation.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "evaluated-by$TAB$KEY_C11_SRC" "$EVIDENCE/log-c11-result.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

grep -F "evaluated-by$TAB$KEY_AWK_SRC" "$EVIDENCE/log-awk-result.txt" >/dev/null ||
    fail "YODA_RELATION_RECOVERY_FAILURE"

echo "FILING_SUPERSEDES_RELATION_RECOVERY=PASS"
echo "FACT_PROVENANCE_RELATION_RECOVERY=PASS"
echo "SELECTION_PROVENANCE_RELATION_RECOVERY=PASS"
echo "EVALUATION_RELATION_RECOVERY=PASS"
echo "AUTHORITY_RELATION_RECOVERY=PASS"
echo "EVALUATION_LINEAGE_RELATION_RECOVERY=PASS"

section "11. EVALUATION LINEAGE SEMANTIC RECOVERY"

grep -F "$(printf 'A\toriginal\t0001807166\t0001213900-24-083458\t10-K\t2024-09-30\t2024-06-30')" \
    "$RECOVERED/filing-state-A.tsv" >/dev/null ||
    fail "SEMANTIC_RECOVERY_FAILURE"

grep -F "$(printf 'B\tamendment\t0001807166\t0001213900-25-000438\t10-K/A\t2025-01-02\t2024-06-30')" \
    "$RECOVERED/filing-state-B.tsv" >/dev/null ||
    fail "SEMANTIC_RECOVERY_FAILURE"

grep -F "$(printf 'A\t0001213900-24-083458\tAssets\tUSD\t-\t2024-06-30\t3314177')" \
    "$RECOVERED/fact-state-A.tsv" >/dev/null ||
    fail "SEMANTIC_RECOVERY_FAILURE"

grep -F "$(printf 'B\t0001213900-25-000438\tAssets\tUSD\t-\t2024-06-30\t3314177')" \
    "$RECOVERED/fact-state-B.tsv" >/dev/null ||
    fail "SEMANTIC_RECOVERY_FAILURE"

grep -F "$(printf 'A\tB\tYES\tNO\tUNCHANGED')" \
    "$RECOVERED/transition-A-to-B.tsv" >/dev/null ||
    fail "SEMANTIC_RECOVERY_FAILURE"

grep -F "$(printf 'A\tB\tPUBLIC-DISCLOSURE-EVALUATION-V1\tAssets\tUSD\t-\t2024-06-30\t3314177\t3314177\t0\t3314177\t100\tUNCHANGED')" \
    "$RECOVERED/evaluation-A-to-B.tsv" >/dev/null ||
    fail "SEMANTIC_RECOVERY_FAILURE"

echo "FILING_IDENTITY_CHANGED_RECOVERY=PASS"
echo "PUBLIC_DISCLOSURE_STATE_ADVANCED_RECOVERY=PASS"
echo "SELECTED_FACT_VALUE_STABLE_RECOVERY=PASS"
echo "EVALUATION_UNCHANGED_RECOVERY=PASS"
echo "EVALUATION_LINEAGE_SEMANTICS=PASS"

section "12. FINAL VERIFY + FREEZE YODA STATE"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-final-verify.txt" 2>&1 ||
    fail "YODA_PERSISTENCE_FAILURE"

test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "YODA_IDENTITY_MISMATCH"

DATA_YODA="$STORE/data.yoda"

test -f "$DATA_YODA" ||
    fail "YODA_PERSISTENCE_FAILURE"

DATA_YODA_SHA256="$(sha "$DATA_YODA")"
DATA_YODA_BYTES="$(wc -c < "$DATA_YODA" | awk '{print $1}')"

echo "FINAL_YODA_VERIFY=PASS"
echo "YODA_BINARY_IDENTITY_UNCHANGED=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "DATA_YODA_BYTES=$DATA_YODA_BYTES"

section "13. SUMMARY"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
YODA_SHA256	$ACTUAL_YODA_SHA256
A0_C1_LOCK_SHA256	$EXPECTED_A0_LOCK_SHA256
A0_C1_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
A1_R1_LOCK_SHA256	$EXPECTED_A1_LOCK_SHA256
A1_R1_MANIFEST_SHA256	$EXPECTED_A1_MANIFEST_SHA256
CANONICAL_FACTS_SHA256	$EXPECTED_CANONICAL_FACTS_SHA256
CANONICAL_EVALUATION_SHA256	$EXPECTED_CANONICAL_EVALUATION_SHA256
OBJECT_COUNT	$OBJECT_COUNT
LINK_COUNT	$LINK_COUNT
BYTE_EXACT_RECOVERY	PASS
FILING_SUPERSEDES_RELATION_RECOVERY	PASS
FACT_PROVENANCE_RELATION_RECOVERY	PASS
SELECTION_PROVENANCE_RELATION_RECOVERY	PASS
EVALUATION_RELATION_RECOVERY	PASS
AUTHORITY_RELATION_RECOVERY	PASS
EVALUATION_LINEAGE_RELATION_RECOVERY	PASS
FILING_IDENTITY_CHANGED_RECOVERY	PASS
PUBLIC_DISCLOSURE_STATE_ADVANCED_RECOVERY	PASS
SELECTED_FACT_VALUE_STABLE_RECOVERY	PASS
EVALUATION_UNCHANGED_RECOVERY	PASS
EVALUATION_LINEAGE_SEMANTICS	PASS
FINAL_YODA_VERIFY	PASS
DATA_YODA_SHA256	$DATA_YODA_SHA256
DATA_YODA_BYTES	$DATA_YODA_BYTES
SEC_FETCHES	ZERO
CLASSIFICATION_EXECUTED	NO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

section "14. FREEZE A2 EVIDENCE"

cp "$0" "$EVIDENCE/stage-a2-r1-script.sh" ||
    fail "A2_EVIDENCE_MATERIALIZATION_FAILURE"

cp "$EXECUTION_LOCK" "$EVIDENCE/execution-started.txt" ||
    fail "A2_EVIDENCE_MATERIALIZATION_FAILURE"

(
    cd "$STAGE"

    find evidence objects recovered yoda-store \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
) || fail "A2_EVIDENCE_INTEGRITY_FAILURE"

A2_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A2_EVIDENCE_INTEGRITY=PASS"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"

section "15. A2 HOMOLOGATION"

echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A2=PASS"
echo "A2_REVISION=$REVISION"

echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "LINK_COUNT=$LINK_COUNT"

echo "BYTE_EXACT_RECOVERY=PASS"
echo "FILING_SUPERSEDES_RELATION_RECOVERY=PASS"
echo "FACT_PROVENANCE_RELATION_RECOVERY=PASS"
echo "SELECTION_PROVENANCE_RELATION_RECOVERY=PASS"
echo "EVALUATION_RELATION_RECOVERY=PASS"
echo "AUTHORITY_RELATION_RECOVERY=PASS"
echo "EVALUATION_LINEAGE_RELATION_RECOVERY=PASS"

echo "FILING_IDENTITY_CHANGED_RECOVERY=PASS"
echo "PUBLIC_DISCLOSURE_STATE_ADVANCED_RECOVERY=PASS"
echo "SELECTED_FACT_VALUE_STABLE_RECOVERY=PASS"
echo "EVALUATION_UNCHANGED_RECOVERY=PASS"
echo "EVALUATION_LINEAGE_SEMANTICS=PASS"

echo "FINAL_YODA_VERIFY=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"

echo "SEC_FETCHES=ZERO"
echo "CLASSIFICATION_EXECUTED=NO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=B_INDEPENDENT_EVALUATION_REPLAY_FROM_YODA_GET_ONLY"
