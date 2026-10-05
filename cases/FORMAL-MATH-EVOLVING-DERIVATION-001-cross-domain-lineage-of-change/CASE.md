# CASE — FORMAL-MATH-EVOLVING-DERIVATION-001

## Question

> **Can the same Yoda derivation model that demonstrated Lineage of Change for a controlled biological artifact preserve a semantics-preserving evolution of a formal proof such that independent formal checking can be reproduced after recovery, without changing Yoda or Kyber?**

This CASE is a cross-domain test of the property formalized in `properties/LINEAGE-OF-CHANGE.md`.

The new domain is **formal mathematics**.

The goal is not to prove that Yoda understands mathematics. The goal is to test whether the same state / transformation / derivation / evidence model survives a radically different artifact type.

---

## Hypothesis

```text
LINEAGE_OF_CHANGE
BIOLOGICAL_ARTIFACT -> demonstrated
FORMAL_PROOF        -> test now
```

The hypothesis did **not** change after A1.0.

A1.0 was not a mathematical rejection. It was a measurement that reached the current capability boundary of the secondary authority.

---

## Public source authority

The statement authority is the public OpenAI `miniF2F` benchmark.

Frozen repository:

```text
REPOSITORY=openai/miniF2F
COMMIT=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
```

The dataset is statement authority, not proof authority.

### A1.0 source workload — historical and frozen

```text
THEOREM=mathd_algebra_182
TARGET=forall y : Complex, 7 * (3 * y + 2) = 21 * y + 14
```

A1.0 is preserved unchanged as a capability-boundary discovery.

### A1-R1 source workload — pre-registered revision

```text
THEOREM=mathd_numbertheory_188
TARGET=Nat.gcd 180 168 = 12
```

The revision is permitted because the experiment is not testing OxiLean's coverage of Complex or Mathlib. It is testing Lineage of Change in formal mathematics under two frozen authorities.

The revision changes only the workload:

```text
HYPOTHESIS_CHANGED=NO
DOMAIN_CHANGED=NO
CORPUS_CHANGED=NO
CORPUS_COMMIT_CHANGED=NO
AUTHORITIES_CHANGED=NO
YODA_CHANGED=NO
KYBER_CHANGED=NO
WORKLOAD_CHANGED=YES
```

---

## Frozen formal environment

```text
LEAN_TOOLCHAIN=leanprover/lean4:v4.32.0-rc1
LEAN_GITHASH=b4812ae53eea93439ad5dce5a5c26591c31cb697

MATHLIB_TAG=v4.32.0-rc1
MATHLIB_COMMIT=360da6fa66c1273b76b6b2d8c5666fd5ac2e3b56

LEAN4EXPORT_COMMIT=3de59f10bc4b4a0f2de698597aeb1246caa0df0a

OXILEAN_COMMIT=9077af778fe467cba61d9c8385fb2b7e6a8d385f
OXILEAN_VERSION=0.1.3
```

---

## Authority separation

### Authority A — Lean reference checker

```text
Lean 4 kernel + frozen Mathlib
-> formal validity
```

### Authority B — OxiLean verifier

```text
oxilean-verify
-> independent Lean 4 proof re-checking
```

OxiLean consumes frozen `lean4export` NDJSON and preserves three verdict buckets:

```text
verified
unsupported
rejected
```

`unsupported` is not PASS and is not mathematical rejection.

The target proof declaration itself must land in `verified` for Authority B to count as PASS.

### Yoda

```text
Yoda
-> derivation integrity
```

### Kyber

```text
Kyber
-> durable state integrity
```

---

## Stage A0 — authority freeze

A0 is homologated:

```text
STATUS=PASS

MINIF2F_SOURCE_AUTHORITY=PASS
LEAN_AUTHORITY=PASS
MATHLIB_AUTHORITY=PASS
LEAN4EXPORT_AUTHORITY=PASS
OXILEAN_AUTHORITY=PASS
YODA_AUTHORITY=PASS

A0_EVIDENCE_INTEGRITY=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Frozen A0 evidence manifest:

```text
A0_EVIDENCE_MANIFEST_SHA256=
80cb8e086c70015dd6f5e259a354a75c24e3b69809e71cb0c04666634771a408
```

---

## Stage A1.0 — controlled proof evolution / capability-boundary discovery

A1.0 used `mathd_algebra_182`.

Proof A used `ring_nf`; Proof B used `ring`.

Observed:

```text
STATEMENT_PORT=PASS
PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS

PROOF_A_LEAN=PASS
PROOF_B_LEAN=PASS

LEAN4EXPORT_A=PASS
LEAN4EXPORT_B=PASS

OXILEAN_A_RC=0
OXILEAN_B_RC=0

PROOF_A_OXILEAN=UNSUPPORTED
PROOF_B_OXILEAN=UNSUPPORTED

OXILEAN_REJECTED_A=0
OXILEAN_REJECTED_B=0
```

Both target declarations were classified:

```text
verdict=unsupported
detail=dependency on an unsupported declaration
```

Observed dependency pressure included the Complex / commutative-ring hierarchy and unsupported dependency closure.

Official classification:

```text
STAGE_A1.0=NOT_EVALUATED
INTERPRETATION=CAPABILITY_BOUNDARY_DISCOVERED
FAILURE_CLASS=SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY

MATHEMATICAL_REJECTION=NO
HARNESS_FAILURE=NO
YODA_FAILURE=NO
KYBER_FAILURE=NO

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The hypothesis was not evaluated.

See `ATTEMPTS/A1.0-CAPABILITY-BOUNDARY.md`.

---

## Stage A1-R1 — authority-compatible formal workload

A1-R1 is pre-registered before execution.

Workload:

```text
CORPUS=openai/miniF2F
COMMIT=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
THEOREM=mathd_numbertheory_188
TARGET=Nat.gcd 180 168 = 12
```

Selection rationale:

```text
same formal domain
same public corpus
same frozen commit
same frozen authorities
smaller dependency surface
no Complex hierarchy
concrete Nat computation
single pre-registered revision
no candidate search after execution
```

The proof-state pair and exact A1-R1 harness are frozen before the first execution:

```text
Proof A
method=kernel_computation_rfl

Proof B
method=explicit_euclidean_gcd_derivation

Transformation
kernel_computation_to_explicit_euclidean_derivation
```

Proof B exposes the Euclidean chain:

```text
gcd(180,168)
-> gcd(168,180)
-> gcd(12,168)
-> gcd(0,12)
-> 12
```

The transformation is not cosmetic: state A relies on direct kernel computation, while state B records explicit GCD recursion steps against the same proposition.

PASS requires:

```text
STATEMENT_PORT=PASS
PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS

PROOF_A_LEAN=PASS
PROOF_B_LEAN=PASS

PROOF_A_OXILEAN=VERIFIED
PROOF_B_OXILEAN=VERIFIED

TRANSFORMATION_RECORD=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

If either target is `unsupported`, A1-R1 is `NOT_EVALUATED`. No opportunistic search through additional theorems is allowed.

---

## Stage A2 — Yoda versioned derivation

A1-R1 passed on its single pre-registered execution.

A2 has now been evaluated.

The pre-registered A2-R1 one-shot is preserved as `NOT_EVALUATED` because the harness stopped on a query-tokenization mismatch after the persistence and byte-recovery gates had already passed.

No A2 rerun was performed.

The exact durable Yoda state was then adjudicated read-only, and the A2 research question passed:

```text
A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=
PASS_BY_READ_ONLY_ADJUDICATION
```

Research question:

> **Can Yoda preserve a versioned derivation between two independently verified formal proof states without changing Yoda or Kyber?**

A2 introduces no new theorem, corpus, formal authority, or workload. Every formal input comes from the frozen A1-R1 evidence authority.

Yoda must preserve at minimum:

```text
formal statement
proof state A
proof state B
transformation A -> B
Lean evaluation A
Lean evaluation B
OxiLean evaluation A
OxiLean evaluation B
Lean evaluation evidence A
Lean evaluation evidence B
OxiLean evaluation evidence A
OxiLean evaluation evidence B
A1-R1 evidence authority
```

Required relations include:

```text
B --derived-from--> A
B --transformed-by--> T
A --proves--> S
B --proves--> S
A --validated-by--> Lean
B --validated-by--> Lean
A --rechecked-by--> OxiLean
B --rechecked-by--> OxiLean
```

No domain-specific Yoda or Kyber behavior is allowed.

A2 success requires byte-exact recovery of the statement, both proofs, the transformation and formal-evaluation evidence, plus recovery of the version relation:

```text
Proof B --derived-from--> Proof A
```

A2 does not re-run Lean or OxiLean. That independent replay remains the responsibility of Stage B.

The final adjudication demonstrated on the unchanged durable state:

```text
YODA_VERIFY=PASS
BYTE_EXACT_RECOVERY=PASS

Proof B --derived-from--> Proof A
recoverable

Proof B --transformed-by--> Transformation
recoverable

FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS
DATA_YODA_IDENTITY_UNCHANGED=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The distinction is deliberate:

```text
A2-R1 one-shot
-> NOT_EVALUATED

A2 research question
-> PASS_BY_READ_ONLY_ADJUDICATION
```

The complete CASE remains open until Stage B independently replays Lean and OxiLean against Yoda-recovered proof states.

---

## Stage B — independent replay after recovery

Stage B remains unchanged in purpose.

It must consume only artifacts recovered from Yoda and rerun the frozen formal authorities.

PASS requires byte-exact recovery, matching Lean evaluations, matching OxiLean evaluations, and recoverable derivation / transformation evidence.

---

## Primary success criterion

The CASE passes only if all evaluated stages pass with:

```text
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The intended property remains:

```text
CROSS_DOMAIN_LINEAGE_OF_CHANGE
```

It is not recorded as demonstrated until the complete CASE passes.

---

## Negative results policy

Negative and non-evaluable measurements are first-class evidence.

A1.0 must remain visible because it distinguishes:

```text
Lean VALID
OxiLean CANNOT CURRENTLY EVALUATE
```

from:

```text
Lean VALID
OxiLean INVALID
```

The second event did not occur.

A failed measurement is not necessarily a failed hypothesis.

---

## Stop conditions

Stop before Yoda writes if any external compatibility gate prevents both formal authorities from evaluating the pre-registered target.

Do not modify Yoda or Kyber to rescue the CASE.

Do not silently convert `unsupported` to `verified`.

Do not search multiple replacement workloads after A1-R1 begins.
