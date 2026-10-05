# Research Program

Yoda's research program asks whether **verifiable derivation** survives across qualitatively different authority models without domain-specific expansion.

The goal is not to accumulate features.

The goal is to expose the same small architecture to different forms of pressure.

---

## Central research question

> **Can the same derivation layer preserve enough evidence, identity and lineage for different independent authorities to evaluate a result again later?**

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

---

# Research pattern — Independent Authority Replay

Two recent CASEs exposed the same pattern:

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

We use **independent authority replay** as an internal name for this pattern.

It is a research pattern, not yet a claim of universal product capability.

---

# Track A — Formal reasoning

## AXIOM-YODA-PROOF-LINEAGE-001 — VALIDATED

AXLE was used as the external formal-verification authority.

### Question

> Can Yoda preserve and reconstruct the derivation lineage of a formally verified result such that recovered artifacts can be submitted again to AXLE and reproduce the original formal verification outcome?

### Result

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

### Experimental structure

```text
SynthID Bio artifact
        ↓
official detector
        ↓
g-value measurement
        ↓
       Yoda
        ↓
byte-exact recovery
        ↓
official detector again
        ↓
same g-value measurement
```

The experiment included both a non-watermarked control and a watermarked positive arm.

### Result

```text
SYNTHID_BIO_YODA_PROVENANCE_001=VALIDATED
STAGE_A0=PASS
STAGE_A1=PASS
STAGE_B=PASS
DEEPMIND_ORACLE_REPRODUCED=PASS
CONTROL_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
WATERMARKED_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
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

# Composed provenance

The SynthID Bio CASE introduced a useful distinction:

```text
inside the artifact
→ intrinsic provenance signal

outside the artifact
→ workflow provenance / derivation
```

This CASE demonstrated that both layers can coexist while the independent measurement remains unchanged after Yoda recovery.

That makes **composed provenance** a demonstrated property of one controlled workflow.

It does not imply general support for arbitrary provenance systems.

---

# Track C — External empirical biology

## BIO-DESIGN-LINEAGE-001 — NEXT

The strongest next falsification attempt is no longer another internally defined biology demo.

It should be a real Design-Build-Test-Learn workflow or question selected by an external scientific team.

### Question

> Given a final candidate from a Design-Build-Test-Learn workflow, can Yoda reconstruct which designs, builds, tests, analyses and evidence led to that candidate without adding biology-specific storage features?

Conceptually:

```text
hypothesis
    ↓
design
    ↓
build
    ↓
test
    ↓
analysis
    ↓
selected candidate
```

The reverse query is the important one:

```text
selected candidate
       ↓
show the derivation
       ↓
design + build + test + analysis + evidence
```

### Authority separation

```text
domain scientists / domain systems
→ biological and experimental validity

Yoda
→ derivation integrity
```

Yoda must not pretend to validate biology.

The external team should define the problem before Yoda code or schema is added.

---

# What changed across the three major evidence blocks

The research sequence is now:

```text
GENOME-LINEAGE-001
empirical scientific lineage
        PASS

AXIOM-YODA-PROOF-LINEAGE-001
independent formal decision replay
        PASS

SYNTHID-BIO-YODA-PROVENANCE-001
independent provenance measurement replay
+
composed provenance
        PASS
```

The same small Yoda surface survived all three without a domain-specific engine mode.

This strengthens the hypothesis that **verifiable derivation may be a cross-domain infrastructure property**.

It does not prove that hypothesis.

---

# What would count as stronger evidence

```text
formal authority replay PASS
+
artifact-provenance replay PASS
+
external empirical workflow PASS
+
no Math Mode
+
no SynthID Mode
+
no Biology Mode
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

- lineage cannot be recovered without embedding domain semantics into the core;
- independent replay requires special-case integrations for every authority;
- bounded context becomes unusable outside controlled workloads;
- provenance data overwhelms the value of the underlying result;
- byte-exact preservation is insufficient for real scientific workflows;
- developers or scientists do not find reconstructed derivation useful;
- existing systems solve the problem more simply;
- external teams will not integrate the evidence contract into real workflows.

Any of these should change the roadmap.

---

# Commercial hypothesis

As AI makes generation abundant, organizations may pay for infrastructure that makes high-value results traceable, inspectable and reproducible across tools, models and independent authorities.

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

A possible market-facing description is:

> **Trust infrastructure for AI-native science.**

Product-market fit remains open.

The current sequence is therefore:

```text
formal authority replay
        PASS
        ↓
artifact provenance replay
        PASS
        ↓
external empirical workflow
        NEXT
        ↓
partner feedback
        ↓
product hypothesis
        ↓
commercial validation
```
