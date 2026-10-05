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
