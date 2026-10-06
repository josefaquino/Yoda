#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
REVISION="A0-C1"

ROOT="$HOME/cmu/$CASE"
A0R1="$ROOT/stage-a0-r1"
A0R1_LOCK="$ROOT/.stage-a0-r1-execution-started"

STAGE="$ROOT/stage-a0-c1"
LOCK="$ROOT/.stage-a0-c1-execution-started"

RAW="$STAGE/raw"
SELECTION="$STAGE/selection"
CANONICAL="$STAGE/canonical"
EVIDENCE="$STAGE/evidence"
CONTRACTS="$STAGE/contracts"
PARSERS="$STAGE/parsers"

A0R1_SELECTION="$A0R1/selection/selection.tsv"
A0R1_CANONICAL="$A0R1/canonical/canonical-facts.tsv"
A0R1_SELECTED_RAW="$A0R1/raw/selected"
A0R1_MASTER="$A0R1/raw/master-index"
A0R1_CANDIDATE_SCAN="$A0R1/evidence/candidate-scan.tsv"

EXPECTED_A0R1_LOCK_SHA256="95143c814b061a68e0857eb508f7b0324bf3eabe755d872c72bc4c257f404b0f"
EXPECTED_SELECTION_SHA256="3bff9ec5b957231543e1c9c6d45dc0d026cf2bd1113660a39056d7ffc25dc85f"
EXPECTED_PARTIAL_CANONICAL_SHA256="67de9dc83bf2223a84b3541de26ab87e8a72c4916c2fe87609baee45a755b7b3"
EXPECTED_CANONICAL_PAYLOAD_SHA256="0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d"
EXPECTED_CANDIDATE_SCAN_SHA256="e7e6648419715b1402e5a25b3ff2c2e1348e4e2e90637710c481aeb556fdaba2"

EXPECTED_SUBMISSIONS_CURRENT_SHA256="ec0c168cb1f8bbec6d9ffe676219679aad0cc4d05f8427f3078eedf48f37e027"
EXPECTED_HISTORY_FILES_SHA256="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
EXPECTED_ALL_FILINGS_SHA256="94dedbdbdbbeed6d6df7e9d06baa959423c51e4a81c6b52f5dc2e3282c8f657e"
EXPECTED_COMPANYFACTS_SHA256="a012fe95a36f2d1277fd31dad59e09003d0ced5bdff279dcbdc145ee1ca228c2"
EXPECTED_ORIGINAL_INDEX_SHA256="4a6c0db737a1bd01f4fbba4e46d8c09a75eac2050161e8c336eec624fd2fe5a0"
EXPECTED_AMENDMENT_INDEX_SHA256="7b1d5a6d9846baa478c599a304b16c1f7e75ef3bc6170fe845449cfb8f97c4df"

EXPECTED_QTR1_SHA256="1e62ae3cddf4a97c23a2732709d75926dcf794c57a4df2cf96ad1027ca7aed2f"
EXPECTED_QTR2_SHA256="673b90f8e958bdee2b23345e0a2d8170e4cb4dd110e9be84d84590db86324068"
EXPECTED_QTR3_SHA256="593b69116a04cb7a0b155a4eeec7ba7ca1fb6c560fc9936639227254afce96db"
EXPECTED_QTR4_SHA256="7f430dc4f33f9930b872753d9b469da1cb55e1382d8ec1076299e151734e8d85"

EXPECTED_POLICY_SHA256="390a46190a204d8c6eb2e3b249b5b875370728e8770f7c1cfdb6410a59575aff"
EXPECTED_EVALUATION_CONTRACT_SHA256="ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd"
EXPECTED_SUBMISSIONS_PARSER_SHA256="44efbbe85b4061fdee796a37ff2e291e9ad5697941f4ad2581093a321a7b0584"
EXPECTED_COMPANYFACTS_PARSER_SHA256="64bca9c530ed653970af3e5715bbea52f9bdf30f7a2bbaf4e703c8b75da50775"

CIK="1807166"
CIK10="0001807166"
ORIGINAL_ACCN="0001213900-24-083458"
AMENDMENT_ACCN="0001213900-25-000438"
ORIGINAL_COMPACT="000121390024083458"
AMENDMENT_COMPACT="000121390025000438"
REPORT_DATE_COMPACT="20240630"

SEC_ARCHIVE_BASE="https://www.sec.gov/Archives/edgar/data"
REQUEST_SPACING_SECONDS="0.40"
SEC_REQUEST_COUNT=0
AUTHORIZED_SEC_REQUEST_COUNT=2

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
    echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A0_C1=NOT_EVALUATED"
    echo "A0_CONTINUATION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A0_R1_STATUS=NOT_EVALUATED"
    echo "A0_R1_RERUN=NO"
    echo "SELECTED_TUPLE_RESELECTION=FORBIDDEN"
    echo "PARSER_EXECUTED=NO"
    echo "CLASSIFICATION_EXECUTED=NO"
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
        not_evaluated "LOCAL_TOOLCHAIN_MISSING"
    fi
}

verify_file()
{
    file="$1"
    expected="$2"
    label="$3"

    test -f "$file" ||
        not_evaluated "$label"_MISSING

    actual="$(sha "$file")"

    if test "$actual" != "$expected"
    then
        echo "$label"_ACTUAL_SHA256="$actual"
        not_evaluated "$label"_IDENTITY_MISMATCH
    fi

    echo "$label=PASS"
    echo "$label"_SHA256="$actual"
}

sec_fetch()
{
    url="$1"
    body="$2"

    sleep "$REQUEST_SPACING_SECONDS"
    SEC_REQUEST_COUNT=$((SEC_REQUEST_COUNT + 1))

    curl         --fail         --silent         --show-error         --location         --compressed         --user-agent "$SEC_USER_AGENT"         --header "Accept: text/plain,*/*;q=0.8"         --output "$body"         "$url"
}

test ! -e "$LOCK" ||
    not_evaluated "A0_C1_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "A0_C1_STAGE_ALREADY_EXISTS"

section "0. GOVERNANCE + TOOLCHAIN"

for pair in     "curl:CURL"     "awk:AWK"     "grep:GREP"     "sed:SED"     "sha256sum:SHA256SUM"     "wc:WC"     "tail:TAIL"     "find:FIND"     "sort:SORT"     "xargs:XARGS"     "cp:CP"     "mkdir:MKDIR"     "sleep:SLEEP"
do
    cmd="$(printf '%s\n' "$pair" | cut -d: -f1)"
    label="$(printf '%s\n' "$pair" | cut -d: -f2)"
    require_cmd "$cmd" "$label"
done

if test -z "${SEC_USER_AGENT:-}"
then
    not_evaluated "SEC_USER_AGENT_MISSING"
fi

case "$SEC_USER_AGENT" in
    *" "*@*.*)
        echo "USER_AGENT_POLICY=PASS"
        ;;
    *)
        not_evaluated "SEC_USER_AGENT_FORMAT"
        ;;
esac

echo "A0_R1_RERUN=NO"
echo "CANDIDATE_RESCAN=FORBIDDEN"
echo "SELECTED_TUPLE_RESELECTION=FORBIDDEN"
echo "PARSER_EXECUTED=NO"
echo "CLASSIFICATION_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

section "1. VERIFY CONSUMED A0-R1 AUTHORITY"

verify_file     "$A0R1_LOCK"     "$EXPECTED_A0R1_LOCK_SHA256"     "A0_R1_LOCK_IDENTITY"

verify_file     "$A0R1_SELECTION"     "$EXPECTED_SELECTION_SHA256"     "SELECTION_IDENTITY"

verify_file     "$A0R1_CANONICAL"     "$EXPECTED_PARTIAL_CANONICAL_SHA256"     "PARTIAL_CANONICAL_IDENTITY"

verify_file     "$A0R1_CANDIDATE_SCAN"     "$EXPECTED_CANDIDATE_SCAN_SHA256"     "CANDIDATE_SCAN_IDENTITY"

test "$(wc -l < "$A0R1_SELECTION" | tr -d ' ')" = "2" ||
    not_evaluated "SELECTION_SHAPE_MISMATCH"

grep -F "$(printf '1\t0001807166\tAmesite Inc.\t2024-09-30\t2025-01-02\t2024-06-30\t0001213900-24-083458\t0001213900-25-000438\tAssets\tinstant\tUSD\t-\t2024-06-30')"     "$A0R1_SELECTION" >/dev/null ||
    not_evaluated "FROZEN_SELECTION_TUPLE_MISMATCH"

test "$(wc -l < "$A0R1_CANONICAL" | tr -d ' ')" = "4" ||
    not_evaluated "PARTIAL_CANONICAL_SHAPE_MISMATCH"

test "$(sed -n '1p' "$A0R1_CANONICAL")" = "PARSER_STATUS=PASS" ||
    not_evaluated "PARTIAL_CANONICAL_PREAMBLE_MISMATCH"

PAYLOAD_SHA256="$(
    tail -n +2 "$A0R1_CANONICAL" |
    sha256sum |
    awk '{print $1}'
)"

test "$PAYLOAD_SHA256" = "$EXPECTED_CANONICAL_PAYLOAD_SHA256" ||
    not_evaluated "CANONICAL_PAYLOAD_IDENTITY_MISMATCH"

echo "CANONICAL_PAYLOAD_IDENTITY=PASS"
echo "CANONICAL_PAYLOAD_SHA256=$PAYLOAD_SHA256"

section "2. VERIFY EXISTING SELECTED RAW BYTES"

verify_file     "$A0R1_SELECTED_RAW/submissions-current.json"     "$EXPECTED_SUBMISSIONS_CURRENT_SHA256"     "SUBMISSIONS_CURRENT_IDENTITY"

verify_file     "$A0R1_SELECTED_RAW/history-files.txt"     "$EXPECTED_HISTORY_FILES_SHA256"     "HISTORY_FILES_IDENTITY"

verify_file     "$A0R1_SELECTED_RAW/submissions-all-filings.tsv"     "$EXPECTED_ALL_FILINGS_SHA256"     "ALL_FILINGS_IDENTITY"

verify_file     "$A0R1_SELECTED_RAW/companyfacts.json"     "$EXPECTED_COMPANYFACTS_SHA256"     "COMPANYFACTS_IDENTITY"

verify_file     "$A0R1_SELECTED_RAW/original-index.htm"     "$EXPECTED_ORIGINAL_INDEX_SHA256"     "ORIGINAL_INDEX_IDENTITY"

verify_file     "$A0R1_SELECTED_RAW/amendment-index.htm"     "$EXPECTED_AMENDMENT_INDEX_SHA256"     "AMENDMENT_INDEX_IDENTITY"

test ! -e "$A0R1_SELECTED_RAW/original-submission.txt" ||
    not_evaluated "A0_R1_PARTIAL_STATE_CHANGED"

test ! -e "$A0R1_SELECTED_RAW/amendment-submission.txt" ||
    not_evaluated "A0_R1_PARTIAL_STATE_CHANGED"

echo "ALL_EXISTING_SELECTED_RAW_IDENTITIES=PASS"

section "3. VERIFY FROZEN 2025 UNIVERSE"

verify_file     "$A0R1_MASTER/QTR1-master.idx"     "$EXPECTED_QTR1_SHA256"     "QTR1_MASTER_INDEX_IDENTITY"

verify_file     "$A0R1_MASTER/QTR2-master.idx"     "$EXPECTED_QTR2_SHA256"     "QTR2_MASTER_INDEX_IDENTITY"

verify_file     "$A0R1_MASTER/QTR3-master.idx"     "$EXPECTED_QTR3_SHA256"     "QTR3_MASTER_INDEX_IDENTITY"

verify_file     "$A0R1_MASTER/QTR4-master.idx"     "$EXPECTED_QTR4_SHA256"     "QTR4_MASTER_INDEX_IDENTITY"

echo "FROZEN_MASTER_INDEX_IDENTITIES=PASS"

section "4. VERIFY FROZEN DESIGN ARTIFACTS"

verify_file     "$A0R1/contracts/A0-DESIGN-AND-SELECTION-POLICY.md"     "$EXPECTED_POLICY_SHA256"     "A0_SELECTION_POLICY_IDENTITY"

verify_file     "$A0R1/contracts/evaluation-contract-v1.txt"     "$EXPECTED_EVALUATION_CONTRACT_SHA256"     "EVALUATION_CONTRACT_IDENTITY"

verify_file     "$A0R1/parsers/sec-submissions-v1.c"     "$EXPECTED_SUBMISSIONS_PARSER_SHA256"     "SUBMISSIONS_PARSER_SOURCE_IDENTITY"

verify_file     "$A0R1/parsers/sec-companyfacts-v1.c"     "$EXPECTED_COMPANYFACTS_PARSER_SHA256"     "COMPANYFACTS_PARSER_SOURCE_IDENTITY"

echo "A0_C1_PREFLIGHT=PASS"

section "5. ONE-EXECUTION CONTINUATION GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
A0_R1_LOCK_SHA256=$EXPECTED_A0R1_LOCK_SHA256
SELECTION_SHA256=$EXPECTED_SELECTION_SHA256
PARTIAL_CANONICAL_SHA256=$EXPECTED_PARTIAL_CANONICAL_SHA256
CANONICAL_PAYLOAD_SHA256=$EXPECTED_CANONICAL_PAYLOAD_SHA256
AUTHORIZED_SEC_REQUEST_COUNT=$AUTHORIZED_SEC_REQUEST_COUNT
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_A0_C1_WRITE=YES
LOCK_CREATED_BEFORE_FIRST_A0_C1_SEC_REQUEST=YES
EOF

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A0_C1_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A0_C1_EXECUTION_GATE=PASS"

mkdir -p "$RAW" "$SELECTION" "$CANONICAL" "$EVIDENCE" "$CONTRACTS" "$PARSERS"

section "6. MATERIALIZE FROZEN A0 AUTHORITY WITHOUT RESELECTION"

cp "$A0R1_SELECTION" "$SELECTION/selection.tsv"
cp "$A0R1_CANDIDATE_SCAN" "$EVIDENCE/candidate-scan.tsv"

cp "$A0R1_SELECTED_RAW/submissions-current.json" "$RAW/submissions-current.json"
cp "$A0R1_SELECTED_RAW/history-files.txt" "$RAW/history-files.txt"
cp "$A0R1_SELECTED_RAW/submissions-all-filings.tsv" "$RAW/submissions-all-filings.tsv"
cp "$A0R1_SELECTED_RAW/companyfacts.json" "$RAW/companyfacts.json"
cp "$A0R1_SELECTED_RAW/original-index.htm" "$RAW/original-index.htm"
cp "$A0R1_SELECTED_RAW/amendment-index.htm" "$RAW/amendment-index.htm"

if test -d "$A0R1_SELECTED_RAW/history"
then
    cp -R "$A0R1_SELECTED_RAW/history" "$RAW/history"
fi

if test -d "$A0R1_SELECTED_RAW/concept-checks"
then
    cp -R "$A0R1_SELECTED_RAW/concept-checks" "$RAW/concept-checks"
fi

cp "$A0R1/contracts/A0-DESIGN-AND-SELECTION-POLICY.md"     "$CONTRACTS/A0-DESIGN-AND-SELECTION-POLICY.md"

cp "$A0R1/contracts/evaluation-contract-v1.txt"     "$CONTRACTS/evaluation-contract-v1.txt"

cp "$A0R1/parsers/sec-submissions-v1.c"     "$PARSERS/sec-submissions-v1.c"

cp "$A0R1/parsers/sec-companyfacts-v1.c"     "$PARSERS/sec-companyfacts-v1.c"

tail -n +2 "$A0R1_CANONICAL" > "$CANONICAL/canonical-facts.tsv"

test "$(wc -l < "$CANONICAL/canonical-facts.tsv" | tr -d ' ')" = "3" ||
    not_evaluated "A0_C1_CANONICAL_SHAPE_FAILURE"

test "$(sha "$CANONICAL/canonical-facts.tsv")" = "$EXPECTED_CANONICAL_PAYLOAD_SHA256" ||
    not_evaluated "A0_C1_CANONICAL_IDENTITY_FAILURE"

echo "CANONICAL_PAYLOAD_DERIVATION=PASS"
echo "CANONICAL_FACTS_SHA256=$(sha "$CANONICAL/canonical-facts.tsv")"

section "7. FETCH ONLY TWO MISSING FROZEN SUBMISSIONS"

sec_fetch     "$SEC_ARCHIVE_BASE/$CIK/$ORIGINAL_COMPACT/$ORIGINAL_ACCN.txt"     "$RAW/original-submission.txt" ||
    not_evaluated "ORIGINAL_SUBMISSION_FETCH_FAILURE"

echo "ORIGINAL_SUBMISSION_FETCH=PASS"

sec_fetch     "$SEC_ARCHIVE_BASE/$CIK/$AMENDMENT_COMPACT/$AMENDMENT_ACCN.txt"     "$RAW/amendment-submission.txt" ||
    not_evaluated "AMENDMENT_SUBMISSION_FETCH_FAILURE"

echo "AMENDMENT_SUBMISSION_FETCH=PASS"

test "$SEC_REQUEST_COUNT" -eq "$AUTHORIZED_SEC_REQUEST_COUNT" ||
    not_evaluated "AUTHORIZED_SEC_REQUEST_COUNT_VIOLATION"

echo "AUTHORIZED_SEC_REQUEST_COUNT=$AUTHORIZED_SEC_REQUEST_COUNT"
echo "ACTUAL_SEC_REQUEST_COUNT=$SEC_REQUEST_COUNT"

grep -F "$ORIGINAL_ACCN" "$RAW/original-submission.txt" >/dev/null ||
    not_evaluated "ORIGINAL_SUBMISSION_IDENTITY_CONTENT_MISMATCH"

grep -E '^CONFORMED SUBMISSION TYPE:[[:space:]]*10-K[[:space:]]*$'     "$RAW/original-submission.txt" >/dev/null ||
    not_evaluated "ORIGINAL_SUBMISSION_FORM_MISMATCH"

grep -E '^CONFORMED PERIOD OF REPORT:[[:space:]]*'"$REPORT_DATE_COMPACT"'[[:space:]]*$'     "$RAW/original-submission.txt" >/dev/null ||
    not_evaluated "ORIGINAL_SUBMISSION_PERIOD_MISMATCH"

grep -F "$AMENDMENT_ACCN" "$RAW/amendment-submission.txt" >/dev/null ||
    not_evaluated "AMENDMENT_SUBMISSION_IDENTITY_CONTENT_MISMATCH"

grep -E '^CONFORMED SUBMISSION TYPE:[[:space:]]*10-K/A[[:space:]]*$'     "$RAW/amendment-submission.txt" >/dev/null ||
    not_evaluated "AMENDMENT_SUBMISSION_FORM_MISMATCH"

grep -E '^CONFORMED PERIOD OF REPORT:[[:space:]]*'"$REPORT_DATE_COMPACT"'[[:space:]]*$'     "$RAW/amendment-submission.txt" >/dev/null ||
    not_evaluated "AMENDMENT_SUBMISSION_PERIOD_MISMATCH"

echo "ORIGINAL_SUBMISSION_SHA256=$(sha "$RAW/original-submission.txt")"
echo "AMENDMENT_SUBMISSION_SHA256=$(sha "$RAW/amendment-submission.txt")"

section "8. VERIFY A0-R1 REMAINED IMMUTABLE"

test "$(sha "$A0R1_SELECTION")" = "$EXPECTED_SELECTION_SHA256" ||
    not_evaluated "A0_R1_MUTATION_DETECTED"

test "$(sha "$A0R1_CANONICAL")" = "$EXPECTED_PARTIAL_CANONICAL_SHA256" ||
    not_evaluated "A0_R1_MUTATION_DETECTED"

test "$(sha "$A0R1_CANDIDATE_SCAN")" = "$EXPECTED_CANDIDATE_SCAN_SHA256" ||
    not_evaluated "A0_R1_MUTATION_DETECTED"

test ! -e "$A0R1_SELECTED_RAW/original-submission.txt" ||
    not_evaluated "A0_R1_MUTATION_DETECTED"

test ! -e "$A0R1_SELECTED_RAW/amendment-submission.txt" ||
    not_evaluated "A0_R1_MUTATION_DETECTED"

echo "A0_R1_MUTATION=NO"

section "9. FREEZE A0-C1 EVIDENCE"

cp "$LOCK" "$EVIDENCE/execution-started.txt"
cp "$0" "$EVIDENCE/stage-a0-c1-script.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
A0_R1_STATUS	NOT_EVALUATED
A0_R1_FAILURE_CLASS	SELECTED_FACT_CANONICALIZATION_FAILURE
A0_R1_EXECUTION_LOCK_SHA256	$EXPECTED_A0R1_LOCK_SHA256
SELECTION_SHA256	$EXPECTED_SELECTION_SHA256
PARTIAL_CANONICAL_SHA256	$EXPECTED_PARTIAL_CANONICAL_SHA256
CANONICAL_FACTS_SHA256	$EXPECTED_CANONICAL_PAYLOAD_SHA256
SELECTED_CANDIDATE_ORDINAL	1
CIK	$CIK10
ISSUER	Amesite Inc.
ORIGINAL_ACCESSION	$ORIGINAL_ACCN
AMENDMENT_ACCESSION	$AMENDMENT_ACCN
REPORT_DATE	2024-06-30
CONCEPT	Assets
KIND	instant
UNIT	USD
AUTHORIZED_SEC_REQUEST_COUNT	$AUTHORIZED_SEC_REQUEST_COUNT
ACTUAL_SEC_REQUEST_COUNT	$SEC_REQUEST_COUNT
ORIGINAL_SUBMISSION_SHA256	$(sha "$RAW/original-submission.txt")
AMENDMENT_SUBMISSION_SHA256	$(sha "$RAW/amendment-submission.txt")
CANDIDATE_RESCAN	FORBIDDEN
RESELECTION	FORBIDDEN
PARSER_EXECUTED	NO
CLASSIFICATION_EXECUTED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

(
    cd "$STAGE"

    find raw selection canonical evidence contracts parsers         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS         > evidence/SHA256SUMS.check
) || not_evaluated "A0_C1_EVIDENCE_INTEGRITY_FAILURE"

A0_C1_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A0_C1_EVIDENCE_INTEGRITY=PASS"
echo "A0_C1_EVIDENCE_MANIFEST_SHA256=$A0_C1_MANIFEST_SHA256"

section "10. A0-C1 HOMOLOGATION"

echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A0_C1=PASS"
echo "A0_CONTINUATION=$REVISION"

echo "A0_R1_STATUS=NOT_EVALUATED"
echo "A0_R1_RERUN=NO"

echo "SELECTION_IDENTITY=PASS"
echo "CANONICAL_PAYLOAD_IDENTITY=PASS"
echo "ALL_EXISTING_SELECTED_RAW_IDENTITIES=PASS"
echo "FROZEN_MASTER_INDEX_IDENTITIES=PASS"

echo "CANDIDATE_RESCAN=FORBIDDEN"
echo "SELECTED_TUPLE_RESELECTION=FORBIDDEN"

echo "AUTHORIZED_SEC_REQUEST_COUNT=$AUTHORIZED_SEC_REQUEST_COUNT"
echo "ACTUAL_SEC_REQUEST_COUNT=$SEC_REQUEST_COUNT"

echo "ORIGINAL_SUBMISSION_FETCH=PASS"
echo "AMENDMENT_SUBMISSION_FETCH=PASS"

echo "PARSER_EXECUTED=NO"
echo "CLASSIFICATION_EXECUTED=NO"

echo "A0_C1_EVIDENCE_INTEGRITY=PASS"

echo "A0_AUTHORITY=PASS_BY_FROZEN_SELECTION_COMPLETION"

echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A1_DETERMINISTIC_EVALUATION_AUTHORITY"
