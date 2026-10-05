# AXIOM-YODA-PROOF-LINEAGE-001

## Verifiable Proof Derivation

This CASE tests a narrow complementarity between two independent systems:

- **AXLE** as the external formal-verification authority;
- **Yoda** as the derivation-lineage and evidence layer.

The question is not whether Yoda can prove mathematics.

It cannot and does not claim to.

The question is:

> **Can Yoda preserve the exact artifacts and derivation lineage of a formally verified result such that AXLE can reproduce the same formal verification outcome after those artifacts are recovered from Yoda?**

---

## Authority separation

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

The experiment deliberately keeps those authorities separate.

AXLE decides whether a candidate proof matches the formal statement.
Yoda preserves the statement, candidate proof, environment, verification evidence, relationships and history needed to reconstruct the derivation later.

---

## Stage A0 — External formal authority

A frozen Lean environment was selected from AXLE:

```text
SELECTED_ENVIRONMENT=lean-4.34.0
SELECTED_LEAN_TOOLCHAIN=leanprover/lean4:v4.34.0
```

The formal statement was:

```lean
import Mathlib

theorem yoda_axle_lineage_seed : 2 + 2 = 4 := by
  sorry
```

The positive candidate was:

```lean
import Mathlib

theorem yoda_axle_lineage_seed : 2 + 2 = 4 := by
  rfl
```

AXLE accepted it:

```text
AXLE_POSITIVE_VERIFICATION=PASS
```

The negative candidate was intentionally **valid Lean proving a different theorem**:

```lean
import Mathlib

theorem yoda_axle_lineage_seed : 2 + 3 = 5 := by
  rfl
```

It compiled successfully:

```text
CONTROLLED_MUTATION_VALID_LEAN=PASS
```

AXLE rejected it against the frozen formal statement:

```text
AXLE_CONTROLLED_REJECTION=PASS
```

The rejection reason was a signature mismatch: the candidate proved `2 + 3 = 5` where the formal authority required `2 + 2 = 4`.

This isolates the intended property:

> **A valid artifact is not necessarily a valid derivation against a specification.**

---

## Stage A1 — Yoda derivation replay

Yoda stored:

- formal statement;
- valid proof;
- controlled mutation;
- selected AXLE environment;
- A0 positive verification evidence;
- A0 negative verification evidence;
- frozen A0 summary and manifest;
- explicit positive and negative lineage relations.

Yoda then verified its authoritative state and recovered the original artifacts through its public CLI.

The recovered artifacts were byte-exact:

```text
FORMAL_BYTE_EXACT_RECOVERY=PASS
VALID_PROOF_BYTE_EXACT_RECOVERY=PASS
CONTROLLED_MUTATION_BYTE_EXACT_RECOVERY=PASS
POSITIVE_EVIDENCE_BYTE_EXACT_RECOVERY=PASS
NEGATIVE_EVIDENCE_BYTE_EXACT_RECOVERY=PASS
YODA_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
```

The recovered positive proof was submitted again to AXLE:

```text
AXLE_POSITIVE_REPLAY_FROM_YODA=PASS
```

The recovered controlled mutation still compiled as valid Lean:

```text
CONTROLLED_MUTATION_VALID_LEAN_AFTER_YODA=PASS
```

It was then submitted again to AXLE against the original formal statement and was rejected for the same semantic reason:

```text
AXLE_NEGATIVE_REPLAY_FROM_YODA=PASS
```

The formal decisions were reproduced:

```text
A0_POSITIVE_OKAY=true
A1_POSITIVE_OKAY=true

A0_NEGATIVE_OKAY=false
A1_NEGATIVE_OKAY=false

AXLE_POSITIVE_DECISION_REPRODUCED=PASS
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
PROOF_DERIVATION_REPLAY=PASS
```

---

## What was demonstrated

The strongest narrow claim supported by this CASE is:

> **Yoda can preserve and reconstruct the lineage of a formally verified result such that an independent formal authority can reproduce the verification outcome from Yoda-recovered artifacts.**

Or more compactly:

> **AXLE verifies the proof. Yoda preserves the derivation required to verify it again.**

---

## What was not demonstrated

This CASE does **not** establish that:

- Yoda proves mathematics;
- Yoda replaces Lean;
- Yoda replaces AXLE;
- Yoda validates logical truth independently;
- AXLE response JSON is byte-identical across requests;
- arbitrary theorem-proving workflows are supported;
- the system is production-ready for formal-methods workloads;
- product-market fit exists.

The AXLE replay responses contain request-specific runtime metadata such as request IDs, cache state and timings. Therefore the validated property is **semantic verification-outcome replay**, not byte-identical AXLE response replay.

---

## Frozen identities

```text
FORMAL_STATEMENT_SHA256=24bea18925bf1a4b9e1dddc4ea6b34bd0cba323d57de42bfdcfd79c1756d2ee9
VALID_PROOF_SHA256=0082af12ce4e8b8c249f90706c3c9b0264e1e0ebcf05e3d3ece25fdf76f79a29
CONTROLLED_MUTATION_SHA256=a74af4eb7a514a97163f7d86dd8216298e478763eade920f91e08b52e12fd392
A0_EVIDENCE_MANIFEST_SHA256=f6c1b0a71c4d4b706628ee42008ac2f1dd495f2861fa39899217d0f0e0c567b3
A1_EVIDENCE_MANIFEST_SHA256=94a0801e2a554a80c32228c1eb6edf4334d4ce59c27b75cb876e2171c0196c90
DATA_YODA_SHA256=b3cd12a421fe84b2728a65ddf474db0aa3ec0f9da7bc292c4f7608d9ff36ff8c
```

---

## Result

```text
AXIOM_YODA_PROOF_LINEAGE_001=VALIDATED
STAGE_A0=PASS
STAGE_A1=PASS
YODA_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
AXLE_POSITIVE_DECISION_REPRODUCED=PASS
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
POSITIVE_DERIVATION_LINEAGE_RECOVERY=PASS
NEGATIVE_DERIVATION_LINEAGE_RECOVERY=PASS
PROOF_DERIVATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```
