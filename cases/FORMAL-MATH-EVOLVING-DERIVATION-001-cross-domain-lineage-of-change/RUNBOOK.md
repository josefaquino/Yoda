# Runbook — FORMAL-MATH-EVOLVING-DERIVATION-001

## Execution order

The CASE is intentionally gated.

```text
A0 external authority freeze
        ↓ only if PASS
A1 controlled proof evolution
        ↓ only if PASS
A2 Yoda versioned derivation
        ↓ only if PASS
B independent formal replay
        ↓ only if PASS
final homologation
```

Do not skip stages.

Do not modify Yoda or Kyber to rescue an external compatibility failure.

---

## Local case root

All scripts use:

```text
$HOME/cmu/FORMAL-MATH-EVOLVING-DERIVATION-001
```

Frozen Yoda authority:

```text
/home/jose/YodaCore-015-FROZEN/product/yoda
SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

---

## Fetch scripts

From a local clone of the Yoda repository:

```bash
CASE_DIR="cases/FORMAL-MATH-EVOLVING-DERIVATION-001-cross-domain-lineage-of-change"

chmod +x "$CASE_DIR"/scripts/*.sh
```

Or copy the scripts to `$HOME/cmu/` while preserving their contents exactly.

Before each execution:

```bash
bash -n script.sh
sha256sum script.sh
```

---

## Stage A0

Purpose:

```text
freeze MiniF2F
freeze Lean
freeze Mathlib
freeze lean4export
freeze OxiLean
verify frozen Yoda identity
Yoda writes = zero
```

Run:

```bash
set +e
set -o pipefail

./scripts/00-authority-freeze.sh 2>&1 |
tee "$HOME/cmu/formal-math-evolving-derivation-001-stage-a0-console.log"

RUN_RC="${PIPESTATUS[0]}"
echo "RUN_RC=$RUN_RC"
```

Required end state:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A0=PASS
MINIF2F_SOURCE_AUTHORITY=PASS
LEAN_AUTHORITY=PASS
MATHLIB_AUTHORITY=PASS
LEAN4EXPORT_AUTHORITY=PASS
OXILEAN_AUTHORITY=PASS
YODA_AUTHORITY=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

If A0 is `NOT_EVALUATED`, stop.

---

## Stage A1

Purpose:

```text
create Proof A
create controlled Proof B
validate both with Lean
export both with lean4export
require target theorem VERIFIED by OxiLean
Yoda writes = zero
```

Run:

```bash
set +e
set -o pipefail

./scripts/01-controlled-proof-evolution.sh 2>&1 |
tee "$HOME/cmu/formal-math-evolving-derivation-001-stage-a1-console.log"

RUN_RC="${PIPESTATUS[0]}"
echo "RUN_RC=$RUN_RC"
```

Required end state:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A1=PASS
STATEMENT_PORT=PASS
PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS
PROOF_A_LEAN=PASS
PROOF_B_LEAN=PASS
PROOF_A_OXILEAN=VERIFIED
PROOF_B_OXILEAN=VERIFIED
TRANSFORMATION_RECORD=PASS
YODA_WRITES=ZERO
```

`unsupported` for the target theorem is not PASS.

If A1 is `NOT_EVALUATED`, stop before Yoda.

---

## Stage A2

Purpose:

```text
preserve statement
preserve Proof A
preserve Proof B
preserve transformation
preserve Lean evaluations
preserve OxiLean evaluations
preserve authority identities
create explicit derivation relations
recover byte-exact artifacts
recover bounded Lineage-of-Change context
```

Run:

```bash
set +e
set -o pipefail

./scripts/02-yoda-versioned-derivation.sh 2>&1 |
tee "$HOME/cmu/formal-math-evolving-derivation-001-stage-a2-console.log"

RUN_RC="${PIPESTATUS[0]}"
echo "RUN_RC=$RUN_RC"
```

Required end state:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=PASS
OBJECT_COUNT=11
LINK_COUNT=15
PROOF_A_BYTE_EXACT_RECOVERY=PASS
PROOF_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
FINAL_YODA_VERIFY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Stage B

Purpose:

```text
recover only from Yoda
create fresh formal project
rerun Lean
rerun leanchecker
re-export recovered proofs
rerun OxiLean
require target declarations VERIFIED again
```

Run:

```bash
set +e
set -o pipefail

./scripts/03-independent-formal-replay.sh 2>&1 |
tee "$HOME/cmu/formal-math-evolving-derivation-001-stage-b-console.log"

RUN_RC="${PIPESTATUS[0]}"
echo "RUN_RC=$RUN_RC"
```

Required end state:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_B=PASS
PROOF_A_IDENTITY_SURVIVED=PASS
PROOF_B_IDENTITY_SURVIVED=PASS
TRANSFORMATION_IDENTITY_SURVIVED=PASS
LEAN_AUTHORITY_REPLAY=PASS
OXILEAN_AUTHORITY_REPLAY=PASS
INDEPENDENT_FORMAL_REPLAY=PASS
FORMAL_LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Final homologation

Do not write the final homologation constants before the real evidence hashes exist.

After Stage B passes, freeze the actual A0/A1/A2/B manifest identities and create the final homologation artifact.

Only then evaluate whether the CASE supports:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001=VALIDATED
CROSS_DOMAIN_LINEAGE_OF_CHANGE=DEMONSTRATED
```

The second property must not be declared before both domain evidence chains are explicitly tied together in the final homologation.
