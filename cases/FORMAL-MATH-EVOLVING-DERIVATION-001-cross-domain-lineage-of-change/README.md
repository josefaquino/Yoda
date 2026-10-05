# FORMAL-MATH-EVOLVING-DERIVATION-001

## Cross-domain Lineage of Change

This CASE asks whether a property first demonstrated with a controlled biological artifact survives in a radically different domain: **formal mathematics**.

The question is:

> **Can the same Yoda derivation model preserve the evolution of a formal proof and allow frozen formal authorities to reproduce their original evaluations after recovery?**

The experiment intentionally does not ask Yoda to prove mathematics.

It asks whether Yoda can preserve the derivation around mathematical proof artifacts while formal authorities remain external.

---

## Why this CASE exists

The current evidence ladder is:

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

The next question is not whether Yoda can do more biology.

It is whether `Lineage of Change` is beginning to look like a property of the derivation model rather than a property of the biological environment in which it was first demonstrated.

```text
Biological artifact
Lineage of Change
PASS

Formal proof artifact
Lineage of Change
TEST NOW
```

---

## Public theorem source

The source statement comes from OpenAI's public MiniF2F benchmark:

```text
repository=openai/miniF2F
commit=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
theorem=mathd_algebra_182
```

MiniF2F is used only as the public statement authority.

The proposition is ported from Lean 3 to Lean 4 without changing the mathematical target.

---

## Proof evolution

The proposition remains constant while the proof artifact changes.

```text
Statement S

Proof A
ring_nf
   |
   | controlled proof refactor
   v
Proof B
ring
```

Required:

```text
identity(A) != identity(B)
statement(A) = statement(B)
```

Both proofs must remain formally valid.

---

## Two formal checking paths

### Lean

Frozen reference environment:

```text
Lean 4 v4.32.0-rc1
Mathlib v4.32.0-rc1
```

Lean answers:

```text
Does this proof elaborate and pass the reference kernel?
```

### OxiLean

Frozen OxiLean `oxilean-verify` provides an independent Rust checker over `lean4export` NDJSON.

OxiLean answers:

```text
Does this exported declaration verify under the independent checker?
```

The target proof declaration must be explicitly `verified`.

An `unsupported` result is not PASS.

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

No authority is asked to perform another layer's job.

---

## Experiment stages

```text
A0
freeze external authorities
Yoda writes = zero
        |
        v
A1
create Proof A -> Proof B
validate both with Lean + OxiLean
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

A2 is not allowed to begin until A0 and A1 pass.

---

## What would matter if it passes

A successful result would not mean that Yoda became a theorem prover.

It would mean that the same small derivation architecture preserved a meaningful state transition in two fundamentally different domains:

```text
protein sequence
!=
formal proof

SynthID measurement
!=
formal proof checking

same Yoda derivation model
same state-transition model
same evidence discipline
no engine changes
```

That would strengthen — but still not prove — the hypothesis that `Lineage of Change` is cross-domain.

---

## Working property under test

```text
CROSS_DOMAIN_LINEAGE_OF_CHANGE
```

This name is provisional until the complete CASE passes.

The already demonstrated property remains:

```text
LINEAGE_OF_CHANGE
=
derivation integrity across state transitions
```

See [`../../properties/LINEAGE-OF-CHANGE.md`](../../properties/LINEAGE-OF-CHANGE.md).

---

## Discipline

```text
one new domain
one controlled transition
one primary property
external formal authorities
zero preventive engine changes
```

If an external checker or toolchain cannot support the experiment, classify the stage honestly.

Do not modify Yoda to rescue the CASE.

> **Big vision. Small steps. Evidence always.**

For the complete experiment contract, see [CASE.md](CASE.md).
For execution, see [RUNBOOK.md](RUNBOOK.md).
