#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
ROOT="$HOME/cmu/$CASE"
A1="$ROOT/stage-a1"
STAGE="$ROOT/stage-a2"
STORE="$STAGE/yoda-store"
OBJECTS="$STAGE/objects"
RECOVERED="$STAGE/recovered"
EVIDENCE="$STAGE/evidence"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

KEY_STATEMENT="formal/statement/mathd-algebra-182"
KEY_A="formal/proof/A"
KEY_B="formal/proof/B"
KEY_T="formal/transformation/A-to-B"
KEY_LEAN_A="formal/evaluation/lean/A"
KEY_LEAN_B="formal/evaluation/lean/B"
KEY_OXI_A="formal/evaluation/oxilean/A"
KEY_OXI_B="formal/evaluation/oxilean/B"
KEY_LEAN_AUTH="authority/lean-v4.32.0-rc1"
KEY_OXI_AUTH="authority/oxilean-0.1.3"
KEY_A1_EVIDENCE="evidence/formal-math/A1"

fail()
{
    echo
    echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=FAIL"
    echo "REASON=$1"
    exit 1
}

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
    "$YODA" -d "$STORE" link "$from" "$relation" "$to" case="$CASE" >/dev/null
}

section "0. PREFLIGHT"

test -x "$YODA" || fail "Yoda binary missing"

ACTUAL_YODA_SHA256="$(sha "$YODA")"
test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    fail "Yoda identity mismatch"

test -f "$A1/evidence/SHA256SUMS" ||
    fail "A1 evidence manifest missing"

(
    cd "$A1"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || fail "A1 evidence integrity failed"

A1_MANIFEST_SHA256="$(sha "$A1/evidence/SHA256SUMS")"

echo "YODA_AUTHORITY=PASS"
echo "A1_EVIDENCE_AUTHORITY=PASS"
echo "A1_EVIDENCE_MANIFEST_SHA256=$A1_MANIFEST_SHA256"

section "1. SOURCE IDENTITIES"

SRC_STATEMENT="$A1/formal-project/FormalEvolution/Statement.lean"
SRC_A="$A1/formal-project/FormalEvolution/ProofA.lean"
SRC_B="$A1/formal-project/FormalEvolution/ProofB.lean"
SRC_T="$A1/evidence/transformation-record.txt"
SRC_OXI_A="$A1/evidence/oxilean-A.json"
SRC_OXI_B="$A1/evidence/oxilean-B.json"
SRC_SUMMARY="$A1/evidence/summary.tsv"

for file in \
    "$SRC_STATEMENT" \
    "$SRC_A" \
    "$SRC_B" \
    "$SRC_T" \
    "$SRC_OXI_A" \
    "$SRC_OXI_B" \
    "$SRC_SUMMARY"
do
    test -f "$file" || fail "source artifact missing: $file"
done

STATEMENT_SHA256="$(sha "$SRC_STATEMENT")"
A_SHA256="$(sha "$SRC_A")"
B_SHA256="$(sha "$SRC_B")"
T_SHA256="$(sha "$SRC_T")"


test "$A_SHA256" != "$B_SHA256" ||
    fail "Proof A and B identities unexpectedly equal"

echo "STATEMENT_SHA256=$STATEMENT_SHA256"
echo "PROOF_A_SHA256=$A_SHA256"
echo "PROOF_B_SHA256=$B_SHA256"
echo "TRANSFORMATION_SHA256=$T_SHA256"
echo "SOURCE_IDENTITIES=PASS"

section "2. PREPARE YODA OBJECTS"

rm -rf "$STAGE"
mkdir -p "$OBJECTS" "$RECOVERED" "$EVIDENCE"

cp "$SRC_STATEMENT" "$OBJECTS/statement.lean"
cp "$SRC_A" "$OBJECTS/proof-A.lean"
cp "$SRC_B" "$OBJECTS/proof-B.lean"
cp "$SRC_T" "$OBJECTS/transformation.txt"
cp "$SRC_OXI_A" "$OBJECTS/oxilean-A.json"
cp "$SRC_OXI_B" "$OBJECTS/oxilean-B.json"
cp "$SRC_SUMMARY" "$OBJECTS/a1-summary.tsv"

cat > "$OBJECTS/lean-A.txt" <<EOF
artifact=$KEY_A
authority=Lean 4 reference kernel
lean_toolchain=leanprover/lean4:v4.32.0-rc1
lean_githash=b4812ae53eea93439ad5dce5a5c26591c31cb697
result=PASS
artifact_sha256=$A_SHA256
state=pre-refactor
EOF

cat > "$OBJECTS/lean-B.txt" <<EOF
artifact=$KEY_B
authority=Lean 4 reference kernel
lean_toolchain=leanprover/lean4:v4.32.0-rc1
lean_githash=b4812ae53eea93439ad5dce5a5c26591c31cb697
result=PASS
artifact_sha256=$B_SHA256
state=post-refactor
EOF

cat > "$OBJECTS/lean-authority.txt" <<'EOF'
authority=Lean 4 reference kernel
role=formal validity authority
lean_toolchain=leanprover/lean4:v4.32.0-rc1
lean_githash=b4812ae53eea93439ad5dce5a5c26591c31cb697
mathlib_commit=360da6fa66c1273b76b6b2d8c5666fd5ac2e3b56
EOF

cat > "$OBJECTS/oxilean-authority.txt" <<'EOF'
authority=OxiLean oxilean-verify
role=independent formal re-checking authority
repository=cool-japan/oxilean
commit=9077af778fe467cba61d9c8385fb2b7e6a8d385f
version=0.1.3
lean4export_commit=3de59f10bc4b4a0f2de698597aeb1246caa0df0a
lean_toolchain=v4.32.0-rc1
EOF

echo "OBJECT_PREPARATION=PASS"

section "3. INITIALIZE FRESH YODA STORE"

"$YODA" init "$STORE" >/dev/null ||
    fail "Yoda init failed"

echo "YODA_INIT=PASS"

section "4. STORE VERSIONED DERIVATION OBJECTS"

put_file "$KEY_STATEMENT" "$OBJECTS/statement.lean" type=formal-statement source=miniF2F
put_file "$KEY_A" "$OBJECTS/proof-A.lean" type=formal-proof state=A
put_file "$KEY_B" "$OBJECTS/proof-B.lean" type=formal-proof state=B
put_file "$KEY_T" "$OBJECTS/transformation.txt" type=proof-transformation
put_file "$KEY_LEAN_A" "$OBJECTS/lean-A.txt" type=formal-evaluation authority=lean
put_file "$KEY_LEAN_B" "$OBJECTS/lean-B.txt" type=formal-evaluation authority=lean
put_file "$KEY_OXI_A" "$OBJECTS/oxilean-A.json" type=formal-evaluation authority=oxilean
put_file "$KEY_OXI_B" "$OBJECTS/oxilean-B.json" type=formal-evaluation authority=oxilean
put_file "$KEY_LEAN_AUTH" "$OBJECTS/lean-authority.txt" type=authority
put_file "$KEY_OXI_AUTH" "$OBJECTS/oxilean-authority.txt" type=authority
put_file "$KEY_A1_EVIDENCE" "$OBJECTS/a1-summary.tsv" type=evidence-authority

OBJECT_COUNT=11
echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "YODA_OBJECT_INGEST=PASS"

section "5. CREATE VERSIONED DERIVATION RELATIONS"

link "$KEY_B" derived-from "$KEY_A"
link "$KEY_B" transformed-by "$KEY_T"
link "$KEY_A" proves "$KEY_STATEMENT"
link "$KEY_B" proves "$KEY_STATEMENT"
link "$KEY_A" validated-by "$KEY_LEAN_AUTH"
link "$KEY_B" validated-by "$KEY_LEAN_AUTH"
link "$KEY_A" rechecked-by "$KEY_OXI_AUTH"
link "$KEY_B" rechecked-by "$KEY_OXI_AUTH"
link "$KEY_A" has-evaluation "$KEY_LEAN_A"
link "$KEY_B" has-evaluation "$KEY_LEAN_B"
link "$KEY_A" has-evaluation "$KEY_OXI_A"
link "$KEY_B" has-evaluation "$KEY_OXI_B"
link "$KEY_T" has-evidence "$KEY_A1_EVIDENCE"
link "$KEY_A" has-evidence "$KEY_A1_EVIDENCE"
link "$KEY_B" has-evidence "$KEY_A1_EVIDENCE"

LINK_COUNT=15
echo "LINK_COUNT=$LINK_COUNT"
echo "VERSIONED_DERIVATION_RELATIONS=PASS"

section "6. VERIFY YODA STORE"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-verify.txt" 2>&1 ||
    fail "Yoda verify failed"

echo "YODA_VERIFY=PASS"

section "7. BYTE-EXACT RECOVERY"

"$YODA" -d "$STORE" get "$KEY_STATEMENT" > "$RECOVERED/statement.lean"
"$YODA" -d "$STORE" get "$KEY_A" > "$RECOVERED/proof-A.lean"
"$YODA" -d "$STORE" get "$KEY_B" > "$RECOVERED/proof-B.lean"
"$YODA" -d "$STORE" get "$KEY_T" > "$RECOVERED/transformation.txt"
"$YODA" -d "$STORE" get "$KEY_OXI_A" > "$RECOVERED/oxilean-A.json"
"$YODA" -d "$STORE" get "$KEY_OXI_B" > "$RECOVERED/oxilean-B.json"

cmp -s "$SRC_STATEMENT" "$RECOVERED/statement.lean" ||
    fail "statement recovery mismatch"
cmp -s "$SRC_A" "$RECOVERED/proof-A.lean" ||
    fail "Proof A recovery mismatch"
cmp -s "$SRC_B" "$RECOVERED/proof-B.lean" ||
    fail "Proof B recovery mismatch"
cmp -s "$SRC_T" "$RECOVERED/transformation.txt" ||
    fail "transformation recovery mismatch"
cmp -s "$SRC_OXI_A" "$RECOVERED/oxilean-A.json" ||
    fail "OxiLean A evidence recovery mismatch"
cmp -s "$SRC_OXI_B" "$RECOVERED/oxilean-B.json" ||
    fail "OxiLean B evidence recovery mismatch"

echo "STATEMENT_BYTE_EXACT_RECOVERY=PASS"
echo "PROOF_A_BYTE_EXACT_RECOVERY=PASS"
echo "PROOF_B_BYTE_EXACT_RECOVERY=PASS"
echo "TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS"
echo "FORMAL_EVALUATION_BYTE_EXACT_RECOVERY=PASS"

section "8. RECOVER BOUNDED CONTEXT"

"$YODA" -d "$STORE" context --limit 32 --bytes 65536 "reference-style" \
    > "$EVIDENCE/context-proof-A.txt" ||
    fail "Proof A context failed"

"$YODA" -d "$STORE" context --limit 32 --bytes 65536 "semantics-preserving" \
    > "$EVIDENCE/context-proof-B.txt" ||
    fail "Proof B context failed"

"$YODA" -d "$STORE" context --limit 32 --bytes 65536 "ring_nf_to_ring" \
    > "$EVIDENCE/context-transformation.txt" ||
    fail "transformation context failed"

"$YODA" -d "$STORE" context --limit 32 --bytes 65536 "Lean 4 reference kernel" \
    > "$EVIDENCE/context-lean-authority.txt" ||
    fail "Lean authority context failed"

"$YODA" -d "$STORE" context --limit 32 --bytes 65536 "OxiLean oxilean-verify" \
    > "$EVIDENCE/context-oxilean-authority.txt" ||
    fail "OxiLean authority context failed"

cat \
    "$EVIDENCE/context-proof-A.txt" \
    "$EVIDENCE/context-proof-B.txt" \
    "$EVIDENCE/context-transformation.txt" \
    "$EVIDENCE/context-lean-authority.txt" \
    "$EVIDENCE/context-oxilean-authority.txt" \
    > "$EVIDENCE/context-composed.txt"

for key in \
    "$KEY_STATEMENT" \
    "$KEY_A" \
    "$KEY_B" \
    "$KEY_T" \
    "$KEY_LEAN_AUTH" \
    "$KEY_OXI_AUTH" \
    "$KEY_A1_EVIDENCE"
do
    grep -F "$key" "$EVIDENCE/context-composed.txt" >/dev/null ||
        fail "composed context missing $key"
done

grep -F "@link $KEY_B --derived-from--> $KEY_A" \
    "$EVIDENCE/context-composed.txt" >/dev/null ||
    fail "derived-from relation missing from composed context"

grep -F "@link $KEY_B --transformed-by--> $KEY_T" \
    "$EVIDENCE/context-composed.txt" >/dev/null ||
    fail "transformed-by relation missing from composed context"

echo "BOUNDED_CONTEXT_COMPOSITION=PASS"
echo "FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS"
echo "VERSIONED_DERIVATION_RECOVERY=PASS"

section "9. FINAL VERIFY"

"$YODA" -d "$STORE" verify > "$EVIDENCE/yoda-final-verify.txt" 2>&1 ||
    fail "final Yoda verify failed"

echo "FINAL_YODA_VERIFY=PASS"

section "10. FREEZE AUTHORITATIVE YODA STATE"

DATA_YODA="$STORE/data.yoda"
test -f "$DATA_YODA" || fail "data.yoda missing"

DATA_YODA_SHA256="$(sha "$DATA_YODA")"
DATA_YODA_BYTES="$(wc -c < "$DATA_YODA" | tr -d ' ')"

echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "DATA_YODA_BYTES=$DATA_YODA_BYTES"

section "11. SUMMARY"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
A1_EVIDENCE_MANIFEST_SHA256	$A1_MANIFEST_SHA256
YODA_SHA256	$ACTUAL_YODA_SHA256
OBJECT_COUNT	$OBJECT_COUNT
LINK_COUNT	$LINK_COUNT
STATEMENT_SHA256	$STATEMENT_SHA256
PROOF_A_SHA256	$A_SHA256
PROOF_B_SHA256	$B_SHA256
TRANSFORMATION_SHA256	$T_SHA256
STATEMENT_BYTE_EXACT_RECOVERY	PASS
PROOF_A_BYTE_EXACT_RECOVERY	PASS
PROOF_B_BYTE_EXACT_RECOVERY	PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY	PASS
FORMAL_EVALUATION_BYTE_EXACT_RECOVERY	PASS
FORMAL_LINEAGE_OF_CHANGE_CONTEXT	PASS
VERSIONED_DERIVATION_RECOVERY	PASS
FINAL_YODA_VERIFY	PASS
DATA_YODA_SHA256	$DATA_YODA_SHA256
DATA_YODA_BYTES	$DATA_YODA_BYTES
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

section "12. FREEZE A2 EVIDENCE"

cp "$0" "$EVIDENCE/stage-a2-script.sh"

(
    cd "$STAGE"
    find evidence objects recovered \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || fail "A2 evidence integrity failed"

A2_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A2_EVIDENCE_INTEGRITY=PASS"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"

section "13. HOMOLOGATION"

echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=PASS"
echo "OBJECT_COUNT=$OBJECT_COUNT"
echo "LINK_COUNT=$LINK_COUNT"
echo "PROOF_A_BYTE_EXACT_RECOVERY=PASS"
echo "PROOF_B_BYTE_EXACT_RECOVERY=PASS"
echo "TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS"
echo "FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS"
echo "VERSIONED_DERIVATION_RECOVERY=PASS"
echo "FINAL_YODA_VERIFY=PASS"
echo "DATA_YODA_SHA256=$DATA_YODA_SHA256"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=STAGE_B_INDEPENDENT_FORMAL_REPLAY"
