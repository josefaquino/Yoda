# RESULTS — FORMAL-MATH-EVOLVING-DERIVATION-001

## Status summary

| Stage | Status | Interpretation |
|---|---|---|
| A0 | PASS | External authorities frozen and evidence integrity established |
| A1.0 | NOT_EVALUATED | Secondary authority capability boundary discovered |
| A1-R1 | PASS | Both pre-registered proof states verified by Lean and OxiLean on the single execution |
| A2-R1 one-shot | NOT_EVALUATED | Harness query-tokenization mismatch after persistence/recovery gates passed |
| A2 research question | PASS_BY_READ_ONLY_ADJUDICATION | Frozen Yoda state preserved bytes, relations, bounded context and durable identity without rerun |
| B-R1 | PRE-REGISTERED / NOT EXECUTED | Independent Lean + OxiLean replay from Yoda-recovered A1-R1 proof states |

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
A2_R1_ONE_SHOT=NOT_EVALUATED
A2_R1_FAILURE_CLASS=HARNESS_QUERY_TOKENIZATION_MISMATCH
A2_R1_RERUN=NO

A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=
PASS_BY_READ_ONLY_ADJUDICATION
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


---

## A2-R1 one-shot execution — measurement interruption

The single pre-registered A2-R1 execution consumed its one-execution lock and must not be rerun.

Observed before the interruption:

```text
A1_R1_EVIDENCE_AUTHORITY=PASS
A1_R1_SOURCE_IDENTITIES=PASS

NO_NEW_WORKLOAD=PASS
NO_NEW_AUTHORITY=PASS

YODA_INIT=PASS
OBJECT_COUNT=9
LINK_COUNT=15
YODA_VERIFY=PASS

STATEMENT_BYTE_EXACT_RECOVERY=PASS
PROOF_A_BYTE_EXACT_RECOVERY=PASS
PROOF_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
LEAN_EVIDENCE_BYTE_EXACT_RECOVERY=PASS
OXILEAN_EVIDENCE_BYTE_EXACT_RECOVERY=PASS
A1_R1_AUTHORITY_BYTE_EXACT_RECOVERY=PASS
```

The harness then stopped at:

```text
REASON=OxiLean A context failed
```

This is not currently classified as a Yoda preservation failure.

Source audit of the frozen Yoda search implementation shows that indexing splits punctuation-delimited text into separate terms while query parsing splits only on whitespace before normalization. The query:

```text
FormalEvolutionR1.ProofA.proof
```

therefore normalized to one term, while the indexed value contains separate terms:

```text
formalevolutionr1
proofa
proof
```

The one-shot execution is therefore classified pending adjudication as:

```text
A2_R1_EXECUTION=NOT_EVALUATED
FAILURE_CLASS=HARNESS_QUERY_TOKENIZATION_MISMATCH
YODA_PRESERVATION_FAILURE=NOT_ESTABLISHED
```

Authoritative observed identities:

```text
A2_R1_SCRIPT_SHA256=
1568c92514e12be7ecb7bc57dd9e31a51fcb32240b75b21c3cfc003dfd191fbe

A2_R1_CONSOLE_SHA256=
a8f3f499cdc89a58e613deb5c2f07f68eaea9278b05a75c0280dd6ebd088a6d7

A2_R1_EXECUTION_LOCK_SHA256=
c8ec9022ffd989fcc9dff818fbcc1268a03154c2a3267cbde40585f328f18241

DATA_YODA_SHA256_AT_INTERRUPTION=
5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba

DATA_YODA_BYTES=80761
```

The only permitted continuation was read-only adjudication against that exact durable state. No A2-R1 rerun was performed.

### First read-only adjudication

The first adjudicator confirmed:

```text
A2_R1_FROZEN_STATE_AUTHORITY=PASS
YODA_VERIFY=PASS
BYTE_EXACT_RECOVERY=PASS
DERIVED_FROM_RELATION_RECOVERY=PASS
TRANSFORMED_BY_RELATION_RECOVERY=PASS
```

It then stopped on an assertion requiring a specific `@link` presentation inside a composed context:

```text
REASON=derived-from relation missing from corrected context
```

That assertion was not equivalent to relation loss. Yoda had already recovered both relations through the authoritative per-key log.

First adjudication identities:

```text
SCRIPT_SHA256=
899201cab8d1f66140a7a428a34e6d62d87ae1f99294505f82f7bc9ac9a3d2a4

CONSOLE_SHA256=
9ee10d81d554c93275878f8669b37f4147a9337352966c16c37fb1e5ab568c08
```

### Final read-only adjudication

A final, pre-registered read-only adjudication used a single bounded-context query aligned with Yoda's key-search semantics.

Observed:

```text
FROZEN_EVIDENCE_CHAIN=PASS
YODA_VERIFY=PASS
DERIVED_FROM_RELATION_LOG=PASS
TRANSFORMED_BY_RELATION_LOG=PASS
BOUNDED_CONTEXT_PROOF_B=PASS
BOUNDED_CONTEXT_DERIVED_FROM=PASS
BOUNDED_CONTEXT_TRANSFORMED_BY=PASS
FORMAL_LINEAGE_OF_CHANGE_CONTEXT=PASS
DATA_YODA_IDENTITY_UNCHANGED=PASS
FINAL_ADJUDICATION_EVIDENCE_INTEGRITY=PASS
A2_FINAL_READ_ONLY_ADJUDICATION=PASS
```

Final identities:

```text
FINAL_ADJUDICATION_SCRIPT_SHA256=
104357a8793c97117e64183682a37e9b943d900360687e496c50f79627e89850

FINAL_ADJUDICATION_CONSOLE_SHA256=
574b4b0becb909376169769cd3fb0d0513cf98a23dfff51132a904bae54e6a13

FINAL_ADJUDICATION_EVIDENCE_MANIFEST_SHA256=
e603b0ac3fe1b477a2dd6b3db71c46c7a07e3a098843067fc68c23711775accb

DATA_YODA_SHA256=
5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba

DATA_YODA_BYTES=80761
```

Stage-level adjudication:

```text
A2_R1_ONE_SHOT=NOT_EVALUATED
A2_R1_FAILURE_CLASS=HARNESS_QUERY_TOKENIZATION_MISMATCH
A2_R1_RERUN=NO

A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=
PASS_BY_READ_ONLY_ADJUDICATION

YODA_APPLICATION_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

This does not yet validate the complete CASE. Stage B independent formal replay remains pending.
