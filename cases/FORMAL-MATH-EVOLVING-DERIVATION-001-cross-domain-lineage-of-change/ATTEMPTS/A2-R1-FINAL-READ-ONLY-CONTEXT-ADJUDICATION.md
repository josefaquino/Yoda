# A2-R1 — Final Read-Only Context Adjudication

## Purpose

This is not an A2 rerun.

The one-shot A2-R1 execution remains consumed. The first read-only adjudication also remains preserved.

This final adjudication tests the original bounded-context relation criterion using a query aligned with Yoda's actual search semantics.

## Why the prior assertion was invalid

Yoda search scores matches in keys more strongly than matches in values.

For each query term:

```text
key match    +8
source match +4
value match  +2
```

The previous corrected queries could return relevant objects while not necessarily making Proof B the primary context hit. In addition, `context` prints an `@link` marker only when it emits an unseen related object.

Therefore absence of a particular `@link` line in a composed multi-query context is not equivalent to absence of the relation.

The relation itself was independently recovered through:

```text
yoda log formal/proof/B
```

with both:

```text
derived-from
transformed-by
```

present.

## Final bounded-context query

```text
formal proof
```

Both terms occur in the proof keys. Proof B is newer than Proof A, so it is the highest-priority primary hit among equal-scoring proof keys.

The final adjudication requires that this single bounded context expose:

```text
formal/proof/B

@link formal/proof/B --derived-from--> formal/proof/A

@link formal/proof/B --transformed-by--> formal/transformation/A-to-B
```

## No-write rule

No A2 rerun.

No `yoda init`.

No `yoda put`.

No `yoda link`.

The exact frozen `data.yoda` must remain byte-identical before and after adjudication.

## PASS meaning

If the final adjudication passes, the stage-level conclusion is:

```text
A2_R1_ONE_SHOT=NOT_EVALUATED
A2_R1_FAILURE_CLASS=HARNESS_QUERY_TOKENIZATION_MISMATCH

A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=PASS_BY_READ_ONLY_ADJUDICATION

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

This distinction preserves the failed measurement while allowing the already-created immutable state to answer the research question.


---

## Observed result

The final read-only adjudication passed.

```text
RUN_RC=0

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
A2_R1_ONE_SHOT=NOT_EVALUATED
A2_R1_RERUN=NO

A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A2=
PASS_BY_READ_ONLY_ADJUDICATION

YODA_APPLICATION_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Frozen final identities:

```text
SCRIPT_SHA256=
104357a8793c97117e64183682a37e9b943d900360687e496c50f79627e89850

CONSOLE_SHA256=
574b4b0becb909376169769cd3fb0d0513cf98a23dfff51132a904bae54e6a13

EVIDENCE_MANIFEST_SHA256=
e603b0ac3fe1b477a2dd6b3db71c46c7a07e3a098843067fc68c23711775accb

DATA_YODA_SHA256=
5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba

DATA_YODA_BYTES=80761
```

Stage B remains the next independent replay gate and has not been executed.
