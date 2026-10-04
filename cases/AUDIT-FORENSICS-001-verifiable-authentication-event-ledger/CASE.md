# AUDIT-FORENSICS-001 — Case Contract

## Objective

Validate whether the current KyberDB public embedded API can preserve a real ordered authentication-event ledger exactly across durable persistence and close/reopen, then reject a controlled one-byte mutation in a persisted segment without changing the engine.

This case intentionally begins at 10,000 events. It does not scale further unless a new unanswered question justifies it.

## Public source

Authority:

- Los Alamos National Laboratory (LANL)

Dataset:

- User-Computer Authentication Associations in Time

Canonical page:

- `https://csr.lanl.gov/data/auth/`

Frozen source part:

- `lanl-auth-dataset-1-03.bz2`

Source identity:

```text
SOURCE_BYTES=184600177
SOURCE_SHA256=ae42db8f4a7dafcfa7c286447eba5d1c7d3c5de076538647c57582d14c21f57f
OFFICIAL_SHA256=ae42db8f4a7dafcfa7c286447eba5d1c7d3c5de076538647c57582d14c21f57f
```

The local SHA-256 must match the SHA-256 entry published in LANL `checksums.txt`.

Compression integrity must also pass with `bzip2 -t`.

## Source semantics

The source event schema is exactly:

```text
time,user,computer
```

The case does not invent additional authentication fields.

The source timestamps are used as published. The experiment preserves their ordering and does not reinterpret them as wall-clock UTC dates.

## B0 — 10K baseline

### Sampling rule

Select exactly the first 10,000 decompressed event lines from the frozen source part, without reordering or semantic transformation.

The sample itself is frozen separately by SHA-256.

Expected contract:

```text
EVENTS=10000
BAD_FIELDS=0
BAD_TIME=0
EMPTY_USER=0
EMPTY_COMPUTER=0
TIME_REGRESSIONS=0
```

### Event identity

The dataset does not provide a guaranteed globally unique event ID for this case.

The ledger therefore uses a deterministic ordinal identity:

```text
auth/event/000000000001
auth/event/000000000002
...
auth/event/000000010000
```

The ordinal represents event position in the frozen source slice.

### Event value

The value is the exact original LANL event line:

```text
time,user,computer
```

No JSON conversion or semantic enrichment is part of the authoritative tested path.

## Independent oracle

An independent POSIX/AWK oracle constructs the canonical ledger without calling KyberDB.

Canonical representation:

```text
<ledger-key>\t<exact-source-line>\n
```

The oracle records:

- canonical record count;
- canonical ledger byte count;
- SHA-256 of the canonical ledger.

The oracle SHA-256 is the external correctness target for the post-reopen KyberDB replay.

## KyberDB contract

Use only the public C11 ABI from:

```text
include/kyber/kyber.h
```

Frozen public header identity:

```text
6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d
```

Frozen library identity:

```text
ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4
```

Durability:

```text
KYBER_DURABILITY_FULL
```

Batch size:

```text
1000 events
```

Expected durable commits:

```text
10
```

No internal KyberDB API may be used.

## B0 validation gates

The baseline passes only if all of the following hold:

```text
SOURCE_AUTHORITY=PASS
SOURCE_OFFICIAL_SHA256=PASS
SOURCE_COMPRESSION_INTEGRITY=PASS
DATASET_CONTRACT=PASS

EVENTS_SELECTED=10000
ORACLE_RECORDS=10000

EVENT_PUTS=10000
COMMIT_COUNT=10
LOAD=PASS

VERIFY_PRE_CLOSE=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS

POST_REOPEN_FOUND=10000
POST_REOPEN_MISSING=0
POST_REOPEN_VALUE_MISMATCH=0
KYBER_LEDGER_REPLAY=PASS

ORACLE_LEDGER_SHA256 == KYBER_LEDGER_SHA256
POST_REOPEN_LEDGER_EQUIVALENCE=PASS

EVIDENCE_INTEGRITY=PASS
RUN_RC=0
```

## TAMPER-A

TAMPER-A is run only after a B0 database has been homologated.

### Safety rule

The homologated B0 database must never be modified.

The experiment first verifies the frozen B0 evidence, then copies only the database into a separate tamper workspace.

### Baseline-clone gate

Before mutation, the copied database must open and verify successfully:

```text
OPEN_STATUS=OK
VERIFY_STATUS=OK
BASELINE_CLONE_VERIFY=PASS
```

### Mutation rule

Select one persisted `.kseg` deterministically.

For the validated run, selection was the largest segment with lexical path tie-breaking.

Change exactly one byte at a deterministic offset while preserving file length.

Record before and after:

- target segment path;
- target segment size;
- byte offset;
- original byte value;
- mutated byte value;
- original SHA-256;
- mutated SHA-256.

Required mutation gates:

```text
ONE_BYTE_MUTATION=PASS
SEGMENT_SIZE_PRESERVED=PASS
ORIGINAL_SEGMENT_SHA256 != TAMPERED_SEGMENT_SHA256
```

## Tamper hypothesis

The narrow hypothesis is:

> A persisted database that verified successfully before mutation will not be accepted unchanged by the current KyberDB integrity path after a controlled one-byte physical mutation in a persisted segment.

A rejection may occur during `kyber_env_open()` or during explicit `kyber_verify()`.

The case must report the observed detection stage exactly.

## TAMPER-A validation gates

The stage passes if:

```text
SOURCE_B0_INTEGRITY=PASS
SOURCE_DB_CLONED=PASS
BASELINE_CLONE_VERIFY=PASS
ONE_BYTE_MUTATION=PASS
SEGMENT_SIZE_PRESERVED=PASS
TAMPER_DETECTION=PASS
SOURCE_B0_STILL_INTACT=PASS
EVIDENCE_INTEGRITY=PASS
RUN_RC=0
```

For the validated run, corruption was detected at open, so the expected observed classification is:

```text
DETECTION_STAGE=ENV_OPEN
KYBER_VERIFY_REJECTION=NOT_REACHED
```

## Allowed claims

If B0 passes, the case may claim:

- exact preservation of the tested 10,000-event LANL ledger;
- durable survival across close/reopen;
- exact post-reopen reconstruction against an independent oracle;
- public-ABI-only execution for the tested KyberDB path.

If TAMPER-A also passes, the case may additionally claim:

- a controlled one-byte mutation in the tested persisted segment caused the altered database to be rejected;
- the rejection occurred at the exact observed stage reported by the experiment.

## Claims not earned

This case does not establish:

- intrusion detection;
- threat classification;
- SIEM functionality;
- automatic compliance;
- user/session reconstruction beyond the tested ledger representation;
- point-in-time time-travel;
- multiple concurrent writers;
- crash/power-loss recovery semantics;
- automatic localization of the corrupted segment or offset by KyberDB;
- cryptographic non-repudiation;
- performance superiority over another engine.

## Engine-change rule

PASS does not automatically justify a new feature.

FAIL does not automatically justify a new feature.

An engine change is earned only when a limitation recurs across independent real-world cases and the missing capability is clearly identified.

For the validated B0 and TAMPER-A runs:

```text
ENGINE_CHANGE=NO
```

## Official-path constraints

```text
C11=YES
POSIX=YES
PYTHON=NO
SQL=NO
LLM=NO
KYBER_INTERNAL_API=NO
```
