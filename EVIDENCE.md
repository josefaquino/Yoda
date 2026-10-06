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

Public claims should be traceable through:

```text
EVIDENCE
   ↓
FORMAL PROPERTY
   ↓
PROJECT THESIS
   ↓
PUBLIC LANGUAGE
```

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
| SYNTHID-BIO-EVOLVING-PROVENANCE-001 | Controlled evolving artifact | Lineage of Change + state-specific authority replay | PASS |
| FORMAL-MATH-EVOLVING-DERIVATION-001 | Formal mathematics | cross-domain Lineage of Change + independent Lean/OxiLean replay | PASS |
| MARKET-REGIME-LINEAGE-001 | Deterministic public-data decisions | Decision Lineage + Yoda-only independent classification replay | PASS |

Negative experiments and invalid harness attempts remain evidence when they are classified honestly.

---

# Genomics — Lineage of State

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

Question answered inside the CASE scope:

> **Where did this result come from?**

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

# SynthID Bio — Composed Provenance

`SYNTHID-BIO-YODA-PROVENANCE-001` tested whether intrinsic provenance inside an artifact and external workflow provenance around it could coexist and remain independently measurable after Yoda persistence and recovery.

Authority separation:

```text
Google DeepMind SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity
```

The public implementation was frozen at:

```text
DEEPMIND_COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

The official external detector behavior was reproduced before Yoda entered the experiment.

Yoda then stored the control and watermarked artifacts, measurements, authority identity, parameters and evidence.

Only Yoda-recovered artifacts were submitted to the frozen detector in the replay stage.

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

# Evolving provenance — Lineage of Change

`SYNTHID-BIO-EVOLVING-PROVENANCE-001` asked a different question:

> **Can a legitimate change create a new identity without destroying the verifiable lineage of what came before?**

The biological domain and SynthID Bio were the experimental environment, not the property definition.

The controlled transition was:

```text
Artifact A
SHA256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
measurement=0.7961

        │
        │ random-residue substitution
        │ 6 changed residues
        │ 5.660377% actual change
        ▼

Artifact B
SHA256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00
measurement=0.6990
```

The two states had distinct identities and distinct independent measurements.

## Yoda preservation

Yoda stored nine objects and eleven explicit relations covering:

```text
Artifact A
Artifact B
Measurement A
Measurement B
Transformation
Mutation table
Detector authority
Supplementary authority
Experimental evidence
```

The relation set included:

```text
B --derived-from--> A
B --transformed-by--> Transformation
A --has-measurement--> Measurement A
B --has-measurement--> Measurement B
Measurement A --measured-by--> Detector
Measurement B --measured-by--> Detector
```

Recovery gates:

```text
ARTIFACT_A_BYTE_EXACT_RECOVERY=PASS
ARTIFACT_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
MUTATION_TABLE_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
LINEAGE_OF_CHANGE_CONTEXT=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
FINAL_YODA_VERIFY=PASS
```

The validating Yoda state was:

```text
DATA_YODA_SHA256=0aac02391eec12c2caa2a0bca725af6ddcdab4530c2153002b6673a7e7729954
DATA_YODA_BYTES=9971
```

## Independent state-specific replay

Only the Yoda-recovered A and B states were sent back to the frozen SynthID Bio detector.

```text
G_A_BEFORE=0.7961
G_A_AFTER_RECOVERY=0.7961

G_B_BEFORE=0.6990
G_B_AFTER_RECOVERY=0.6990
```

```text
STATE_A_MEASUREMENT_EQUIVALENCE=PASS
STATE_B_MEASUREMENT_EQUIVALENCE=PASS
STATE_SPECIFIC_MEASUREMENT_REPLAY=PASS
INDEPENDENT_STATE_REPLAY=PASS
LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
```

Final homologation:

```text
SYNTHID_BIO_EVOLVING_PROVENANCE_001=VALIDATED
STAGE_A0=PASS
STAGE_A0_1=PASS
STAGE_A1=PASS
STAGE_A2=PASS
STAGE_B=PASS
LINEAGE_OF_CHANGE=DEMONSTRATED
INDEPENDENT_AUTHORITY_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
FINAL_EVIDENCE_INTEGRITY=PASS
```

Frozen authorities:

```text
A2_EVIDENCE_MANIFEST_SHA256=ab4e996f28d5d70995620f5d14d2e50886eec1d493955b31b419624fab735728
STAGE_B_EVIDENCE_MANIFEST_SHA256=6eba74b9b659db8950c3fd7d0e5b39b0c7fcae49fa2682023c3a528c7f87b8a7
REPLAY_CONTRACT_SHA256=ccdd19b43094b883f682e235a50fd21e06d1c4cfa08531560c9549768548d2c9
FINAL_EVIDENCE_MANIFEST_SHA256=e46bcb223be3264f97390abac792a889b5a79033d9ff55eb8f400c818ebcc17a
```

Formal property:

```text
Lineage of Change
=
derivation integrity across state transitions
```

See:

- `cases/SYNTHID-BIO-EVOLVING-PROVENANCE-001-lineage-of-change/`
- `properties/LINEAGE-OF-CHANGE.md`

---

# Evidence ladder

The demonstrated sequence is now:

```text
LINEAGE OF STATE
Where did this result come from?
        ↓
INDEPENDENT AUTHORITY REPLAY
Can the right authority evaluate it again?
        ↓
COMPOSED PROVENANCE
Can independent provenance layers coexist?
        ↓
LINEAGE OF CHANGE
How did this become what it is now?
        ↓
DECISION LINEAGE
Why did the deterministic system decide this then,
and can that decision be replayed from recovered evidence?
```

These are not separate engine modes.

They are increasingly strong observations of the same small derivation architecture.

---

# Emerging architectural pattern

Across AXLE and the two SynthID Bio CASEs, the authority remained external.

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

The evidence supports a narrow architectural thesis:

> **Yoda does not need to be the authority that decides whether something is true. Yoda can preserve the derivation required for independent authorities to decide again.**

The evolving-provenance CASE adds another demonstrated observation:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

That sentence is scoped to the validating CASE and is not a universal guarantee.

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
arbitrary state-transition support
native arbitrary multi-hop graph reasoning
production-scale long change histories
biotech-scale operation
product-market fit
Google DeepMind or Axiom endorsement
```

Domain authorities remain responsible for domain validity.

---

# Next external falsification

The strongest next test should be externally defined rather than another internal format or biology demonstration.

A useful target remains a real Design-Build-Test-Learn or other iterative workflow selected by an external team.

The stronger question is now not merely whether Yoda can recover a final candidate's ancestry, but whether it can preserve a longer sequence of meaningful state transitions without domain-specific engine changes.

That experiment should be defined by the external problem before Yoda code or schema is added.


---

# Decision Lineage — deterministic decision replay

`MARKET-REGIME-LINEAGE-001` extended the evidence program from artifact/proof state transitions to successive deterministic evaluations.

Three point-in-time source states produced:

```text
A=STRESSED
B=FRAGILE
C=FRAGILE
```

The transition record preserved both a label change and a stable-label/new-evidence transition:

```text
A -> B
STRESSED -> FRAGILE
CLASSIFICATION_CHANGED=YES

B -> C
FRAGILE -> FRAGILE
CLASSIFICATION_CHANGED=NO
UNDERLYING_EVIDENCE_CHANGED=YES
```

Yoda preserved 18 objects and 31 explicit relations, including source snapshots, decision states, the classification contract, two independent authority implementations, original evaluation evidence and transition evidence.

A2 demonstrated:

```text
BYTE_EXACT_RECOVERY=PASS
DECISION_LINEAGE_RELATION_RECOVERY=PASS
DECISION_LINEAGE_SEMANTICS=PASS
FINAL_YODA_VERIFY=PASS
```

B-R1 then recovered replay inputs only from the frozen Yoda store:

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY

REPLAY_AUTHORITY_1=PASS
REPLAY_AUTHORITY_2=PASS
REPLAY_AUTHORITY_EQUIVALENCE=PASS
REPLAY_VS_ORIGINAL_CANONICAL=PASS

STATE_A_INDEPENDENT_REPLAY=PASS
STATE_B_INDEPENDENT_REPLAY=PASS
STATE_C_INDEPENDENT_REPLAY=PASS

INDEPENDENT_CLASSIFICATION_REPLAY=PASS
```

All replayed result bytes matched:

```text
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba
```

The Yoda store remained byte-identical through replay:

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_SHA256_AFTER=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_IDENTITY_UNCHANGED=PASS
```

Final homologation:

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Formal property:

`properties/DECISION-LINEAGE.md`

This is an infrastructure/reproducibility result, not a market forecast or investment claim.
