# GENOME-REFERENCE-001 — Results

## Final status

```text
GENOME_REFERENCE_001=VALIDATED
STAGE_A=PASS
STAGE_B_ATTEMPT_001=FAIL_HARNESS_SETUP
STAGE_B_ATTEMPT_002=PASS
ENGINE_CHANGE=NO
PUBLIC_ABI_ONLY=YES
MORE_SCALE_REQUIRED=NO
```

## Stage A — Authority + Oracle

```text
KYBER_HEADER_SHA256=6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d
KYBER_LIBRARY_SHA256=ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4
SAMTOOLS_SHA256=3163fb5490fa8f3de0a358d903e2a8706ed748d46f48bd8dca1d6fbeaf2c983d
SAMTOOLS_VERSION=samtools 1.21

SOURCE_OFFICIAL_MD5=PASS
FASTA_GZ_BYTES=1379902
FASTA_GZ_SHA256=a96d3cfa58c88d477013c768f90a11d2386d42a70d566abfb6d9013dcbd24255

FASTA_BYTES=4699745
FASTA_SHA256=53bb6a51b6e92139ced1e38f74b7938781027c52200922ff03718c2237d23bb4

FAI_SEQUENCE_COUNT=1
FAI_ACCESSION=NC_000913.3
FAI_REFERENCE_LENGTH=4641652
REFERENCE_CONTRACT=PASS

REGION_QUERY_COUNT=256
ORACLE_QUERY_COUNT=256
BAD_ORACLE_ROWS=0
ORACLE_SANITY=PASS

ORACLE_SHA256=888dc81d391347aaecf3cb458bf34075fed1b0730d97090da4940d92af437ff7
EVIDENCE_INTEGRITY=PASS
EVIDENCE_MANIFEST_SHA256=7c3f07d660e9a28d4edd8ad18ebd038ca3a79bbb498d819d26f8df5b482974d2
KYBER_DB_WRITES=ZERO
```

Stage A script identity:

```text
bf44d44bbbf6d6f4523e38f2120805e8451cff4ca5ba7ad04e960281a8052911
```

Stage A Attempt 002 console identity:

```text
53458bba3208ad8dca0fc188c6421b3b624065cd385c2f57a32a62a5e06fd59a
```

## Stage B — Attempt 001

The harness compiled successfully, but the run stopped at environment creation:

```text
KYBER_VERSION=0.0.1-genesis
REFERENCE_LAYOUT=FIXED_CHUNK_4096_EXPERIMENTAL
CHUNK_SIZE=4096
REFERENCE_BASES=4641652
CHUNK_COUNT=1134
FAIL_AT=kyber_env_open(create) STATUS=NOT_FOUND
HARNESS_RC=1
```

Root cause: the shell harness created an empty database directory before calling `KYBER_OPEN_CREATE`.

Classification:

```text
GENOME_REFERENCE_001_STAGE_B_ATTEMPT_001=FAIL
FAILURE_CLASS=HARNESS_SETUP_ERROR
KYBER_REGRESSION=NO
CORRECTNESS_TESTED=NO
KYBER_DATA_INGESTED=NO
ENGINE_CHANGE=NO
```

Attempt 001 script SHA-256:

```text
dd30d2a1a76a0948dc8721eb18e39b5e6d33bf87ffeddd9eab192fdb52dc4843
```

Attempt 001 console SHA-256:

```text
5a1ba5596c49feae49f3444dd85491339b56a7b1b8f1765b67d5b38c3d9fd981
```

## Stage B — Attempt 002

The only setup correction was to stop pre-creating the empty database path.

The source, oracle, engine, public ABI and scientific question remained unchanged.

### Build

```text
HARNESS_SOURCE_SHA256=71e90f59ce3577977362fb4e342adc454d558ad1bd3da42205c9e1e1567af37b
HARNESS_BINARY_SHA256=d783b7d38a23c604d60183e5897483969121056b5025e86112d5e9ff01101b16
BUILD=PASS
```

### Load + persistence

```text
KYBER_VERSION=0.0.1-genesis
REFERENCE_LAYOUT=FIXED_CHUNK_4096_EXPERIMENTAL
CHUNK_SIZE=4096
REFERENCE_BASES=4641652
CHUNK_COUNT=1134
PUT_COUNT=1136
LOAD_PRECOMMIT_NS=218133469
COMMIT_NS=173156699
```

### Verification + reopen

```text
VERIFY_PRE_CLOSE=PASS
VERIFY_PRE_CLOSE_NS=260457144
SOURCE_SEQUENCE_RELEASED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
REOPEN_NS=131833440
VERIFY_POST_REOPEN=PASS
VERIFY_POST_REOPEN_NS=128504593
```

### Region reconstruction

```text
POST_REOPEN_QUERY_COUNT=256
POST_REOPEN_QUERY_NS=10240117
HARNESS_RESULT=PASS
HARNESS_RC=0
```

### Exact parity

Independent `samtools faidx` oracle:

```text
888dc81d391347aaecf3cb458bf34075fed1b0730d97090da4940d92af437ff7
```

Post-reopen Kyber region output:

```text
888dc81d391347aaecf3cb458bf34075fed1b0730d97090da4940d92af437ff7
```

Gates:

```text
KYBER_QUERY_COUNT=256
BYTE_EXACT_REGION_EQUIVALENCE=PASS
MISSING=0
MISMATCH=0
POST_REOPEN_REGION_EQUIVALENCE=PASS
```

### Footprint

```text
DATABASE_BYTES=6877970
DATABASE_FILES=5
```

For context, the decompressed FASTA was 4,699,745 bytes. The tested database therefore occupied about 1.46× the raw FASTA file size. This ratio is descriptive evidence for this exact experimental layout, not a general storage-amplification claim.

### Stage B evidence

```text
STAGE_B_EVIDENCE_INTEGRITY=PASS
STAGE_B_MANIFEST_SHA256=e47bed422371e9eb936912d12bb8db7fc3d8c899104edb3ad05fc9d54755bbe5
```

Attempt 002 script SHA-256:

```text
ae9bc2f59ace875fece42934e676fd297476b9f37beaa3b25e5ab1f7e1c22d52
```

Attempt 002 console SHA-256:

```text
dcc7f3a487b432a1925b012df68cfaf0308a77c7fab38358a3c83f972db68065
```

## Safe conclusion

> KyberDB represented the complete NCBI RefSeq *E. coli* K-12 MG1655 reference genome as durable embedded state and reproduced 256 deterministic coordinate queries byte-for-byte against `samtools faidx` after verification, close/reopen, and release of the original in-memory sequence.

## Interpretation

This case earns one new capability claim: **reference-region retrieval parity for the tested reference and deterministic query suite**.

It does not earn claims of general FASTA replacement, optimized genomic performance, alignment, variant processing, multi-reference support, clinical use or production readiness.
