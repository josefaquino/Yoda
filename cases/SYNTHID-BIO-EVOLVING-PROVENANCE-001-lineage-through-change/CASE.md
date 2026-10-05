# CASE — SYNTHID-BIO-EVOLVING-PROVENANCE-001

## Status

```text
CASE_STATUS=PLANNED
TRANSFORMATION_CONTRACT=FROZEN
CODE_WRITING=NO
YODA_WRITES=ZERO
```

## Research question

> **Can Yoda preserve a versioned derivation across a controlled biological artifact transformation while an independent authority continues evaluating each state independently?**

This CASE is about **lineage through change**.

It does not ask whether a watermark survives a transformation.
It asks whether two legitimately different states can retain distinct identities, measurements, evidence and an explicit derivation relationship.

---

## Why this is a new question

Previous CASEs tested different properties:

```text
GENOME-LINEAGE-001
Where did this result come from?

AXIOM-YODA-PROOF-LINEAGE-001
Can an independent authority reproduce its decision after Yoda recovery?

SYNTHID-BIO-YODA-PROVENANCE-001
Can intrinsic artifact provenance coexist with external workflow provenance?
```

This CASE asks:

```text
How did this artifact become what it is now?
```

The object under test is no longer only state or static lineage.
It is **change itself**.

---

## Transformation authority

The transformation model is taken from the Google DeepMind SynthID Bio paper:

**Stutz et al., “Function-preserving watermarking of AI-generated proteins,” Nature (2026).**

The paper describes a SynthIDBio-sequence robustness experiment in which a watermarked binder is **resequenced with non-watermarked ProteinMPNN at the default sampling temperature of 0.1**.

The transformation is therefore frozen as:

```text
TRANSFORMATION_CLASS=RESEQUENCING
TRANSFORMATION_TOOL=ProteinMPNN
TRANSFORMATION_MODE=NON_WATERMARKED
SAMPLING_TEMPERATURE=0.1
SOURCE_STATE=WATERMARKED_BINDER
TARGET_STATE=RESEQUENCED_BINDER
```

The paper reports that this attack substantially reduces or removes the watermark signal. That behavior is not the property under test here.

---

## Authority separation

```text
Google DeepMind paper
→ transformation-method authority

ProteinMPNN
→ transformation execution

SynthID Bio detector
→ intrinsic provenance measurement

Yoda
→ derivation integrity
```

Yoda must not become the biological authority, the watermark detector or the transformation tool.

---

## Planned state model

```text
Artifact A
watermarked source state
      │
      ├── measured-by ─────► SynthID Bio detector
      ├── has-measurement ─► g(A)
      │
      └── transformed-by ──► non-watermarked ProteinMPNN
                                │
                                ▼
                           Artifact B
                           resequenced state
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

A legitimate transformation may change the measurement.

The required property is state-specific reproducibility:

```text
SHA(A') = SHA(A)
SHA(B') = SHA(B)

g(A') = g(A)
g(B') = g(B)

B derived-from A = recoverable
transformation evidence = recoverable
```

where `A'` and `B'` are artifacts recovered from Yoda.

---

## Planned stages

### Stage A0 — Transformation authority

Freeze the scientific and software authority for the transformation before any Yoda write.

Required gates:

```text
DEEPMIND_PAPER_AUTHORITY=PASS
RESEQUENCING_ATTACK_DOCUMENTED=PASS
TRANSFORMATION_TOOL_AUTHORITY=PASS
TRANSFORMATION_PARAMETERS_FROZEN=PASS
TRANSFORMATION_CONTRACT=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

### Stage A1 — Produce state A and state B

Generate or select one watermarked source state A, measure it with the official detector, apply the frozen resequencing transformation, then independently measure state B.

No Yoda write is required until both states and their measurements are independently frozen.

### Stage B — Versioned derivation in Yoda

Store A, B, measurements, tool identities, parameters, transformation evidence and explicit relations.

Required relationship:

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
- infer biological function from provenance metadata;
- call Yoda a SynthID detector;
- modify Yoda or Kyber pre-emptively;
- replace the official detector with a Yoda-native implementation;
- claim Google DeepMind participation or endorsement;
- treat a transformed artifact as corruption merely because its bytes differ from the source state.

---

## Success claim

If all planned gates pass, the permitted narrow claim will be:

> **For one controlled biological transformation, Yoda preserved the distinct identities, measurements, evidence and derivation relationship of the pre- and post-transformation states such that an independent detector could reproduce each state’s original measurement after byte-exact recovery.**

A shorter research formulation is:

> **Yoda preserved lineage through change.**

---

## Non-claims

This CASE will not establish:

- watermark robustness;
- watermark resistance to attack;
- preservation of biological function;
- protein safety;
- biological truth;
- general-purpose biological versioning;
- arbitrary transformation support;
- production readiness;
- product-market fit.

---

## Research principle

```text
State can change legitimately.
Identity must remain explicit.
Derivation must remain recoverable.
Authority must remain independent.
```
