#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
REVISION="A1-R1"
ROOT="$HOME/cmu/$CASE"
EXTERNAL="$ROOT/external"
A0="$ROOT/stage-a0"
A1_0="$ROOT/stage-a1"
STAGE="$ROOT/stage-a1-r1"
PROJECT="$STAGE/formal-project"
EVIDENCE="$STAGE/evidence"
EXPORTS="$STAGE/exports"

MINIF2F_COMMIT="4e433ff5cadff23f9911a2bb5bbab2d351ce5554"
MINIF2F_THEOREM="mathd_numbertheory_188"
MINIF2F_SOURCE_SHA256="798e4f5f6a77b4dfbe0e0bb33d0a54ff1bf27badaffc4c331a1ba351e0306055"

LEAN_TOOLCHAIN="leanprover/lean4:v4.32.0-rc1"
LEAN_GITHASH="b4812ae53eea93439ad5dce5a5c26591c31cb697"
MATHLIB_COMMIT="360da6fa66c1273b76b6b2d8c5666fd5ac2e3b56"
LEAN4EXPORT_COMMIT="3de59f10bc4b4a0f2de698597aeb1246caa0df0a"
OXILEAN_COMMIT="9077af778fe467cba61d9c8385fb2b7e6a8d385f"

A0_MANIFEST_SHA256_EXPECTED="80cb8e086c70015dd6f5e259a354a75c24e3b69809e71cb0c04666634771a408"

A1_0_PROOF_A_EXPORT_SHA256="786b4d2a4796929d4e0e38b520e0f1c2d1a4bca0d8488d7398868e47914155bb"
A1_0_PROOF_B_EXPORT_SHA256="f748d0746ba864fefe7382cfb26a4a378695ac0385acea2719a302fb7238dda4"
A1_0_OXILEAN_A_JSON_SHA256="c1b0dd0ea9ab812fdb52b12380cdffbc8ce137b289e38ac9ea08e697024c98eb"
A1_0_OXILEAN_B_JSON_SHA256="f2c33226851e7209c09ce04f14c3410c027f48d40478b0a544d5532ddbf66fc0"

MINIF2F="$EXTERNAL/miniF2F"
MATHLIB="$EXTERNAL/mathlib4"
LEAN4EXPORT_BIN="$EXTERNAL/lean4export/.lake/build/bin/lean4export"
OXILEAN_BIN="$EXTERNAL/oxilean/target/release/oxilean-verify"
EXECUTION_LOCK="$ROOT/.stage-a1-r1-execution-started"

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
    echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A1_R1=NOT_EVALUATED"
    echo "REASON=$1"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
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

decl_verdict()
{
    report="$1"
    decl="$2"

    awk -v target="$decl" '
        index($0, "\"name\": \"" target "\"") {
            in_target = 1
            next
        }

        in_target && index($0, "\"verdict\": \"") {
            line = $0
            sub(/^.*"verdict": "/, "", line)
            sub(/".*$/, "", line)
            print line
            found = 1
            exit
        }

        in_target && /^[[:space:]]*}[,]?[[:space:]]*$/ {
            exit
        }

        END {
            if (!found)
                exit 1
        }
    ' "$report"
}

decl_detail()
{
    report="$1"
    decl="$2"

    awk -v target="$decl" '
        index($0, "\"name\": \"" target "\"") {
            in_target = 1
            next
        }

        in_target && index($0, "\"detail\": ") {
            line = $0
            sub(/^.*"detail": /, "", line)
            sub(/,[[:space:]]*$/, "", line)
            print line
            found = 1
            exit
        }

        in_target && /^[[:space:]]*}[,]?[[:space:]]*$/ {
            exit
        }

        END {
            if (!found)
                exit 1
        }
    ' "$report"
}

test ! -e "$EXECUTION_LOCK" ||
    not_evaluated "A1-R1 one-execution policy already consumed; existing evidence preserved"

section "0. A0 AUTHORITY + A1.0 PREDECESSOR"

test -f "$A0/evidence/SHA256SUMS" ||
    not_evaluated "A0 evidence manifest missing"

(
    cd "$A0"
    sha256sum -c evidence/SHA256SUMS >/dev/null
) || not_evaluated "A0 evidence integrity failed"

A0_MANIFEST_SHA256="$(sha "$A0/evidence/SHA256SUMS")"

test "$A0_MANIFEST_SHA256" = "$A0_MANIFEST_SHA256_EXPECTED" ||
    not_evaluated "A0 evidence authority identity changed"

echo "A0_EVIDENCE_MANIFEST_SHA256=$A0_MANIFEST_SHA256"
echo "A0_EVIDENCE_AUTHORITY=PASS"

test -f "$A1_0/exports/proof-A.ndjson" ||
    not_evaluated "A1.0 Proof A export missing"

test -f "$A1_0/exports/proof-B.ndjson" ||
    not_evaluated "A1.0 Proof B export missing"

test -f "$A1_0/evidence/oxilean-A.json" ||
    not_evaluated "A1.0 OxiLean A report missing"

test -f "$A1_0/evidence/oxilean-B.json" ||
    not_evaluated "A1.0 OxiLean B report missing"

test "$(sha "$A1_0/exports/proof-A.ndjson")" = "$A1_0_PROOF_A_EXPORT_SHA256" ||
    not_evaluated "A1.0 Proof A export identity changed"

test "$(sha "$A1_0/exports/proof-B.ndjson")" = "$A1_0_PROOF_B_EXPORT_SHA256" ||
    not_evaluated "A1.0 Proof B export identity changed"

test "$(sha "$A1_0/evidence/oxilean-A.json")" = "$A1_0_OXILEAN_A_JSON_SHA256" ||
    not_evaluated "A1.0 OxiLean A evidence identity changed"

test "$(sha "$A1_0/evidence/oxilean-B.json")" = "$A1_0_OXILEAN_B_JSON_SHA256" ||
    not_evaluated "A1.0 OxiLean B evidence identity changed"

A1_0_A_VERDICT="$(decl_verdict "$A1_0/evidence/oxilean-A.json" "FormalEvolution.ProofA.proof" || true)"
A1_0_B_VERDICT="$(decl_verdict "$A1_0/evidence/oxilean-B.json" "FormalEvolution.ProofB.proof" || true)"

test "$A1_0_A_VERDICT" = "unsupported" ||
    not_evaluated "A1.0 Proof A predecessor verdict changed"

test "$A1_0_B_VERDICT" = "unsupported" ||
    not_evaluated "A1.0 Proof B predecessor verdict changed"

echo "A1_0_STATUS=NOT_EVALUATED"
echo "A1_0_CLASS=SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY"
echo "A1_0_EVIDENCE_AUTHORITY=PASS"

section "1. EXTERNAL PIN RECHECK"

test "$(cd "$MINIF2F" && git rev-parse HEAD)" = "$MINIF2F_COMMIT" ||
    not_evaluated "MiniF2F pin changed"

test "$(cd "$MATHLIB" && git rev-parse HEAD)" = "$MATHLIB_COMMIT" ||
    not_evaluated "Mathlib pin changed"

test "$(cd "$EXTERNAL/lean4export" && git rev-parse HEAD)" = "$LEAN4EXPORT_COMMIT" ||
    not_evaluated "lean4export pin changed"

test "$(cd "$EXTERNAL/oxilean" && git rev-parse HEAD)" = "$OXILEAN_COMMIT" ||
    not_evaluated "OxiLean pin changed"

test -x "$LEAN4EXPORT_BIN" ||
    not_evaluated "lean4export binary missing"

test -x "$OXILEAN_BIN" ||
    not_evaluated "OxiLean binary missing"

echo "EXTERNAL_PINS=PASS"

section "2. FREEZE A1-R1 SOURCE AUTHORITY"

SOURCE_FILE="$MINIF2F/lean/src/valid.lean"
test -f "$SOURCE_FILE" ||
    not_evaluated "MiniF2F Lean source missing"

rm -rf "$STAGE"
mkdir -p \
    "$PROJECT/FormalEvolutionR1" \
    "$EVIDENCE" \
    "$EXPORTS"

awk '
/^theorem mathd_numbertheory_188 :$/ { capture=1 }
capture { print }
capture && /^end$/ { exit }
' "$SOURCE_FILE" > "$EVIDENCE/minif2f-mathd_numbertheory_188.txt"

test -s "$EVIDENCE/minif2f-mathd_numbertheory_188.txt" ||
    not_evaluated "A1-R1 MiniF2F theorem extraction empty"

ACTUAL_R1_SOURCE_SHA256="$(sha "$EVIDENCE/minif2f-mathd_numbertheory_188.txt")"

test "$ACTUAL_R1_SOURCE_SHA256" = "$MINIF2F_SOURCE_SHA256" ||
    not_evaluated "A1-R1 MiniF2F theorem source identity mismatch"

grep -F "theorem mathd_numbertheory_188 :" \
    "$EVIDENCE/minif2f-mathd_numbertheory_188.txt" >/dev/null ||
    not_evaluated "A1-R1 theorem name mismatch"

grep -F "nat.gcd 180 168 = 12 :=" \
    "$EVIDENCE/minif2f-mathd_numbertheory_188.txt" >/dev/null ||
    not_evaluated "A1-R1 theorem target mismatch"

echo "MINIF2F_COMMIT=$MINIF2F_COMMIT"
echo "MINIF2F_THEOREM=$MINIF2F_THEOREM"
echo "MINIF2F_SOURCE_SHA256=$ACTUAL_R1_SOURCE_SHA256"
echo "A1_R1_SOURCE_AUTHORITY=PASS"

section "3. CREATE PRE-REGISTERED LEAN PROJECT"

cat > "$PROJECT/lean-toolchain" <<EOF
$LEAN_TOOLCHAIN
EOF

cat > "$PROJECT/lakefile.toml" <<'EOF'
name = "FormalEvolutionR1Case"
defaultTargets = ["FormalEvolutionR1"]

[[require]]
name = "mathlib"
path = "../../external/mathlib4"

[[lean_lib]]
name = "FormalEvolutionR1"
EOF

cat > "$PROJECT/FormalEvolutionR1/Statement.lean" <<'EOF'
import Mathlib

namespace FormalEvolutionR1

/-- Lean 4 port of OpenAI miniF2F `mathd_numbertheory_188`. -/
def Target : Prop :=
  Nat.gcd 180 168 = 12

end FormalEvolutionR1
EOF

cat > "$PROJECT/FormalEvolutionR1/ProofA.lean" <<'EOF'
import FormalEvolutionR1.Statement

namespace FormalEvolutionR1.ProofA

/-- State A: direct kernel computation. -/
theorem proof : FormalEvolutionR1.Target := by
  rfl

end FormalEvolutionR1.ProofA
EOF

cat > "$PROJECT/FormalEvolutionR1/ProofB.lean" <<'EOF'
import FormalEvolutionR1.Statement

namespace FormalEvolutionR1.ProofB

/-- State B: explicit Euclidean-algorithm derivation. -/
theorem proof : FormalEvolutionR1.Target := by
  unfold FormalEvolutionR1.Target
  calc
    Nat.gcd 180 168 = Nat.gcd (168 % 180) 180 := Nat.gcd_rec 180 168
    _ = Nat.gcd 168 180 := by rfl
    _ = Nat.gcd (180 % 168) 168 := Nat.gcd_rec 168 180
    _ = Nat.gcd 12 168 := by rfl
    _ = Nat.gcd (168 % 12) 12 := Nat.gcd_rec 12 168
    _ = Nat.gcd 0 12 := by rfl
    _ = 12 := Nat.gcd_zero_left 12

end FormalEvolutionR1.ProofB
EOF

cat > "$PROJECT/FormalEvolutionR1.lean" <<'EOF'
import FormalEvolutionR1.Statement
import FormalEvolutionR1.ProofA
import FormalEvolutionR1.ProofB
EOF

cat > "$EVIDENCE/preregistration.txt" <<EOF
CASE=$CASE
REVISION=$REVISION
PREDECESSOR_STAGE=A1.0
PREDECESSOR_STATUS=NOT_EVALUATED
PREDECESSOR_CLASS=SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY

HYPOTHESIS=LINEAGE_OF_CHANGE
DOMAIN=FORMAL_MATHEMATICS

CORPUS=openai/miniF2F
CORPUS_COMMIT=$MINIF2F_COMMIT
THEOREM=$MINIF2F_THEOREM
TARGET=Nat.gcd 180 168 = 12

STATE_A=FormalEvolutionR1.ProofA.proof
STATE_A_METHOD=kernel_computation_rfl

STATE_B=FormalEvolutionR1.ProofB.proof
STATE_B_METHOD=explicit_euclidean_gcd_derivation

TRANSFORMATION=kernel_computation_to_explicit_euclidean_derivation
TRANSFORMATION_CLASS=semantics_preserving_proof_refactor

HYPOTHESIS_CHANGED=NO
DOMAIN_CHANGED=NO
CORPUS_CHANGED=NO
CORPUS_COMMIT_CHANGED=NO
AUTHORITIES_CHANGED=NO
YODA_CHANGED=NO
KYBER_CHANGED=NO
WORKLOAD_CHANGED=YES

SELECTION_BEFORE_EXECUTION=YES
CANDIDATE_SEARCH_AFTER_EXECUTION=NO
EXECUTION_POLICY=ONE_EXECUTION
YODA_WRITES=ZERO
EOF

STATEMENT_SHA256="$(sha "$PROJECT/FormalEvolutionR1/Statement.lean")"
PROOF_A_SHA256="$(sha "$PROJECT/FormalEvolutionR1/ProofA.lean")"
PROOF_B_SHA256="$(sha "$PROJECT/FormalEvolutionR1/ProofB.lean")"
PREREGISTRATION_SHA256="$(sha "$EVIDENCE/preregistration.txt")"

echo "STATEMENT_SHA256=$STATEMENT_SHA256"
echo "PROOF_A_SHA256=$PROOF_A_SHA256"
echo "PROOF_B_SHA256=$PROOF_B_SHA256"
echo "PREREGISTRATION_SHA256=$PREREGISTRATION_SHA256"

test "$PROOF_A_SHA256" != "$PROOF_B_SHA256" ||
    not_evaluated "A1-R1 proof identities are not distinct"

echo "PROOF_IDENTITIES_DISTINCT=PASS"
echo "MATHEMATICAL_TARGET_IDENTICAL=PASS"
echo "SEMANTICS_EQUIVALENT_BY_COMMON_TARGET=PASS"
echo "PREREGISTRATION=PASS"

section "4. RESOLVE FROZEN MATHLIB DEPENDENCIES"

(
    cd "$PROJECT"
    lake update
    lake exe cache get
) > "$EVIDENCE/lake-setup.log" 2>&1 ||
    not_evaluated "Lake dependency/cache setup failed"

ACTUAL_PROJECT_MATHLIB_COMMIT="$(
    cd "$MATHLIB"
    git rev-parse HEAD
)"

test "$ACTUAL_PROJECT_MATHLIB_COMMIT" = "$MATHLIB_COMMIT" ||
    not_evaluated "project Mathlib authority changed"

echo "PROJECT_MATHLIB_COMMIT=$ACTUAL_PROJECT_MATHLIB_COMMIT"
echo "FROZEN_PROJECT_DEPENDENCIES=PASS"

section "5. ONE-EXECUTION GATE"

test ! -e "$EXECUTION_LOCK" ||
    not_evaluated "A1-R1 one-execution policy already consumed"

cat > "$EXECUTION_LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
PREREGISTRATION_SHA256=$PREREGISTRATION_SHA256
EXECUTION_POLICY=ONE_EXECUTION
EOF

cp "$EXECUTION_LOCK" "$EVIDENCE/execution-started.txt"

echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$EXECUTION_LOCK")"
echo "EXECUTION_GATE=PASS"

section "6. LEAN REFERENCE VALIDATION"

(
    cd "$PROJECT"
    lake build FormalEvolutionR1
) > "$EVIDENCE/lean-build.log" 2>&1 ||
    not_evaluated "Lean build rejected pre-registered Proof A or Proof B"

(
    cd "$PROJECT"
    lake env leanchecker FormalEvolutionR1.ProofA
) > "$EVIDENCE/leanchecker-A.log" 2>&1 ||
    not_evaluated "leanchecker rejected Proof A module"

(
    cd "$PROJECT"
    lake env leanchecker FormalEvolutionR1.ProofB
) > "$EVIDENCE/leanchecker-B.log" 2>&1 ||
    not_evaluated "leanchecker rejected Proof B module"

echo "LEAN_A=PASS"
echo "LEAN_B=PASS"
echo "LEAN_REFERENCE_VALIDATION=PASS"

section "7. EXPORT TARGET DECLARATIONS"

(
    cd "$PROJECT"
    lake env "$LEAN4EXPORT_BIN" \
        FormalEvolutionR1.ProofA \
        -- FormalEvolutionR1.ProofA.proof \
        > "$EXPORTS/proof-A.ndjson"
) || not_evaluated "Proof A lean4export failed"

(
    cd "$PROJECT"
    lake env "$LEAN4EXPORT_BIN" \
        FormalEvolutionR1.ProofB \
        -- FormalEvolutionR1.ProofB.proof \
        > "$EXPORTS/proof-B.ndjson"
) || not_evaluated "Proof B lean4export failed"

test -s "$EXPORTS/proof-A.ndjson" ||
    not_evaluated "Proof A export empty"

test -s "$EXPORTS/proof-B.ndjson" ||
    not_evaluated "Proof B export empty"

echo "PROOF_A_EXPORT_SHA256=$(sha "$EXPORTS/proof-A.ndjson")"
echo "PROOF_B_EXPORT_SHA256=$(sha "$EXPORTS/proof-B.ndjson")"
echo "LEAN4EXPORT=PASS"

section "8. OXILEAN INDEPENDENT CHECK"

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

test -s "$EVIDENCE/oxilean-A.json" ||
    not_evaluated "OxiLean Proof A report missing"

test -s "$EVIDENCE/oxilean-B.json" ||
    not_evaluated "OxiLean Proof B report missing"

json_contains \
    "$EVIDENCE/oxilean-A.json" \
    "\"file_lean_githash\":\"$LEAN_GITHASH\"" ||
    not_evaluated "Proof A export Lean githash mismatch"

json_contains \
    "$EVIDENCE/oxilean-B.json" \
    "\"file_lean_githash\":\"$LEAN_GITHASH\"" ||
    not_evaluated "Proof B export Lean githash mismatch"

A_VERDICT="$(decl_verdict "$EVIDENCE/oxilean-A.json" "FormalEvolutionR1.ProofA.proof" || true)"
B_VERDICT="$(decl_verdict "$EVIDENCE/oxilean-B.json" "FormalEvolutionR1.ProofB.proof" || true)"

A_DETAIL="$(decl_detail "$EVIDENCE/oxilean-A.json" "FormalEvolutionR1.ProofA.proof" || true)"
B_DETAIL="$(decl_detail "$EVIDENCE/oxilean-B.json" "FormalEvolutionR1.ProofB.proof" || true)"

echo "OXILEAN_A_TARGET_VERDICT=${A_VERDICT:-NOT_FOUND}"
echo "OXILEAN_B_TARGET_VERDICT=${B_VERDICT:-NOT_FOUND}"
echo "OXILEAN_A_TARGET_DETAIL=${A_DETAIL:-NOT_FOUND}"
echo "OXILEAN_B_TARGET_DETAIL=${B_DETAIL:-NOT_FOUND}"

test "$OXI_A_RC" -eq 0 ||
    not_evaluated "OxiLean Proof A run did not complete cleanly"

test "$OXI_B_RC" -eq 0 ||
    not_evaluated "OxiLean Proof B run did not complete cleanly"

test "$A_VERDICT" = "verified" ||
    not_evaluated "pre-registered Proof A target not VERIFIED by OxiLean"

test "$B_VERDICT" = "verified" ||
    not_evaluated "pre-registered Proof B target not VERIFIED by OxiLean"

echo "OXILEAN_A=VERIFIED"
echo "OXILEAN_B=VERIFIED"
echo "OXILEAN_INDEPENDENT_CHECK=PASS"

section "9. CONTROLLED TRANSFORMATION RECORD"

cat > "$EVIDENCE/transformation-record.txt" <<EOF
CASE=$CASE
REVISION=$REVISION

SOURCE_CORPUS=openai/miniF2F
SOURCE_COMMIT=$MINIF2F_COMMIT
SOURCE_THEOREM=$MINIF2F_THEOREM
STATEMENT_SHA256=$STATEMENT_SHA256

STATE_A=FormalEvolutionR1.ProofA.proof
STATE_A_SHA256=$PROOF_A_SHA256
STATE_A_METHOD=kernel_computation_rfl

STATE_B=FormalEvolutionR1.ProofB.proof
STATE_B_SHA256=$PROOF_B_SHA256
STATE_B_METHOD=explicit_euclidean_gcd_derivation

TRANSFORMATION=kernel_computation_to_explicit_euclidean_derivation
TRANSFORMATION_CLASS=semantics_preserving_proof_refactor

STATEMENT_IDENTITY_PRESERVED=YES
PROOF_IDENTITY_CHANGED=YES
SEMANTICS_EQUIVALENT_BY_COMMON_TARGET=YES

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

section "10. FREEZE A1-R1 EVIDENCE"

cp "$0" "$EVIDENCE/stage-a1-r1-script.sh"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
A0_EVIDENCE_MANIFEST_SHA256	$A0_MANIFEST_SHA256
A1_0_CLASS	SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY
MINIF2F_COMMIT	$MINIF2F_COMMIT
MINIF2F_THEOREM	$MINIF2F_THEOREM
MINIF2F_SOURCE_SHA256	$ACTUAL_R1_SOURCE_SHA256
LEAN_TOOLCHAIN	$LEAN_TOOLCHAIN
LEAN_GITHASH	$LEAN_GITHASH
MATHLIB_COMMIT	$MATHLIB_COMMIT
STATEMENT_SHA256	$STATEMENT_SHA256
PROOF_A_SHA256	$PROOF_A_SHA256
PROOF_B_SHA256	$PROOF_B_SHA256
PREREGISTRATION_SHA256	$PREREGISTRATION_SHA256
TRANSFORMATION_RECORD_SHA256	$TRANSFORMATION_RECORD_SHA256
LEAN_A	PASS
LEAN_B	PASS
OXILEAN_A	VERIFIED
OXILEAN_B	VERIFIED
PROOF_IDENTITIES_DISTINCT	PASS
MATHEMATICAL_TARGET_IDENTICAL	PASS
SEMANTICS_EQUIVALENT_BY_COMMON_TARGET	PASS
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

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
) || not_evaluated "A1-R1 evidence integrity failed"

A1_R1_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A1_R1_EVIDENCE_INTEGRITY=PASS"
echo "A1_R1_EVIDENCE_MANIFEST_SHA256=$A1_R1_MANIFEST_SHA256"

section "11. HOMOLOGATION"

echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A1_R1=PASS"
echo "MINIF2F_SOURCE_AUTHORITY=PASS"
echo "STATEMENT_PORT=PASS"
echo "PROOF_IDENTITIES_DISTINCT=PASS"
echo "MATHEMATICAL_TARGET_IDENTICAL=PASS"
echo "SEMANTICS_EQUIVALENT=YES"
echo "LEAN_A=PASS"
echo "LEAN_B=PASS"
echo "OXILEAN_A=VERIFIED"
echo "OXILEAN_B=VERIFIED"
echo "TRANSFORMATION_RECORD=PASS"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=STAGE_A2_YODA_VERSIONED_DERIVATION"
