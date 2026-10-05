# RESULTS — FORMAL-MATH-EVOLVING-DERIVATION-001

## Status summary

| Stage | Status | Interpretation |
|---|---|---|
| A0 | PASS | External authorities frozen and evidence integrity established |
| A1.0 | NOT_EVALUATED | Secondary authority capability boundary discovered |
| A1-R1 | PRE-REGISTERED | Authority-compatible workload selected; not yet executed |
| A2 | BLOCKED | Requires A1-R1 PASS |
| B | BLOCKED | Requires A2 PASS |

---

## Stage A0

```text
STATUS=PASS
```

Authority freeze completed.

```text
MiniF2F frozen
Lean frozen
Mathlib frozen
lean4export frozen
OxiLean frozen
Yoda binary authority frozen

A0_EVIDENCE_INTEGRITY=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Primary evidence authority:

```text
A0_EVIDENCE_MANIFEST_SHA256=
80cb8e086c70015dd6f5e259a354a75c24e3b69809e71cb0c04666634771a408
```

---

## Stage A1.0

Official stage status:

```text
STATUS=NOT_EVALUATED
```

Interpretation:

```text
CAPABILITY_BOUNDARY_DISCOVERED
FAILURE_CLASS=SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY
```

### What was observed

```text
Lean Proof A
-> PASS

Lean Proof B
-> PASS

lean4export Proof A
-> PASS

lean4export Proof B
-> PASS

OxiLean Proof A process
-> RC 0

OxiLean Proof B process
-> RC 0

OxiLean target Proof A
-> UNSUPPORTED

OxiLean target Proof B
-> UNSUPPORTED
```

Target detail:

```text
dependency on an unsupported declaration
```

The OxiLean reports contained zero rejected declarations.

### What was not observed

This did **not** occur:

```text
Lean VALID
+
OxiLean INVALID
```

Therefore:

```text
MATHEMATICAL_REJECTION=NO
```

The experiment discovered a capability boundary in the secondary authority rather than a mathematical disagreement between authorities.

### Observed capability pressure

Proof A:

```text
2557 verified
2151 unsupported
0 rejected
```

Proof B:

```text
2557 verified
2149 unsupported
0 rejected
```

Both target declarations were:

```text
verdict=unsupported
detail=dependency on an unsupported declaration
```

The dependency surface included Complex / commutative-ring infrastructure. OxiLean also reported unsupported-feature groups including nested inductives, propagated unsupported-declaration dependencies, and a per-declaration clone-fuel resource limit.

### System attribution

```text
HARNESS_FAILURE=NO
MATHEMATICAL_REJECTION=NO
YODA_FAILURE=NO
KYBER_FAILURE=NO

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Negative Results

### A1.0 — Capability Boundary Discovery

A1.0 is intentionally preserved.

It is a negative result in the sense that the multi-authority hypothesis could not be evaluated on the original workload.

It is a positive methodological result because it identified a real boundary of the measurement instrument without changing Yoda, Kyber, the hypothesis, or the interpretation rules.

> **A failed measurement is not necessarily a failed hypothesis.**

---

## Stage A1-R1

```text
STATUS=PRE-REGISTERED
EXECUTED=NO
```

Revision rationale:

```text
Not because the hypothesis failed.
Not because Yoda failed.
Not because Kyber failed.
Not because Lean rejected the theorem.

The original workload exceeded the current
evaluation capacity of the secondary authority.
```

New workload:

```text
Corpus:
openai/miniF2F

Commit:
4e433ff5cadff23f9911a2bb5bbab2d351ce5554

Theorem:
mathd_numbertheory_188

Target:
Nat.gcd 180 168 = 12
```

Pre-registered selection reasoning:

```text
same domain
same corpus
same frozen commit
same authorities
smaller dependency surface
no Complex hierarchy
concrete Nat target
one revision only
```

Expected gates:

```text
Lean(A)=PASS
Lean(B)=PASS
OxiLean(A)=VERIFIED
OxiLean(B)=VERIFIED
identity(A) != identity(B)
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

No A1-R1 result should be entered here until the first pre-registered execution completes.
