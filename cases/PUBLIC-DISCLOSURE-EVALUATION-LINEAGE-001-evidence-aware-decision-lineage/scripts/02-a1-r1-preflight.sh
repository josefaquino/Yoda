#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
ROOT="$HOME/cmu/$CASE"

A0="$ROOT/stage-a0-c1"
A0_LOCK="$ROOT/.stage-a0-c1-execution-started"

A1_STAGE="$ROOT/stage-a1-r1"
A1_LOCK="$ROOT/.stage-a1-r1-execution-started"
PREFLIGHT="$ROOT/.stage-a1-r1-preflight"

A0_CANONICAL="$A0/canonical/canonical-facts.tsv"
A0_CONTRACT="$A0/contracts/evaluation-contract-v1.txt"

EXPECTED_A0_LOCK_SHA256="7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2"
EXPECTED_A0_MANIFEST_SHA256="40499e4c4545974f3ed106d72cc5da356bdbadc8a4478f0a152e6d4f454c84cb"
EXPECTED_CANONICAL_FACTS_SHA256="0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d"
EXPECTED_CONTRACT_SHA256="ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd"

AUTHORITY_COMMIT="f5145ca95e31f9a2cc3b7c9ef127d3a25b140c93"
RAW_GITHUB_BASE="https://raw.githubusercontent.com/josefaquino/Yoda/$AUTHORITY_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage"

EXPECTED_C11_SOURCE_SHA256="9f41bda1c4e5a082cb739362f36030be047e00edef727518e7f74c161098fad0"
EXPECTED_AWK_SOURCE_SHA256="8b88216d22e6435319c73ec91dd3968cb453539c1a9effa1460bd9930fe0da91"

C11_SRC="$PREFLIGHT/authority-1-c11-v1.c"
C11_BIN="$PREFLIGHT/authority-1-c11-v1"
AWK_SRC="$PREFLIGHT/authority-2-posix-v1.awk"

OUT_HEADER="$(printf 'contract\tconcept\tunit\tstart\tend\tvalue_a_raw\tvalue_b_raw\tcommon_scale\tdelta_coefficient\tbase_coefficient\tthreshold_basis_points\tclassification')"

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

abort()
{
    echo
    echo "A1_R1_PRE_EXECUTION_AUDIT=NOT_EVALUATED"
    echo "FAILURE_CLASS=$1"
    echo "SCIENTIFIC_EXECUTION_STARTED=NO"
    echo "A1_EXECUTION_LOCK_CONSUMED=NO"
    echo "SEC_FETCHES=ZERO"
    echo "YODA_WRITES=ZERO"
    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        abort "LOCAL_TOOLCHAIN_MISSING_$2"

    echo "$2=PASS"
}

fetch()
{
    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --output "$2" \
        "$1"
}

make_input()
{
    {
        printf 'state\taccession\tform\tconcept\tunit\tstart\tend\tvalue_raw\n'
        printf 'A\tA-ACC\t10-K\tAssets\t%s\t%s\t%s\t%s\n' "$2" "$4" "$6" "$8"
        printf 'B\tB-ACC\t10-K/A\tAssets\t%s\t%s\t%s\t%s\n' "$3" "$5" "$7" "$9"
    } > "$1"
}

make_expected()
{
    file="$1"
    unit="$2"
    start="$3"
    end="$4"
    a_raw="$5"
    b_raw="$6"
    scale="$7"
    delta="$8"
    base="$9"
    shift 9
    classification="$1"

    {
        printf '%s\n' "$OUT_HEADER"
        printf 'PUBLIC-DISCLOSURE-EVALUATION-V1\tAssets\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t100\t%s\n' \
            "$unit" "$start" "$end" "$a_raw" "$b_raw" "$scale" "$delta" "$base" "$classification"
    } > "$file"
}

run_case()
{
    name="$1"
    input="$2"
    expected="$3"

    "$C11_BIN" "$input" > "$PREFLIGHT/$name.c11.tsv" ||
        abort "SYNTHETIC_C11_RUNTIME_FAILURE"

    awk -f "$AWK_SRC" "$input" > "$PREFLIGHT/$name.awk.tsv" ||
        abort "SYNTHETIC_AWK_RUNTIME_FAILURE"

    cmp -s "$PREFLIGHT/$name.c11.tsv" "$PREFLIGHT/$name.awk.tsv" ||
        abort "SYNTHETIC_AUTHORITY_DIVERGENCE_$name"

    cmp -s "$PREFLIGHT/$name.c11.tsv" "$expected" ||
        abort "SYNTHETIC_EXPECTATION_MISMATCH_$name"

    echo "SYNTHETIC_CASE_$name=PASS"
}

test ! -e "$A1_LOCK" ||
    abort "A1_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

test ! -e "$A1_STAGE" ||
    abort "A1_STAGE_ALREADY_EXISTS"

rm -rf "$PREFLIGHT"
mkdir -p "$PREFLIGHT"

section "0. TOOLCHAIN"

require_cmd curl CURL
require_cmd cc CC
require_cmd awk AWK
require_cmd cmp CMP
require_cmd grep GREP
require_cmd sha256sum SHA256SUM
require_cmd wc WC
require_cmd rm RM
require_cmd mkdir MKDIR

section "1. A0-C1 AUTHORITY"

test -f "$A0_LOCK" ||
    abort "A0_C1_LOCK_MISSING"

test "$(sha "$A0_LOCK")" = "$EXPECTED_A0_LOCK_SHA256" ||
    abort "A0_C1_LOCK_IDENTITY_MISMATCH"

test -f "$A0/evidence/SHA256SUMS" ||
    abort "A0_C1_MANIFEST_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    abort "A0_C1_MANIFEST_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || abort "A0_C1_EVIDENCE_INTEGRITY_FAILURE"

test "$(sha "$A0_CANONICAL")" = "$EXPECTED_CANONICAL_FACTS_SHA256" ||
    abort "A0_CANONICAL_FACTS_IDENTITY_MISMATCH"

test "$(sha "$A0_CONTRACT")" = "$EXPECTED_CONTRACT_SHA256" ||
    abort "A0_EVALUATION_CONTRACT_IDENTITY_MISMATCH"

echo "A0_C1_LOCK_IDENTITY=PASS"
echo "A0_C1_MANIFEST_IDENTITY=PASS"
echo "A0_C1_EVIDENCE_INTEGRITY=PASS"
echo "A0_CANONICAL_FACTS_IDENTITY=PASS"
echo "A0_EVALUATION_CONTRACT_IDENTITY=PASS"
echo "A0_AUTHORITY=PASS_BY_FROZEN_SELECTION_COMPLETION"

section "2. CONTRACT-DERIVED EXPECTATION"

VALUE_A="$(awk -F '\t' 'NR == 2 { print $8 }' "$A0_CANONICAL")"
VALUE_B="$(awk -F '\t' 'NR == 3 { print $8 }' "$A0_CANONICAL")"
UNIT_A="$(awk -F '\t' 'NR == 2 { print $5 }' "$A0_CANONICAL")"
UNIT_B="$(awk -F '\t' 'NR == 3 { print $5 }' "$A0_CANONICAL")"
START_A="$(awk -F '\t' 'NR == 2 { print $6 }' "$A0_CANONICAL")"
START_B="$(awk -F '\t' 'NR == 3 { print $6 }' "$A0_CANONICAL")"
END_A="$(awk -F '\t' 'NR == 2 { print $7 }' "$A0_CANONICAL")"
END_B="$(awk -F '\t' 'NR == 3 { print $7 }' "$A0_CANONICAL")"

test "$VALUE_A" = "3314177" ||
    abort "FROZEN_INPUT_EXPECTATION_MISMATCH"

test "$VALUE_B" = "3314177" ||
    abort "FROZEN_INPUT_EXPECTATION_MISMATCH"

test "$VALUE_A" = "$VALUE_B" ||
    abort "FROZEN_CONTRACT_EXPECTATION_NOT_UNCHANGED"

test "$UNIT_A" = "$UNIT_B" ||
    abort "FROZEN_CONTEXT_EXPECTATION_MISMATCH"

test "$START_A" = "$START_B" ||
    abort "FROZEN_CONTEXT_EXPECTATION_MISMATCH"

test "$END_A" = "$END_B" ||
    abort "FROZEN_CONTEXT_EXPECTATION_MISMATCH"

grep -F "IF_DELTA_EQ_0=UNCHANGED" "$A0_CONTRACT" >/dev/null ||
    abort "FROZEN_CONTRACT_SEMANTICS_MISMATCH"

echo "VALUE_A_EQUALS_VALUE_B=YES"
echo "REQUIRED_CONTEXT_MATCH=YES"
echo "EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED"

section "3. AUTHORITY SOURCE IDENTITIES"

fetch \
    "$RAW_GITHUB_BASE/authorities/authority-1-c11-v1.c" \
    "$C11_SRC" ||
    abort "C11_SOURCE_FETCH_FAILURE"

fetch \
    "$RAW_GITHUB_BASE/authorities/authority-2-posix-v1.awk" \
    "$AWK_SRC" ||
    abort "AWK_SOURCE_FETCH_FAILURE"

test "$(sha "$C11_SRC")" = "$EXPECTED_C11_SOURCE_SHA256" ||
    abort "C11_SOURCE_IDENTITY_MISMATCH"

test "$(sha "$AWK_SRC")" = "$EXPECTED_AWK_SOURCE_SHA256" ||
    abort "AWK_SOURCE_IDENTITY_MISMATCH"

if grep -E '\<(float|double|strtod|atof)\>' "$C11_SRC" >/dev/null
then
    abort "C11_FLOATING_POINT_POLICY_VIOLATION"
fi

echo "C11_SOURCE_IDENTITY=PASS"
echo "AWK_SOURCE_IDENTITY=PASS"
echo "C11_FLOATING_POINT_POLICY=PASS"

section "4. C11 COMPILE"

cc \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    "$C11_SRC" \
    -o "$C11_BIN" ||
    abort "C11_AUTHORITY_COMPILE_FAILURE"

echo "C11_AUTHORITY_COMPILE=PASS"
echo "C11_AUTHORITY_BINARY_SHA256=$(sha "$C11_BIN")"

section "5. SYNTHETIC DUAL-AUTHORITY SUITE"

make_input "$PREFLIGHT/unchanged.tsv" USD USD - - 2024-12-31 2024-12-31 1000 1000
make_expected "$PREFLIGHT/unchanged.expected.tsv" USD - 2024-12-31 1000 1000 0 0 1000 UNCHANGED
run_case UNCHANGED "$PREFLIGHT/unchanged.tsv" "$PREFLIGHT/unchanged.expected.tsv"

make_input "$PREFLIGHT/within.tsv" USD USD - - 2024-12-31 2024-12-31 1000 1005
make_expected "$PREFLIGHT/within.expected.tsv" USD - 2024-12-31 1000 1005 0 5 1005 CHANGED_WITHIN_THRESHOLD
run_case WITHIN "$PREFLIGHT/within.tsv" "$PREFLIGHT/within.expected.tsv"

make_input "$PREFLIGHT/above.tsv" USD USD - - 2024-12-31 2024-12-31 1000 1020
make_expected "$PREFLIGHT/above.expected.tsv" USD - 2024-12-31 1000 1020 0 20 1020 CHANGED_ABOVE_THRESHOLD
run_case ABOVE "$PREFLIGHT/above.tsv" "$PREFLIGHT/above.expected.tsv"

make_input "$PREFLIGHT/decimal.tsv" USD USD - - 2024-12-31 2024-12-31 100.00 100.50
make_expected "$PREFLIGHT/decimal.expected.tsv" USD - 2024-12-31 100.00 100.50 2 50 10050 CHANGED_WITHIN_THRESHOLD
run_case DECIMAL "$PREFLIGHT/decimal.tsv" "$PREFLIGHT/decimal.expected.tsv"

make_input "$PREFLIGHT/scale.tsv" USD USD - - 2024-12-31 2024-12-31 1.0 1.00
make_expected "$PREFLIGHT/scale.expected.tsv" USD - 2024-12-31 1.0 1.00 2 0 100 UNCHANGED
run_case SCALE "$PREFLIGHT/scale.tsv" "$PREFLIGHT/scale.expected.tsv"

make_input "$PREFLIGHT/not-comparable.tsv" USD EUR - - 2024-12-31 2024-12-31 1000 1000
make_expected "$PREFLIGHT/not-comparable.expected.tsv" USD - 2024-12-31 1000 1000 - - - NOT_COMPARABLE
run_case NOT_COMPARABLE "$PREFLIGHT/not-comparable.tsv" "$PREFLIGHT/not-comparable.expected.tsv"

make_input "$PREFLIGHT/not-evaluable.tsv" USD USD - - 2024-12-31 2024-12-31 abc 1000
make_expected "$PREFLIGHT/not-evaluable.expected.tsv" USD - 2024-12-31 abc 1000 - - - NOT_EVALUABLE
run_case NOT_EVALUABLE "$PREFLIGHT/not-evaluable.tsv" "$PREFLIGHT/not-evaluable.expected.tsv"

make_input "$PREFLIGHT/negative.tsv" USD USD - - 2024-12-31 2024-12-31 -100 -101
make_expected "$PREFLIGHT/negative.expected.tsv" USD - 2024-12-31 -100 -101 0 1 101 CHANGED_WITHIN_THRESHOLD
run_case NEGATIVE "$PREFLIGHT/negative.tsv" "$PREFLIGHT/negative.expected.tsv"

make_input "$PREFLIGHT/opposite.tsv" USD USD - - 2024-12-31 2024-12-31 -100 100
make_expected "$PREFLIGHT/opposite.expected.tsv" USD - 2024-12-31 -100 100 0 200 100 CHANGED_ABOVE_THRESHOLD
run_case OPPOSITE "$PREFLIGHT/opposite.tsv" "$PREFLIGHT/opposite.expected.tsv"

echo "SYNTHETIC_AUTHORITY_1=PASS"
echo "SYNTHETIC_AUTHORITY_2=PASS"
echo "SYNTHETIC_AUTHORITY_EQUIVALENCE=PASS"

section "6. PREFLIGHT VERDICT"

echo "A1_R1_PRE_EXECUTION_AUDIT=PASS"
echo "A1_PREFLIGHT=PASS"

echo "A1_EXECUTION_LOCK=ABSENT"
echo "A1_STAGE=ABSENT"
echo "SCIENTIFIC_EXECUTION_STARTED=NO"
echo "A1_EXECUTION_LOCK_CONSUMED=NO"

echo "SEC_FETCHES=ZERO"
echo "YODA_WRITES=ZERO"

rm -rf "$PREFLIGHT"
