# GENOME-REFERENCE-001 — FASTA/faidx Region Equivalence

GENOME-REFERENCE-001 is a KyberDB field case using the public NCBI RefSeq genome of *Escherichia coli* K-12 MG1655 and `samtools faidx` as an independent bioinformatics oracle.

It asks one narrow question:

> Can KyberDB represent a real reference genome as durable embedded state, close and reopen the database, and reproduce standard coordinate-region queries byte-for-byte against `samtools faidx`?

The validated answer for the tested workload is **yes**.

## Public authority

- source: NCBI RefSeq;
- assembly: `GCF_000005845.2` (`ASM584v2`);
- sequence accession: `NC_000913.3`;
- reference length: `4,641,652` bases;
- oracle: `samtools 1.21`, using HTSlib 1.21;
- region semantics: standard `faidx` coordinate lookup;
- deterministic query set: 256 regions.

## Tested architecture

The experiment deliberately used no genomic engine feature and no internal KyberDB API.

The reference was stored through the existing public embedded ABI as fixed 4096-byte values:

```text
NCBI FASTA
    ↓
4096-byte reference chunks
    ↓
KyberDB public ABI
    ↓
durable commit
    ↓
verify
    ↓
release original in-memory sequence
    ↓
close / reopen
    ↓
verify
    ↓
256 coordinate queries
```

The fixed-chunk layout is an **experimental representation for this case**, not a claim that 4096-byte chunks are the final Kyber Genome Engine format.

## Independent oracle

Stage A built the reference oracle with `samtools faidx` before KyberDB was allowed to answer any region query.

The frozen oracle identity is:

```text
888dc81d391347aaecf3cb458bf34075fed1b0730d97090da4940d92af437ff7
```

Stage B then generated the same 256 region results exclusively from reopened KyberDB state.

The post-reopen KyberDB result identity was exactly the same:

```text
888dc81d391347aaecf3cb458bf34075fed1b0730d97090da4940d92af437ff7
```

Result:

```text
REGION_QUERY_COUNT=256
POST_REOPEN_QUERY_COUNT=256
MISSING=0
MISMATCH=0
POST_REOPEN_REGION_EQUIVALENCE=PASS
```

## Durability and verification

The validated run also produced:

```text
VERIFY_PRE_CLOSE=PASS
SOURCE_SEQUENCE_RELEASED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO
```

The source sequence was released from memory before close/reopen, so the post-reopen region answers were reconstructed from persisted KyberDB state rather than from the original in-memory FASTA sequence.

## Measured implementation evidence

For this specific adapter and workload:

```text
REFERENCE_BASES=4641652
CHUNK_COUNT=1134
PUT_COUNT=1136

LOAD_PRECOMMIT_NS=218133469
COMMIT_NS=173156699
VERIFY_PRE_CLOSE_NS=260457144
REOPEN_NS=131833440
VERIFY_POST_REOPEN_NS=128504593
POST_REOPEN_QUERY_NS=10240117

DATABASE_BYTES=6877970
DATABASE_FILES=5
```

These numbers are implementation evidence, not a claim of performance superiority over `faidx` or another genomic storage system.

## What this establishes

GENOME-KMER-001 proved exact durable k-mer state.

GENOME-REFERENCE-001 moves one step closer to the real bioinformatics workflow by reproducing a standard reference-genome primitive: coordinate-based region retrieval.

This is the first Yoda/Kyber genomic case in which a standard bioinformatics tool acts as the independent functional adversary.

## What this does not establish

This case does **not** claim:

- general replacement of FASTA/faidx;
- multi-reference or pangenome support;
- human-genome-scale validation;
- BAM/CRAM support;
- FASTQ support;
- VCF/BCF support;
- HTSlib API compatibility;
- production readiness;
- performance superiority;
- biological interpretation.

## Files

- `CASE.md` — hypothesis, authorities, representation and validation gates.
- `RESULTS.md` — measured Stage A/Stage B evidence and identities.
- `WHY-WE-BUILT-THIS.md` — product/research motivation and the next earned question.

This is a KyberDB Public Embedded ABI field case, not a Yoda CORE-015 CLI validation.
