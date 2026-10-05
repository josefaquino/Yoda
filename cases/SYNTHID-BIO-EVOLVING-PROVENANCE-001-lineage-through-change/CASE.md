# CASE — SYNTHID-BIO-EVOLVING-PROVENANCE-001

## Status

```text
CASE_STATUS=PLANNED
TRANSFORMATION_CONTRACT_002=FROZEN
INSTANCE_CONTRACT=FROZEN_BEFORE_G_B
NEXT_GATE=A0_INSTANCE_AUTHORITY_AND_PRE_YODA_MEASUREMENT
YODA_WRITES=ZERO
```

## Research question

> **Can Yoda preserve a versioned derivation across a controlled biological artifact transformation while an independent authority continues evaluating each state independently?**

This CASE is about **lineage through change**.

It does not ask whether a watermark survives a transformation.
It asks whether two legitimately different states can retain distinct identities, measurements, evidence and an explicit derivation relationship.

---

## Why this is a new question

```text
GENOME-LINEAGE-001
Where did this result come from?

AXIOM-YODA-PROOF-LINEAGE-001
Can an independent authority reproduce its decision after Yoda recovery?

SYNTHID-BIO-YODA-PROVENANCE-001
Can intrinsic artifact provenance coexist with external workflow provenance?

SYNTHID-BIO-EVOLVING-PROVENANCE-001
How did this artifact become what it is now?
```

The object under test is no longer only state or static lineage.
It is **change itself**.

---

## Transformation authority

The Google DeepMind SynthID Bio paper explicitly discusses legitimate manual post-design modification, including addition of a C-terminal expression tag, and publishes the C-terminal tags used in its SC2RBD and VEGF-A experimental constructs.

Frozen transformation:

```text
TRANSFORMATION_CLASS=C_TERMINAL_TAG_ADDITION
SOURCE_STATE=PDW_0903
TARGET=VEGFA
SOURCE_SETTING=watermark_0.1

GFP11=RDHMVLHEYVNAAGIT
TWIN_STREP=WSHPQFEKGGGSGGGSGGSAWSHPQFEK

B = A || GFP11 || TWIN_STREP
```

The earlier resequencing contract is retained as research history. It was not selected for execution because the exact AlphaProteo binder-target complex structures used in the paper’s resequencing attack are not exposed as a directly replayable public A→B instance in the frozen repository.

See:

- `TRANSFORMATION-CONTRACT.md` — initial resequencing investigation;
- `TRANSFORMATION-CONTRACT-002.md` — executable direct-change contract;
- `INSTANCE-CONTRACT.md` — concrete A→B selection frozen before g(B).

---

## Anti-cherry-picking rule

Artifact A was selected before transformed-state measurement using only public metadata and deterministic file order:

```text
Plate Target ID = VEGFA
Subset_Name = watermark_0.1
binding = TRUE
first unique design in source-file order
```

Result:

```text
ARTIFACT_A_ID=PDW_0903
BACKBONE_ID=Backbone 0
```

The value of `g(B)` is deliberately absent from the instance contract.
If it is surprising, the instance is not replaced.

---

## Authority separation

```text
Google DeepMind / Nature paper
→ external scientific authority for the recognized post-design modification
→ authority for published tag sequences

Google DeepMind public dataset
→ authority for Artifact A sequence and metadata

SynthID Bio detector
→ independent intrinsic provenance measurement of each state

Yoda
→ derivation integrity
```

Yoda is not the biological authority, watermark detector or transformation authority.

---

## State model

```text
Artifact A
PDW_0903
watermarked public source state
      │
      ├── measured-by ─────► SynthID Bio detector
      ├── has-measurement ─► g(A)
      │
      └── transformed-by ──► append GFP11 + Twin-Strep
                                │
                                ▼
                           Artifact B
                           tagged derivative
                                │
                                ├── derived-from ─────► Artifact A
                                ├── measured-by ──────► SynthID Bio detector
                                └── has-measurement ──► g(B)
```

---

## Critical distinction

The CASE does **not** require:

```text
g(A) = g(B)
```

Legitimate change may alter the external measurement.

Required property:

```text
SHA(A') = SHA(A)
SHA(B') = SHA(B)

g(A') = g(A)
g(B') = g(B)

B derived-from A = recoverable
transformation evidence = recoverable
```

where `A'` and `B'` are Yoda-recovered artifacts.

---

## Planned stages

### Stage A0 — Instance authority + pre-Yoda measurement

- reverify frozen DeepMind commit and detector;
- rederive PDW_0903 from the public dataset using the frozen selection rule;
- construct B deterministically from A and the published tags;
- freeze A and B identities;
- independently measure g(A) and g(B) with the official detector;
- perform zero Yoda writes.

### Stage B — Versioned derivation in Yoda

Store A, B, measurements, source authority, transformation evidence and explicit relations.

Required relation:

```text
B derived-from A
```

### Stage C — Independent replay after recovery

Recover A and B byte-exactly from Yoda and rerun the same official detector independently on each state.

PASS requires:

```text
SHA(A') = SHA(A)
SHA(B') = SHA(B)
g(A') = g(A)
g(B') = g(B)
VERSIONED_DERIVATION_RECOVERY=PASS
LINEAGE_THROUGH_CHANGE=PASS
```

---

## Forbidden shortcuts

The CASE must not:

- redefine watermark robustness as a Yoda responsibility;
- require the transformed artifact to preserve the original g-value;
- choose another artifact after observing g(B);
- infer biological function from provenance metadata;
- call Yoda a SynthID detector;
- modify Yoda or Kyber pre-emptively;
- replace the official detector with a Yoda-native implementation;
- claim Google DeepMind participation or endorsement;
- treat a legitimately transformed artifact as corruption merely because its bytes differ from A.

---

## Success claim

If all planned gates pass, the permitted narrow claim will be:

> **For one controlled biological artifact transformation, Yoda preserved the distinct identities, measurements, evidence and derivation relationship of the pre- and post-transformation states such that an independent detector reproduced each state’s original measurement after byte-exact recovery.**

Or more compactly:

> **Yoda preserved lineage through change.**

---

## Non-claims

This CASE will not establish watermark robustness, preservation of biological function, protein safety, biological truth, general-purpose biological versioning, arbitrary transformation support, production readiness or product-market fit.

---

## Research principle

```text
State can change legitimately.
Identity must remain explicit.
Derivation must remain recoverable.
Authority must remain independent.
```
