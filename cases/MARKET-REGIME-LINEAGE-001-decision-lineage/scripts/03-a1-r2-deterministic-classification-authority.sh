#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
REVISION="A1-R2"

ROOT="$HOME/cmu/$CASE"
A0="$ROOT/stage-a0-r1"
R1="$ROOT/stage-a1-r1"
STAGE="$ROOT/stage-a1-r2"
EVIDENCE="$STAGE/evidence"
AUTH="$STAGE/authorities"
RESULTS="$STAGE/results"

LOCK="$ROOT/.stage-a1-r2-execution-started"
R1_LOCK="$ROOT/.stage-a1-r1-execution-started"

AUTHORITY_COMMIT="9695b2830bcddaefa0c727c663d3b716f1623bb1"
RAW_BASE="https://raw.githubusercontent.com/josefaquino/Yoda/$AUTHORITY_COMMIT/cases/MARKET-REGIME-LINEAGE-001-decision-lineage"

EXPECTED_A0_MANIFEST_SHA256="0440ffea6e2377fa6843f972f35d127f44727f114c2d91ae94039ff1ca4a78c8"
EXPECTED_SNAPSHOT_A_SHA256="10ce61f2bd18d1f32191a91c317759a87ca11b993f22f630818c56a96bef9410"
EXPECTED_SNAPSHOT_B_SHA256="d1688f9b362c84018f9fc093e8a6f7b985e56e3965bdb9bf8d2bdffa3af39a34"
EXPECTED_SNAPSHOT_C_SHA256="b0604231b66c6d24ef7e640bb5cf423ed138984a69342eff0f2585ac446006c2"

EXPECTED_R1_LOCK_SHA256="e0d24e57b3112eb605d775d645f736f557c1a31772aae63fa79a441e7a324f3c"
EXPECTED_R1_AUTHORITY1_PARTIAL_SHA256="0480c6d20b20b22c4eafd291f1342691fd37ad40cef3181dfc7ace7baa20b77b"

EXPECTED_CONTRACT_SHA256="8516bb27a0099995ee09c4900d26477a8ff142e3e9aa6c4b496f94b21b6d09be"
EXPECTED_AUTHORITY_1_SOURCE_SHA256="29b82504373f54bb225f76be2bfd0c9e2d439268da6c7e90442a7eeb820c6573"
EXPECTED_AUTHORITY_2_SOURCE_SHA256="c48b6fe73b1ea327397b68476de9a29d8f87f5a9c0d3303b529c64757b2e6fc8"

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
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A1_R2=NOT_EVALUATED"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A1_R1_RERUN=NO"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

fail()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A1_R2=FAIL"
    echo "A1_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "A1_R1_RERUN=NO"
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

test ! -e "$LOCK" ||
    not_evaluated "A1_R2_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

section "0. FROZEN A0 + A1-R1 AUTHORITY"

for pair in     "curl:CURL"     "cc:CC"     "awk:AWK"     "sha256sum:SHA256SUM"     "cmp:CMP"     "diff:DIFF"     "grep:GREP"     "sed:SED"     "wc:WC"     "find:FIND"     "sort:SORT"     "xargs:XARGS"
do
    cmd="${pair%%:*}"
    label="${pair#*:}"
    require_cmd "$cmd" "$label"
done

test -f "$A0/evidence/SHA256SUMS" ||
    not_evaluated "A0_EVIDENCE_MISSING"

test "$(sha "$A0/evidence/SHA256SUMS")" = "$EXPECTED_A0_MANIFEST_SHA256" ||
    not_evaluated "A0_EVIDENCE_IDENTITY_MISMATCH"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

test "$(sha "$A0/snapshots/state-A.tsv")" = "$EXPECTED_SNAPSHOT_A_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-B.tsv")" = "$EXPECTED_SNAPSHOT_B_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test "$(sha "$A0/snapshots/state-C.tsv")" = "$EXPECTED_SNAPSHOT_C_SHA256" ||
    not_evaluated "A0_SNAPSHOT_IDENTITY_MISMATCH"

test -f "$R1_LOCK" ||
    not_evaluated "A1_R1_EVIDENCE_MISSING"

test "$(sha "$R1_LOCK")" = "$EXPECTED_R1_LOCK_SHA256" ||
    not_evaluated "A1_R1_EVIDENCE_IDENTITY_MISMATCH"

test -f "$R1/results/authority-1.tsv" ||
    not_evaluated "A1_R1_EVIDENCE_MISSING"

test "$(sha "$R1/results/authority-1.tsv")" = "$EXPECTED_R1_AUTHORITY1_PARTIAL_SHA256" ||
    not_evaluated "A1_R1_EVIDENCE_IDENTITY_MISMATCH"

test "$(wc -l < "$R1/results/authority-1.tsv" | tr -d ' ')" = "1" ||
    not_evaluated "A1_R1_EVIDENCE_SHAPE_MISMATCH"

test ! -e "$R1/results/authority-2.tsv" ||
    not_evaluated "A1_R1_EVIDENCE_SHAPE_MISMATCH"

test ! -e "$R1/results/canonical-results.tsv" ||
    not_evaluated "A1_R1_EVIDENCE_SHAPE_MISMATCH"

echo "A0_EVIDENCE_AUTHORITY=PASS"
echo "A0_SNAPSHOT_A_AUTHORITY=PASS"
echo "A0_SNAPSHOT_B_AUTHORITY=PASS"
echo "A0_SNAPSHOT_C_AUTHORITY=PASS"
echo "A1_R1_NOT_EVALUATED_AUTHORITY=PASS"
echo "A1_R1_RERUN=NO"

section "1. FIXED5 INPUT COMPATIBILITY PRECHECK"

FIXED5_VIOLATIONS="$(
    for state in A B C
    do
        awk -F '\t' '
            NR > 1 {
                s = $5

                if (substr(s,1,1) == "+" || substr(s,1,1) == "-")
                    s = substr(s,2)

                n = split(s, p, ".")
                frac = (n == 2 ? length(p[2]) : 0)

                if (s !~ /^[0-9]+([.][0-9]+)?$/ || frac > 5)
                    bad++
            }

            END {
                print bad + 0
            }
        ' "$A0/snapshots/state-$state.tsv"
    done |
    awk '{ total += $1 } END { print total + 0 }'
)"

echo "FIXED5_INPUT_CONTRACT_VIOLATION_COUNT=$FIXED5_VIOLATIONS"

test "$FIXED5_VIOLATIONS" = "0" ||
    not_evaluated "NUMERIC_REPRESENTATION_CONTRACT_MISMATCH"

echo "FIXED5_INPUT_COMPATIBILITY=PASS"

section "2. FETCH + VERIFY FROZEN V2 AUTHORITIES"

rm -rf "$STAGE"
mkdir -p "$EVIDENCE" "$AUTH" "$RESULTS"

curl -fsSL     "$RAW_BASE/contracts/classification-contract-v2.txt"     -o "$STAGE/classification-contract-v2.txt" ||
    not_evaluated "AUTHORITY_FETCH_FAILURE"

curl -fsSL     "$RAW_BASE/authorities/authority-1-c11-v2.c"     -o "$AUTH/authority-1-c11-v2.c" ||
    not_evaluated "AUTHORITY_FETCH_FAILURE"

curl -fsSL     "$RAW_BASE/authorities/authority-2-posix-v2.awk"     -o "$AUTH/authority-2-posix-v2.awk" ||
    not_evaluated "AUTHORITY_FETCH_FAILURE"

test "$(sha "$STAGE/classification-contract-v2.txt")" = "$EXPECTED_CONTRACT_SHA256" ||
    not_evaluated "CLASSIFICATION_CONTRACT_IDENTITY_MISMATCH"

test "$(sha "$AUTH/authority-1-c11-v2.c")" = "$EXPECTED_AUTHORITY_1_SOURCE_SHA256" ||
    not_evaluated "AUTHORITY_1_IDENTITY_MISMATCH"

test "$(sha "$AUTH/authority-2-posix-v2.awk")" = "$EXPECTED_AUTHORITY_2_SOURCE_SHA256" ||
    not_evaluated "AUTHORITY_2_IDENTITY_MISMATCH"

echo "AUTHORITY_COMMIT=$AUTHORITY_COMMIT"
echo "CLASSIFICATION_CONTRACT_V2=FROZEN"
echo "CLASSIFICATION_CONTRACT_V2_SHA256=$EXPECTED_CONTRACT_SHA256"
echo "AUTHORITY_1_V2_IDENTITY=FROZEN"
echo "AUTHORITY_1_V2_SOURCE_SHA256=$EXPECTED_AUTHORITY_1_SOURCE_SHA256"
echo "AUTHORITY_2_V2_IDENTITY=FROZEN"
echo "AUTHORITY_2_V2_SOURCE_SHA256=$EXPECTED_AUTHORITY_2_SOURCE_SHA256"

echo "DATES_CHANGED=NO"
echo "A0_SNAPSHOT_BYTES_CHANGED=NO"
echo "THRESHOLDS_CHANGED=NO"
echo "LABEL_MAPPING_CHANGED=NO"
echo "SCIENTIFIC_QUESTION_CHANGED=NO"

section "3. COMPILE AUTHORITY 1 V2 BEFORE EXECUTION GATE"

cc     -std=c11     -O2     -Wall     -Wextra     -Werror     "$AUTH/authority-1-c11-v2.c"     -o "$AUTH/authority-1-c11-v2" ||
    not_evaluated "TOOLCHAIN_DRIFT"

AUTHORITY_1_BINARY_SHA256="$(sha "$AUTH/authority-1-c11-v2")"

echo "AUTHORITY_1_V2_COMPILE=PASS"
echo "AUTHORITY_1_V2_BINARY_SHA256=$AUTHORITY_1_BINARY_SHA256"

section "4. ONE-EXECUTION GATE"

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
A0_EVIDENCE_MANIFEST_SHA256=$EXPECTED_A0_MANIFEST_SHA256
A1_R1_EXECUTION_LOCK_SHA256=$EXPECTED_R1_LOCK_SHA256
CLASSIFICATION_CONTRACT_V2_SHA256=$EXPECTED_CONTRACT_SHA256
AUTHORITY_1_V2_SOURCE_SHA256=$EXPECTED_AUTHORITY_1_SOURCE_SHA256
AUTHORITY_1_V2_BINARY_SHA256=$AUTHORITY_1_BINARY_SHA256
AUTHORITY_2_V2_SOURCE_SHA256=$EXPECTED_AUTHORITY_2_SOURCE_SHA256
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_A1_R2_CLASSIFICATION=YES
EOF

cp "$LOCK" "$EVIDENCE/execution-started.txt"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "EXECUTION_GATE=PASS"

section "5. AUTHORITY 1 V2 - C11"

HEADER="$(printf 'state\tevaluation_date\tdgs10_scaled5\tnfci_scaled5\tvixcls_scaled5\trate_flag\tnfci_flag\tvix_flag\tscore\tclassification')"
printf '%s\n' "$HEADER" > "$RESULTS/authority-1-v2.tsv"

for state in A B C
do
    set +e
    "$AUTH/authority-1-c11-v2" "$state" "$A0/snapshots/state-$state.tsv"         >> "$RESULTS/authority-1-v2.tsv"
    rc=$?
    set -e

    echo "AUTHORITY_1_V2_STATE_${state}_RC=$rc"

    test "$rc" -eq 0 ||
        not_evaluated "HARNESS_FAILURE"
done

test "$(wc -l < "$RESULTS/authority-1-v2.tsv" | tr -d ' ')" = "4" ||
    not_evaluated "HARNESS_FAILURE"

echo "AUTHORITY_1_V2_EXECUTION=PASS"
echo "AUTHORITY_1_V2_RESULTS_SHA256=$(sha "$RESULTS/authority-1-v2.tsv")"

section "6. AUTHORITY 2 V2 - POSIX AWK"

printf '%s\n' "$HEADER" > "$RESULTS/authority-2-v2.tsv"

for state in A B C
do
    set +e
    awk -v state="$state" -f "$AUTH/authority-2-posix-v2.awk"         "$A0/snapshots/state-$state.tsv"         >> "$RESULTS/authority-2-v2.tsv"
    rc=$?
    set -e

    echo "AUTHORITY_2_V2_STATE_${state}_RC=$rc"

    test "$rc" -eq 0 ||
        not_evaluated "HARNESS_FAILURE"
done

test "$(wc -l < "$RESULTS/authority-2-v2.tsv" | tr -d ' ')" = "4" ||
    not_evaluated "HARNESS_FAILURE"

echo "AUTHORITY_2_V2_EXECUTION=PASS"
echo "AUTHORITY_2_V2_RESULTS_SHA256=$(sha "$RESULTS/authority-2-v2.tsv")"

section "7. INDEPENDENT AUTHORITY EQUIVALENCE"

if ! cmp -s "$RESULTS/authority-1-v2.tsv" "$RESULTS/authority-2-v2.tsv"
then
    diff -u         "$RESULTS/authority-1-v2.tsv"         "$RESULTS/authority-2-v2.tsv"         > "$EVIDENCE/authority-v2-divergence.diff" || true

    fail "AUTHORITY_IMPLEMENTATION_DIVERGENCE"
fi

cp     "$RESULTS/authority-1-v2.tsv"     "$RESULTS/canonical-results-v2.tsv"

echo "STATE_A_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_B_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_C_AUTHORITY_EQUIVALENCE=PASS"
echo "AUTHORITY_FEATURE_EQUIVALENCE=PASS"
echo "AUTHORITY_CLASSIFICATION_EQUIVALENCE=PASS"
echo "CANONICAL_RESULTS_V2_SHA256=$(sha "$RESULTS/canonical-results-v2.tsv")"

section "8. OBSERVED CLASSIFICATIONS"

cat "$RESULTS/canonical-results-v2.tsv"

for state in A B C
do
    count="$(
        awk -F '\t' -v state="$state" '
            NR > 1 && $1 == state {
                n++
            }

            END {
                print n + 0
            }
        ' "$RESULTS/canonical-results-v2.tsv"
    )"

    test "$count" = "1" ||
        not_evaluated "HARNESS_FAILURE"
done

echo "STATE_A_CLASSIFICATION_RECORDED=PASS"
echo "STATE_B_CLASSIFICATION_RECORDED=PASS"
echo "STATE_C_CLASSIFICATION_RECORDED=PASS"

section "9. FREEZE A1-R2 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
A0_EVIDENCE_MANIFEST_SHA256	$EXPECTED_A0_MANIFEST_SHA256
A1_R1_EXECUTION_LOCK_SHA256	$EXPECTED_R1_LOCK_SHA256
CLASSIFICATION_CONTRACT_V2_SHA256	$EXPECTED_CONTRACT_SHA256
AUTHORITY_1_V2_SOURCE_SHA256	$EXPECTED_AUTHORITY_1_SOURCE_SHA256
AUTHORITY_1_V2_BINARY_SHA256	$AUTHORITY_1_BINARY_SHA256
AUTHORITY_2_V2_SOURCE_SHA256	$EXPECTED_AUTHORITY_2_SOURCE_SHA256
AUTHORITY_1_V2_RESULTS_SHA256	$(sha "$RESULTS/authority-1-v2.tsv")
AUTHORITY_2_V2_RESULTS_SHA256	$(sha "$RESULTS/authority-2-v2.tsv")
CANONICAL_RESULTS_V2_SHA256	$(sha "$RESULTS/canonical-results-v2.tsv")
FIXED5_INPUT_COMPATIBILITY	PASS
STATE_A_AUTHORITY_EQUIVALENCE	PASS
STATE_B_AUTHORITY_EQUIVALENCE	PASS
STATE_C_AUTHORITY_EQUIVALENCE	PASS
AUTHORITY_FEATURE_EQUIVALENCE	PASS
AUTHORITY_CLASSIFICATION_EQUIVALENCE	PASS
DATES_CHANGED	NO
A0_SNAPSHOT_BYTES_CHANGED	NO
THRESHOLDS_CHANGED	NO
LABEL_MAPPING_CHANGED	NO
SCIENTIFIC_QUESTION_CHANGED	NO
A1_R1_RERUN	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-a1-r2-script.sh"
cp "$STAGE/classification-contract-v2.txt" "$EVIDENCE/classification-contract-v2.txt"
cp "$AUTH/authority-1-c11-v2.c" "$EVIDENCE/authority-1-c11-v2.c"
cp "$AUTH/authority-1-c11-v2" "$EVIDENCE/authority-1-c11-v2.bin"
cp "$AUTH/authority-2-posix-v2.awk" "$EVIDENCE/authority-2-posix-v2.awk"
cp "$RESULTS/canonical-results-v2.tsv" "$EVIDENCE/canonical-results-v2.tsv"

(
    cd "$STAGE"

    find evidence results authorities         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS         > evidence/SHA256SUMS.check
) || not_evaluated "A1_R2_EVIDENCE_INTEGRITY_FAILURE"

A1_R2_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A1_R2_EVIDENCE_INTEGRITY=PASS"
echo "A1_R2_EVIDENCE_MANIFEST_SHA256=$A1_R2_MANIFEST_SHA256"

section "10. A1-R2 HOMOLOGATION"

echo "MARKET_REGIME_LINEAGE_001_STAGE_A1_R2=PASS"
echo "A1_REVISION=$REVISION"
echo "A1_R1_STATUS=NOT_EVALUATED"
echo "A1_R1_RERUN=NO"

echo "CLASSIFICATION_CONTRACT_V2=FROZEN"
echo "AUTHORITY_1_V2_EXECUTION=PASS"
echo "AUTHORITY_2_V2_EXECUTION=PASS"

echo "STATE_A_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_B_AUTHORITY_EQUIVALENCE=PASS"
echo "STATE_C_AUTHORITY_EQUIVALENCE=PASS"
echo "AUTHORITY_FEATURE_EQUIVALENCE=PASS"
echo "AUTHORITY_CLASSIFICATION_EQUIVALENCE=PASS"

echo "A1_R2_EVIDENCE_INTEGRITY=PASS"

echo "DATES_CHANGED=NO"
echo "A0_SNAPSHOT_BYTES_CHANGED=NO"
echo "THRESHOLDS_CHANGED=NO"
echo "LABEL_MAPPING_CHANGED=NO"
echo "SCIENTIFIC_QUESTION_CHANGED=NO"

echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

echo "NEXT_GATE=A2_YODA_DECISION_LINEAGE"
