# Transformation Contract — SYNTHID-BIO-EVOLVING-PROVENANCE-001

## Contract status

```text
CONTRACT_VERSION=001
CONTRACT_STATUS=FROZEN_FOR_A0
CODE_WRITING=NO
EXECUTION_STATUS=NOT_STARTED
```

## Scientific authority

Primary publication:

**Stutz, D. et al. Function-preserving watermarking of AI-generated proteins. Nature (2026).**

DOI:

`10.1038/s41586-026-10965-y`

The paper’s SynthIDBio-sequence robustness section reports a resequencing attack performed on 38,396 binders and states that this approach effectively removes the watermark.

The Methods section defines the attack operationally:

- start from a known watermarked binder;
- use the binder in complex with its target;
- run **non-watermarked ProteinMPNN**;
- use ProteinMPNN’s **default sampling temperature of 0.1**.

This paper-defined method is the transformation authority for this CASE.

---

## Frozen external software authority

Repository:

`google-deepmind/synthidbio`

Frozen commit reused from the validated prior CASE:

```text
acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

The repository’s canonical non-watermarked ProteinMPNN example uses:

```text
--num_seq_per_target 2
--sampling_temp 0.1
--seed 37
--batch_size 1
```

and does not pass `--watermark`.

This confirms that the frozen repository exposes the non-watermarked ProteinMPNN execution mode required by the paper-defined transformation class.

Important: the example script is supporting software authority. The paper remains the scientific authority for calling resequencing a robustness transformation.

---

## Frozen transformation semantics

```text
SOURCE_STATE=A
SOURCE_CLASS=watermarked biological sequence

TRANSFORMATION_CLASS=resequencing
TRANSFORMATION_TOOL=ProteinMPNN
TRANSFORMATION_WATERMARK_MODE=off
TRANSFORMATION_SAMPLING_TEMPERATURE=0.1

TARGET_STATE=B
TARGET_CLASS=resequenced biological sequence
```

The specific source binder, target/backbone input, seed and exact generated target sequence are **not yet frozen**. Those belong to the execution-design gate after A0.

Therefore this contract freezes the **method class**, not yet the concrete A→B instance.

---

## Measurement semantics

For each independently frozen state:

```text
A → official SynthID Bio detector → g(A)
B → official SynthID Bio detector → g(B)
```

The CASE does not assume or require any ordering relationship between the measurements.

Specifically, none of the following is a success criterion:

```text
g(B) < g(A)
g(B) > g(A)
g(B) = g(A)
```

The scientific paper studies watermark removal; Yoda does not.

For Yoda, each measurement belongs to the identity of the state on which it was independently computed.

---

## Replay semantics

After Yoda persistence and recovery:

```text
A → Yoda → A'
B → Yoda → B'
```

The independent detector is rerun:

```text
A' → detector → g(A')
B' → detector → g(B')
```

Required equivalence:

```text
SHA256(A') = SHA256(A)
SHA256(B') = SHA256(B)

g(A') = g(A)
g(B') = g(B)
```

The derivation relationship must also remain recoverable:

```text
B derived-from A
```

---

## What counts as change

A and B are expected to differ.

```text
SHA256(A) != SHA256(B)
```

is not corruption.

It is the expected consequence of a legitimate transformation, provided the transformation evidence and derivation relationship are preserved.

This CASE explicitly distinguishes:

```text
LEGITIMATE_CHANGE
!=
CORRUPTION
```

---

## Stage A0 gates

Before execution design begins:

```text
DEEPMIND_PAPER_AUTHORITY=PASS
RESEQUENCING_ATTACK_DOCUMENTED=PASS
NON_WATERMARKED_PROTEINMPNN_MODE=PASS
SAMPLING_TEMPERATURE_0_1_AUTHORITY=PASS
FROZEN_DEEPMIND_COMMIT=PASS
TRANSFORMATION_METHOD_CLASS_FROZEN=PASS
```

A0 must also preserve the product boundary:

```text
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Deferred parameters

These are intentionally unresolved until the next gate:

```text
SOURCE_BINDER_ID
SOURCE_STRUCTURE_ID
TARGET_ID
SOURCE_G_VALUE
TRANSFORMATION_SEED
TARGET_SEQUENCE_SELECTION_RULE
TARGET_G_VALUE
```

They must be selected from reproducible public artifacts or generated under a frozen deterministic procedure.

No parameter may be chosen retroactively to produce a preferred g-value outcome.

---

## Supplementary-material status

The Nature article explicitly states that supplementary material contains additional results for resequencing and substitution-based attacks.

At contract-freeze time:

```text
RESEQUENCING_PROTOCOL_MAIN_PAPER=SUFFICIENT
SUBSTITUTION_ATTACK_REPORTED=YES
SUBSTITUTION_PROTOCOL_FROZEN=NO
SUBSTITUTION_USED_IN_CASE=NO
```

The Supplementary Information is therefore not required to define the current resequencing transformation contract.

If a future CASE uses substitution-based transformations, its exact protocol must be separately frozen before code is written.

---

## Research boundary

This contract exists to test:

> **lineage through change**

It does not exist to test:

```text
watermark robustness
watermark removal effectiveness
biological fitness
binding preservation
biosecurity screening
```

Those remain external scientific questions.

---

## Next gate

```text
NEXT_GATE=SELECT_REPRODUCIBLE_A_TO_B_INSTANCE
```

The next decision is not an engine decision.

It is an experiment-design decision:

> Which public, reproducible watermarked source state and ProteinMPNN input should become Artifact A, and what deterministic rule will select exactly one resequenced Artifact B?
