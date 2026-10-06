# FORMAL-MATH-EVOLVING-DERIVATION-001

## Cross-domain Lineage of Change

This CASE asks whether a property first demonstrated with a controlled biological artifact survives in a radically different domain: **formal mathematics**.

The question is:

> **Can the same Yoda derivation model preserve the evolution of a formal proof and allow frozen formal authorities to reproduce their original evaluations after recovery?**

The experiment intentionally does not ask Yoda to prove mathematics. It asks whether Yoda can preserve the derivation around mathematical proof artifacts while formal authorities remain external.

---

## Current status

```text
A0
PASS
  |
  v
A1.0
mathd_algebra_182
NOT_EVALUATED
SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY
  |
  v
A1-R1
mathd_numbertheory_188
PASS
  |
  v
A2-R1 one-shot
NOT_EVALUATED
HARNESS_QUERY_TOKENIZATION_MISMATCH
  |
  v
A2 research question
PASS_BY_READ_ONLY_ADJUDICATION
  |
  v
B-R1
PASS
  |
  v
FINAL HOMOLOGATION
VALIDATED
```

A1.0 is preserved as a **negative result with positive methodological value**.

Lean accepted both proof states and `lean4export` exported them. OxiLean completed with zero rejected declarations but classified both target proof declarations as `unsupported` because they depended on an unsupported declaration closure in the Complex / commutative-ring dependency graph.

Therefore:

```text
MATHEMATICAL_REJECTION=NO
HARNESS_FAILURE=NO
YODA_FAILURE=NO
KYBER_FAILURE=NO

A1.0=NOT_EVALUATED
INTERPRETATION=CAPABILITY_BOUNDARY_DISCOVERED
```

The experiment discovered a capability boundary in the secondary authority rather than a mathematical disagreement between authorities.

See [RESULTS.md](RESULTS.md) and [ATTEMPTS/A1.0-CAPABILITY-BOUNDARY.md](ATTEMPTS/A1.0-CAPABILITY-BOUNDARY.md).

---

## Why this CASE exists

The evidence ladder is:

```text
GENOME-LINEAGE-001
-> Lineage of State

AXIOM-YODA-PROOF-LINEAGE-001
-> Independent Authority Replay

SYNTHID-BIO-YODA-PROVENANCE-001
-> Composed Provenance

SYNTHID-BIO-EVOLVING-PROVENANCE-001
-> Lineage of Change
```

The next question is not whether Yoda can do more biology. It is whether `Lineage of Change` is beginning to look like a property of the derivation model rather than a property of the biological environment in which it was first demonstrated.

---

## Public theorem source

The public statement authority remains the same frozen OpenAI MiniF2F repository:

```text
repository=openai/miniF2F
commit=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
```

### A1.0 workload — preserved historical attempt

```text
theorem=mathd_algebra_182
domain surface=Complex / commutative-ring hierarchy
status=NOT_EVALUATED
reason=secondary authority capability boundary
```

### A1-R1 workload — pre-registered revision

```text
theorem=mathd_numbertheory_188
target=Nat.gcd 180 168 = 12
status=PASS
execution_count=1
```

The hypothesis, domain, corpus, frozen commit, authorities, Yoda, and Kyber remain unchanged. Only the mathematical workload changes so that the two frozen formal authorities can actually evaluate the intended property.

See [ATTEMPTS/A1-R1-AUTHORITY-COMPATIBLE-WORKLOAD.md](ATTEMPTS/A1-R1-AUTHORITY-COMPATIBLE-WORKLOAD.md).

---

## Authority model

```text
MiniF2F
-> public mathematical statement authority

Lean / Mathlib
-> reference formal validity

OxiLean
-> independent formal re-checking

Yoda
-> derivation integrity

Kyber
-> durable state integrity
```

OxiLean's three buckets remain authoritative:

```text
verified
unsupported
rejected
```

`unsupported` is never silently treated as `verified`.

---

## Experiment stages

```text
A0
freeze external authorities
PASS
        |
        v
A1.0
Complex-dependent workload
NOT_EVALUATED
CAPABILITY BOUNDARY DISCOVERED
        |
        v
A1-R1
authority-compatible workload
Lean + OxiLean
Yoda writes = zero
        |
        v
A2
preserve versioned proof derivation in Yoda
        |
        v
B
recover from Yoda
re-run formal authorities
```

A1-R1 passed on its single pre-registered execution.

The A2-R1 one-shot is preserved as NOT_EVALUATED after a harness query-tokenization mismatch. No rerun was performed. The exact durable Yoda state produced by that execution was then adjudicated read-only.

The A2 research question passed by read-only adjudication:

```text
A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The durable state remained byte-identical throughout adjudication.

Stage B-R1 passed on its single pre-registered execution.

The proof states recovered from the frozen Yoda store reproduced the same Lean and OxiLean outcomes observed before Yoda preservation. The Lean4export byte identities also reproduced exactly, the derivation relations remained recoverable, and the authoritative `data.yoda` state remained byte-identical.

Final CASE status:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001=VALIDATED
CROSS_DOMAIN_LINEAGE_OF_CHANGE=DEMONSTRATED

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

This is evidence across two qualitatively different domains, not a universal guarantee.

---

## Working property under test

```text
CROSS_DOMAIN_LINEAGE_OF_CHANGE
```

The complete CASE passed. The cross-domain claim is demonstrated within the combined biological + formal-mathematics evidence scope.

---

## Research discipline

```text
one new domain
one controlled transition
one primary property
two deterministic formal authorities
zero preventive engine changes
negative results preserved
```

The A1.0 result is intentionally retained. A failed measurement is not necessarily a failed hypothesis.

> **The hypothesis remains unchanged. The instrument changed.**

See [WHY-WE-BUILT-THIS.md](WHY-WE-BUILT-THIS.md).

For the complete experiment contract, see [CASE.md](CASE.md).  
For execution, see [RUNBOOK.md](RUNBOOK.md).  
For observed results, see [RESULTS.md](RESULTS.md).
