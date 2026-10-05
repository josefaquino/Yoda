# Research Program

Yoda's current research program asks whether **verifiable derivation** survives across qualitatively different authority models without domain-specific expansion.

The goal is not to accumulate features.

The goal is to expose the same small architecture to different forms of pressure.

---

## Research question

> **Is verifiable derivation a cross-domain property, or only an artifact of the workflows we designed ourselves?**

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

---

# Track A — Formal reasoning

## AXIOM-YODA-PROOF-LINEAGE-001 — VALIDATED

AXLE was used as the external formal-verification authority.

### Question

> Can Yoda preserve and reconstruct the complete derivation lineage of a formally verified proof such that recovered artifacts can be submitted again to AXLE and reproduce the original formal verification outcome?

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

### Positive arm

```text
formal statement
      +
candidate proof
      ↓
AXLE accepts
      ↓
Yoda preserves derivation
      ↓
byte-exact artifact recovery
      ↓
AXLE accepts again
```

### Negative arm

The controlled mutation was valid Lean but proved a different theorem.

```text
controlled mutation
      ↓
Lean check succeeds
      ↓
AXLE rejects against frozen statement
      ↓
Yoda preserves derivation
      ↓
byte-exact artifact recovery
      ↓
Lean check still succeeds
      ↓
AXLE rejects again
```

### Authority separation

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

This separation held.

Yoda did not become a theorem prover and no `Math Mode` was added.

See:

`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`

External references:

- Axiom: https://axiommath.ai/
- AXLE: https://axiommath.ai/research/releasing-axle/
- AXLE docs: https://axle.axiommath.ai/v1/docs/

---

# Track B — Empirical biology

## BIO-DESIGN-LINEAGE-001 — NEXT

The next track should use a biological R&D workflow selected by an external scientific team.

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

### Authority separation

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

- https://deepmind.google/blog/introducing-synthid-bio/

This is future work, not a current capability claim.

---

# What changed after Track A

Before the AXLE experiment, cross-domain derivation was only a hypothesis.

Now we have two distinct demonstrations:

```text
GENOME-LINEAGE-001
empirical scientific lineage
        PASS

AXIOM-YODA-PROOF-LINEAGE-001
formal proof derivation replay
        PASS
```

This is evidence that the abstraction may travel across domains.

It is not enough to call the hypothesis proven.

The strongest next falsification attempt is an externally chosen empirical workflow that was not designed around Yoda.

---

# What would count as stronger evidence

```text
formal workflow PASS
+
external empirical workflow PASS
+
no Math Mode
+
no Biology Mode
+
no engine rewrite
```

That would strengthen the hypothesis:

```text
VERIFIABLE_DERIVATION
may be a cross-domain property
```

---

# What would falsify the thesis

Useful negative results include:

- lineage cannot be recovered without embedding domain semantics into the core;
- bounded context becomes unusable outside controlled workloads;
- external workflows require arbitrary graph planning to remain understandable;
- provenance data overwhelms the value of the underlying result;
- developers or scientists do not find reconstructed derivation useful;
- existing systems solve the problem more simply;
- external teams will not integrate the evidence contract into real workflows.

Any of these should change the roadmap.

---

# Commercial hypothesis

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

Product-market fit remains open.

The current sequence is therefore:

```text
formal external validation
        PASS
        ↓
empirical external validation
        NEXT
        ↓
partner feedback
        ↓
product hypothesis
        ↓
commercial validation
```
