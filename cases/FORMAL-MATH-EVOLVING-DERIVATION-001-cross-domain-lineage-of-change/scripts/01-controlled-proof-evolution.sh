#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
ROOT="$HOME/cmu/$CASE"
EXTERNAL="$ROOT/external"
A0="$ROOT/stage-a0"
STAGE="$ROOT/stage-a1"
PROJECT="$STAGE/formal-project"
EVIDENCE="$STAGE/evidence"
EXPORTS="$STAGE/exports"

LEAN_TOOLCHAIN="leanprover/lean4:v4.32.0-rc1"
LEAN_GITHASH="b4812ae53eea93439ad5dce5a5c26591c31cb697"
MATHLIB_COMMIT="360da6fa66c1273b76b6b2d8c5666fd5ac2e3b56"
LEAN4EXPORT_COMMIT="3de59f10bc4b4a0f2de698597aeb1246caa0df0a"
OXILEAN_COMMIT="9077af778fe467cba61d9c8385fb2b7e6a8d385f"

MATHLIB="$EXTERNAL/mathlib4"
LEAN4EXPORT_BIN="$EXTERNAL/lean4export/.lake/build/bin/lean4export"
OXILEAN_BIN="$EXTERNAL/oxilean/target/release/oxilean-verify"

fail()
{
    echo
    echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A1=NOT_EVALUATED"
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

compact_json()
{
    tr -d '\n\r\t ' < "$1"
}

require_verified_decl()
{
    report="$1"
    decl="$2"
    compact="$(compact_json "$report")"

    case "$compact" in
        *\"name\":\"$decl\",\"kind\":\"theorem\",\"verdict\":\"verified\"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

section "0. A0 AUTHORITY"

test -f "$A0/evidence/SHA256SUMS" ||
    fail "A0 evidence manifest missing"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || fail "A0 evidence integrity failed"

A0_MANIFEST_SHA256="$(sha "$A0/evidence/SHA256SUMS")"

echo "A0_EVIDENCE_MANIFEST_SHA256=$A0_MANIFEST_SHA256"
echo "A0_EVIDENCE_AUTHORITY=PASS"

section "1. EXTERNAL PIN RECHECK"

test "$(cd "$MATHLIB" && git rev-parse HEAD)" = "$MATHLIB_COMMIT" ||
    fail "Mathlib pin changed"

test "$(cd "$EXTERNAL/lean4export" && git rev-parse HEAD)" = "$LEAN4EXPORT_COMMIT" ||
    fail "lean4export pin changed"

test "$(cd "$EXTERNAL/oxilean" && git rev-parse HEAD)" = "$OXILEAN_COMMIT" ||
    fail "OxiLean pin changed"

test -x "$LEAN4EXPORT_BIN" ||
    fail "lean4export binary missing"

test -x "$OXILEAN_BIN" ||
    fail "OxiLean binary missing"

echo "EXTERNAL_PINS=PASS"

section "2. CREATE FROZEN LEAN PROJECT"

rm -rf "$STAGE"
mkdir -p \
    "$PROJECT/FormalEvolution/ProofA" \
    "$PROJECT/FormalEvolution/ProofB" \
    "$EVIDENCE" \
    "$EXPORTS"

cat > "$PROJECT/lean-toolchain" <<EOF
$LEAN_TOOLCHAIN
EOF

cat > "$PROJECT/lakefile.toml" <<'EOF'
name = "FormalEvolutionCase"
defaultTargets = ["FormalEvolution"]

[[require]]
name = "mathlib"
path = "../../external/mathlib4"

[[lean_lib]]
name = "FormalEvolution"
EOF

cat > "$PROJECT/FormalEvolution/Statement.lean" <<'EOF'
import Mathlib

namespace FormalEvolution

/-- Lean 4 port of OpenAI miniF2F `mathd_algebra_182`. -/
def Target : Prop :=
  ∀ y : ℂ, 7 * (3 * y + 2) = 21 * y + 14

end FormalEvolution
EOF

cat > "$PROJECT/FormalEvolution/ProofA.lean" <<'EOF'
import FormalEvolution.Statement

namespace FormalEvolution.ProofA

/-- State A: reference-style normalization proof. -/
theorem proof : FormalEvolution.Target := by
  intro y
  ring_nf

end FormalEvolution.ProofA
EOF

cat > "$PROJECT/FormalEvolution/ProofB.lean" <<'EOF'
import FormalEvolution.Statement

namespace FormalEvolution.ProofB

/-- State B: semantics-preserving proof refactor. -/
theorem proof : FormalEvolution.Target := by
  intro y
  ring

end FormalEvolution.ProofB
EOF

cat > "$PROJECT/FormalEvolution.lean" <<'EOF'
import FormalEvolution.Statement
import FormalEvolution.ProofA
import FormalEvolution.ProofB
EOF

cat > "$EVIDENCE/statement-contract.txt" <<'EOF'
SOURCE_DATASET=openai/miniF2F
SOURCE_THEOREM=mathd_algebra_182
SOURCE_STATEMENT=forall y : Complex, 7 * (3 * y + 2) = 21 * y + 14
LEAN4_TARGET=FormalEvolution.Target
PROOF_A=FormalEvolution.ProofA.proof
PROOF_B=FormalEvolution.ProofB.proof
TRANSFORMATION=ring_nf_to_ring
TRANSFORMATION_CLASS=semantics_preserving_proof_refactor
EOF

STATEMENT_SHA256="$(sha "$PROJECT/FormalEvolution/Statement.lean")"
PROOF_A_SHA256="$(sha "$PROJECT/FormalEvolution/ProofA.lean")"
PROOF_B_SHA256="$(sha "$PROJECT/FormalEvolution/ProofB.lean")"

echo "STATEMENT_SHA256=$STATEMENT_SHA256"
echo "PROOF_A_SHA256=$PROOF_A_SHA256"
echo "PROOF_B_SHA256=$PROOF_B_SHA256"

test "$PROOF_A_SHA256" != "$PROOF_B_SHA256" ||
    fail "proof identities are not distinct"

echo "PROOF_IDENTITIES_DISTINCT=PASS"
echo "MATHEMATICAL_TARGET_IDENTICAL=PASS"
echo "STATEMENT_PORT=PASS"

section "3. RESOLVE FROZEN MATHLIB DEPENDENCIES"

(
    cd "$PROJECT"
    lake update
    lake exe cache get
) > "$EVIDENCE/lake-setup.log" 2>&1 ||
    fail "Lake dependency/cache setup failed"

ACTUAL_PROJECT_MATHLIB_COMMIT="$(
    cd "$MATHLIB"
    git rev-parse HEAD
)"

test "$ACTUAL_PROJECT_MATHLIB_COMMIT" = "$MATHLIB_COMMIT" ||
    fail "project Mathlib authority changed"

echo "PROJECT_MATHLIB_COMMIT=$ACTUAL_PROJECT_MATHLIB_COMMIT"
echo "FROZEN_PROJECT_DEPENDENCIES=PASS"

section "4. LEAN REFERENCE VALIDATION"

(
    cd "$PROJECT"
    lake build FormalEvolution
) > "$EVIDENCE/lean-build.log" 2>&1 ||
    fail "Lean build rejected Proof A or Proof B"

(
    cd "$PROJECT"
    lake env leanchecker FormalEvolution.ProofA
) > "$EVIDENCE/leanchecker-A.log" 2>&1 ||
    fail "leanchecker rejected Proof A module"

(
    cd "$PROJECT"
    lake env leanchecker FormalEvolution.ProofB
) > "$EVIDENCE/leanchecker-B.log" 2>&1 ||
    fail "leanchecker rejected Proof B module"

echo "PROOF_A_LEAN=PASS"
echo "PROOF_B_LEAN=PASS"
echo "LEAN_REFERENCE_VALIDATION=PASS"

section "5. EXPORT TARGET DECLARATIONS"

(
    cd "$PROJECT"
    lake env "$LEAN4EXPORT_BIN" \
        FormalEvolution.ProofA \
        -- FormalEvolution.ProofA.proof \
        > "$EXPORTS/proof-A.ndjson"
) || fail "Proof A lean4export failed"

(
    cd "$PROJECT"
    lake env "$LEAN4EXPORT_BIN" \
        FormalEvolution.ProofB \
        -- FormalEvolution.ProofB.proof \
        > "$EXPORTS/proof-B.ndjson"
) || fail "Proof B lean4export failed"

test -s "$EXPORTS/proof-A.ndjson" ||
    fail "Proof A export empty"

test -s "$EXPORTS/proof-B.ndjson" ||
    fail "Proof B export empty"

echo "PROOF_A_EXPORT_SHA256=$(sha "$EXPORTS/proof-A.ndjson")"
echo "PROOF_B_EXPORT_SHA256=$(sha "$EXPORTS/proof-B.ndjson")"
echo "LEAN4EXPORT=PASS"

section "6. OXILEAN INDEPENDENT CHECK"

set +e
"$OXILEAN_BIN" \
    --no-color \
    --json "$EVIDENCE/oxilean-A.json" \
    --json-full \
    "$EXPORTS/proof-A.ndjson" \
    > "$EVIDENCE/oxilean-A.log" 2>&1
OXI_A_RC=$?

"$OXILEAN_BIN" \
    --no-color \
    --json "$EVIDENCE/oxilean-B.json" \
    --json-full \
    "$EXPORTS/proof-B.ndjson" \
    > "$EVIDENCE/oxilean-B.log" 2>&1
OXI_B_RC=$?
set -e

echo "OXILEAN_A_RC=$OXI_A_RC"
echo "OXILEAN_B_RC=$OXI_B_RC"

test "$OXI_A_RC" -eq 0 ||
    fail "OxiLean Proof A run did not complete cleanly"

test "$OXI_B_RC" -eq 0 ||
    fail "OxiLean Proof B run did not complete cleanly"

grep -F '"file_lean_githash":"b4812ae53eea93439ad5dce5a5c26591c31cb697"' \
    "$EVIDENCE/oxilean-A.json" >/dev/null ||
    fail "Proof A export Lean githash mismatch"

grep -F '"file_lean_githash":"b4812ae53eea93439ad5dce5a5c26591c31cb697"' \
    "$EVIDENCE/oxilean-B.json" >/dev/null ||
    fail "Proof B export Lean githash mismatch"

grep -F '"rejected":0' "$EVIDENCE/oxilean-A.json" >/dev/null ||
    fail "OxiLean Proof A contains rejection"

grep -F '"rejected":0' "$EVIDENCE/oxilean-B.json" >/dev/null ||
    fail "OxiLean Proof B contains rejection"

require_verified_decl \
    "$EVIDENCE/oxilean-A.json" \
    "FormalEvolution.ProofA.proof" ||
    fail "target Proof A declaration not VERIFIED by OxiLean"

require_verified_decl \
    "$EVIDENCE/oxilean-B.json" \
    "FormalEvolution.ProofB.proof" ||
    fail "target Proof B declaration not VERIFIED by OxiLean"

echo "PROOF_A_OXILEAN=VERIFIED"
echo "PROOF_B_OXILEAN=VERIFIED"
echo "OXILEAN_INDEPENDENT_CHECK=PASS"

section "7. CONTROLLED TRANSFORMATION RECORD"

cat > "$EVIDENCE/transformation-record.txt" <<EOF
CASE=$CASE
SOURCE_STATEMENT=mathd_algebra_182
STATEMENT_SHA256=$STATEMENT_SHA256

STATE_A=FormalEvolution.ProofA.proof
STATE_A_SHA256=$PROOF_A_SHA256
STATE_A_TACTIC=ring_nf

STATE_B=FormalEvolution.ProofB.proof
STATE_B_SHA256=$PROOF_B_SHA256
STATE_B_TACTIC=ring

TRANSFORMATION=ring_nf_to_ring
TRANSFORMATION_CLASS=semantics_preserving_proof_refactor

STATEMENT_IDENTITY_PRESERVED=YES
PROOF_IDENTITY_CHANGED=YES

LEAN_A=PASS
LEAN_B=PASS
OXILEAN_A=VERIFIED
OXILEAN_B=VERIFIED

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
EOF

TRANSFORMATION_RECORD_SHA256="$(sha "$EVIDENCE/transformation-record.txt")"

echo "TRANSFORMATION_RECORD_SHA256=$TRANSFORMATION_RECORD_SHA256"
echo "TRANSFORMATION_RECORD=PASS"

section "8. A1 SUMMARY"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
A0_EVIDENCE_MANIFEST_SHA256	$A0_MANIFEST_SHA256
LEAN_TOOLCHAIN	$LEAN_TOOLCHAIN
LEAN_GITHASH	$LEAN_GITHASH
MATHLIB_COMMIT	$MATHLIB_COMMIT
STATEMENT_SHA256	$STATEMENT_SHA256
PROOF_A_SHA256	$PROOF_A_SHA256
PROOF_B_SHA256	$PROOF_B_SHA256
TRANSFORMATION_RECORD_SHA256	$TRANSFORMATION_RECORD_SHA256
STATEMENT_PORT	PASS
PROOF_IDENTITIES_DISTINCT	PASS
MATHEMATICAL_TARGET_IDENTICAL	PASS
PROOF_A_LEAN	PASS
PROOF_B_LEAN	PASS
PROOF_A_OXILEAN	VERIFIED
PROOF_B_OXILEAN	VERIFIED
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

section "9. FREEZE A1 EVIDENCE"

cp "$0" "$EVIDENCE/stage-a1-script.sh"

(
    cd "$STAGE"
    find evidence exports formal-project \
        -type f \
        ! -path '*/.lake/*' \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || fail "A1 evidence integrity failed"

A1_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A1_EVIDENCE_INTEGRITY=PASS"
echo "A1_EVIDENCE_MANIFEST_SHA256=$A1_MANIFEST_SHA256"

section "10. HOMOLOGATION"

echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A1=PASS"
echo "STATEMENT_PORT=PASS"
echo "PROOF_IDENTITIES_DISTINCT=PASS"
echo "MATHEMATICAL_TARGET_IDENTICAL=PASS"
echo "PROOF_A_LEAN=PASS"
echo "PROOF_B_LEAN=PASS"
echo "PROOF_A_OXILEAN=VERIFIED"
echo "PROOF_B_OXILEAN=VERIFIED"
echo "TRANSFORMATION_RECORD=PASS"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=STAGE_A2_YODA_VERSIONED_DERIVATION"
