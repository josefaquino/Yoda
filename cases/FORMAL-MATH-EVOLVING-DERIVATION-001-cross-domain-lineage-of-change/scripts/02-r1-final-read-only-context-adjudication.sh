#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
ROOT="$HOME/cmu/$CASE"
A2="$ROOT/stage-a2"
STORE="$A2/yoda-store"
STAGE="$ROOT/stage-a2-r1-final-readonly-adjudication"
EVIDENCE="$STAGE/evidence"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"
EXPECTED_DATA_YODA="5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba"
EXPECTED_A2_SCRIPT="1568c92514e12be7ecb7bc57dd9e31a51fcb32240b75b21c3cfc003dfd191fbe"
EXPECTED_A2_CONSOLE="a8f3f499cdc89a58e613deb5c2f07f68eaea9278b05a75c0280dd6ebd088a6d7"
EXPECTED_A2_LOCK="c8ec9022ffd989fcc9dff818fbcc1268a03154c2a3267cbde40585f328f18241"
EXPECTED_ADJ1_SCRIPT="899201cab8d1f66140a7a428a34e6d62d87ae1f99294505f82f7bc9ac9a3d2a4"
EXPECTED_ADJ1_CONSOLE="9ee10d81d554c93275878f8669b37f4147a9337352966c16c37fb1e5ab568c08"

A2_SCRIPT="$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-r1.sh"
A2_CONSOLE="$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-r1-attempt-001-console.log"
A2_LOCK="$ROOT/.stage-a2-r1-execution-started"
ADJ1_SCRIPT="$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-r1-readonly-adjudication.sh"
ADJ1_CONSOLE="$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-r1-readonly-adjudication-console.log"

KEY_A="formal/proof/A"
KEY_B="formal/proof/B"
KEY_T="formal/transformation/A-to-B"

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

fail()
{
    echo
    echo "A2_FINAL_READ_ONLY_ADJUDICATION=FAIL"
    echo "REASON=$1"
    echo "A2_R1_RERUN=NO"
    echo "YODA_APPLICATION_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

section "0. FROZEN EVIDENCE CHAIN"

for f in "$YODA" "$STORE/data.yoda" "$A2_SCRIPT" "$A2_CONSOLE" "$A2_LOCK" "$ADJ1_SCRIPT" "$ADJ1_CONSOLE"
do
    test -f "$f" || fail "required frozen artifact missing: $f"
done

test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "Yoda identity mismatch"
test "$(sha "$STORE/data.yoda")" = "$EXPECTED_DATA_YODA" ||
    fail "data.yoda identity mismatch"
test "$(sha "$A2_SCRIPT")" = "$EXPECTED_A2_SCRIPT" ||
    fail "A2 one-shot script identity mismatch"
test "$(sha "$A2_CONSOLE")" = "$EXPECTED_A2_CONSOLE" ||
    fail "A2 one-shot console identity mismatch"
test "$(sha "$A2_LOCK")" = "$EXPECTED_A2_LOCK" ||
    fail "A2 execution lock identity mismatch"
test "$(sha "$ADJ1_SCRIPT")" = "$EXPECTED_ADJ1_SCRIPT" ||
    fail "first adjudication script identity mismatch"
test "$(sha "$ADJ1_CONSOLE")" = "$EXPECTED_ADJ1_CONSOLE" ||
    fail "first adjudication console identity mismatch"

DATA_BEFORE="$(sha "$STORE/data.yoda")"

echo "FROZEN_EVIDENCE_CHAIN=PASS"
echo "DATA_YODA_SHA256_BEFORE=$DATA_BEFORE"

rm -rf "$STAGE"
mkdir -p "$EVIDENCE"

section "1. YODA VERIFY"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-verify.txt" 2>&1 ||
    fail "Yoda verify failed"

echo "YODA_VERIFY=PASS"

section "2. AUTHORITATIVE RELATION LOG"

"$YODA" -d "$STORE" log "$KEY_B" > "$EVIDENCE/proof-B.log" ||
    fail "Proof B log failed"

grep -F $'derived-from\t'"$KEY_A" "$EVIDENCE/proof-B.log" >/dev/null ||
    fail "derived-from relation missing from authoritative log"

grep -F $'transformed-by\t'"$KEY_T" "$EVIDENCE/proof-B.log" >/dev/null ||
    fail "transformed-by relation missing from authoritative log"

echo "DERIVED_FROM_RELATION_LOG=PASS"
echo "TRANSFORMED_BY_RELATION_LOG=PASS"

section "3. SINGLE BOUNDED CONTEXT"

"$YODA" -d "$STORE" context --limit 64 --bytes 131072 "formal proof"     > "$EVIDENCE/context-formal-proof.txt" ||
    fail "bounded context query failed"

grep -F -- "--- $KEY_B ---" "$EVIDENCE/context-formal-proof.txt" >/dev/null ||
    fail "Proof B missing from bounded context"

grep -F "@link $KEY_B --derived-from--> $KEY_A"     "$EVIDENCE/context-formal-proof.txt" >/dev/null ||
    fail "derived-from relation missing from bounded context"

grep -F "@link $KEY_B --transformed-by--> $KEY_T"     "$EVIDENCE/context-formal-proof.txt" >/dev/null ||
    fail "transformed-by relation missing from bounded context"

echo "BOUNDED_CONTEXT_PROOF_B=PASS"
echo "BOUNDED_CONTEXT_DERIVED_FROM=PASS"
echo "BOUNDED_CONTEXT_TRANSFORMED_BY=PASS"
echo "FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS"

section "4. DURABLE STATE IMMUTABILITY"

DATA_AFTER="$(sha "$STORE/data.yoda")"

echo "DATA_YODA_SHA256_AFTER=$DATA_AFTER"

test "$DATA_AFTER" = "$DATA_BEFORE" ||
    fail "data.yoda changed during final read-only adjudication"

echo "DATA_YODA_IDENTITY_UNCHANGED=PASS"

section "5. FREEZE FINAL ADJUDICATION"

cp "$0" "$EVIDENCE/final-adjudication-script.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
A2_R1_ONE_SHOT	NOT_EVALUATED
A2_R1_FAILURE_CLASS	HARNESS_QUERY_TOKENIZATION_MISMATCH
A2_R1_RERUN	NO
DATA_YODA_SHA256	$DATA_AFTER
YODA_VERIFY	PASS
DERIVED_FROM_RELATION_LOG	PASS
TRANSFORMED_BY_RELATION_LOG	PASS
BOUNDED_CONTEXT_PROOF_B	PASS
BOUNDED_CONTEXT_DERIVED_FROM	PASS
BOUNDED_CONTEXT_TRANSFORMED_BY	PASS
FORMAL_LINEAGE_OF_CHANGE_CONTEXT	PASS
DATA_YODA_IDENTITY_UNCHANGED	PASS
A2_RESEARCH_QUESTION	PASS_BY_READ_ONLY_ADJUDICATION
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2	PASS_BY_READ_ONLY_ADJUDICATION
YODA_APPLICATION_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

(
    cd "$STAGE"
    find evidence         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || fail "final adjudication evidence integrity failed"

MANIFEST="$(sha "$EVIDENCE/SHA256SUMS")"

echo "FINAL_ADJUDICATION_EVIDENCE_INTEGRITY=PASS"
echo "FINAL_ADJUDICATION_EVIDENCE_MANIFEST_SHA256=$MANIFEST"

section "6. FINAL ADJUDICATION RESULT"

echo "A2_FINAL_READ_ONLY_ADJUDICATION=PASS"
echo "A2_R1_ONE_SHOT=NOT_EVALUATED"
echo "A2_R1_FAILURE_CLASS=HARNESS_QUERY_TOKENIZATION_MISMATCH"
echo "A2_R1_RERUN=NO"
echo "A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION"
echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=PASS_BY_READ_ONLY_ADJUDICATION"
echo "YODA_APPLICATION_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=STAGE_B_INDEPENDENT_FORMAL_REPLAY"
