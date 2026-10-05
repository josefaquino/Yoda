# A2-R1 — Read-Only Adjudication

## Purpose

This is not a second A2 execution.

The A2-R1 one-shot has already been consumed.

This adjudication reads the exact durable Yoda state produced by that execution and determines whether the observed stop was caused by the pre-registered query syntax rather than by loss of derivation state.

## Frozen authorities

```text
A2_R1_SCRIPT_SHA256=
1568c92514e12be7ecb7bc57dd9e31a51fcb32240b75b21c3cfc003dfd191fbe

A2_R1_CONSOLE_SHA256=
a8f3f499cdc89a58e613deb5c2f07f68eaea9278b05a75c0280dd6ebd088a6d7

A2_R1_EXECUTION_LOCK_SHA256=
c8ec9022ffd989fcc9dff818fbcc1268a03154c2a3267cbde40585f328f18241

DATA_YODA_SHA256=
5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba
```

## Hypothesis under adjudication

The Yoda durable state already contains the complete A1-R1 derivation and the harness stopped because a context query was tokenized incompatibly.

## No-write policy

The adjudicator must not execute:

```text
yoda init
yoda put
yoda link
```

It may use only read/audit operations against the already-created store.

## Required observations

```text
YODA_VERIFY=PASS

Statement recovery=byte exact
Proof A recovery=byte exact
Proof B recovery=byte exact
Transformation recovery=byte exact
Lean evidence recovery=byte exact
OxiLean evidence recovery=byte exact
A1-R1 authority recovery=byte exact

Proof B --derived-from--> Proof A
recoverable

Proof B --transformed-by--> Transformation
recoverable

corrected derivation-core context query=PASS

DATA_YODA_SHA256_BEFORE
=
DATA_YODA_SHA256_AFTER
```

No stage-level PASS is assigned until this read-only evidence is reviewed.


---

## Observed result

```text
RUN_RC=1

A2_R1_FROZEN_STATE_AUTHORITY=PASS
YODA_VERIFY=PASS
BYTE_EXACT_RECOVERY=PASS
DERIVED_FROM_RELATION_RECOVERY=PASS
TRANSFORMED_BY_RELATION_RECOVERY=PASS
```

The adjudicator stopped at:

```text
REASON=derived-from relation missing from corrected context
```

This did not establish relation loss. The authoritative Proof B log had already recovered both relations.

The remaining mismatch was a context-presentation assertion: Yoda can suppress an `@link` marker when the related object has already been emitted in the current context's seen-set.

Frozen identities:

```text
SCRIPT_SHA256=
899201cab8d1f66140a7a428a34e6d62d87ae1f99294505f82f7bc9ac9a3d2a4

CONSOLE_SHA256=
9ee10d81d554c93275878f8669b37f4147a9337352966c16c37fb1e5ab568c08

DATA_YODA_SHA256_AFTER=
5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba
```
