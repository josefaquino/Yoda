# Evidence

Yoda is developed through narrow, reproducible CASEs.

The project does not treat a successful demo as proof of a broad market claim.

Each CASE should answer one question, freeze its evidence and make the next question clearer.

---

## Research rule

```text
one question
one hypothesis
one controlled experiment
explicit PASS / FAIL gates
frozen evidence
no speculative engine change
```

> **Big vision. Small steps. Evidence always.**

---

# Cross-domain evidence map

| Case | Domain | Property tested | Status |
|---|---|---|---|
| FIRMS-001 | Satellite observations | fact / decision equivalence | PASS |
| USGS-001 | Earthquake events | external identity + replay | PASS |
| BGP-RIPE-RIS-001 | Internet routing | mutation-state equivalence | PASS |
| AUDIT-FORENSICS-001 | Security events | exact ledger + tamper rejection | PASS |
| GENOME-KMER-001 | Genomics | exact indexed state | PASS |
| GENOME-REFERENCE-001 | Genomics | reference coordinate equivalence | PASS |
| GENOME-READ-001 | Genomics | paired-read state preservation | PASS |
| GENOME-ALIGNMENT-001 | Genomics | workflow-derived alignment state | PASS |
| GENOME-VARIANT-001 | Genomics | downstream workflow continuity | PASS |
| GENOME-LINEAGE-001 | Genomics | verifiable scientific lineage | PASS |
| AXIOM-YODA-PROOF-LINEAGE-001 | Formal verification | proof-derivation replay through AXLE | PASS |

Negative experiments are evidence too.

---

# Genomics research ladder

Genomics was the first domain where the questions progressed from state to derivation.

```text
identity
   ↓
state
   ↓
workflow
   ↓
derived state
   ↓
workflow continuity
   ↓
verifiable lineage
```

The key endpoint was `GENOME-LINEAGE-001`.

Result:

```text
GENOME_LINEAGE_001_STAGE_A=PASS
EXACT_EVIDENCE_RECOVERY=PASS
VARIANT_CONTEXT_1HOP=PASS
ALIGNMENT_CONTEXT_1HOP=PASS
EXTERNAL_TWO_NEIGHBORHOOD_COMPOSITION=PASS
FULL_GENOMIC_LINEAGE_RECOVERY=PASS
YODA_VERIFY=PASS
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

Frozen lineage bundle:

```text
99a4b9380e48ae703410c2bc54554c151b02475bc2f1d1e5ce64743802ed747b
```

See:

`cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/`

---

# Formal verification — AXIOM-YODA-PROOF-LINEAGE-001

This CASE deliberately moved Yoda into a qualitatively different authority model.

AXLE remained the external formal-verification authority.

Yoda was responsible only for preserving derivation state and evidence.

## Stage A0 — AXLE authority

A valid proof was accepted:

```text
AXLE_POSITIVE_VERIFICATION=PASS
```

A controlled mutation that was itself valid Lean was rejected because it proved a different theorem:

```text
CONTROLLED_MUTATION_VALID_LEAN=PASS
AXLE_CONTROLLED_REJECTION=PASS
```

Frozen environment:

```text
SELECTED_ENVIRONMENT=lean-4.34.0
SELECTED_LEAN_TOOLCHAIN=leanprover/lean4:v4.34.0
```

## Stage A1 — Yoda replay

Yoda stored the formal statement, proof artifacts, environment, verification evidence and explicit relations.

It then recovered the relevant artifacts byte-for-byte:

```text
YODA_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
```

Those recovered artifacts were submitted again to AXLE.

Positive path:

```text
A0_POSITIVE_OKAY=true
A1_POSITIVE_OKAY=true
AXLE_POSITIVE_DECISION_REPRODUCED=PASS
```

Negative path:

```text
A0_NEGATIVE_OKAY=false
A1_NEGATIVE_OKAY=false
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
```

The controlled mutation remained valid Lean after Yoda recovery and was rejected again for the expected signature mismatch:

```text
CONTROLLED_MUTATION_VALID_LEAN_AFTER_YODA=PASS
AXLE_NEGATIVE_REPLAY_FROM_YODA=PASS
```

Lineage was recovered for both paths:

```text
POSITIVE_DERIVATION_LINEAGE_RECOVERY=PASS
NEGATIVE_DERIVATION_LINEAGE_RECOVERY=PASS
PROOF_DERIVATION_REPLAY=PASS
```

Frozen identities:

```text
FORMAL_STATEMENT_SHA256=24bea18925bf1a4b9e1dddc4ea6b34bd0cba323d57de42bfdcfd79c1756d2ee9
VALID_PROOF_SHA256=0082af12ce4e8b8c249f90706c3c9b0264e1e0ebcf05e3d3ece25fdf76f79a29
CONTROLLED_MUTATION_SHA256=a74af4eb7a514a97163f7d86dd8216298e478763eade920f91e08b52e12fd392
A0_EVIDENCE_MANIFEST_SHA256=f6c1b0a71c4d4b706628ee42008ac2f1dd495f2861fa39899217d0f0e0c567b3
A1_EVIDENCE_MANIFEST_SHA256=94a0801e2a554a80c32228c1eb6edf4334d4ce59c27b75cb876e2171c0196c90
DATA_YODA_SHA256=b3cd12a421fe84b2728a65ddf474db0aa3ec0f9da7bc292c4f7608d9ff36ff8c
```

Important nuance:

AXLE response JSON is request-specific and therefore not expected to be byte-identical across requests. The validated property is **semantic verification-outcome replay using byte-exact recovered proof artifacts**.

Final classification:

```text
AXIOM_YODA_PROOF_LINEAGE_001=VALIDATED
FORMAL_AUTHORITY=AXLE
DERIVATION_AUTHORITY=YODA
PROOF_DERIVATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

See:

`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`

---

# What the combined evidence now suggests

The same small Yoda architecture has now demonstrated derivation recovery in two qualitatively different settings:

```text
empirical scientific workflow
→ genomics lineage

formal verification workflow
→ AXLE proof lineage
```

This supports — but does not prove — the hypothesis that verifiable derivation may be a cross-domain property.

No `Genome Mode` was added.
No `Math Mode` was added.
No Yoda or Kyber engine change was required for the AXLE CASE.

---

# What is not proven

The evidence does not establish:

```text
general-purpose lineage engine
biotech-scale operation
arbitrary theorem-proving workflow support
logical validity independent of AXLE
biological truth
clinical validity
product-market fit
production readiness for all workloads
```

Those remain open questions.

---

# Next external test

## BIO-DESIGN-LINEAGE-001

The next adversary should be an externally chosen empirical R&D workflow.

Question:

> Given a final candidate from a Design-Build-Test-Learn workflow, can Yoda reconstruct which designs, builds, tests, analyses and evidence led to that candidate without adding biology-specific storage features?

If that passes, Yoda will have survived both formal and empirical external workflows.

That would be stronger evidence for the broader thesis.

It would still not be proof of a market.
