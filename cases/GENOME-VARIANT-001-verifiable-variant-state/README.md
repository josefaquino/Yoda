# GENOME-VARIANT-001 — Verifiable Variant State

GENOME-VARIANT-001 extends the genomic validation chain from reference and reads through alignment into variant state.

It asks a narrow product question:

> Can KyberDB preserve an exact variant-call state derived from a real genomic workflow, then reconstruct the same state after durable persistence and close/reopen?

The case uses:

- matched reference: `GCA_009015325.1`;
- BioSample: `SAMN12676338`;
- read run: `SRR10058842`;
- 10,000 frozen paired reads;
- upstream alignment state reconstructed from KyberDB;
- `bcftools 1.21` / HTSlib 1.21;
- haploid calling (`PLOIDY=1`).

## Workflow

```text
matched reference
      +
Kyber post-reopen alignment state
      ↓
SAM/BAM rehydration
      ↓
bcftools mpileup
      ↓
bcftools call
      ↓
327 canonical variant records
      ↓
KyberDB
      ↓
verify → close/reopen → verify
      ↓
byte-exact variant reconstruction
```

## Stage A0 — Variant oracle

The upstream alignment evidence was reverified before variant calling.

The Kyber-reconstructed alignment contained:

- 20,074 total alignment records;
- 20,000 primary records;
- 19,917 mapped primary records;
- 18,608 properly paired primary records.

That state was rehydrated into a coordinate-sorted BAM, preserving the measured alignment semantics.

`bcftools mpileup` and `bcftools call` then produced a real non-empty variant state:

```text
VARIANT_RECORD_COUNT=327
SNP_RECORD_COUNT=325
INDEL_RECORD_COUNT=2
BAD_VARIANT_ROWS=0
```

The frozen canonical variant oracle is:

```text
7bb54f1c2786ec562e68e8f77c546e6f4da8f6d3a9abd21916cdc8c105b85ff1
```

## Stage B — Kyber parity

The 327 canonical records were persisted through the KyberDB Public Embedded ABI using an ordinal key layout.

After commit, verification, close/reopen and a second verification, all 327 records were reconstructed.

Result:

```text
GENOME_VARIANT_001_STAGE_B=PASS
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO
VARIANT_RECORD_COUNT=327
POST_REOPEN_VARIANT_COUNT=327
MISSING=0
MISMATCH=0
POST_REOPEN_VARIANT_EQUIVALENCE=PASS
```

Oracle and KyberDB post-reopen state produced the same SHA-256:

```text
7bb54f1c2786ec562e68e8f77c546e6f4da8f6d3a9abd21916cdc8c105b85ff1
```

## Physical evidence

```text
ORACLE_BYTES=36422
DATABASE_BYTES=485693
DATABASE_FILES=5
PHYSICAL_AMPLIFICATION=13.335155
```

These are measurements of the tested representation, not claims of performance superiority.

## Why this case matters

The important property is not only that KyberDB can store VCF-like records.

The variant oracle was derived from an alignment state that had already been persisted by KyberDB, closed, reopened, reconstructed exactly, and then consumed by standard scientific tooling.

That establishes a stronger workflow property:

> durable KyberDB state can feed the next stage of a real genomics pipeline, and the newly derived scientific state can itself be returned to KyberDB without loss.

The case does **not** claim clinical validity, variant-calling superiority, comprehensive genome coverage, or production-readiness.

This is a KyberDB Public Embedded ABI field case, not a Yoda Core CLI validation.
