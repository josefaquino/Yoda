#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
REVISION="A1-R1"

ROOT="$HOME/cmu/$CASE"

A0="$ROOT/stage-a0-c1"
A0_LOCK="$ROOT/.stage-a0-c1-execution-started"

STAGE="$ROOT/stage-a1-r1"
LOCK="$ROOT/.stage-a1-r1-execution-started"
PREFLIGHT_WORK="$ROOT/.stage-a1-r1-scientific-preflight"

INPUT="$STAGE/input"
AUTH="$STAGE/authorities"
RESULTS="$STAGE/results"
EVIDENCE="$STAGE/evidence"
CONTRACTS="$STAGE/contracts"

PREFLIGHT_CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a1-r1-preflight-console.log"

EXPECTED_PREFLIGHT_CONSOLE_SHA256="a584144d3a6555ba62cf01d3ab27df98ad1c806ea1fa1692f7f245e5e3c4f544"
EXPECTED_A0_LOCK_SHA256="7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2"
EXPECTED_A0_MANIFEST_SHA256="40499e4c4545974f3ed106d72cc5da356bdbadc8a4478f0a152e6d4f454c84cb"
EXPECTED_CANONICAL_FACTS_SHA256="0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d"
EXPECTED_CONTRACT_SHA256="ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd"

AUTHORITY_COMMIT="f5145ca95e31f9a2cc3b7c9ef127d3a25b140c93"
RAW_GITHUB_BASE="https://raw.githubusercontent.com/josefaquino/Yoda/$AUTHORITY_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage"

EXPECTED_C11_SOURCE_SHA256="9f41bda1c4e5a082cb739362f36030be047e00edef727518e7f74c161098fad0"
EXPECTED_AWK_SOURCE_SHA256="8b88216d22e6435319c73ec91dd3968cb453539c1a9effa1460bd9930fe0da91"
EXPECTED_PREFLIGHT_BINARY_SHA256="cda6c18ee6ecfadca2feabda93debfd5b61a680d0dc0de9d3030f6516acf179b"

A0_CANONICAL="$A0/canonical/canonical-facts.tsv"
A0_CONTRACT="$A0/contracts/evaluation-contract-v1.txt"

C11_SRC="$PREFLIGHT_WORK/authority-1-c11-v1.c"
C11_BIN="$PREFLIGHT_WORK/authority-1-c11-v1"
AWK_SRC="$PREFLIGHT_WORK/authority-2-posix-v1.awk"

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
    echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A1=NOT_EVALUATED"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "SCIENTIFIC_EXECUTION_STARTED=NO"
    echo "A1_EXECUTION_LOCK_CONSUMED=NO"
    echo "SEC_FETCHES=ZERO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

scientific_fail()
{
    echo
    echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A1=FAIL"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A1_R1_RERUN=NO"
    echo "SEC_FETCHES=ZERO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        not_evaluated "LOCAL_TOOLCHAIN_MISSING_$2"

    echo "$2=PASS"
}

github_fetch()
{
    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --output "$2" \
        "$1"
}

test ! -e "$LOCK" ||
    not_evaluated "A1_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$STAGE" ||
    not_evaluated "A1_STAGE_ALREADY_EXISTS"

rm -rf "$PREFLIGHT_WORK"
mkdir -p "$PREFLIGHT_WORK"

section "0. LOCAL TOOLCHAIN"

require_cmd curl CURL
require_cmd cc CC
require_cmd awk AWK
require_cmd cmp CMP
require_cmd grep GREP
require_cmd sha256sum SHA256SUM
require_cmd wc WC
require_cmd find FIND
require_cmd sort SORT
require_cmd xargs XARGS
require_cmd cp CP
require_cmd mkdir MKDIR
require_cmd rm RM
require_cmd cat CAT

section "1. PRE-EXECUTION AUDIT AUTHORITY"

test -f "$PREFLIGHT_CONSOLE" ||
    not_evaluated "A1_PREFLIGHT_CONSOLE_MISSING"

test "$(sha "$PREFLIGHT_CONSOLE")" = "$EXPECTED_PREFLIGHT_CONSOLE_SHA256" ||
    not_evaluated "A1_PREFLIGHT_CONSOLE_IDENTITY_MISMATCH"

grep -F "A1_R1_PRE_EXECUTION_AUDIT=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "A1_PREFLIGHT_RESULT_MISMATCH"

grep -F "SYNTHETIC_AUTHORITY_EQUIVALENCE=PASS" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "A1_PREFLIGHT_RESULT_MISMATCH"

grep -F "SCIENTIFIC_EXECUTION_STARTED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "A1_PREFLIGHT_BOUNDARY_MISMATCH"

grep -F "A1_EXECUTION_LOCK_CONSUMED=NO" "$PREFLIGHT_CONSOLE" >/dev/null ||
    not_evaluated "A1_PREFLIGHT_BOUNDARY_MISMATCH"

echo "A1_PREFLIGHT_CONSOLE_IDENTITY=PASS"
echo "A1_PREFLIGHT_AUTHORITY=PASS"

section "2. A0-C1 INPUT AUTHORITY"

test -f "$A0_LOCK" ||
    not_evaluated "A0_C1_LOCK_MISSING"

test "$(sha "$A0_LOCK")" = "$EXPECTED_A0_LOCK_SHA256" ||
    not_evaluated "A0_C1_LOCK_IDENTITY_MISMATCH"

test -f "$A0/evidence/SHA256SUMS" ||
    not_evaluated "A0_C1_MANIFEST_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    not_evaluated "A0_C1_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0_C1_EVIDENCE_INTEGRITY_FAILURE"

test "$(sha "$A0_CANONICAL")" = "$EXPECTED_CANONICAL_FACTS_SHA256" ||
    not_evaluated "A0_CANONICAL_FACTS_IDENTITY_MISMATCH"

test "$(sha "$A0_CONTRACT")" = "$EXPECTED_CONTRACT_SHA256" ||
    not_evaluated "A0_EVALUATION_CONTRACT_IDENTITY_MISMATCH"

echo "A0_C1_LOCK_IDENTITY=PASS"
echo "A0_C1_MANIFEST_IDENTITY=PASS"
echo "A0_C1_EVIDENCE_INTEGRITY=PASS"
echo "A0_CANONICAL_FACTS_IDENTITY=PASS"
echo "A0_EVALUATION_CONTRACT_IDENTITY=PASS"
echo "A0_AUTHORITY=PASS_BY_FROZEN_SELECTION_COMPLETION"

section "3. CONTRACT EXPECTATION AUTHORITY"

test "$(awk -F '\t' 'NR == 2 { print $8 }' "$A0_CANONICAL")" = "3314177" ||
    not_evaluated "FROZEN_INPUT_EXPECTATION_MISMATCH"

test "$(awk -F '\t' 'NR == 3 { print $8 }' "$A0_CANONICAL")" = "3314177" ||
    not_evaluated "FROZEN_INPUT_EXPECTATION_MISMATCH"

test "$(awk -F '\t' 'NR == 2 { print $5 FS $6 FS $7 }' "$A0_CANONICAL")" = \
     "$(awk -F '\t' 'NR == 3 { print $5 FS $6 FS $7 }' "$A0_CANONICAL")" ||
    not_evaluated "FROZEN_CONTEXT_EXPECTATION_MISMATCH"

grep -F "IF_DELTA_EQ_0=UNCHANGED" "$A0_CONTRACT" >/dev/null ||
    not_evaluated "FROZEN_CONTRACT_SEMANTICS_MISMATCH"

echo "EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED"

section "4. AUTHORITY SOURCE + TOOLCHAIN IDENTITY"

github_fetch \
    "$RAW_GITHUB_BASE/authorities/authority-1-c11-v1.c" \
    "$C11_SRC" ||
    not_evaluated "C11_SOURCE_FETCH_FAILURE"

github_fetch \
    "$RAW_GITHUB_BASE/authorities/authority-2-posix-v1.awk" \
    "$AWK_SRC" ||
    not_evaluated "AWK_SOURCE_FETCH_FAILURE"

test "$(sha "$C11_SRC")" = "$EXPECTED_C11_SOURCE_SHA256" ||
    not_evaluated "C11_SOURCE_IDENTITY_MISMATCH"

test "$(sha "$AWK_SRC")" = "$EXPECTED_AWK_SOURCE_SHA256" ||
    not_evaluated "AWK_SOURCE_IDENTITY_MISMATCH"

cc \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    "$C11_SRC" \
    -o "$C11_BIN" ||
    not_evaluated "C11_AUTHORITY_COMPILE_FAILURE"

C11_BINARY_SHA256="$(sha "$C11_BIN")"

test "$C11_BINARY_SHA256" = "$EXPECTED_PREFLIGHT_BINARY_SHA256" ||
    not_evaluated "C11_BINARY_TOOLCHAIN_DRIFT"

echo "C11_SOURCE_IDENTITY=PASS"
echo "AWK_SOURCE_IDENTITY=PASS"
echo "C11_AUTHORITY_COMPILE=PASS"
echo "C11_AUTHORITY_BINARY_SHA256=$C11_BINARY_SHA256"
echo "C11_BINARY_MATCHES_PREFLIGHT=PASS"

section "5. ONE-EXECUTION SCIENTIFIC GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
PREFLIGHT_CONSOLE_SHA256=$EXPECTED_PREFLIGHT_CONSOLE_SHA256
A0_C1_LOCK_SHA256=$EXPECTED_A0_LOCK_SHA256
A0_C1_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
CANONICAL_FACTS_SHA256=$EXPECTED_CANONICAL_FACTS_SHA256
EVALUATION_CONTRACT_SHA256=$EXPECTED_CONTRACT_SHA256
C11_SOURCE_SHA256=$EXPECTED_C11_SOURCE_SHA256
AWK_SOURCE_SHA256=$EXPECTED_AWK_SOURCE_SHA256
C11_BINARY_SHA256=$C11_BINARY_SHA256
EXPECTED_CLASSIFICATION=UNCHANGED
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_SCIENTIFIC_AUTHORITY_EXECUTION=YES
EOF

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "A1_EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "A1_EXECUTION_GATE=PASS"

mkdir -p "$INPUT" "$AUTH" "$RESULTS" "$EVIDENCE" "$CONTRACTS"

cp "$A0_CANONICAL" "$INPUT/canonical-facts.tsv"
cp "$A0_CONTRACT" "$CONTRACTS/evaluation-contract-v1.txt"
cp "$C11_SRC" "$AUTH/authority-1-c11-v1.c"
cp "$C11_BIN" "$AUTH/authority-1-c11-v1"
cp "$AWK_SRC" "$AUTH/authority-2-posix-v1.awk"

section "6. SCIENTIFIC AUTHORITY 1 - C11"

"$AUTH/authority-1-c11-v1" \
    "$INPUT/canonical-facts.tsv" \
    > "$RESULTS/authority-1.tsv" ||
    scientific_fail "C11_AUTHORITY_RUNTIME_FAILURE"

echo "C11_AUTHORITY=PASS"
echo "AUTHORITY_1_RESULTS_SHA256=$(sha "$RESULTS/authority-1.tsv")"

section "7. SCIENTIFIC AUTHORITY 2 - POSIX AWK"

awk -f "$AUTH/authority-2-posix-v1.awk" \
    "$INPUT/canonical-facts.tsv" \
    > "$RESULTS/authority-2.tsv" ||
    scientific_fail "AWK_AUTHORITY_RUNTIME_FAILURE"

echo "AWK_AUTHORITY=PASS"
echo "AUTHORITY_2_RESULTS_SHA256=$(sha "$RESULTS/authority-2.tsv")"

section "8. INDEPENDENT AUTHORITY EQUIVALENCE"

cmp -s "$RESULTS/authority-1.tsv" "$RESULTS/authority-2.tsv" ||
    scientific_fail "INDEPENDENT_AUTHORITY_DIVERGENCE"

test "$(wc -l < "$RESULTS/authority-1.tsv" | awk '{print $1}')" = "2" ||
    scientific_fail "EVALUATION_OUTPUT_SHAPE_FAILURE"

OBSERVED="$(awk -F '\t' 'NR == 2 { print $12 }' "$RESULTS/authority-1.tsv")"

test "$OBSERVED" = "UNCHANGED" ||
    scientific_fail "FROZEN_CONTRACT_EXPECTATION_MISMATCH"

EXPECTED_ROW="$(printf 'PUBLIC-DISCLOSURE-EVALUATION-V1\tAssets\tUSD\t-\t2024-06-30\t3314177\t3314177\t0\t0\t3314177\t100\tUNCHANGED')"

grep -Fx "$EXPECTED_ROW" "$RESULTS/authority-1.tsv" >/dev/null ||
    scientific_fail "CANONICAL_EVALUATION_CONTENT_MISMATCH"

cp "$RESULTS/authority-1.tsv" "$RESULTS/canonical-evaluation.tsv"

echo "STATE_A_B_AUTHORITY_EQUIVALENCE=PASS"
echo "AUTHORITY_EQUIVALENCE=PASS"
echo "EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED"
echo "OBSERVED_CLASSIFICATION=$OBSERVED"
echo "CONTRACT_EXPECTATION_MATCH=PASS"
echo "CANONICAL_EVALUATION_SHA256=$(sha "$RESULTS/canonical-evaluation.tsv")"

section "9. FREEZE A1 EVIDENCE"

cp "$LOCK" "$EVIDENCE/execution-started.txt"
cp "$0" "$EVIDENCE/stage-a1-r1-script.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
A0_AUTHORITY	PASS_BY_FROZEN_SELECTION_COMPLETION
PREFLIGHT_CONSOLE_SHA256	$EXPECTED_PREFLIGHT_CONSOLE_SHA256
A0_C1_LOCK_SHA256	$EXPECTED_A0_LOCK_SHA256
A0_C1_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
CANONICAL_FACTS_SHA256	$EXPECTED_CANONICAL_FACTS_SHA256
EVALUATION_CONTRACT_SHA256	$EXPECTED_CONTRACT_SHA256
C11_SOURCE_SHA256	$EXPECTED_C11_SOURCE_SHA256
AWK_SOURCE_SHA256	$EXPECTED_AWK_SOURCE_SHA256
C11_BINARY_SHA256	$C11_BINARY_SHA256
AUTHORITY_1_RESULTS_SHA256	$(sha "$RESULTS/authority-1.tsv")
AUTHORITY_2_RESULTS_SHA256	$(sha "$RESULTS/authority-2.tsv")
CANONICAL_EVALUATION_SHA256	$(sha "$RESULTS/canonical-evaluation.tsv")
EXPECTED_CLASSIFICATION	UNCHANGED
OBSERVED_CLASSIFICATION	$OBSERVED
AUTHORITY_EQUIVALENCE	PASS
CONTRACT_EXPECTATION_MATCH	PASS
SEC_FETCHES	ZERO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

(
    cd "$STAGE"

    find input authorities results evidence contracts \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS \
        > evidence/SHA256SUMS.check
) || scientific_fail "A1_EVIDENCE_INTEGRITY_FAILURE"

A1_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A1_EVIDENCE_INTEGRITY=PASS"
echo "A1_EVIDENCE_MANIFEST_SHA256=$A1_MANIFEST_SHA256"

section "10. A1 HOMOLOGATION"

echo "PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A1=PASS"
echo "A1_REVISION=$REVISION"

echo "C11_AUTHORITY=PASS"
echo "AWK_AUTHORITY=PASS"
echo "STATE_A_B_AUTHORITY_EQUIVALENCE=PASS"
echo "CONTRACT_EXPECTATION_MATCH=PASS"
echo "CLASSIFICATION=$OBSERVED"

echo "SEC_FETCHES=ZERO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A2_YODA_EVALUATION_LINEAGE"

rm -rf "$PREFLIGHT_WORK"
