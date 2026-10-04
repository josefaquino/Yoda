# AUDIT-FORENSICS-001 — Verifiable Authentication Event Ledger

AUDIT-FORENSICS-001 is a KyberDB field case using the public LANL User-Computer Authentication Associations in Time dataset.

It asks a narrow product question:

> Can KyberDB preserve a real authentication-event ledger durably, reconstruct exactly the same ordered ledger after close/reopen, and reject persisted storage after a controlled one-byte physical tamper?

The case uses:

- public authority: Los Alamos National Laboratory (LANL);
- dataset: User-Computer Authentication Associations in Time;
- source part: `lanl-auth-dataset-1-03.bz2`;
- source schema: `time,user,computer`;
- baseline event count: 10,000;
- key: deterministic ledger ordinal `auth/event/<12-digit ordinal>`;
- value: exact original LANL event line.

## What the solution does

The tested pipeline turns real authentication events into a durable local ledger:

```text
LANL authentication events
        ↓
ordered event stream
        ↓
auth/event/<ordinal> → exact source line
        ↓
KyberDB
        ↓
durable, reopenable, verifiable event ledger
```

The baseline case proves preservation and exact reconstruction. A second stage copies the homologated database, flips exactly one byte in one persisted segment, and tests whether the altered database is accepted.

This provides a foundational storage primitive for workflows that need locally preserved audit evidence and corruption rejection.

The case does **not** claim intrusion detection, SIEM functionality, automatic compliance, automatic attribution, time-travel, concurrent writers, or localization of the corrupted segment/offset by KyberDB.

## Validated stages

### B0 — 10K exact ledger preservation

The baseline stage used the first 10,000 events from the frozen LANL source part.

Source authority:

```text
SOURCE_BYTES=184600177
SOURCE_SHA256=ae42db8f4a7dafcfa7c286447eba5d1c7d3c5de076538647c57582d14c21f57f
OFFICIAL_SHA256=ae42db8f4a7dafcfa7c286447eba5d1c7d3c5de076538647c57582d14c21f57f
SOURCE_OFFICIAL_SHA256=PASS
SOURCE_COMPRESSION_INTEGRITY=PASS
```

The deterministic sample contained:

```text
EVENTS=10000
FIRST_TIME=7257601
LAST_TIME=7258534
BAD_FIELDS=0
BAD_TIME=0
EMPTY_USER=0
EMPTY_COMPUTER=0
TIME_REGRESSIONS=0
```

The independent oracle produced:

```text
ORACLE_RECORDS=10000
ORACLE_LEDGER_SHA256=e65fe0f6cdb8cbe378fb8bb2410bc549a0f329495a63f5806ad8d78ecc9cee85
```

KyberDB then persisted the same 10,000 events across 10 durable commits, verified the database, closed and reopened it, verified again, and replayed every record.

Result:

```text
EVENT_PUTS=10000
COMMIT_COUNT=10
VERIFY_PRE_CLOSE=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
POST_REOPEN_FOUND=10000
POST_REOPEN_MISSING=0
POST_REOPEN_VALUE_MISMATCH=0
KYBER_LEDGER_REPLAY=PASS
```

The post-reopen KyberDB ledger produced the exact same SHA-256 as the independent oracle:

```text
ORACLE_LEDGER_SHA256=e65fe0f6cdb8cbe378fb8bb2410bc549a0f329495a63f5806ad8d78ecc9cee85
KYBER_LEDGER_SHA256=e65fe0f6cdb8cbe378fb8bb2410bc549a0f329495a63f5806ad8d78ecc9cee85
POST_REOPEN_LEDGER_EQUIVALENCE=PASS
```

Therefore:

```text
AUDIT_FORENSICS_001_B0_10K=PASS
ENGINE_CHANGE=NO
```

### TAMPER-A — one-byte physical tamper rejection

TAMPER-A started from an integrity-checked copy of the B0 database. Before mutation, the clone opened and verified successfully:

```text
OPEN_STATUS=OK
VERIFY_STATUS=OK
BASELINE_CLONE_VERIFY=PASS
```

The experiment selected one persisted segment deterministically and changed exactly one byte while preserving file size:

```text
TARGET_SEGMENT=segments/34b3066118e84ac2c70a5858b952e158d9709aa5d21b1d147e99698ae97ee3bb.kseg
TARGET_SIZE=2654707
TAMPER_OFFSET=1327353
ORIGINAL_BYTE_DEC=48
TAMPERED_BYTE_DEC=49
ORIGINAL_SEGMENT_SHA256=df96e0c06a69c61502d1ab3408254c07f4273ac20c98a02d72bd310643f48241
TAMPERED_SEGMENT_SHA256=3e5db2a6173035558922ccd1e77fce09f25b8d38dca21570f1fdffefd02b4aee
ONE_BYTE_MUTATION=PASS
SEGMENT_SIZE_PRESERVED=PASS
```

When the altered copy was opened, KyberDB rejected it immediately:

```text
OPEN_STATUS=CORRUPT
OPEN_CODE=6
DETECTION_STAGE=ENV_OPEN
KYBER_VERIFY_REJECTION=NOT_REACHED
TAMPER_DETECTION=PASS
```

The original B0 database remained unchanged and its frozen evidence still verified successfully.

Therefore:

```text
AUDIT_FORENSICS_001_TAMPER_A=PASS
SOURCE_B0_STILL_INTACT=PASS
EVIDENCE_INTEGRITY=PASS
ENGINE_CHANGE=NO
```

## Performance evidence

B0 also recorded the operational cost for the tested 10K workload:

```text
DURABLE_EVENTS_S=1810.651
COMMIT_P50_US=103244
COMMIT_P95_US=121280
COMMIT_P99_US=121280
VERIFY_PRE_CLOSE_NS=1861337768
REOPEN_NS=753911577
VERIFY_POST_REOPEN_NS=1063734474
POST_REOPEN_GET_OPS_S=76326.816
MAX_RSS_KB=12168
DATABASE_BYTES=23986954
PHYSICAL_AMPLIFICATION=59.602617
```

These measurements are evidence about the tested implementation. They are not a claim of performance superiority.

## Why this case matters

FIRMS and USGS exercised public scientific observations and event identity. RIPE RIS exercised mutable routing state. GENOME-KMER-001 exercised a deterministic genomic index. AUDIT-FORENSICS-001 changes the pressure again: an ordered authentication-event ledger whose exact source bytes must survive persistence and whose persisted representation must reject a controlled physical mutation.

The case establishes two distinct properties for the tested workload:

```text
PRESERVATION      = PROVEN
TAMPER_REJECTION  = PROVEN
```

More precisely, the tamper was rejected during `kyber_env_open()`. The experiment does not claim that `kyber_verify()` performed the detection, because explicit verify was never reached on the corrupted copy.

## Files

- `CASE.md` — hypothesis, source contract, event identity model, stages and gates.
- `RESULTS.md` — measured B0 and TAMPER-A evidence.

This is a KyberDB Public Embedded ABI field case, not a Yoda CORE-015 CLI validation.
