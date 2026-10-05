#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
ROOT="$HOME/cmu/$CASE"
A1="$ROOT/stage-a1-r1"
A2="$ROOT/stage-a2"
STORE="$A2/yoda-store"
STAGE="$ROOT/stage-a2-r1-readonly-adjudication"
RECOVERED="$STAGE/recovered"
EVIDENCE="$STAGE/evidence"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"
EXPECTED_A1_MANIFEST="fad7416a7528d9d6ec885836668668d20c3cb942bc04b4f509949f92227c8bca"
EXPECTED_A2_SCRIPT="1568c92514e12be7ecb7bc57dd9e31a51fcb32240b75b21c3cfc003dfd191fbe"
EXPECTED_A2_CONSOLE="a8f3f499cdc89a58e613deb5c2f07f68eaea9278b05a75c0280dd6ebd088a6d7"
EXPECTED_A2_LOCK="c8ec9022ffd989fcc9dff818fbcc1268a03154c2a3267cbde40585f328f18241"
EXPECTED_DATA_YODA="5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba"

A2_SCRIPT="$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-r1.sh"
A2_CONSOLE="$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-r1-attempt-001-console.log"
A2_LOCK="$ROOT/.stage-a2-r1-execution-started"

KEY_STATEMENT="formal/statement/mathd-numbertheory-188"
KEY_A="formal/proof/A"
KEY_B="formal/proof/B"
KEY_T="formal/transformation/A-to-B"
KEY_LEAN_A="formal/evaluation/lean/A"
KEY_LEAN_B="formal/evaluation/lean/B"
KEY_OXI_A="formal/evaluation/oxilean/A"
KEY_OXI_B="formal/evaluation/oxilean/B"
KEY_A1_AUTH="evidence/formal-math/A1-R1"

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
    echo "A2_R1_READ_ONLY_ADJUDICATION=FAIL"
    echo "REASON=$1"
    echo "A2_R1_RERUN=NO"
    echo "YODA_APPLICATION_WRITES=ZERO"
    exit 1
}

section "0. FROZEN STATE AUTHORITY"

test -x "$YODA" || fail "Yoda binary missing"
test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "Yoda binary identity mismatch"

test -f "$A1/evidence/SHA256SUMS" ||
    fail "A1-R1 manifest missing"
test "$(sha "$A1/evidence/SHA256SUMS")" = "$EXPECTED_A1_MANIFEST" ||
    fail "A1-R1 manifest identity mismatch"

test -f "$A2_SCRIPT" || fail "executed A2-R1 script missing"
test -f "$A2_CONSOLE" || fail "A2-R1 console missing"
test -f "$A2_LOCK" || fail "A2-R1 one-execution lock missing"
test -f "$STORE/data.yoda" || fail "A2 data.yoda missing"

test "$(sha "$A2_SCRIPT")" = "$EXPECTED_A2_SCRIPT" ||
    fail "A2-R1 script identity mismatch"
test "$(sha "$A2_CONSOLE")" = "$EXPECTED_A2_CONSOLE" ||
    fail "A2-R1 console identity mismatch"
test "$(sha "$A2_LOCK")" = "$EXPECTED_A2_LOCK" ||
    fail "A2-R1 lock identity mismatch"

DATA_BEFORE="$(sha "$STORE/data.yoda")"
test "$DATA_BEFORE" = "$EXPECTED_DATA_YODA" ||
    fail "A2 durable-state identity mismatch before adjudication"

echo "A2_R1_FROZEN_STATE_AUTHORITY=PASS"
echo "DATA_YODA_SHA256_BEFORE=$DATA_BEFORE"

rm -rf "$STAGE"
mkdir -p "$RECOVERED" "$EVIDENCE"

section "1. VERIFY EXISTING YODA STATE"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-verify.txt" 2>&1 ||
    fail "Yoda verify failed"

echo "YODA_VERIFY=PASS"

section "2. BYTE-EXACT RECOVERY FROM EXISTING STORE"

"$YODA" -d "$STORE" get "$KEY_STATEMENT" > "$RECOVERED/statement.lean"
"$YODA" -d "$STORE" get "$KEY_A" > "$RECOVERED/proof-A.lean"
"$YODA" -d "$STORE" get "$KEY_B" > "$RECOVERED/proof-B.lean"
"$YODA" -d "$STORE" get "$KEY_T" > "$RECOVERED/transformation.txt"
"$YODA" -d "$STORE" get "$KEY_LEAN_A" > "$RECOVERED/lean-A.tsv"
"$YODA" -d "$STORE" get "$KEY_LEAN_B" > "$RECOVERED/lean-B.tsv"
"$YODA" -d "$STORE" get "$KEY_OXI_A" > "$RECOVERED/oxilean-A.json"
"$YODA" -d "$STORE" get "$KEY_OXI_B" > "$RECOVERED/oxilean-B.json"
"$YODA" -d "$STORE" get "$KEY_A1_AUTH" > "$RECOVERED/a1-r1-authority.sha256"

cmp -s "$A1/formal-project/FormalEvolutionR1/Statement.lean" "$RECOVERED/statement.lean" ||
    fail "statement recovery mismatch"
cmp -s "$A1/formal-project/FormalEvolutionR1/ProofA.lean" "$RECOVERED/proof-A.lean" ||
    fail "Proof A recovery mismatch"
cmp -s "$A1/formal-project/FormalEvolutionR1/ProofB.lean" "$RECOVERED/proof-B.lean" ||
    fail "Proof B recovery mismatch"
cmp -s "$A1/evidence/transformation-record.txt" "$RECOVERED/transformation.txt" ||
    fail "transformation recovery mismatch"
cmp -s "$A1/evidence/summary.tsv" "$RECOVERED/lean-A.tsv" ||
    fail "Lean A evidence recovery mismatch"
cmp -s "$A1/evidence/summary.tsv" "$RECOVERED/lean-B.tsv" ||
    fail "Lean B evidence recovery mismatch"
cmp -s "$A1/evidence/oxilean-A.json" "$RECOVERED/oxilean-A.json" ||
    fail "OxiLean A evidence recovery mismatch"
cmp -s "$A1/evidence/oxilean-B.json" "$RECOVERED/oxilean-B.json" ||
    fail "OxiLean B evidence recovery mismatch"
cmp -s "$A1/evidence/SHA256SUMS" "$RECOVERED/a1-r1-authority.sha256" ||
    fail "A1-R1 authority recovery mismatch"

echo "BYTE_EXACT_RECOVERY=PASS"

section "3. RELATION RECOVERY"

"$YODA" -d "$STORE" log "$KEY_B" > "$EVIDENCE/proof-B.log" ||
    fail "Proof B log recovery failed"

grep -F $'LINK\t' "$EVIDENCE/proof-B.log" >/dev/null ||
    fail "Proof B relation log empty"

grep -F $'derived-from\t'"$KEY_A" "$EVIDENCE/proof-B.log" >/dev/null ||
    fail "derived-from relation not recoverable"

grep -F $'transformed-by\t'"$KEY_T" "$EVIDENCE/proof-B.log" >/dev/null ||
    fail "transformed-by relation not recoverable"

echo "DERIVED_FROM_RELATION_RECOVERY=PASS"
echo "TRANSFORMED_BY_RELATION_RECOVERY=PASS"

section "4. CORRECTED CONTEXT AUDIT"

"$YODA" -d "$STORE" context --limit 64 --bytes 131072 "kernel_computation_rfl"     > "$EVIDENCE/context-A.txt" ||
    fail "Proof A context failed"

"$YODA" -d "$STORE" context --limit 64 --bytes 131072 "explicit_euclidean_gcd_derivation"     > "$EVIDENCE/context-B.txt" ||
    fail "Proof B context failed"

"$YODA" -d "$STORE" context --limit 64 --bytes 131072 "kernel_computation_to_explicit_euclidean_derivation"     > "$EVIDENCE/context-T.txt" ||
    fail "transformation context failed"

"$YODA" -d "$STORE" context --limit 64 --bytes 131072 "oxilean proofa"     > "$EVIDENCE/context-oxilean-A-corrected.txt" ||
    fail "corrected OxiLean A context failed"

"$YODA" -d "$STORE" context --limit 64 --bytes 131072 "oxilean proofb"     > "$EVIDENCE/context-oxilean-B-corrected.txt" ||
    fail "corrected OxiLean B context failed"

cat "$EVIDENCE"/context-*.txt > "$EVIDENCE/context-composed.txt"

for key in "$KEY_STATEMENT" "$KEY_A" "$KEY_B" "$KEY_T"
do
    grep -F "$key" "$EVIDENCE/context-composed.txt" >/dev/null ||
        fail "derivation core context missing $key"
done

grep -F "@link $KEY_B --derived-from--> $KEY_A" "$EVIDENCE/context-composed.txt" >/dev/null ||
    fail "derived-from relation missing from corrected context"

grep -F "@link $KEY_B --transformed-by--> $KEY_T" "$EVIDENCE/context-composed.txt" >/dev/null ||
    fail "transformed-by relation missing from corrected context"

echo "CORRECTED_CONTEXT_QUERY=PASS"
echo "FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS"

section "5. DURABLE STATE IMMUTABILITY"

DATA_AFTER="$(sha "$STORE/data.yoda")"

echo "DATA_YODA_SHA256_AFTER=$DATA_AFTER"

test "$DATA_AFTER" = "$DATA_BEFORE" ||
    fail "data.yoda changed during read-only adjudication"

echo "DATA_YODA_IDENTITY_UNCHANGED=PASS"

section "6. FREEZE ADJUDICATION EVIDENCE"

cp "$0" "$EVIDENCE/adjudication-script.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
A2_R1_EXECUTION	NOT_EVALUATED
FAILURE_CLASS	HARNESS_QUERY_TOKENIZATION_MISMATCH
A1_R1_EVIDENCE_MANIFEST_SHA256	$EXPECTED_A1_MANIFEST
A2_R1_SCRIPT_SHA256	$EXPECTED_A2_SCRIPT
A2_R1_CONSOLE_SHA256	$EXPECTED_A2_CONSOLE
A2_R1_EXECUTION_LOCK_SHA256	$EXPECTED_A2_LOCK
DATA_YODA_SHA256	$DATA_AFTER
YODA_VERIFY	PASS
BYTE_EXACT_RECOVERY	PASS
DERIVED_FROM_RELATION_RECOVERY	PASS
TRANSFORMED_BY_RELATION_RECOVERY	PASS
CORRECTED_CONTEXT_QUERY	PASS
FORMAL_LINEAGE_OF_CHANGE_CONTEXT	PASS
DATA_YODA_IDENTITY_UNCHANGED	PASS
A2_R1_RERUN	NO
YODA_APPLICATION_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

(
    cd "$STAGE"
    find evidence recovered         -type f         ! -name SHA256SUMS         ! -name SHA256SUMS.check         -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || fail "adjudication evidence integrity failed"

AUDIT_MANIFEST="$(sha "$EVIDENCE/SHA256SUMS")"

echo "ADJUDICATION_EVIDENCE_INTEGRITY=PASS"
echo "ADJUDICATION_EVIDENCE_MANIFEST_SHA256=$AUDIT_MANIFEST"

section "7. ADJUDICATION RESULT"

echo "A2_R1_READ_ONLY_ADJUDICATION=PASS"
echo "A2_R1_RERUN=NO"
echo "YODA_APPLICATION_WRITES=ZERO"
echo "DATA_YODA_IDENTITY_UNCHANGED=PASS"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
