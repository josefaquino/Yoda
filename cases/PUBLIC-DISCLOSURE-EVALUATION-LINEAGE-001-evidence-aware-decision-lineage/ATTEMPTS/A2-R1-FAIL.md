# A2-R1 — Yoda Evaluation Lineage — FAIL

## Verdict

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A2=FAIL
A2_REVISION=A2-R1
FAILURE_CLASS=YODA_PERSISTENCE_FAILURE

A2_R1_RERUN=NO

SEC_FETCHES=ZERO
CLASSIFICATION_EXECUTED=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

This is a scientific FAIL, not NOT_EVALUATED.

The one-execution gate was already consumed before the persistence failure.

## Pre-lock authority

All preregistered pre-lock gates passed:

```text
SCRIPT_IDENTITY=PASS

YODA_AUTHORITY=PASS
YODA_SHA256=
1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb

A0_C1_AUTHORITY=PASS
A1_R1_AUTHORITY=PASS
A1_CANONICAL_EVALUATION_AUTHORITY=PASS

SEMANTIC_OBJECTS=FROZEN

OBJECT_COUNT=25
A2_INPUT_SET=PASS

SEC_FETCHES=ZERO
CLASSIFICATION_EXECUTED=NO
```

## Consumed scientific gate

```text
EXECUTION_POLICY=ONE_EXECUTION

A2_R1_EXECUTION_LOCK_SHA256=
32cf7138c88b381c0b3f544f9e985cfafa5c9e5c88ea5f2d75b7599d716ca6f2

EXECUTION_GATE=PASS

LOCK_CREATED_BEFORE_FIRST_YODA_WRITE=YES
```

## Observed persistence failure

Yoda initialized successfully:

```text
YODA_INIT=PASS
```

During preregistered object ingestion, the frozen Yoda binary terminated the operation with:

```text
yoda: terms table capacity exhausted
```

The harness adjudicated:

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A2=FAIL
FAILURE_CLASS=YODA_PERSISTENCE_FAILURE
```

No A2 evidence manifest was completed.

```text
A2_MANIFEST=NOT_AVAILABLE
```

## Execution identities

```text
A2_R1_SCRIPT_SHA256=
b47d6349131755fde45a3004ce08f58508b1831bf48237f6cc1af18929934dac

A2_R1_CONSOLE_SHA256=
2db9758c01d360e4ac09d61e6d7a285202f12d5a56033c0f26ae60feab74c40a

A2_R1_EXECUTION_LOCK_SHA256=
32cf7138c88b381c0b3f544f9e985cfafa5c9e5c88ea5f2d75b7599d716ca6f2
```

## Partial Yoda store

A partial Yoda store exists because persistence began before failure.

```text
DATA_YODA_SHA256=
48700481d01777910f5976ffe8d5de755288772088856dbaf59713df960f9cea

DATA_YODA_BYTES=4091828
```

This partial store is failure evidence and must not be deleted, repaired, compacted, or reused for another scientific execution.

## Frozen scientific interpretation

The research gate asked whether the frozen Yoda binary could persist and recover the preregistered Evaluation Lineage object graph without Yoda or Kyber changes.

Under the preregistered workload, it could not complete persistence.

Therefore:

```text
A2_YODA_EVALUATION_LINEAGE=FAIL
REASON=FROZEN_YODA_PERSISTENCE_CAPACITY_EXHAUSTED_DURING_INGEST
```

The exact internal cause of the capacity exhaustion remains subject to read-only adjudication.

## Governance

Forbidden:

```text
A2_R1_RERUN
LOCK_DELETION
STAGE_DELETION
PARTIAL_STORE_DELETION
WORKLOAD_REDUCTION_AND_RELABEL_AS_SAME_EXPERIMENT
YODA_CHANGE_AND_RELABEL_AS_A2_R1
```

Stage B is not authorized from this failed A2-R1.

A read-only diagnostic may inspect the partial store, frozen inputs, executable identity and available source artifacts without writing to the A2 store.
