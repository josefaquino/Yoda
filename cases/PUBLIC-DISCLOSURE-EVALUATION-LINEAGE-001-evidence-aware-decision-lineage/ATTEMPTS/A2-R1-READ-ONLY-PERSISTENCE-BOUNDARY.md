# A2-R1 — Read-only Persistence Boundary Adjudication

## Purpose

Locate the exact object-ingest boundary of the consumed A2-R1 failure without rerunning A2 and without mutating the partial Yoda store.

## Frozen failure evidence

```text
A2_R1=FAIL
FAILURE_CLASS=YODA_PERSISTENCE_FAILURE

A2_R1_EXECUTION_LOCK_SHA256=
32cf7138c88b381c0b3f544f9e985cfafa5c9e5c88ea5f2d75b7599d716ca6f2

A2_R1_CONSOLE_SHA256=
2db9758c01d360e4ac09d61e6d7a285202f12d5a56033c0f26ae60feab74c40a

PARTIAL_DATA_YODA_SHA256=
48700481d01777910f5976ffe8d5de755288772088856dbaf59713df960f9cea

PARTIAL_DATA_YODA_BYTES=4091828

OBSERVED_ERROR=
yoda: terms table capacity exhausted
```

## Diagnostic contract

The diagnostic may execute only read operations against the partial store.

```text
YODA_INIT=FORBIDDEN
YODA_PUT=FORBIDDEN
YODA_LINK=FORBIDDEN
A2_R1_RERUN=FORBIDDEN

AUTHORIZED_YODA_OPERATION=get
```

It probes the 25 preregistered keys in their exact original put order and byte-compares any recovered object against the already materialized A2 object source.

The diagnostic freezes a complete store-file manifest before and after probing.

PASS for read-only behavior requires:

```text
DATA_YODA_BEFORE_SHA256 == DATA_YODA_AFTER_SHA256
STORE_BEFORE_MANIFEST_SHA256 == STORE_AFTER_MANIFEST_SHA256

YODA_STORE_MUTATED_BY_DIAGNOSTIC=NO
YODA_WRITES=ZERO
```

## Frozen diagnostic identities

```text
READ_ONLY_DIAGNOSTIC_SHA256=
3cffbe3044974f458361af0ac4fd78e42850e4cb26af4825b9273d286a5ac67f

READ_ONLY_DIAGNOSTIC_COMMIT=
1f8c3bfc4a42cc50450cfdc969585a05804d6df1

SAFE_LAUNCHER_SHA256=
9cbc9fa1accd023c7fdff27d863dd671fc9002dda01ec68f9c1e95a9715aeeee

SAFE_LAUNCHER_COMMIT=
7c37db15627d722226ab23fe4cdb99f9b3e2aa07
```

## Expected adjudication fields

```text
PERSISTED_OBJECT_COUNT=...
FIRST_MISSING_ORDINAL=...
FIRST_MISSING_KEY=...
PERSISTED_AFTER_FIRST_MISSING=...

PERSISTENCE_BOUNDARY=PREFIX_CONFIRMED | NON_PREFIX_STATE | INCONCLUSIVE_ALL_KEYS_PRESENT

RELATION_PHASE_STARTED=NO
EXPECTED_LINKS_WRITTEN=0

YODA_STORE_MUTATED_BY_DIAGNOSTIC=NO
YODA_WRITES=ZERO

ROOT_CAUSE_LAYER=YODA_PERSISTENCE_CAPACITY
ENGINE_INTERNAL_CAUSE=NOT_YET_SOURCE_ADJUDICATED
READ_ONLY_ADJUDICATION=COMPLETE
```
