# Evidence

Yoda is developed through narrow, reproducible CASEs.

A successful demo is not treated as proof of a broad product or market claim.

Each CASE should answer one question, freeze its evidence, preserve negative results and make the next question clearer.

---

## Research rule

```text
one question
one hypothesis
one controlled experiment
explicit PASS / FAIL gates
frozen evidence
independent authority where possible
no speculative engine change
```

> **Big vision. Small steps. Evidence always.**

---

# Cross-domain evidence map

| CASE | Domain | Property tested | Status |
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
| AXIOM-YODA-PROOF-LINEAGE-001 | Formal verification | independent formal decision replay | PASS |
| SYNTHID-BIO-YODA-PROVENANCE-001 | Biological artifact provenance | composed provenance + independent measurement replay | PASS |

Negative experiments and invalid harness attempts remain evidence when they are classified honestly.

---

# Genomics — scientific lineage

The genomics ladder moved from exact state to derivation:

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

`GENOME-LINEAGE-001` recovered the bounded lineage behind a controlled genomic result without a Genome Mode.

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

# AXLE — independent formal authority replay

`AXIOM-YODA-PROOF-LINEAGE-001` moved Yoda into a different authority model.

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

A valid proof was accepted by AXLE. A controlled mutation was valid Lean but proved a different theorem and was rejected against the frozen formal statement.

Yoda stored the statement, proof artifacts, environment, verification evidence and explicit relations, then recovered the proof artifacts byte-for-byte.

AXLE reproduced both decisions from Yoda-recovered artifacts:

```text
A0_POSITIVE_OKAY=true
A1_POSITIVE_OKAY=true
AXLE_POSITIVE_DECISION_REPRODUCED=PASS

A0_NEGATIVE_OKAY=false
A1_NEGATIVE_OKAY=false
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS

PROOF_DERIVATION_REPLAY=PASS
```

Frozen evidence:

```text
FORMAL_STATEMENT_SHA256=24bea18925bf1a4b9e1dddc4ea6b34bd0cba323d57de42bfdcfd79c1756d2ee9
VALID_PROOF_SHA256=0082af12ce4e8b8c249f90706c3c9b0264e1e0ebcf05e3d3ece25fdf76f79a29
CONTROLLED_MUTATION_SHA256=a74af4eb7a514a97163f7d86dd8216298e478763eade920f91e08b52e12fd392
A0_EVIDENCE_MANIFEST_SHA256=f6c1b0a71c4d4b706628ee42008ac2f1dd495f2861fa39899217d0f0e0c567b3
A1_EVIDENCE_MANIFEST_SHA256=94a0801e2a554a80c32228c1eb6edf4334d4ce59c27b75cb876e2171c0196c90
DATA_YODA_SHA256=b3cd12a421fe84b2728a65ddf474db0aa3ec0f9da7bc292c4f7608d9ff36ff8c
```

Important nuance: AXLE response bytes are request-specific. The validated property is semantic accept/reject replay using byte-exact recovered proof artifacts.

See:

`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`

---

# SynthID Bio — composed provenance

`SYNTHID-BIO-YODA-PROVENANCE-001` tested a new question:

> Can an intrinsic provenance signal inside a biological artifact coexist with external workflow provenance around that artifact, survive Yoda persistence and recovery, and remain independently measurable afterward?

Authority separation:

```text
Google DeepMind SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity
```

## Stage A0 — external oracle

The official public repository was frozen at:

```text
DEEPMIND_COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

The official control, watermarked and standalone detector tests were reproduced before Yoda entered the experiment.

```text
OFFICIAL_NON_WATERMARKED_TEST=PASS
OFFICIAL_WATERMARKED_TEST=PASS
OFFICIAL_G_VALUE_TEST=PASS
OFFICIAL_STANDALONE_DETECTOR=PASS
EXPECTED_G_VALUES=PASS
YODA_WRITES=ZERO
```

## Stage A1 — Yoda composition

Yoda stored eight objects and eleven relations covering the control and watermarked artifacts, measurements, external authority, parameters and evidence.

```text
YODA_OBJECT_INGEST=PASS
COMPOSED_PROVENANCE_RELATIONS=PASS
CONTROL_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
WATERMARKED_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
ORACLE_PARAMETERS_BYTE_EXACT_RECOVERY=PASS
COMPOSED_PROVENANCE_CONTEXT=PASS
FINAL_YODA_VERIFY=PASS
```

The detector was not rerun in A1.

## Stage B — detector replay

Only the artifacts recovered from Yoda were submitted to the frozen SynthID Bio detector.

```text
ARM          SAMPLE   BEFORE   AFTER
CONTROL      1        0.5037   0.5037
CONTROL      2        0.5130   0.5130
WATERMARKED  1        0.7961   0.7961
WATERMARKED  2        0.7184   0.7184
```

```text
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
CONTROL_SIGNAL_NOT_FABRICATED=PASS
WATERMARKED_SIGNAL_MEASUREMENT_PRESERVED=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
```

Frozen evidence:

```text
CONTROL_5L33_SHA256=77aaf2a4d2fa522f84280420d1605f28c78a1913bd39e9ac4b628d45e3681a4f
WATERMARKED_5L33_SHA256=16ce25bd9f444efcf3dd4adfd7b1732b5adc3f35289f6e498aa3ceabf0d0a1f4
A0_EVIDENCE_MANIFEST_SHA256=3114caf012ee41f3be15dae292f688299e872cef180dd3073750f05a4cee038e
A1_EVIDENCE_MANIFEST_SHA256=8a8a5482bcd2b691bef8fb155c310633d3cbddaf171fb5a11f98b386406c9272
B_EVIDENCE_MANIFEST_SHA256=e89730407d3d3ee6b76d76e4c0d9f8949a09ba90ccee585e1fc9113209693256
DATA_YODA_SHA256=3170d81272ae37a7d8ca4bddebf546ca9cced08a06c864f0f128a59da5facd60
```

See:

`cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/`

---

# Emerging architectural pattern

Across AXLE and SynthID Bio, the same pattern appeared:

```text
independent authority
        ↓
measurement / decision
        ↓
       Yoda
        ↓
exact recovery + lineage
        ↓
same independent authority
        ↓
same measurement / decision
```

We refer to this as an **independent authority replay** pattern.

The evidence supports a narrow architectural thesis:

> **Yoda does not need to be the authority that decides whether something is true. Yoda can preserve the derivation required for independent authorities to decide again.**

This pattern has now been demonstrated in two qualitatively different authority models:

```text
AXLE
→ semantic formal decision replay

SynthID Bio
→ intrinsic provenance measurement replay
```

Genomics provides a third, empirical lineage context.

This is evidence that verifiable derivation may travel across domains.
It is not proof that the property is universal.

---

# Composed provenance

The SynthID Bio CASE introduced another useful distinction:

```text
inside the artifact
→ intrinsic provenance signal

outside the artifact
→ workflow provenance / derivation
```

The controlled CASE demonstrated that these layers can coexist while preserving the independent detector measurement.

`COMPOSED_PROVENANCE=PASS` is therefore a demonstrated CASE property, not a claim that Yoda generally solves provenance for all artifact types.

---

# What is not proven

The evidence does not establish:

```text
general-purpose truth engine
general-purpose provenance platform
proof of authorship or ownership
biological truth or clinical validity
arbitrary theorem-proving workflow support
arbitrary watermark support
biotech-scale operation
production readiness for all workloads
product-market fit
Google DeepMind or Axiom endorsement
```

Domain authorities remain responsible for domain validity.

---

# Next external falsification

## BIO-DESIGN-LINEAGE-001

The strongest next test is a real biological R&D question selected by an external scientific team.

> Given a final candidate from a Design-Build-Test-Learn workflow, can Yoda reconstruct which designs, builds, tests, analyses and evidence led to that candidate without adding biology-specific storage features?

That test should be partner-defined.

The goal is not another format demo. The goal is to expose the same small architecture to a workflow that was not designed around Yoda.