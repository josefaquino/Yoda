# AUDIT-FORENSICS-001 — Results

## Final status

```text
AUDIT_FORENSICS_001_B0_10K=PASS
AUDIT_FORENSICS_001_TAMPER_A=PASS
ENGINE_CHANGE=NO
```

This case has two validated stages:

1. B0-10K — exact durable ledger preservation and reconstruction.
2. TAMPER-A — controlled one-byte physical mutation rejected by KyberDB during environment open.

---

## B0-10K — Exact Authentication Ledger Preservation

### Source authority

```text
PUBLIC_AUTHORITY=LANL
DATASET=User-Computer Authentication Associations in Time
SOURCE_PART=lanl-auth-dataset-1-03.bz2
SOURCE_BYTES=184600177
SOURCE_SHA256=ae42db8f4a7dafcfa7c286447eba5d1c7d3c5de076538647c57582d14c21f57f
OFFICIAL_SHA256=ae42db8f4a7dafcfa7c286447eba5d1c7d3c5de076538647c57582d14c21f57f
CHECKSUMS_FILE_SHA256=a783e1eb168287702d0f46692f4304b4309456e5ba6ddd146e5de8a6e948bf64
SOURCE_AUTHORITY=PASS
SOURCE_OFFICIAL_SHA256=PASS
SOURCE_COMPRESSION_INTEGRITY=PASS
```

### Frozen 10K sample

```text
EVENT_SCHEMA=time,user,computer
EVENTS=10000
FIRST_TIME=7257601
LAST_TIME=7258534
BAD_FIELDS=0
BAD_TIME=0
EMPTY_USER=0
EMPTY_COMPUTER=0
TIME_REGRESSIONS=0
SAMPLE_EVENTS=10000
SAMPLE_BYTES=182448
SAMPLE_SHA256=6c3a4bec92c377fe5808947ee3fb6c5daf17f99e26d9cc64146e3f89e296e0ab
DATASET_CONTRACT=PASS
```

### Independent oracle

```text
ORACLE_RECORDS=10000
ORACLE_BYTES=422448
ORACLE_LEDGER_SHA256=e65fe0f6cdb8cbe378fb8bb2410bc549a0f329495a63f5806ad8d78ecc9cee85
LOGICAL_STATE_BYTES=402448
INDEPENDENT_ORACLE=PASS
```

### KyberDB authority

```text
KYBER_HEADER_SHA256=6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d
KYBER_LIBRARY_SHA256=ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4
HARNESS_C_SHA256=dbaa35af29ff05722abbb03b8689abc194f630db6dcbe9b42cd16268f9b02162
HARNESS_BINARY_SHA256=e211b3c071b92576a4f4f3263507fa599faeb1cba4783a0147b0ff6f9981d23e
KYBER_PUBLIC_ABI=PASS
INTERNAL_KYBER_API_USED=NO
```

### Durable ingest

```text
OPEN_CREATE_NS=10539357
EVENT_PUTS=10000
COMMIT_COUNT=10
DURABLE_INGEST_NS=5522876487
DURABLE_EVENTS_S=1810.651
COMMIT_P50_US=103244
COMMIT_P95_US=121280
COMMIT_P99_US=121280
COMMIT_MAX_US=121280
LOAD=PASS
```

### Verify, reopen and replay

```text
VERIFY_PRE_CLOSE=PASS
VERIFY_PRE_CLOSE_NS=1861337768

CLOSE_REOPEN=PASS
REOPEN_NS=753911577

VERIFY_POST_REOPEN=PASS
VERIFY_POST_REOPEN_NS=1063734474

READ_TXN_BEGIN_NS=78308
POST_REOPEN_FOUND=10000
POST_REOPEN_MISSING=0
POST_REOPEN_VALUE_MISMATCH=0
POST_REOPEN_REPLAY_NS=131015553
POST_REOPEN_GET_OPS_S=76326.816
MAX_RSS_KB=12168
KYBER_LEDGER_REPLAY=PASS
```

### Exact equivalence

```text
ORACLE_RECORDS=10000
KYBER_RECORDS=10000

ORACLE_LEDGER_SHA256=e65fe0f6cdb8cbe378fb8bb2410bc549a0f329495a63f5806ad8d78ecc9cee85
KYBER_LEDGER_SHA256=e65fe0f6cdb8cbe378fb8bb2410bc549a0f329495a63f5806ad8d78ecc9cee85

POST_REOPEN_LEDGER_EQUIVALENCE=PASS
```

### Physical footprint

```text
DATABASE_BYTES=23986954
SEGMENT_COUNT=20
LOGICAL_STATE_BYTES=402448
PHYSICAL_AMPLIFICATION=59.602617
```

### B0 final result

```text
AUDIT_FORENSICS_001_B0_10K=PASS
EVIDENCE_INTEGRITY=PASS
RUN_RC=0
CONSOLE_SHA256=a75df118d5b4a7e33623de5684f0761d89370f2ca72dafb547377b8eac0d4a50
ENGINE_CHANGE=NO
```

Interpretation:

> KyberDB preserved the tested ordered 10,000-event LANL authentication ledger exactly across durable persistence, verification, close/reopen and replay. The post-reopen ledger was byte-identical to the independent oracle representation.

---

## TAMPER-A — One-Byte Physical Tamper Rejection

### Homologated source protection

Before the tamper experiment, every frozen B0 evidence artifact verified successfully.

```text
SOURCE_B0_INTEGRITY=PASS
SOURCE_DB_CLONED=PASS
```

The original homologated database was not used as the mutation target.

### Clone baseline

Before mutation, the cloned database opened and verified normally:

```text
OPEN_STATUS=OK
OPEN_CODE=0
OPEN_NS=726299059
VERIFY_STATUS=OK
VERIFY_CODE=0
VERIFY_NS=974743138
BASELINE_CLONE_VERIFY=PASS
```

### Controlled mutation

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

Exactly one byte was changed and file size was preserved.

### Detection result

```text
OPEN_STATUS=CORRUPT
OPEN_CODE=6
OPEN_NS=266791192
TAMPER_VERIFY_RC=20
DETECTION_STAGE=ENV_OPEN
KYBER_VERIFY_REJECTION=NOT_REACHED
TAMPER_DETECTION=PASS
```

The corrupted database was rejected during `kyber_env_open()`.

Explicit `kyber_verify()` was never reached on the corrupted copy, so this case does not attribute the detection to `kyber_verify()`.

### Original database remained intact

After the tamper experiment, the frozen B0 evidence was verified again successfully:

```text
SOURCE_B0_STILL_INTACT=PASS
```

### TAMPER-A authority

```text
KYBER_HEADER_SHA256=6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d
KYBER_LIBRARY_SHA256=ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4
VERIFY_C_SHA256=88e320dc12b6aacc4af16ab790555e61768d507db6ad10b6ff19ad6b4a79002b
VERIFY_BINARY_SHA256=821afb7aa06b38769f2d560cf08721e830f59744e210d2eab3a4aa6929c92a37
PUBLIC_ABI_ONLY=YES
```

### TAMPER-A final result

```text
AUDIT_FORENSICS_001_TAMPER_A=PASS
TAMPER_DETECTION=PASS
DETECTION_STAGE=ENV_OPEN
SOURCE_B0_STILL_INTACT=PASS
EVIDENCE_INTEGRITY=PASS
RUN_RC=0
CONSOLE_SHA256=a00b2e556cd0fba03ff04dfd760a5592353af852d2a31550defe699ef27dffef
ENGINE_CHANGE=NO
```

Interpretation:

> A controlled one-byte physical mutation in a persisted KyberDB segment caused the altered database to be rejected as `CORRUPT` during environment open, while the original homologated B0 database remained unchanged.

---

## What is proven

For this tested workload and implementation:

```text
EXACT_LEDGER_PRESERVATION=PROVEN
DURABLE_CLOSE_REOPEN_RECONSTRUCTION=PROVEN
ONE_BYTE_PERSISTED_TAMPER_REJECTION=PROVEN
```

## What is not proven

The case does not prove:

- intrusion detection;
- forensic attribution;
- automatic compliance;
- time-travel;
- crash recovery;
- multi-writer concurrency;
- exact corruption localization by KyberDB;
- general detection of every possible corruption pattern;
- performance superiority.

The tamper result is deliberately scoped to the controlled mutation that was actually executed.

## Tooling constraints

```text
PYTHON_USED=NO
SQL_USED=NO
LLM_USED=NO
INTERNAL_KYBER_API_USED=NO
```
