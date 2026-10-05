# Research Program

Yoda's next phase is designed to test whether verifiable derivation survives outside workflows we designed ourselves.

The goal is not to accumulate features.

The goal is to expose the same small architecture to qualitatively different forms of pressure.

---

## Research question

> **Is verifiable derivation a cross-domain property, or only an artifact of the workflows we have already tested?**

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

The next experiments should fail if those primitives are insufficient.

---

# Track A — Formal reasoning

## AXIOM-YODA-PROOF-LINEAGE-001

Axiom's AXLE provides public infrastructure for checking and manipulating Lean proof artifacts.

This makes it a useful external authority for a controlled experiment.

### Question

> Can Yoda preserve and reconstruct the complete derivation lineage of a formally verified proof such that recovered artifacts can be submitted again to AXLE and reproduce the original verification outcome?

### Positive arm

```text
formal statement
      +
candidate proof
      ↓
AXLE verification
      ↓
valid result
      ↓
Yoda lineage
      ↓
recover artifacts
      ↓
AXLE verification again
      ↓
same valid result
```

### Negative arm

```text
valid proof
    ↓
controlled mutation
    ↓
AXLE rejection
    ↓
Yoda preserves both derivations and outcomes
```

### Separation of authority

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

Yoda must not pretend to verify mathematics.

AXLE remains the formal authority.

### External references

- Axiom mission: https://axiommath.ai/mission/
- AXLE release: https://axiommath.ai/research/releasing-axle/
- AXLE docs: https://axle.axiommath.ai/v1/docs/

---

# Track B — Empirical biology

## BIO-DESIGN-LINEAGE-001

The second track should use a biological R&D workflow selected by an external scientific team.

### Question

> Given a final candidate from a Design-Build-Test-Learn workflow, can Yoda reconstruct which designs, builds, tests, analyses and evidence led to that candidate?

A minimal workflow might look like:

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
show the lineage
       ↓
design + build + test + analysis + evidence
```

The first experiment does not require confidential sequence contents.

Artifact IDs, hashes, versions, relationships and redacted evidence may be sufficient to test the lineage hypothesis.

### Separation of authority

```text
domain scientists
→ biological and experimental validity

Yoda
→ derivation integrity
```

Yoda must not pretend to validate biology.

---

# Track C — Artifact provenance

## Future: SYNTHID-BIO-YODA-PROVENANCE-001

Google DeepMind's SynthID Bio suggests a complementary provenance model in which an origin signal can travel inside an AI-generated biological artifact.

Yoda is exploring provenance around the artifact across an external workflow.

A future question is:

> Can intrinsic artifact provenance and external workflow provenance compose into a stronger verification chain?

Conceptually:

```text
AI-generated biological artifact
       │
       ├── intrinsic provenance → watermark / origin signal
       │
       └── external provenance  → Yoda lineage
                                    ↓
                                 experiment
                                    ↓
                                  result
```

Reference:

- Google DeepMind SynthID Bio: https://deepmind.google/blog/introducing-synthid-bio/

This is future work, not a current capability claim.

---

# What would count as strong evidence

The next phase becomes interesting only if the system survives external pressure without domain-specific expansion.

Strong evidence would look like:

```text
formal workflow PASS
+
empirical workflow PASS
+
no Math Mode
+
no Biology Mode
+
no engine rewrite
```

That would support — but not prove — the hypothesis:

```text
VERIFIABLE_DERIVATION
may be a cross-domain property
```

---

# What would falsify the thesis

Useful negative results include:

- lineage cannot be recovered without embedding domain semantics into the core;
- bounded context becomes unusable outside toy workloads;
- external workflows require arbitrary graph planning to remain understandable;
- provenance data overwhelms the value of the underlying result;
- developers do not find reconstructed derivation useful;
- existing systems already solve the problem more simply;
- external teams will not integrate the evidence contract into real workflows.

Any of these should change the roadmap.

---

# Commercial hypothesis

The commercial hypothesis is intentionally downstream from the technical one.

If generation becomes abundant, organizations may pay for infrastructure that makes high-value results traceable, inspectable and reproducible across tools and agents.

Potential environments include:

```text
AI science
biotechnology R&D
formal reasoning
autonomous software
regulated decision workflows
multi-agent research
```

But product-market fit remains open.

The next milestone is not a fundraising narrative.

It is external evidence strong enough that a fundraising narrative can be honest.
