# FIRMS-001 — Validated Results

## Final classification

```text
OBI_FIRMS_001=PASS
```

Validated on 2026-10-02.

## Identities

```text
CORE015_SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
HARNESS_SHA256=2cccc6410f4e41754b0d6277090a96445b8c0dbf26f1cfcd2bc02e91cd2b27a3
SOURCE_SHA256=edf79f62b35ba4485d7c85e01be5f6f61d30ab7b4addcf2eea00e2581982c30f
CONSOLE_SHA256=182aae4738f0e838887591f9665eff09f672b534eb9600d648eee9746d6d9d23
```

## External-source validation

```text
SOURCE_ROWS=74605
SOURCE_BYTES=6077404
BAD_CSV_ROWS=0
NASA_SOURCE_CONTRACT=PASS
```

NASA FIRMS published-reference gates:

```text
NASA_REFERENCE_SUBSET_ROWS=900
NASA_REFERENCE_URT_ROWS=324

RAW_SUBSET_ROWS=900
RAW_URT_ROWS=324
RAW_OTHER_ROWS=576

NASA_RAW_ORACLE=PASS
```

## Canonicalization

```text
MANIFEST_ROWS=900
UNIQUE_KEYS=900
RAW_CANONICALIZATION=PASS
```

Each observation key had the form:

```text
firms/obs/<sha256-of-source-row>
```

## Yoda ingest

```text
INIT=PASS
INGESTED_TOTAL=900
INGEST_SECONDS=24
```

The timing is recorded as a workload observation only. FIRMS-001 is not a performance benchmark.

## Authoritative verification

```text
VERIFY=PASS
RECORDS_SCANNED=900
RECORDS_VERIFIED=900
YODA_VERIFY_GATE=PASS
```

## Yoda replay

```text
YODA_REPLAY_ROWS=900
YODA_URT_ROWS=324
YODA_OTHER_ROWS=576
REPLAY_SECONDS=8
```

Again, replay time is retained as evidence, not as a performance claim.

## Exact equivalence

```text
FACT_EQUIVALENCE=PASS
DECISION_EQUIVALENCE=PASS
```

This means the experiment passed more than aggregate-count comparison:

1. canonical facts reconstructed through Yoda matched the canonical facts independently derived from the raw NASA source;
2. deterministic classifications reconstructed after Yoda replay matched the classifications independently derived from the raw source.

## Durable history

A sampled observation key was:

```text
firms/obs/00150a427d16987222e59e3ccee6c7fd2c93ccec02df7e8ce43903d47b7f48ef
```

Its `log` returned a durable `PUT` history entry with source:

```text
nasa-firms-public-sample
```

Result:

```text
DURABLE_HISTORY=PASS
```

## Storage footprint observed in this run

```text
DATABASE_BYTES=1397823
```

This value is retained as baseline evidence only. No storage-efficiency claim is made by FIRMS-001.

## Runtime exclusions

```text
LLM_USED=NO
PYTHON_USED=NO
SQL_USED=NO
```

The tested path used Yoda CORE-015 plus shell/coreutils/curl processing.

## Evidence freeze

The run completed SHA-256 verification of the evidence set, including:

- authoritative Yoda database files;
- downloaded NASA sample CSV;
- selected raw subset;
- raw canonical facts;
- Yoda-replayed canonical facts;
- raw deterministic classifications;
- Yoda-replayed classifications;
- Yoda verification output;
- sampled history;
- result summary;
- final classification.

Final gate:

```text
EVIDENCE_INTEGRITY=PASS
OBI-FIRMS-001=PASS
OBI_FIRMS_001_RUN_RC=0
```

## What this result supports

The measured evidence supports this narrow statement:

> Yoda CORE-015 persisted 900 public NASA FIRMS observations, verified the resulting state, replayed all 900 observations, and reproduced exactly the canonical facts and deterministic classification independently derived from the original public source.

## What this result does not support

FIRMS-001 does not demonstrate that Yoda detects or predicts fires, improves NASA observations, outperforms another database, or has been validated for larger-scale operational FIRMS workloads.

## Product consequence

```text
CORE016_CHANGE_EARNED=NO
```

The case succeeded without an engine change. The next earned experiment is about temporal observation supersession rather than modifying CORE-015.
