# Research Program

Yoda's research program asks whether **verifiable derivation** survives across qualitatively different authority models and across meaningful state transitions without domain-specific expansion.

The goal is not to accumulate features.

The goal is to expose the same small architecture to different forms of pressure.

---

## Central research questions

The program now has three connected questions:

> **Can the same derivation layer preserve enough evidence, identity and lineage for different independent authorities to evaluate a result again later?**

and:

> **Can the same derivation layer preserve how a result changed from one independently identifiable state into another?**

and:

> **Can the same derivation layer preserve why a deterministic system made a particular decision at a particular point in time, including the evidence needed to reproduce that decision later?**

Current architecture:

```text
identity
+
evidence
+
relations
+
history
+
verification
+
bounded context
```

The current thesis is not that Yoda should become the authority of truth.

It is the opposite:

> **Yoda does not need to be the authority that decides whether something is true. Yoda preserves the derivation required for independent authorities to decide again.**

A second thesis now follows from the validated evolving-provenance CASE:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

---

# Research pattern — Independent Authority Replay

Multiple CASEs now expose the same pattern:

```text
independent authority
        ↓
measurement / decision
        ↓
       Yoda
        ↓
recovery + lineage
        ↓
same independent authority
        ↓
same measurement / decision
```

We use **independent authority replay** as an internal research name for this pattern.

It is not a claim of universal product capability.

---

# Track A — Formal reasoning

## AXIOM-YODA-PROOF-LINEAGE-001 — VALIDATED

AXLE was used as the external formal-verification authority.

### Question

> Can Yoda preserve and reconstruct the derivation lineage of a formally verified result such that recovered artifacts can be submitted again to AXLE and reproduce the original formal verification outcome?

### Result

```text
AXIOM_YODA_PROOF_LINEAGE_001=VALIDATED
YODA_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
AXLE_POSITIVE_DECISION_REPRODUCED=PASS
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
PROOF_DERIVATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

### Authority separation

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

Yoda did not become a theorem prover and no Math Mode was added.

See:

`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`

---

# Track B — Artifact provenance

## SYNTHID-BIO-YODA-PROVENANCE-001 — VALIDATED

Google DeepMind's public SynthID Bio implementation provided a different authority model: an intrinsic provenance signal measured from the biological artifact itself.

### Question

> Can intrinsic artifact provenance and external workflow provenance coexist, survive Yoda persistence and recovery, and remain independently measurable afterward?

### Result

```text
SYNTHID_BIO_YODA_PROVENANCE_001=VALIDATED
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Exact replay matrix:

```text
CONTROL      0.5037 → 0.5037
CONTROL      0.5130 → 0.5130
WATERMARKED  0.7961 → 0.7961
WATERMARKED  0.7184 → 0.7184
```

### Authority separation

```text
SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity
```

Yoda did not become a watermark detector.

No SynthID Mode was added.

See:

`cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/`

---

# Track C — Evolving provenance

## SYNTHID-BIO-EVOLVING-PROVENANCE-001 — VALIDATED

This CASE moved from preserving provenance around a fixed artifact to preserving derivation across a controlled state transition.

### Question

> **Can Yoda preserve a versioned derivation across a controlled biological artifact transformation while an independent authority continues evaluating each state independently?**

Conceptually:

```text
State A
  ↓
Transformation T
  ↓
State B
```

with:

```text
identity(A) != identity(B)
```

### Observed transition

```text
Artifact A
measurement=0.7961

        ↓ 6 controlled substitutions

Artifact B
measurement=0.6990
```

Yoda preserved both endpoint states, the derivation relation, transformation evidence, mutation evidence, state-specific measurements and authority references.

After byte-exact recovery, the frozen independent detector reproduced each state's original measurement:

```text
A  0.7961 → 0.7961
B  0.6990 → 0.6990
```

### Result

```text
SYNTHID_BIO_EVOLVING_PROVENANCE_001=VALIDATED
LINEAGE_OF_CHANGE=DEMONSTRATED
ARTIFACT_A_BYTE_EXACT_RECOVERY=PASS
ARTIFACT_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
MUTATION_TABLE_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
STATE_SPECIFIC_MEASUREMENT_REPLAY=PASS
INDEPENDENT_STATE_REPLAY=PASS
LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

### Formal property

The CASE supports the property definition:

```text
Lineage of Change
=
derivation integrity across state transitions
```

See:

- `cases/SYNTHID-BIO-EVOLVING-PROVENANCE-001-lineage-of-change/`
- `properties/LINEAGE-OF-CHANGE.md`

The biological domain is the validating environment, not the product definition.

---

# Demonstrated property — Lineage of Change

The property formalization separates endpoint identity from transition lineage.

For a recorded transition:

```text
A = prior state
T = transformation evidence
B = resulting state
```

Lineage of Change is preserved when the evidence system can recover:

```text
A
B
identity(A) != identity(B)
B --derived-from--> A
B --transformed-by--> T
state-specific evidence(A)
state-specific evidence(B)
relevant authority references
```

The validating CASE added independent state-specific replay:

```text
E(recover(A)) = E(A)
E(recover(B)) = E(B)
```

where `E` remained an external authority.

This does not mean Yoda determines whether an arbitrary transformation is legitimate.

See [`properties/LINEAGE-OF-CHANGE.md`](properties/LINEAGE-OF-CHANGE.md).

---

# Track D — Decision Lineage

## MARKET-REGIME-LINEAGE-001 — VALIDATED

This CASE moved from artifact and proof transitions into deterministic decision history.

### Question

> **Can Yoda preserve successive deterministic market-regime states and their derivation evidence such that independent implementations reproduce each original classification after recovery?**

Three point-in-time public-data states were frozen before classification.

Two independent authorities — C11 and POSIX awk — agreed byte-for-byte:

```text
A=STRESSED
B=FRAGILE
C=FRAGILE
```

Yoda then preserved the source snapshots, decision states, classification contract, authority implementations, original evaluation evidence and transition evidence.

The observed lineage included both:

```text
A -> B
STRESSED -> FRAGILE
classification_changed=YES
```

and:

```text
B -> C
FRAGILE -> FRAGILE
classification_changed=NO
underlying_evidence_changed=YES
```

Stage B recovered the snapshots and both authority implementations only from Yoda, replayed all three states and reproduced the original canonical bytes exactly.

### Result

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS
REPLAY_INPUT_SOURCE=YODA_GET_ONLY
DATA_YODA_IDENTITY_UNCHANGED=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Formal property:

```text
Decision Lineage
=
verifiable derivation of successive deterministic decisions
```

See:

- `cases/MARKET-REGIME-LINEAGE-001-decision-lineage/`
- `properties/DECISION-LINEAGE.md`

The market-data workflow is the validating environment, not the product definition.

---

# Track E — External empirical workflow

## EXTERNALLY DEFINED ITERATIVE WORKFLOW — NEXT

The strongest next falsification is no longer another internally designed demonstration.

It should be a real iterative workflow selected by an external scientific or engineering team.

A biological Design-Build-Test-Learn workflow remains one candidate, but the important requirement is external problem definition rather than domain label.

### Stronger question

> Given a current high-value result and a longer real history of meaningful transitions, can Yoda reconstruct which prior states, transformations, tests, analyses and evidence led to the current state without adding a domain-specific engine mode?

Conceptually:

```text
State A
  ↓
T1
  ↓
State B
  ↓
T2
  ↓
State C
  ↓
...
  ↓
Current result
```

The reverse query is the important one:

```text
current result
      ↓
show the derivation
      ↓
prior states + transitions + evidence + authorities
```

Domain systems remain responsible for domain validity.

Yoda remains responsible for derivation integrity.

---

# Evidence ladder

The research sequence is now:

```text
GENOME-LINEAGE-001
LINEAGE OF STATE
Where did this result come from?
        PASS

AXIOM-YODA-PROOF-LINEAGE-001
INDEPENDENT AUTHORITY REPLAY
Can the right authority decide again?
        PASS

SYNTHID-BIO-YODA-PROVENANCE-001
COMPOSED PROVENANCE
Can independent provenance layers coexist?
        PASS

SYNTHID-BIO-EVOLVING-PROVENANCE-001
LINEAGE OF CHANGE
How did this become what it is now?
        PASS

FORMAL-MATH-EVOLVING-DERIVATION-001
CROSS-DOMAIN LINEAGE OF CHANGE
Does the same property survive formal proof evolution?
        PASS

MARKET-REGIME-LINEAGE-001
DECISION LINEAGE
Why did the deterministic system decide this then,
and can the decision be reproduced from recovered evidence?
        PASS
```

The same small Yoda surface survived these settings without a Genome Mode, Math Mode, SynthID Mode, Change Mode or Market Mode.

This strengthens the hypothesis that **verifiable derivation may be a cross-domain infrastructure property**.

It does not prove that hypothesis.

---

# Project thesis

The current thesis is now recorded separately in [PROJECT-THESIS.md](PROJECT-THESIS.md).

Its public-level formulation is:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

The narrow demonstrated-property formulation is:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

The second sentence is supported within the scope of the validating CASE and must not be presented as a universal guarantee.

---

# What would count as stronger evidence

Stronger evidence would include:

```text
formal authority replay PASS
+
artifact-provenance replay PASS
+
single-transition Lineage of Change PASS
+
externally defined multi-transition workflow PASS
+
no domain-specific engine mode
+
no engine rewrite
```

That would strengthen the category thesis:

```text
VERIFIABLE DERIVATION INFRASTRUCTURE
```

---

# What would falsify or narrow the thesis

Useful negative results include:

- prior states cannot remain independently recoverable under realistic update workloads;
- derivation relationships become ambiguous as transitions accumulate;
- transformation evidence requires domain semantics inside the core;
- state-specific evidence becomes incorrectly attached across versions;
- independent replay requires special-case engine changes for every authority;
- bounded-context composition becomes impractical for longer change histories;
- provenance overhead overwhelms the value of the underlying result;
- byte-exact preservation is insufficient for meaningful real workflows;
- existing systems solve the problem more simply;
- external teams do not find reconstructed derivation useful.

Any of these should change the roadmap.

---

# Commercial hypothesis

As AI makes generation abundant, organizations may pay for infrastructure that makes high-value results traceable, inspectable and reproducible across tools, models, state transitions and independent authorities.

Potential environments include:

```text
AI-native science
biotechnology R&D
formal reasoning
autonomous software
regulated decision workflows
multi-agent research
```

The category hypothesis is:

> **Verifiable Derivation Infrastructure**

A possible market-facing description remains:

> **Trust infrastructure for AI-native science.**

Product-market fit remains open.

The near-term research sequence is:

```text
single-transition Lineage of Change
        PASS
        ↓
cross-domain formal Lineage of Change
        PASS
        ↓
Decision Lineage
        PASS
        ↓
external iterative workflow
        NEXT
        ↓
partner feedback
        ↓
product hypothesis
        ↓
commercial validation
```
