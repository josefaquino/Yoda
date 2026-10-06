#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
REVISION="A0-R1"
REFERENCE_YEAR="2025"

ROOT="$HOME/cmu/$CASE"
STAGE="$ROOT/stage-a0-r1"
PREFLIGHT="$ROOT/.stage-a0-r1-preflight"
WORK="$ROOT/.stage-a0-r1-work"
LOCK="$ROOT/.stage-a0-r1-execution-started"

RAW="$STAGE/raw"
MASTER="$RAW/master-index"
SELECTED_RAW="$RAW/selected"
SELECTION="$STAGE/selection"
CANONICAL="$STAGE/canonical"
EVIDENCE="$STAGE/evidence"
PARSERS="$STAGE/parsers"
CONTRACTS="$STAGE/contracts"

PRE_A0_SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-pre-a0-r1.sh"
PRE_A0_CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-pre-a0-r1-console.log"

EXPECTED_PRE_A0_SCRIPT_SHA256="ed430dcb7d71c73b0147eaa5d5e89e3424f6b5ec70486c1c6de55ddc04a2b33e"
EXPECTED_PRE_A0_CONSOLE_SHA256="0298fcbbbb776fa14cf29b296dfd963d4c837f77008b2281aa32ef09f2f1d53e"

AUTHORITY_COMMIT="cd6945c61928a565ef4914537839ee151d31181a"
RAW_GITHUB_BASE="https://raw.githubusercontent.com/josefaquino/Yoda/$AUTHORITY_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage"

EXPECTED_POLICY_SHA256="390a46190a204d8c6eb2e3b249b5b875370728e8770f7c1cfdb6410a59575aff"
EXPECTED_SUBMISSIONS_PARSER_SHA256="44efbbe85b4061fdee796a37ff2e291e9ad5697941f4ad2581093a321a7b0584"
EXPECTED_COMPANYFACTS_PARSER_SHA256="64bca9c530ed653970af3e5715bbea52f9bdf30f7a2bbaf4e703c8b75da50775"
EXPECTED_EVALUATION_CONTRACT_SHA256="ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd"

SEC_FULL_INDEX_BASE="https://www.sec.gov/Archives/edgar/full-index/$REFERENCE_YEAR"
SEC_SUBMISSIONS_BASE="https://data.sec.gov/submissions"
SEC_COMPANYFACTS_BASE="https://data.sec.gov/api/xbrl/companyfacts"
SEC_ARCHIVE_BASE="https://www.sec.gov/Archives/edgar/data"

REQUEST_SPACING_SECONDS="0.40"
REQUEST_COUNT=0

SUB_PARSER_SRC="$PREFLIGHT/sec-submissions-v1.c"
SUB_PARSER_BIN="$PREFLIGHT/sec-submissions-v1"

CF_PARSER_SRC="$PREFLIGHT/sec-companyfacts-v1.c"
CF_PARSER_BIN="$PREFLIGHT/sec-companyfacts-v1"

POLICY_FILE="$PREFLIGHT/A0-DESIGN-AND-SELECTION-POLICY.md"
EVAL_CONTRACT_FILE="$PREFLIGHT/evaluation-contract-v1.txt"

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
    echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A0=NOT_EVALUATED"
    echo "A0_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
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

sec_fetch()
{
    url="$1"
    body="$2"
    accept="$3"

    sleep "$REQUEST_SPACING_SECONDS"
    REQUEST_COUNT=$((REQUEST_COUNT + 1))

    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --compressed \
        --user-agent "$SEC_USER_AGENT" \
        --header "Accept: $accept" \
        --output "$body" \
        "$url"
}

github_fetch()
{
    url="$1"
    body="$2"

    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --output "$body" \
        "$url"
}

candidate_reject()
{
    ordinal="$1"
    filed="$2"
    cik="$3"
    accn="$4"
    reason="$5"

    printf '%s\t%s\t%s\t%s\tREJECTED\t%s\n' \
        "$ordinal" "$filed" "$cik" "$accn" "$reason" \
        >> "$EVIDENCE/candidate-scan.tsv"
}

test ! -e "$LOCK" ||
    not_evaluated "A0_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "A0_STAGE_ALREADY_EXISTS"

rm -rf "$PREFLIGHT" "$WORK"
mkdir -p "$PREFLIGHT" "$WORK"

section "0. PRE-A0 AUTHORITY + LOCAL TOOLCHAIN"

for pair in \
    "curl:CURL" \
    "cc:CC" \
    "awk:AWK" \
    "grep:GREP" \
    "sed:SED" \
    "sha256sum:SHA256SUM" \
    "wc:WC" \
    "tr:TR" \
    "sort:SORT" \
    "cut:CUT" \
    "head:HEAD" \
    "tail:TAIL" \
    "find:FIND" \
    "xargs:XARGS" \
    "sleep:SLEEP" \
    "cp:CP" \
    "mkdir:MKDIR" \
    "rm:RM"
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

test -f "$PRE_A0_SCRIPT" ||
    not_evaluated "PRE_A0_AUTHORITY_MISSING"

test -f "$PRE_A0_CONSOLE" ||
    not_evaluated "PRE_A0_AUTHORITY_MISSING"

test "$(sha "$PRE_A0_SCRIPT")" = "$EXPECTED_PRE_A0_SCRIPT_SHA256" ||
    not_evaluated "PRE_A0_AUTHORITY_IDENTITY_MISMATCH"

test "$(sha "$PRE_A0_CONSOLE")" = "$EXPECTED_PRE_A0_CONSOLE_SHA256" ||
    not_evaluated "PRE_A0_AUTHORITY_IDENTITY_MISMATCH"

grep -F "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_PRE_A0=PASS" \
    "$PRE_A0_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_AUTHORITY_NOT_PASS"

grep -F "A0_GATE_CONSUMED=NO" \
    "$PRE_A0_CONSOLE" >/dev/null ||
    not_evaluated "PRE_A0_AUTHORITY_MISMATCH"

echo "PRE_A0_AUTHORITY=PASS"
echo "SEC_USER_AGENT_PRINTED=NO"
echo "REQUEST_SPACING_SECONDS=$REQUEST_SPACING_SECONDS"

section "1. FETCH + VERIFY FROZEN A0 DESIGN AUTHORITIES"

github_fetch \
    "$RAW_GITHUB_BASE/A0-DESIGN-AND-SELECTION-POLICY.md" \
    "$POLICY_FILE" ||
    not_evaluated "A0_AUTHORITY_FETCH_FAILURE"

github_fetch \
    "$RAW_GITHUB_BASE/parsers/sec-submissions-v1.c" \
    "$SUB_PARSER_SRC" ||
    not_evaluated "A0_AUTHORITY_FETCH_FAILURE"

github_fetch \
    "$RAW_GITHUB_BASE/parsers/sec-companyfacts-v1.c" \
    "$CF_PARSER_SRC" ||
    not_evaluated "A0_AUTHORITY_FETCH_FAILURE"

github_fetch \
    "$RAW_GITHUB_BASE/contracts/evaluation-contract-v1.txt" \
    "$EVAL_CONTRACT_FILE" ||
    not_evaluated "A0_AUTHORITY_FETCH_FAILURE"

test "$(sha "$POLICY_FILE")" = "$EXPECTED_POLICY_SHA256" ||
    not_evaluated "A0_POLICY_IDENTITY_MISMATCH"

test "$(sha "$SUB_PARSER_SRC")" = "$EXPECTED_SUBMISSIONS_PARSER_SHA256" ||
    not_evaluated "SUBMISSIONS_PARSER_IDENTITY_MISMATCH"

test "$(sha "$CF_PARSER_SRC")" = "$EXPECTED_COMPANYFACTS_PARSER_SHA256" ||
    not_evaluated "COMPANYFACTS_PARSER_IDENTITY_MISMATCH"

test "$(sha "$EVAL_CONTRACT_FILE")" = "$EXPECTED_EVALUATION_CONTRACT_SHA256" ||
    not_evaluated "EVALUATION_CONTRACT_IDENTITY_MISMATCH"

echo "A0_SELECTION_POLICY=FROZEN"
echo "A0_SELECTION_POLICY_SHA256=$EXPECTED_POLICY_SHA256"
echo "SUBMISSIONS_PARSER_SOURCE=FROZEN"
echo "SUBMISSIONS_PARSER_SHA256=$EXPECTED_SUBMISSIONS_PARSER_SHA256"
echo "COMPANYFACTS_PARSER_SOURCE=FROZEN"
echo "COMPANYFACTS_PARSER_SHA256=$EXPECTED_COMPANYFACTS_PARSER_SHA256"
echo "EVALUATION_CONTRACT=FROZEN"
echo "EVALUATION_CONTRACT_SHA256=$EXPECTED_EVALUATION_CONTRACT_SHA256"

section "2. COMPILE PARSERS BEFORE SCIENTIFIC GATE"

cc \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    "$SUB_PARSER_SRC" \
    -o "$SUB_PARSER_BIN" ||
    not_evaluated "SUBMISSIONS_PARSER_COMPILE_FAILURE"

cc \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    "$CF_PARSER_SRC" \
    -o "$CF_PARSER_BIN" ||
    not_evaluated "COMPANYFACTS_PARSER_COMPILE_FAILURE"

echo "SUBMISSIONS_PARSER_COMPILE=PASS"
echo "SUBMISSIONS_PARSER_BINARY_SHA256=$(sha "$SUB_PARSER_BIN")"
echo "COMPANYFACTS_PARSER_COMPILE=PASS"
echo "COMPANYFACTS_PARSER_BINARY_SHA256=$(sha "$CF_PARSER_BIN")"

section "3. SYNTHETIC PARSER SELF-TEST BEFORE SCIENTIFIC GATE"

cat > "$PREFLIGHT/submissions-synthetic.json" <<'JSON'
{"filings":{"recent":{"accessionNumber":["0000000001-25-000001","0000000001-25-000002"],"filingDate":["2025-01-10","2025-02-10"],"reportDate":["2024-12-31","2024-12-31"],"form":["10-K","10-K/A"]},"files":[{"name":"CIK0000000001-submissions-001.json"}]}}
JSON

"$SUB_PARSER_BIN" rows "$PREFLIGHT/submissions-synthetic.json" \
    > "$PREFLIGHT/submissions-synthetic.tsv" ||
    not_evaluated "SUBMISSIONS_PARSER_SELF_TEST_FAILURE"

"$SUB_PARSER_BIN" history-files "$PREFLIGHT/submissions-synthetic.json" \
    > "$PREFLIGHT/history-synthetic.txt" ||
    not_evaluated "SUBMISSIONS_PARSER_SELF_TEST_FAILURE"

grep -F "$(printf '0000000001-25-000001\t2025-01-10\t2024-12-31\t10-K')" \
    "$PREFLIGHT/submissions-synthetic.tsv" >/dev/null ||
    not_evaluated "SUBMISSIONS_PARSER_SELF_TEST_FAILURE"

grep -F "$(printf '0000000001-25-000002\t2025-02-10\t2024-12-31\t10-K/A')" \
    "$PREFLIGHT/submissions-synthetic.tsv" >/dev/null ||
    not_evaluated "SUBMISSIONS_PARSER_SELF_TEST_FAILURE"

grep -Fx "CIK0000000001-submissions-001.json" \
    "$PREFLIGHT/history-synthetic.txt" >/dev/null ||
    not_evaluated "SUBMISSIONS_PARSER_SELF_TEST_FAILURE"

cat > "$PREFLIGHT/companyfacts-synthetic.json" <<'JSON'
{"facts":{"us-gaap":{"Assets":{"units":{"USD":[{"end":"2024-12-31","val":987654321,"accn":"0000000001-25-000001","form":"10-K"},{"end":"2024-12-31","val":123456789,"accn":"0000000001-25-000002","form":"10-K/A"}]}},"Revenues":{"units":{"USD":[{"start":"2024-01-01","end":"2024-12-31","val":777777777,"accn":"0000000001-25-000001","form":"10-K"},{"start":"2024-01-01","end":"2024-12-31","val":888888888,"accn":"0000000001-25-000002","form":"10-K/A"}]}}}}}
JSON

"$CF_PARSER_BIN" \
    check \
    "$PREFLIGHT/companyfacts-synthetic.json" \
    Assets \
    instant \
    2024-12-31 \
    0000000001-25-000001 \
    0000000001-25-000002 \
    > "$PREFLIGHT/companyfacts-check-instant.txt" ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

grep -F "PARSER_STATUS=PASS" \
    "$PREFLIGHT/companyfacts-check-instant.txt" >/dev/null ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

grep -F "ELIGIBLE=YES" \
    "$PREFLIGHT/companyfacts-check-instant.txt" >/dev/null ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

if grep -E '987654321|123456789' \
    "$PREFLIGHT/companyfacts-check-instant.txt" >/dev/null
then
    not_evaluated "COMPANYFACTS_SELECTION_VALUE_LEAK"
fi

"$CF_PARSER_BIN" \
    check \
    "$PREFLIGHT/companyfacts-synthetic.json" \
    Revenues \
    duration \
    2024-12-31 \
    0000000001-25-000001 \
    0000000001-25-000002 \
    > "$PREFLIGHT/companyfacts-check-duration.txt" ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

grep -F "ELIGIBLE=YES" \
    "$PREFLIGHT/companyfacts-check-duration.txt" >/dev/null ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

if grep -E '777777777|888888888' \
    "$PREFLIGHT/companyfacts-check-duration.txt" >/dev/null
then
    not_evaluated "COMPANYFACTS_SELECTION_VALUE_LEAK"
fi

"$CF_PARSER_BIN" \
    reveal \
    "$PREFLIGHT/companyfacts-synthetic.json" \
    Assets \
    instant \
    2024-12-31 \
    0000000001-25-000001 \
    0000000001-25-000002 \
    > "$PREFLIGHT/companyfacts-reveal-synthetic.tsv" ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

grep -F "987654321" "$PREFLIGHT/companyfacts-reveal-synthetic.tsv" >/dev/null ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

grep -F "123456789" "$PREFLIGHT/companyfacts-reveal-synthetic.tsv" >/dev/null ||
    not_evaluated "COMPANYFACTS_PARSER_SELF_TEST_FAILURE"

echo "SUBMISSIONS_PARSER_SELF_TEST=PASS"
echo "COMPANYFACTS_PARSER_SELF_TEST=PASS"
echo "SELECTION_VALUE_LEAK_TEST=PASS"
echo "A0_PREFLIGHT=PASS"

if test "${A0_PREFLIGHT_ONLY:-NO}" = "YES"
then
    echo "A0_PREFLIGHT_ONLY=PASS"
    echo "SCIENTIFIC_EXECUTION_STARTED=NO"
    echo "A0_EXECUTION_LOCK_CONSUMED=NO"
    echo "SEC_A0_REQUESTS=ZERO"
    echo "YODA_WRITES=ZERO"
    rm -rf "$PREFLIGHT" "$WORK"
    exit 0
fi

section "4. ONE-EXECUTION SCIENTIFIC GATE"

mkdir -p "$STAGE" "$MASTER" "$SELECTED_RAW" "$SELECTION" "$CANONICAL" "$EVIDENCE" "$PARSERS" "$CONTRACTS"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
REFERENCE_YEAR=$REFERENCE_YEAR
PRE_A0_SCRIPT_SHA256=$EXPECTED_PRE_A0_SCRIPT_SHA256
PRE_A0_CONSOLE_SHA256=$EXPECTED_PRE_A0_CONSOLE_SHA256
A0_SELECTION_POLICY_SHA256=$EXPECTED_POLICY_SHA256
SUBMISSIONS_PARSER_SHA256=$EXPECTED_SUBMISSIONS_PARSER_SHA256
COMPANYFACTS_PARSER_SHA256=$EXPECTED_COMPANYFACTS_PARSER_SHA256
EVALUATION_CONTRACT_SHA256=$EXPECTED_EVALUATION_CONTRACT_SHA256
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_SEC_A0_FETCH=YES
EOF

cp "$LOCK" "$EVIDENCE/execution-started.txt"
cp "$POLICY_FILE" "$CONTRACTS/A0-DESIGN-AND-SELECTION-POLICY.md"
cp "$EVAL_CONTRACT_FILE" "$CONTRACTS/evaluation-contract-v1.txt"
cp "$SUB_PARSER_SRC" "$PARSERS/sec-submissions-v1.c"
cp "$SUB_PARSER_BIN" "$PARSERS/sec-submissions-v1"
cp "$CF_PARSER_SRC" "$PARSERS/sec-companyfacts-v1.c"
cp "$CF_PARSER_BIN" "$PARSERS/sec-companyfacts-v1"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "EXECUTION_GATE=PASS"

section "5. FREEZE 2025 EDGAR MASTER INDEX UNIVERSE"

for q in 1 2 3 4
do
    file="$MASTER/QTR$q-master.idx"

    sec_fetch \
        "$SEC_FULL_INDEX_BASE/QTR$q/master.idx" \
        "$file" \
        "text/plain,*/*;q=0.8" ||
        not_evaluated "SEC_MASTER_INDEX_FETCH_FAILURE"

    grep -F "CIK|Company Name|Form Type|Date Filed|Filename" \
        "$file" >/dev/null ||
        not_evaluated "SEC_MASTER_INDEX_SHAPE_FAILURE"

    echo "QTR"$q"_MASTER_INDEX_SHA256=$(sha "$file")"
    echo "QTR"$q"_MASTER_INDEX_BYTES=$(wc -c < "$file" | tr -d ' ')"
done

{
    for q in 1 2 3 4
    do
        awk -F '|' '
            $3 == "10-K/A" {
                printf "%s\t%s\t%s\t%s\n", $4, $1, $5, $2
            }
        ' "$MASTER/QTR$q-master.idx"
    done
} |
LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2n -k3,3 \
    > "$SELECTION/candidates.tsv"

CANDIDATE_COUNT="$(wc -l < "$SELECTION/candidates.tsv" | tr -d ' ')"

echo "REFERENCE_YEAR=$REFERENCE_YEAR"
echo "CANDIDATE_FORM=10-K/A"
echo "CANDIDATE_COUNT=$CANDIDATE_COUNT"

test "$CANDIDATE_COUNT" -gt 0 ||
    not_evaluated "NO_10_K_A_CANDIDATES_IN_FROZEN_UNIVERSE"

printf 'ordinal\tamendment_filing_date\tcik\tamendment_accession\tstatus\treason\n' \
    > "$EVIDENCE/candidate-scan.tsv"

section "6. DETERMINISTIC WORKLOAD SELECTION"

SELECTED="NO"
ORDINAL=0

while IFS="$(printf '\t')" read -r AMEND_MASTER_DATE CIK FILING_PATH COMPANY_NAME
do
    ORDINAL=$((ORDINAL + 1))

    AMEND_FILE="${FILING_PATH##*/}"
    AMEND_ACCN="${AMEND_FILE%.txt}"
    CIK10="$(printf '%010d' "$CIK")"

    CAND="$WORK/candidate-$ORDINAL"
    mkdir -p "$CAND/history" "$CAND/concept-checks"

    sec_fetch \
        "$SEC_SUBMISSIONS_BASE/CIK$CIK10.json" \
        "$CAND/submissions-current.json" \
        "application/json" ||
        not_evaluated "SEC_SUBMISSIONS_FETCH_FAILURE"

    "$SUB_PARSER_BIN" rows "$CAND/submissions-current.json" \
        > "$CAND/current-rows.tsv" ||
        not_evaluated "SUBMISSIONS_PARSER_RUNTIME_FAILURE"

    "$SUB_PARSER_BIN" history-files "$CAND/submissions-current.json" \
        > "$CAND/history-files.txt" ||
        not_evaluated "SUBMISSIONS_PARSER_RUNTIME_FAILURE"

    cp "$CAND/current-rows.tsv" "$CAND/all-rows-unsorted.tsv"

    if test -s "$CAND/history-files.txt"
    then
        while IFS= read -r HISTORY_FILE
        do
            test -n "$HISTORY_FILE" || continue

            sec_fetch \
                "$SEC_SUBMISSIONS_BASE/$HISTORY_FILE" \
                "$CAND/history/$HISTORY_FILE" \
                "application/json" ||
                not_evaluated "SEC_SUBMISSIONS_HISTORY_FETCH_FAILURE"

            "$SUB_PARSER_BIN" rows "$CAND/history/$HISTORY_FILE" \
                > "$CAND/history/$HISTORY_FILE.tsv" ||
                not_evaluated "SUBMISSIONS_PARSER_RUNTIME_FAILURE"

            awk 'NR > 1' "$CAND/history/$HISTORY_FILE.tsv" \
                >> "$CAND/all-rows-unsorted.tsv"
        done < "$CAND/history-files.txt"
    fi

    {
        sed -n '1p' "$CAND/all-rows-unsorted.tsv"
        sed '1d' "$CAND/all-rows-unsorted.tsv" | LC_ALL=C sort -u
    } > "$CAND/all-filings.tsv"

    AMEND_META="$(
        awk -F '\t' -v acc="$AMEND_ACCN" '
            NR > 1 && $1 == acc && $4 == "10-K/A" {
                n++
                filed=$2
                report=$3
            }
            END {
                if (n == 1 && report != "")
                    printf "%s\t%s\n", filed, report
            }
        ' "$CAND/all-filings.tsv"
    )"

    if test -z "$AMEND_META"
    then
        candidate_reject "$ORDINAL" "$AMEND_MASTER_DATE" "$CIK" "$AMEND_ACCN" \
            "AMENDMENT_METADATA_NOT_UNIQUE_OR_REPORT_DATE_MISSING"
        rm -rf "$CAND"
        continue
    fi

    AMEND_FILED="$(printf '%s\n' "$AMEND_META" | cut -f1)"
    REPORT_DATE="$(printf '%s\n' "$AMEND_META" | cut -f2)"

    ORIGINAL_META="$(
        awk -F '\t' \
            -v report="$REPORT_DATE" \
            -v amend_filed="$AMEND_FILED" '
            NR > 1 &&
            $4 == "10-K" &&
            $3 == report &&
            $2 < amend_filed {
                if (best_filed == "" ||
                    $2 > best_filed ||
                    ($2 == best_filed && $1 < best_acc)) {
                    best_acc=$1
                    best_filed=$2
                }
            }
            END {
                if (best_acc != "")
                    printf "%s\t%s\n", best_acc, best_filed
            }
        ' "$CAND/all-filings.tsv"
    )"

    if test -z "$ORIGINAL_META"
    then
        candidate_reject "$ORDINAL" "$AMEND_MASTER_DATE" "$CIK" "$AMEND_ACCN" \
            "NO_PRIOR_10_K_WITH_SAME_REPORT_DATE"
        rm -rf "$CAND"
        continue
    fi

    ORIGINAL_ACCN="$(printf '%s\n' "$ORIGINAL_META" | cut -f1)"
    ORIGINAL_FILED="$(printf '%s\n' "$ORIGINAL_META" | cut -f2)"

    ORIGINAL_COMPACT="$(printf '%s' "$ORIGINAL_ACCN" | tr -d '-')"
    AMEND_COMPACT="$(printf '%s' "$AMEND_ACCN" | tr -d '-')"

    sec_fetch \
        "$SEC_ARCHIVE_BASE/$CIK/$ORIGINAL_COMPACT/$ORIGINAL_ACCN-index.htm" \
        "$CAND/original-index.htm" \
        "text/html,*/*;q=0.8" ||
        not_evaluated "SEC_FILING_ARCHIVE_FETCH_FAILURE"

    sec_fetch \
        "$SEC_ARCHIVE_BASE/$CIK/$AMEND_COMPACT/$AMEND_ACCN-index.htm" \
        "$CAND/amendment-index.htm" \
        "text/html,*/*;q=0.8" ||
        not_evaluated "SEC_FILING_ARCHIVE_FETCH_FAILURE"

    if ! grep -Eiq 'XBRL|Interactive Data' "$CAND/original-index.htm"
    then
        candidate_reject "$ORDINAL" "$AMEND_MASTER_DATE" "$CIK" "$AMEND_ACCN" \
            "ORIGINAL_XBRL_ARCHIVE_EVIDENCE_NOT_FOUND"
        rm -rf "$CAND"
        continue
    fi

    if ! grep -Eiq 'XBRL|Interactive Data' "$CAND/amendment-index.htm"
    then
        candidate_reject "$ORDINAL" "$AMEND_MASTER_DATE" "$CIK" "$AMEND_ACCN" \
            "AMENDMENT_XBRL_ARCHIVE_EVIDENCE_NOT_FOUND"
        rm -rf "$CAND"
        continue
    fi

    sec_fetch \
        "$SEC_COMPANYFACTS_BASE/CIK$CIK10.json" \
        "$CAND/companyfacts.json" \
        "application/json" ||
        not_evaluated "SEC_COMPANYFACTS_FETCH_FAILURE"

    grep -F '"facts"' "$CAND/companyfacts.json" >/dev/null ||
        not_evaluated "SEC_COMPANYFACTS_RESPONSE_SHAPE"

    SELECTED_CONCEPT=""
    SELECTED_KIND=""
    SELECTED_CONTEXT_START=""
    SELECTED_CONTEXT_END=""

    for spec in \
        "Assets:instant" \
        "CashAndCashEquivalentsAtCarryingValue:instant" \
        "Revenues:duration" \
        "NetIncomeLoss:duration" \
        "StockholdersEquity:instant"
    do
        CONCEPT="$(printf '%s\n' "$spec" | cut -d: -f1)"
        KIND="$(printf '%s\n' "$spec" | cut -d: -f2)"
        CHECK_FILE="$CAND/concept-checks/$CONCEPT.txt"

        "$CF_PARSER_BIN" \
            check \
            "$CAND/companyfacts.json" \
            "$CONCEPT" \
            "$KIND" \
            "$REPORT_DATE" \
            "$ORIGINAL_ACCN" \
            "$AMEND_ACCN" \
            > "$CHECK_FILE" ||
            not_evaluated "COMPANYFACTS_PARSER_RUNTIME_FAILURE"

        grep -F "PARSER_STATUS=PASS" "$CHECK_FILE" >/dev/null ||
            not_evaluated "COMPANYFACTS_PARSER_RUNTIME_FAILURE"

        if grep -F "ELIGIBLE=YES" "$CHECK_FILE" >/dev/null
        then
            SELECTED_CONCEPT="$CONCEPT"
            SELECTED_KIND="$KIND"
            SELECTED_CONTEXT_START="$(
                awk -F= '$1 == "CONTEXT_START" { print $2 }' "$CHECK_FILE"
            )"
            SELECTED_CONTEXT_END="$(
                awk -F= '$1 == "CONTEXT_END" { print $2 }' "$CHECK_FILE"
            )"
            break
        fi
    done

    if test -z "$SELECTED_CONCEPT"
    then
        candidate_reject "$ORDINAL" "$AMEND_MASTER_DATE" "$CIK" "$AMEND_ACCN" \
            "NO_PRIORITY_CONCEPT_SATISFIES_FROZEN_CONTEXT_CONTRACT"
        rm -rf "$CAND"
        continue
    fi

    printf 'ordinal\tcik\tissuer\toriginal_filing_date\tamendment_filing_date\treport_date\toriginal_accession\tamendment_accession\tconcept\tkind\tunit\tcontext_start\tcontext_end\n' \
        > "$SELECTION/selection.tsv"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\tUSD\t%s\t%s\n' \
        "$ORDINAL" \
        "$CIK10" \
        "$COMPANY_NAME" \
        "$ORIGINAL_FILED" \
        "$AMEND_FILED" \
        "$REPORT_DATE" \
        "$ORIGINAL_ACCN" \
        "$AMEND_ACCN" \
        "$SELECTED_CONCEPT" \
        "$SELECTED_KIND" \
        "$SELECTED_CONTEXT_START" \
        "$SELECTED_CONTEXT_END" \
        >> "$SELECTION/selection.tsv"

    printf '%s\t%s\t%s\t%s\tSELECTED\tFIRST_AUTHORITY_COMPATIBLE_TUPLE\n' \
        "$ORDINAL" "$AMEND_MASTER_DATE" "$CIK" "$AMEND_ACCN" \
        >> "$EVIDENCE/candidate-scan.tsv"

    echo "SELECTION_GATE=FROZEN"
    echo "SELECTED_CANDIDATE_ORDINAL=$ORDINAL"
    echo "SELECTION_SHA256=$(sha "$SELECTION/selection.tsv")"

    cp "$CAND/submissions-current.json" "$SELECTED_RAW/submissions-current.json"
    cp "$CAND/history-files.txt" "$SELECTED_RAW/history-files.txt"
    cp "$CAND/all-filings.tsv" "$SELECTED_RAW/submissions-all-filings.tsv"
    cp "$CAND/companyfacts.json" "$SELECTED_RAW/companyfacts.json"
    cp "$CAND/original-index.htm" "$SELECTED_RAW/original-index.htm"
    cp "$CAND/amendment-index.htm" "$SELECTED_RAW/amendment-index.htm"
    cp -R "$CAND/history" "$SELECTED_RAW/history"
    cp -R "$CAND/concept-checks" "$SELECTED_RAW/concept-checks"

    "$CF_PARSER_BIN" \
        reveal \
        "$CAND/companyfacts.json" \
        "$SELECTED_CONCEPT" \
        "$SELECTED_KIND" \
        "$REPORT_DATE" \
        "$ORIGINAL_ACCN" \
        "$AMEND_ACCN" \
        > "$CANONICAL/canonical-facts.tsv" ||
        not_evaluated "SELECTED_FACT_REVEAL_FAILURE"

    test "$(wc -l < "$CANONICAL/canonical-facts.tsv" | tr -d ' ')" = "3" ||
        not_evaluated "SELECTED_FACT_CANONICALIZATION_FAILURE"

    sec_fetch \
        "$SEC_ARCHIVE_BASE/$CIK/$ORIGINAL_COMPACT/$ORIGINAL_ACCN.txt" \
        "$SELECTED_RAW/original-submission.txt" \
        "text/plain,*/*;q=0.8" ||
        not_evaluated "SELECTED_ORIGINAL_SUBMISSION_FETCH_FAILURE"

    sec_fetch \
        "$SEC_ARCHIVE_BASE/$CIK/$AMEND_COMPACT/$AMEND_ACCN.txt" \
        "$SELECTED_RAW/amendment-submission.txt" \
        "text/plain,*/*;q=0.8" ||
        not_evaluated "SELECTED_AMENDMENT_SUBMISSION_FETCH_FAILURE"

    SELECTED="YES"
    rm -rf "$CAND"
    break
done < "$SELECTION/candidates.tsv"

test "$SELECTED" = "YES" ||
    not_evaluated "NO_AUTHORITY_COMPATIBLE_WORKLOAD_IN_FROZEN_UNIVERSE"

section "7. SELECTED AUTHORITY FREEZE"

echo "ISSUER_SELECTION_POLICY=FROZEN"
echo "CIK=FROZEN"
echo "ORIGINAL_ACCESSION=FROZEN"
echo "SECOND_ACCESSION=FROZEN"
echo "XBRL_CONCEPT=FROZEN"
echo "FACT_CONTEXT_CONTRACT=FROZEN"

echo "SELECTION_USES_FACT_VALUES=NO"
echo "SELECTION_USES_EVALUATION_RESULT=NO"
echo "PRE_A0_PROBE_USED_AS_CASE_SELECTION=NO"

echo "SELECTION_SHA256=$(sha "$SELECTION/selection.tsv")"
echo "CANONICAL_FACTS_SHA256=$(sha "$CANONICAL/canonical-facts.tsv")"

cat "$SELECTION/selection.tsv"
cat "$CANONICAL/canonical-facts.tsv"

section "8. RAW RESPONSE + CANONICAL FACT INTEGRITY"

test -s "$SELECTED_RAW/original-submission.txt" ||
    not_evaluated "SELECTED_RAW_RESPONSE_EMPTY"

test -s "$SELECTED_RAW/amendment-submission.txt" ||
    not_evaluated "SELECTED_RAW_RESPONSE_EMPTY"

test -s "$SELECTED_RAW/companyfacts.json" ||
    not_evaluated "SELECTED_RAW_RESPONSE_EMPTY"

test -s "$SELECTED_RAW/original-index.htm" ||
    not_evaluated "SELECTED_RAW_RESPONSE_EMPTY"

test -s "$SELECTED_RAW/amendment-index.htm" ||
    not_evaluated "SELECTED_RAW_RESPONSE_EMPTY"

echo "RAW_RESPONSES_FROZEN=PASS"
echo "CANONICAL_FACTS_FROZEN=PASS"
echo "SELECTED_ORIGINAL_SUBMISSION_SHA256=$(sha "$SELECTED_RAW/original-submission.txt")"
echo "SELECTED_AMENDMENT_SUBMISSION_SHA256=$(sha "$SELECTED_RAW/amendment-submission.txt")"
echo "SELECTED_COMPANYFACTS_SHA256=$(sha "$SELECTED_RAW/companyfacts.json")"
echo "SELECTED_ORIGINAL_INDEX_SHA256=$(sha "$SELECTED_RAW/original-index.htm")"
echo "SELECTED_AMENDMENT_INDEX_SHA256=$(sha "$SELECTED_RAW/amendment-index.htm")"

section "9. FREEZE A0 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
REFERENCE_YEAR	$REFERENCE_YEAR
PRE_A0_SCRIPT_SHA256	$EXPECTED_PRE_A0_SCRIPT_SHA256
PRE_A0_CONSOLE_SHA256	$EXPECTED_PRE_A0_CONSOLE_SHA256
A0_SELECTION_POLICY_SHA256	$EXPECTED_POLICY_SHA256
SUBMISSIONS_PARSER_SHA256	$EXPECTED_SUBMISSIONS_PARSER_SHA256
COMPANYFACTS_PARSER_SHA256	$EXPECTED_COMPANYFACTS_PARSER_SHA256
EVALUATION_CONTRACT_SHA256	$EXPECTED_EVALUATION_CONTRACT_SHA256
CANDIDATE_COUNT	$CANDIDATE_COUNT
SELECTED_CANDIDATE_ORDINAL	$ORDINAL
SELECTION_SHA256	$(sha "$SELECTION/selection.tsv")
CANONICAL_FACTS_SHA256	$(sha "$CANONICAL/canonical-facts.tsv")
REQUEST_COUNT	$REQUEST_COUNT
ISSUER_SELECTION_POLICY	FROZEN
CIK	FROZEN
ORIGINAL_ACCESSION	FROZEN
SECOND_ACCESSION	FROZEN
XBRL_CONCEPT	FROZEN
FACT_CONTEXT_CONTRACT	FROZEN
RAW_RESPONSES_FROZEN	PASS
CANONICAL_FACTS_FROZEN	PASS
SELECTION_USES_FACT_VALUES	NO
SELECTION_USES_EVALUATION_RESULT	NO
CLASSIFICATION_EXECUTED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-a0-r1-script.sh"
cp "$LOCK" "$EVIDENCE/execution-started.txt"

(
    cd "$STAGE"

    find raw selection canonical evidence parsers contracts \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

A0_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "A0_EVIDENCE_MANIFEST_SHA256=$A0_MANIFEST_SHA256"

section "10. A0 HOMOLOGATION"

echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A0=PASS"
echo "A0_REVISION=$REVISION"

echo "REFERENCE_YEAR=$REFERENCE_YEAR"
echo "CANDIDATE_COUNT=$CANDIDATE_COUNT"
echo "SELECTED_CANDIDATE_ORDINAL=$ORDINAL"

echo "ISSUER_SELECTION_POLICY=FROZEN"
echo "CIK=FROZEN"
echo "ORIGINAL_ACCESSION=FROZEN"
echo "SECOND_ACCESSION=FROZEN"
echo "XBRL_CONCEPT=FROZEN"
echo "FACT_CONTEXT_CONTRACT=FROZEN"

echo "RAW_RESPONSES_FROZEN=PASS"
echo "CANONICAL_FACTS_FROZEN=PASS"
echo "A0_EVIDENCE_INTEGRITY=PASS"

echo "SELECTION_USES_FACT_VALUES=NO"
echo "SELECTION_USES_EVALUATION_RESULT=NO"

echo "CLASSIFICATION_EXECUTED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A1_DETERMINISTIC_EVALUATION_AUTHORITY"

rm -rf "$WORK" "$PREFLIGHT"
