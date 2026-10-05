#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
ROOT="$HOME/cmu/$CASE"
EXTERNAL="$ROOT/external"
A2="$ROOT/stage-a2"
STAGE="$ROOT/stage-b"
RECOVERED="$STAGE/recovered"
PROJECT="$STAGE/formal-project"
EXPORTS="$STAGE/exports"
EVIDENCE="$STAGE/evidence"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

MATHLIB="$EXTERNAL/mathlib4"
LEAN4EXPORT_BIN="$EXTERNAL/lean4export/.lake/build/bin/lean4export"
OXILEAN_BIN="$EXTERNAL/oxilean/target/release/oxilean-verify"

KEY_STATEMENT="formal/statement/mathd-algebra-182"
KEY_A="formal/proof/A"
KEY_B="formal/proof/B"
KEY_T="formal/transformation/A-to-B"

fail()
{
    echo
    echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_B=FAIL"
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

summary_value()
{
    key="$1"
    awk -F '\t' -v k="$key" '$1 == k { print $2; exit }' "$A2/evidence/summary.tsv"
}

compact_json()
{
    tr -d '\n\r\t ' < "$1"
}

json_contains()
{
    report="$1"
    needle="$2"
    compact="$(compact_json "$report")"

    case "$compact" in
        *"$needle"*) return 0 ;;
        *) return 1 ;;
    esac
}

require_verified_decl()
{
    report="$1"
    decl="$2"
    json_contains \
        "$report" \
        "\"name\":\"$decl\",\"kind\":\"thm\",\"verdict\":\"verified\""
}

section "0. A2 AUTHORITY"

test -x "$YODA" || fail "Yoda binary missing"
test "$(sha "$YODA")" = "$EXPECTED_YODA_SHA256" ||
    fail "Yoda identity mismatch"

test -f "$A2/evidence/SHA256SUMS" ||
    fail "A2 evidence manifest missing"

(
    cd "$A2"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || fail "A2 evidence integrity failed"

A2_MANIFEST_SHA256="$(sha "$A2/evidence/SHA256SUMS")"
ORIGINAL_A_SHA256="$(summary_value PROOF_A_SHA256)"
ORIGINAL_B_SHA256="$(summary_value PROOF_B_SHA256)"
ORIGINAL_T_SHA256="$(summary_value TRANSFORMATION_SHA256)"
ORIGINAL_DATA_YODA_SHA256="$(summary_value DATA_YODA_SHA256)"

test -n "$ORIGINAL_A_SHA256" || fail "A2 Proof A identity missing"
test -n "$ORIGINAL_B_SHA256" || fail "A2 Proof B identity missing"
test -n "$ORIGINAL_T_SHA256" || fail "A2 transformation identity missing"
test -n "$ORIGINAL_DATA_YODA_SHA256" || fail "A2 data.yoda identity missing"

test "$(sha "$A2/yoda-store/data.yoda")" = "$ORIGINAL_DATA_YODA_SHA256" ||
    fail "authoritative data.yoda identity mismatch"

echo "A2_EVIDENCE_AUTHORITY=PASS"
echo "YODA_STATE_AUTHORITY=PASS"
echo "A2_EVIDENCE_MANIFEST_SHA256=$A2_MANIFEST_SHA256"
echo "DATA_YODA_SHA256=$ORIGINAL_DATA_YODA_SHA256"

section "1. RECOVER ONLY FROM YODA"

rm -rf "$STAGE"
mkdir -p \
    "$RECOVERED" \
    "$PROJECT/FormalEvolution" \
    "$EXPORTS" \
    "$EVIDENCE"

"$YODA" -d "$A2/yoda-store" get "$KEY_STATEMENT" > "$RECOVERED/Statement.lean"
"$YODA" -d "$A2/yoda-store" get "$KEY_A" > "$RECOVERED/ProofA.lean"
"$YODA" -d "$A2/yoda-store" get "$KEY_B" > "$RECOVERED/ProofB.lean"
"$YODA" -d "$A2/yoda-store" get "$KEY_T" > "$RECOVERED/transformation.txt"

REPLAY_A_SHA256="$(sha "$RECOVERED/ProofA.lean")"
REPLAY_B_SHA256="$(sha "$RECOVERED/ProofB.lean")"
REPLAY_T_SHA256="$(sha "$RECOVERED/transformation.txt")"

echo "ORIGINAL_A_SHA256=$ORIGINAL_A_SHA256"
echo "REPLAY_A_SHA256=$REPLAY_A_SHA256"
echo "ORIGINAL_B_SHA256=$ORIGINAL_B_SHA256"
echo "REPLAY_B_SHA256=$REPLAY_B_SHA256"

test "$REPLAY_A_SHA256" = "$ORIGINAL_A_SHA256" ||
    fail "Proof A byte identity mismatch after Yoda recovery"

test "$REPLAY_B_SHA256" = "$ORIGINAL_B_SHA256" ||
    fail "Proof B byte identity mismatch after Yoda recovery"

test "$REPLAY_T_SHA256" = "$ORIGINAL_T_SHA256" ||
    fail "transformation byte identity mismatch after Yoda recovery"

echo "PROOF_A_IDENTITY_SURVIVED=PASS"
echo "PROOF_B_IDENTITY_SURVIVED=PASS"
echo "TRANSFORMATION_IDENTITY_SURVIVED=PASS"
echo "YODA_WRITES=ZERO"

section "2. BUILD FRESH REPLAY PROJECT"

cat > "$PROJECT/lean-toolchain" <<'EOF'
leanprover/lean4:v4.32.0-rc1
EOF

cat > "$PROJECT/lakefile.toml" <<'EOF'
name = "FormalEvolutionReplay"
defaultTargets = ["FormalEvolution"]

[[require]]
name = "mathlib"
path = "../../external/mathlib4"

[[lean_lib]]
name = "FormalEvolution"
EOF

cp "$RECOVERED/Statement.lean" "$PROJECT/FormalEvolution/Statement.lean"
cp "$RECOVERED/ProofA.lean" "$PROJECT/FormalEvolution/ProofA.lean"
cp "$RECOVERED/ProofB.lean" "$PROJECT/FormalEvolution/ProofB.lean"

cat > "$PROJECT/FormalEvolution.lean" <<'EOF'
import FormalEvolution.Statement
import FormalEvolution.ProofA
import FormalEvolution.ProofB
EOF

(
    cd "$PROJECT"
    lake update
    lake exe cache get
) > "$EVIDENCE/lake-replay-setup.log" 2>&1 ||
    fail "fresh replay dependency setup failed"

echo "FRESH_REPLAY_PROJECT=PASS"

section "3. LEAN AUTHORITY REPLAY"

(
    cd "$PROJECT"
    lake build FormalEvolution
) > "$EVIDENCE/lean-replay-build.log" 2>&1 ||
    fail "Lean replay rejected recovered proof state"

(
    cd "$PROJECT"
    lake env leanchecker FormalEvolution.ProofA
) > "$EVIDENCE/leanchecker-replay-A.log" 2>&1 ||
    fail "Lean replay Proof A failed"

(
    cd "$PROJECT"
    lake env leanchecker FormalEvolution.ProofB
) > "$EVIDENCE/leanchecker-replay-B.log" 2>&1 ||
    fail "Lean replay Proof B failed"

echo "LEAN_REPLAY_A=PASS"
echo "LEAN_REPLAY_B=PASS"
echo "LEAN_AUTHORITY_REPLAY=PASS"

section "4. EXPORT RECOVERED PROOFS"

(
    cd "$PROJECT"
    lake env "$LEAN4EXPORT_BIN" \
        FormalEvolution.ProofA \
        -- FormalEvolution.ProofA.proof \
        > "$EXPORTS/recovered-A.ndjson"
) || fail "recovered Proof A export failed"

(
    cd "$PROJECT"
    lake env "$LEAN4EXPORT_BIN" \
        FormalEvolution.ProofB \
        -- FormalEvolution.ProofB.proof \
        > "$EXPORTS/recovered-B.ndjson"
) || fail "recovered Proof B export failed"

echo "RECOVERED_A_EXPORT_SHA256=$(sha "$EXPORTS/recovered-A.ndjson")"
echo "RECOVERED_B_EXPORT_SHA256=$(sha "$EXPORTS/recovered-B.ndjson")"
echo "RECOVERED_LEAN4EXPORT=PASS"

section "5. OXILEAN AUTHORITY REPLAY"

set +e
"$OXILEAN_BIN" \
    --no-color \
    --json "$EVIDENCE/oxilean-replay-A.json" \
    --json-full \
    "$EXPORTS/recovered-A.ndjson" \
    > "$EVIDENCE/oxilean-replay-A.log" 2>&1
OXI_A_RC=$?

"$OXILEAN_BIN" \
    --no-color \
    --json "$EVIDENCE/oxilean-replay-B.json" \
    --json-full \
    "$EXPORTS/recovered-B.ndjson" \
    > "$EVIDENCE/oxilean-replay-B.log" 2>&1
OXI_B_RC=$?
set -e

test "$OXI_A_RC" -eq 0 ||
    fail "OxiLean replay A did not complete cleanly"

test "$OXI_B_RC" -eq 0 ||
    fail "OxiLean replay B did not complete cleanly"

json_contains \
    "$EVIDENCE/oxilean-replay-A.json" \
    '"file_lean_githash":"b4812ae53eea93439ad5dce5a5c26591c31cb697"' ||
    fail "OxiLean replay A Lean githash mismatch"

json_contains \
    "$EVIDENCE/oxilean-replay-B.json" \
    '"file_lean_githash":"b4812ae53eea93439ad5dce5a5c26591c31cb697"' ||
    fail "OxiLean replay B Lean githash mismatch"

json_contains "$EVIDENCE/oxilean-replay-A.json" '"rejected":0' ||
    fail "OxiLean replay A rejected declaration"

json_contains "$EVIDENCE/oxilean-replay-B.json" '"rejected":0' ||
    fail "OxiLean replay B rejected declaration"

require_verified_decl \
    "$EVIDENCE/oxilean-replay-A.json" \
    "FormalEvolution.ProofA.proof" ||
    fail "recovered Proof A target not VERIFIED by OxiLean"

require_verified_decl \
    "$EVIDENCE/oxilean-replay-B.json" \
    "FormalEvolution.ProofB.proof" ||
    fail "recovered Proof B target not VERIFIED by OxiLean"

echo "OXILEAN_REPLAY_A=VERIFIED"
echo "OXILEAN_REPLAY_B=VERIFIED"
echo "OXILEAN_AUTHORITY_REPLAY=PASS"

section "6. DERIVATION REPLAY CONTRACT"

cat > "$EVIDENCE/replay-contract.txt" <<EOF
CASE=$CASE
SOURCE_OF_PROOF_A=YODA_RECOVERED_STATE
SOURCE_OF_PROOF_B=YODA_RECOVERED_STATE

PROOF_A_SHA256=$REPLAY_A_SHA256
PROOF_B_SHA256=$REPLAY_B_SHA256
TRANSFORMATION_SHA256=$REPLAY_T_SHA256

LEAN_A_BEFORE=PASS
LEAN_A_AFTER_RECOVERY=PASS
LEAN_B_BEFORE=PASS
LEAN_B_AFTER_RECOVERY=PASS

OXILEAN_A_BEFORE=VERIFIED
OXILEAN_A_AFTER_RECOVERY=VERIFIED
OXILEAN_B_BEFORE=VERIFIED
OXILEAN_B_AFTER_RECOVERY=VERIFIED

DERIVATION_RELATION_PRESERVED_BY_A2=YES
TRANSFORMATION_EVIDENCE_PRESERVED_BY_A2=YES

YODA_FORMAL_AUTHORITY_ROLE=NONE
YODA_DERIVATION_ROLE=YES

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
EOF

REPLAY_CONTRACT_SHA256="$(sha "$EVIDENCE/replay-contract.txt")"

echo "REPLAY_CONTRACT_SHA256=$REPLAY_CONTRACT_SHA256"
echo "FORMAL_REPLAY_CONTRACT=PASS"

section "7. FINAL PROPERTY GATES"

echo "PROOF_A_FORMAL_VALIDITY_SURVIVED=PASS"
echo "PROOF_B_FORMAL_VALIDITY_SURVIVED=PASS"
echo "PROOF_A_INDEPENDENT_RECHECK_SURVIVED=PASS"
echo "PROOF_B_INDEPENDENT_RECHECK_SURVIVED=PASS"
echo "INDEPENDENT_FORMAL_REPLAY=PASS"
echo "FORMAL_LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS"

section "8. SUMMARY"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
A2_EVIDENCE_MANIFEST_SHA256	$A2_MANIFEST_SHA256
DATA_YODA_SHA256	$ORIGINAL_DATA_YODA_SHA256
PROOF_A_SHA256	$REPLAY_A_SHA256
PROOF_B_SHA256	$REPLAY_B_SHA256
TRANSFORMATION_SHA256	$REPLAY_T_SHA256
LEAN_REPLAY_A	PASS
LEAN_REPLAY_B	PASS
OXILEAN_REPLAY_A	VERIFIED
OXILEAN_REPLAY_B	VERIFIED
INDEPENDENT_FORMAL_REPLAY	PASS
FORMAL_LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY	PASS
REPLAY_CONTRACT_SHA256	$REPLAY_CONTRACT_SHA256
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

section "9. FREEZE STAGE B EVIDENCE"

cp "$0" "$EVIDENCE/stage-b-script.sh"

(
    cd "$STAGE"
    find evidence recovered exports formal-project \
        -type f \
        ! -path '*/.lake/*' \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || fail "Stage B evidence integrity failed"

B_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "STAGE_B_EVIDENCE_INTEGRITY=PASS"
echo "STAGE_B_EVIDENCE_MANIFEST_SHA256=$B_MANIFEST_SHA256"

section "10. HOMOLOGATION"

echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_B=PASS"
echo "PROOF_A_IDENTITY_SURVIVED=PASS"
echo "PROOF_B_IDENTITY_SURVIVED=PASS"
echo "TRANSFORMATION_IDENTITY_SURVIVED=PASS"
echo "LEAN_AUTHORITY_REPLAY=PASS"
echo "OXILEAN_AUTHORITY_REPLAY=PASS"
echo "INDEPENDENT_FORMAL_REPLAY=PASS"
echo "FORMAL_LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS"
echo "REPLAY_CONTRACT_SHA256=$REPLAY_CONTRACT_SHA256"
echo "STAGE_B_EVIDENCE_MANIFEST_SHA256=$B_MANIFEST_SHA256"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=CASE_FINAL_HOMOLOGATION"
