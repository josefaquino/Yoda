# GENOME-KMER-001 — Case Contract

## Objective

Validate whether KyberDB can persist and reconstruct an exact genomic k-mer frequency index using only its public embedded ABI.

The experiment is intentionally incremental. It does not start at millions of records. Scale is earned by smaller validated stages.

## Public source

- Authority: NCBI RefSeq
- Assembly: `GCF_000005845.2`
- Assembly name: `ASM584v2`
- Sequence accession: `NC_000913.3`
- Organism: *Escherichia coli* K-12 MG1655
- FASTA: `GCF_000005845.2_ASM584v2_genomic.fna.gz`

Frozen source evidence:

```text
SOURCE_BYTES=1379902
NCBI_MD5=c13d459b5caa702ff7e1f26fe44b8ad7
SOURCE_SHA256=a96d3cfa58c88d477013c768f90a11d2386d42a70d566abfb6d9013dcbd24255
FASTA_SHA256=53bb6a51b6e92139ced1e38f74b7938781027c52200922ff03718c2237d23bb4
```

Expected sequence length:

```text
SEQUENCE_LENGTH=4641652
```

## K-mer semantics

```text
K=31
WINDOW_MODE=LINEAR
CIRCULAR_WRAPAROUND=NO
CASE=UPPERCASE
VALID_BASES=A,C,G,T
REVERSE_COMPLEMENT_NORMALIZATION=NO
```

Each valid sliding window produces a 31-base k-mer.

The canonical logical state is:

```text
KEY   = exact 31-byte ASCII k-mer
VALUE = exact occurrence count
```

The independent oracle sorts all valid k-mers, aggregates equal keys and emits a canonical TSV state.

## Engine contract

The KyberDB path uses only the public embedded ABI.

Required operations:

- environment open/create;
- transaction begin;
- put;
- commit;
- verify;
- close;
- reopen;
- read transaction;
- get;
- final close.

Internal KyberDB APIs are forbidden.

Durability mode is FULL.

## Incremental stages

### B0 — 10K

```text
WINDOW_LIMIT=10000
BATCH_SIZE=1000
```

Purpose: smoke, correctness and first physical-cost measurement.

### B1 — 100K

```text
WINDOW_LIMIT=100000
BATCH_SIZE=1000
```

Purpose: validate the same semantics at the next cardinality step without changing the engine or harness.

No larger stage is implied automatically by a PASS.

## Independent oracle

The oracle is an independent C11 implementation.

For each stage it must determine:

- windows considered;
- valid windows;
- ambiguous windows;
- unique k-mers;
- singleton k-mers;
- maximum k-mer frequency;
- canonical state SHA-256.

The oracle must not call KyberDB.

## Correctness gates

A stage passes only if all applicable gates pass:

```text
SOURCE_AUTHORITY=PASS
SOURCE_IDENTITY_FROZEN=PASS
DATASET_CONTRACT=PASS
INDEPENDENT_ORACLE=PASS

KYBER_PUBLIC_ABI=PASS
FULL_DURABILITY=PASS

DATABASE_VERIFY_PRE_CLOSE=PASS
CLOSE_REOPEN=PASS
DATABASE_VERIFY_POST_REOPEN=PASS

POST_REOPEN_MISSING=0
POST_REOPEN_VALUE_MISMATCH=0
ORACLE_RECORD_COUNT=KYBER_RECORD_COUNT
ORACLE_STATE_SHA256=KYBER_STATE_SHA256
POST_REOPEN_STATE_EQUIVALENCE=PASS

EVIDENCE_INTEGRITY=PASS
RUN_RC=0
```

Performance is measured but is not itself a correctness gate unless an explicit operational timeout is reached.

## Measured performance evidence

The case records:

```text
ORACLE_WINDOWS_S
DURABLE_UNIQUE_PUTS_S
COMMIT_P50_US
COMMIT_P95_US
COMMIT_P99_US
COMMIT_MAX_US
VERIFY_PRE_CLOSE_NS
REOPEN_NS
VERIFY_POST_REOPEN_NS
READ_TXN_BEGIN_NS
POST_REOPEN_GET_OPS_S
MAX_RSS_KB
DATABASE_BYTES
LOGICAL_STATE_BYTES
PHYSICAL_AMPLIFICATION
```

## Claims allowed after PASS

Allowed:

> KyberDB can persist a deterministic k-mer frequency index for the tested genomic window set and reconstruct exactly the same canonical state after verification, close and reopen.

Not allowed:

- variant calling;
- sequence alignment;
- genome assembly;
- pangenome analysis;
- clinical or biological interpretation;
- performance superiority over specialized bioinformatics databases.

## Engine-change rule

A PASS does not automatically authorize a feature.

A performance observation does not automatically identify its internal cause.

Any future engine change must be earned by reproducible evidence and isolated in a separate experiment.
