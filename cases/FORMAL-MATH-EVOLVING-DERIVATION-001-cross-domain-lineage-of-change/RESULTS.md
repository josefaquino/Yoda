# RESULTS — FORMAL-MATH-EVOLVING-DERIVATION-001

## Status summary

| Stage | Status | Interpretation |
|---|---|---|
| A0 | PASS | External authorities frozen and evidence integrity established |
| A1.0 | NOT_EVALUATED | Secondary authority capability boundary discovered |
| A1-R1 | PASS | Both pre-registered proof states verified by Lean and OxiLean on the single execution |
| A2 | READY / PRE-REGISTERED | Yoda versioned-derivation gate; no new workload or authority |
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
STATUS=PASS
EXECUTION_COUNT=1
RUN_RC=0
```

Frozen result:

```text
LEAN_A=PASS
LEAN_B=PASS

OXILEAN_A=VERIFIED
OXILEAN_B=VERIFIED

PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS
SEMANTICS_EQUIVALENT=YES

TRANSFORMATION_RECORD=PASS

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Authoritative identities:

```text
SCRIPT_SHA256=
8a8b4f85877a343b93667506e29118b9d439fcc25b07c10cf72f0383b35303c1

CONSOLE_SHA256=
d0122378aec0111b54b05c9207d4b9a4fa28aece67886955c08e56335bc48a81

STATEMENT_SHA256=
9b2c0b3edf422b58e736484995b471e182cdc32d43681b3b141d9fd1e55eac12

PROOF_A_SHA256=
ba1655c87279a033c0e4ea10c8cd7da813e898d27e7ef598835dca3513869836

PROOF_B_SHA256=
529cb654f5c98c434b4583fac29db061501127eebffcd18f570a7a012dfcf248

PREREGISTRATION_SHA256=
80d3bfc5391c599eff7f08d659baf7426eec779725a8805c333c6531e11910c9

TRANSFORMATION_RECORD_SHA256=
63ce4d91c19c0ad2cec9cfb4eb600f46e9b61fd99c87d4d71562f43caa8e29ed

A1_R1_EVIDENCE_MANIFEST_SHA256=
fad7416a7528d9d6ec885836668668d20c3cb942bc04b4f509949f92227c8bca

A1_R1_EXECUTION_LOCK_SHA256=
5135b3ed18927c7029571bf4cd071c5d449bbcbac6c4d43460b58e657536a440
```

---

## Stage A2

```text
STATUS=READY
REVISION=A2-R1
EXECUTED=NO
```

Research question:

> **Can Yoda preserve a versioned derivation between two independently verified formal proof states without changing Yoda or Kyber?**

Inputs are frozen A1-R1 artifacts only:

```text
Statement
Proof A
Proof B
Transformation A -> B
Lean Evidence A
Lean Evidence B
OxiLean Evidence A
OxiLean Evidence B
A1-R1 Evidence Authority
```

Constraints:

```text
NEW_WORKLOAD=NO
NEW_CORPUS=NO
NEW_AUTHORITY=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

A2 does not rerun Lean or OxiLean. Independent authority replay remains Stage B. A2 tests Yoda's preservation and recovery behavior only.

See `ATTEMPTS/A2-R1-YODA-VERSIONED-DERIVATION.md`.
