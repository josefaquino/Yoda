# CASE — FORMAL-MATH-EVOLVING-DERIVATION-001

## Question

> **Can the same Yoda derivation model that demonstrated Lineage of Change for a controlled biological artifact preserve a semantics-preserving evolution of a formal proof such that independent formal checking can be reproduced after recovery, without changing Yoda or Kyber?**

This CASE is a cross-domain test of the property formalized in `properties/LINEAGE-OF-CHANGE.md`.

The new domain is **formal mathematics**.

The goal is not to prove that Yoda understands mathematics.

The goal is to test whether the same state / transformation / derivation / evidence model survives a radically different artifact type.

---

## Hypothesis

The primary hypothesis is:

```text
LINEAGE_OF_CHANGE
BIOLOGICAL_ARTIFACT -> demonstrated
FORMAL_PROOF        -> test now
```

If the formal-math CASE passes without a Yoda or Kyber change, the evidence for a cross-domain architectural property becomes materially stronger.

The CASE still must not claim universality.

---

## Public source authority

The source theorem is taken from the public OpenAI `miniF2F` benchmark.

Frozen repository:

```text
REPOSITORY=openai/miniF2F
COMMIT=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
THEOREM=mathd_algebra_182
```

Original Lean 3 statement:

```lean
theorem mathd_algebra_182
(y : ℂ) :
7 * (3 * y + 2) = 21 * y + 14 :=
begin
ring_nf,
end
```

The CASE ports the proposition to Lean 4 while preserving the mathematical statement.

The dataset is statement authority, not proof authority.

---

## Frozen formal environment

To align with the independent checker export format, the formal environment is pinned to:

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

A proof state passes Authority A only if the frozen Lean environment accepts it.

### Authority B — OxiLean verifier

```text
oxilean-verify
-> independent Lean 4 proof re-checking
```

OxiLean consumes the frozen `lean4export` NDJSON representation and checks declarations with its independent Rust kernel implementation.

The CASE must preserve OxiLean's three-bucket semantics:

```text
verified
unsupported
rejected
```

`unsupported` must never be silently treated as `verified`.

The target proof declaration itself must land in `verified` for Authority B to count as PASS.

### Yoda

```text
Yoda
-> derivation integrity
```

Yoda does not prove the theorem and does not replace either formal checker.

### Kyber

```text
Kyber
-> durable state integrity
```

---

## State-transition model

The mathematical proposition remains constant.

The proof artifact changes.

```text
Statement S

Proof A
 tactic = ring_nf
      |
      | controlled semantics-preserving proof refactor
      v
Proof B
 tactic = ring
```

Required invariants:

```text
statement(A) = statement(B)
identity(A) != identity(B)
Lean(A) = PASS
Lean(B) = PASS
OxiLean(A) = VERIFIED
OxiLean(B) = VERIFIED
```

The CASE is therefore about **proof evolution**, not theorem evolution.

---

## Stage A0 — authority freeze

No Yoda write is allowed.

A0 must:

1. freeze the MiniF2F source theorem;
2. freeze Lean v4.32.0-rc1;
3. freeze Mathlib v4.32.0-rc1;
4. freeze `lean4export`;
5. freeze and build `oxilean-verify`;
6. verify the frozen Yoda binary identity without writing to it;
7. freeze an evidence manifest.

PASS requires:

```text
MINIF2F_SOURCE_AUTHORITY=PASS
LEAN_AUTHORITY=PASS
MATHLIB_AUTHORITY=PASS
LEAN4EXPORT_AUTHORITY=PASS
OXILEAN_AUTHORITY=PASS
YODA_AUTHORITY=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

If the external tools cannot be frozen or built, the CASE is `NOT_EVALUATED`.

---

## Stage A1 — controlled proof evolution

A1 still contains no Yoda write.

It creates one Lean 4 project with a common statement and two proof states:

```text
FormalEvolution.Statement
FormalEvolution.ProofA
FormalEvolution.ProofB
```

Proof A:

```lean
by
  intro y
  ring_nf
```

Proof B:

```lean
by
  intro y
  ring
```

PASS requires:

```text
STATEMENT_SOURCE=MINIF2F
STATEMENT_PORT=PASS
PROOF_A_LEAN=PASS
PROOF_B_LEAN=PASS
PROOF_A_OXILEAN=VERIFIED
PROOF_B_OXILEAN=VERIFIED
PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS
TRANSFORMATION_RECORD=PASS
YODA_WRITES=ZERO
```

If OxiLean reports the target theorem as unsupported, A1 is `NOT_EVALUATED` for the multi-authority hypothesis. It is not permitted to downgrade that to PASS.

---

## Stage A2 — Yoda versioned derivation

A2 begins only after A0 and A1 pass.

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
Lean authority identity
OxiLean authority identity
A1 evidence authority
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

A2 must use the frozen Yoda product and existing bounded-context semantics.

No Change Mode, Math Mode or domain-specific engine behavior is allowed.

---

## Stage B — independent replay after recovery

Stage B must consume only artifacts recovered from Yoda.

It must rerun:

```text
Lean on recovered A
Lean on recovered B
OxiLean on exported recovered A
OxiLean on exported recovered B
```

PASS requires:

```text
SHA(A_recovered) = SHA(A_original)
SHA(B_recovered) = SHA(B_original)

Lean(A_recovered) = Lean(A_original)
Lean(B_recovered) = Lean(B_original)

OxiLean(A_recovered) = OxiLean(A_original)
OxiLean(B_recovered) = OxiLean(B_original)

B --derived-from--> A remains recoverable
transformation evidence remains recoverable
```

---

## Primary success criterion

The CASE passes only if all stages pass with:

```text
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The intended property under test is:

```text
CROSS_DOMAIN_LINEAGE_OF_CHANGE
```

This property is not recorded as demonstrated until the complete CASE passes.

---

## Permitted claim if validated

> **For one formally verified mathematical derivation, Yoda preserved two distinct proof states, the semantics-preserving transformation between them, and their formal-verification evidence such that the frozen formal authorities reproduced their original evaluations after byte-exact recovery.**

A stronger cross-domain interpretation may then be discussed because `Lineage of Change` would have survived both a biological artifact and a formal proof artifact.

It would still not establish universal domain independence.

---

## Non-claims

This CASE does not establish that:

- Yoda proves mathematics;
- Yoda replaces Lean;
- Yoda replaces OxiLean;
- Yoda determines whether a proof refactor is mathematically insightful;
- every Lean proof can be checked by OxiLean;
- every transformation domain fits the current model;
- arbitrary long proof histories have been validated;
- cross-domain generality is universal;
- Axiom, OpenAI, Lean, Mathlib or OxiLean authors participated in or endorsed the experiment;
- product-market fit exists.

---

## Stop conditions

The CASE stops as `NOT_EVALUATED` before Yoda writes if any of the following occurs:

- source theorem cannot be frozen exactly;
- pinned Lean / Mathlib environment cannot build;
- pinned `lean4export` cannot produce the expected format;
- OxiLean cannot consume the frozen export format;
- either proof fails Lean;
- the target declaration is unsupported by OxiLean;
- Proof A and Proof B are not byte-distinct;
- the mathematical statement differs between A and B.

A failure in an external compatibility gate is evidence about the harness, not a Yoda regression.
