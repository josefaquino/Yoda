# GENOME-READ-001 — Verifiable ReadSet State

GENOME-READ-001 is a KyberDB field case using a real paired-end Illumina sequencing run from EMBL-EBI ENA.

It asks a narrow product question:

> Can KyberDB preserve a real sequencing ReadSet — pair identity, R1 sequence, R1 quality, R2 sequence and R2 quality — then reconstruct exactly the same ReadSet after durable persistence and close/reopen?

The case uses:

- public authority: EMBL-EBI ENA;
- run: `SRR10058842`;
- study: `PRJNA563564`;
- platform: Illumina HiSeq 2500;
- layout: paired-end;
- strategy: WGS;
- deterministic sample: 10,000 read pairs;
- oracle tool: `seqtk 1.4-r122`;
- KyberDB Public Embedded ABI only;
- no engine changes.

## Tested pipeline

```text
ENA paired FASTQ
      ↓
official MD5 verification
      ↓
deterministic 10K paired sample
      ↓
canonical ReadSet oracle
      ↓
KyberDB
      ↓
verify → close → reopen → verify
      ↓
reconstructed ReadSet
      ↓
byte-exact comparison
```

Each canonical pair preserves:

```text
PAIR_ID
R1_SEQUENCE
R1_QUALITY
R2_SEQUENCE
R2_QUALITY
```

## Result

The Stage B run persisted 10,000 read pairs and reconstructed all 10,000 after reopen.

```text
PAIR_PUT_COUNT=10000
POST_REOPEN_PAIR_COUNT=10000
MISSING=0
MISMATCH=0
POST_REOPEN_READSET_EQUIVALENCE=PASS
```

The independent oracle and reconstructed KyberDB state produced the same SHA-256:

```text
2c900493cc32a0c847fb7b78421c0afeab8e21a006fa6b9415951913f9eb9ae7
```

Database verification passed before close and after reopen.

```text
VERIFY_PRE_CLOSE=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
ENGINE_CHANGE=NO
PUBLIC_ABI_ONLY=YES
```

## Measured implementation evidence

```text
LOAD_NS=989132654
COMMIT_NS=658547731
VERIFY_PRE_CLOSE_NS=1235689564
REOPEN_NS=644585637
VERIFY_POST_REOPEN_NS=580861521
POST_REOPEN_QUERY_NS=96123334

ORACLE_BYTES=5234042
DATABASE_BYTES=25546588
DATABASE_FILES=5
PHYSICAL_AMPLIFICATION=4.880853
```

These measurements characterize the tested adapter and current engine. They are not claims of performance superiority.

## Why this matters

GENOME-REFERENCE-001 established exact reference-region lookup against `samtools faidx` after persistence and reopen.

GENOME-READ-001 adds the next real object in the genomic workflow: sequencing reads with their quality strings and mate relationship.

```text
Reference Genome   PASS
       ↓
ReadSet            PASS
       ↓
Alignment          NEXT
```

The case does **not** claim alignment, variant calling, assembly, biological interpretation, clinical readiness or a finished genomic database.

It establishes a narrower capability: exact durable ReadSet state using real public sequencing data and the existing KyberDB public ABI.

## Files

- `CASE.md` — scientific question, authority and validation gates.
- `RESULTS.md` — measured results and evidence identities.
- `WHY-WE-BUILT-THIS.md` — product motivation and next research question.

This is a KyberDB Public Embedded ABI field case, not a Yoda CORE-015 CLI validation.
