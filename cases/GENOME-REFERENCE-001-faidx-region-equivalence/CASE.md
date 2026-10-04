# GENOME-REFERENCE-001 — Case Contract

## Question

Can KyberDB represent a real reference genome as durable embedded state and, after verification plus close/reopen, reproduce the same coordinate-region results as an independent `samtools faidx` oracle?

## Scientific constraint

The case must test a **new genomic property** without modifying the engine.

No new index, genomic API, internal storage path, machine-learning component or domain-specific optimization is allowed before the workload earns it.

## Authorities

### KyberDB

Public header SHA-256:

```text
6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d
```

Static library SHA-256:

```text
ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4
```

Version:

```text
0.0.1-genesis
```

The tested path uses only the public embedded ABI.

### Genomic source

Authority: NCBI RefSeq

```text
ASSEMBLY=GCF_000005845.2
ASSEMBLY_NAME=ASM584v2
ACCESSION=NC_000913.3
REFERENCE_LENGTH=4641652
```

Compressed FASTA SHA-256:

```text
a96d3cfa58c88d477013c768f90a11d2386d42a70d566abfb6d9013dcbd24255
```

Decompressed FASTA SHA-256:

```text
53bb6a51b6e92139ced1e38f74b7938781027c52200922ff03718c2237d23bb4
```

The source was also checked against the official NCBI MD5 manifest.

### Oracle

```text
samtools 1.21
Using htslib 1.21
```

Samtools binary SHA-256:

```text
3163fb5490fa8f3de0a358d903e2a8706ed748d46f48bd8dca1d6fbeaf2c983d
```

## Stage A — Authority and Oracle

Stage A must:

1. verify the NCBI source against the official checksum;
2. confirm a single sequence `NC_000913.3` of exactly 4,641,652 bases;
3. create the standard `.fai` with `samtools faidx`;
4. generate 256 deterministic region queries;
5. resolve those regions through `samtools faidx`;
6. freeze the complete oracle output by SHA-256;
7. write zero KyberDB records.

Required gates:

```text
SOURCE_AUTHORITY=PASS
SOURCE_OFFICIAL_MD5=PASS
REFERENCE_CONTRACT=PASS
REGION_QUERY_COUNT=256
ORACLE_QUERY_COUNT=256
ORACLE_SANITY=PASS
EVIDENCE_INTEGRITY=PASS
KYBER_DB_WRITES=ZERO
```

## Stage B — Kyber Reference Parity

### Experimental representation

The complete reference sequence is split into fixed 4096-byte chunks.

Chunk keys use the reference accession and deterministic zero-based chunk identity.

Two metadata values are also persisted:

- reference length;
- chunk size.

The tested representation produced:

```text
CHUNK_SIZE=4096
CHUNK_COUNT=1134
PUT_COUNT=1136
```

This layout exists only to answer the case question. It is not a final genome-engine format decision.

### Persistence contract

The Stage B harness must:

1. load the FASTA sequence;
2. persist all reference chunks through the KyberDB public ABI;
3. commit with full durability;
4. run `kyber_verify()`;
5. release the original in-memory reference sequence;
6. close the environment;
7. reopen it;
8. run `kyber_verify()` again;
9. answer the exact Stage A region suite from persisted KyberDB state;
10. compare the full Kyber output byte-for-byte with the frozen `faidx` oracle.

### Functional gates

```text
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO
VERIFY_PRE_CLOSE=PASS
SOURCE_SEQUENCE_RELEASED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
REGION_QUERY_COUNT=256
POST_REOPEN_QUERY_COUNT=256
MISSING=0
MISMATCH=0
POST_REOPEN_REGION_EQUIVALENCE=PASS
```

The oracle and post-reopen Kyber output must also have exactly the same SHA-256.

## Attempt policy

### Attempt 001

Stage B Attempt 001 failed before data ingestion because the harness pre-created an empty database directory.

`KYBER_OPEN_CREATE` expects the new repository path not to exist. The pre-created empty directory therefore caused:

```text
FAIL_AT=kyber_env_open(create)
STATUS=NOT_FOUND
```

Classification:

```text
FAILURE_CLASS=HARNESS_SETUP_ERROR
KYBER_REGRESSION=NO
CORRECTNESS_TESTED=NO
ENGINE_CHANGE=NO
```

Only the harness setup was corrected; the engine, public ABI, source, oracle and scientific question remained unchanged.

### Attempt 002

Attempt 002 removed the premature database-directory creation and reran the same Stage B contract.

It passed all gates.

## Pass criterion

GENOME-REFERENCE-001 is validated only if the complete post-reopen region result is byte-identical to the independent `samtools faidx` oracle.

## Out of scope

The case does not test or claim:

- complete FASTA/faidx replacement;
- optimized region-query performance;
- multiple chromosomes or references;
- pangenomes;
- human genome scale;
- alignment;
- variant calling;
- biological interpretation;
- clinical use.
