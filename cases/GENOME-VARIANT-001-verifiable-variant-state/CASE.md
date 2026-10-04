# GENOME-VARIANT-001 — Case Contract

## Question

Can KyberDB preserve and reconstruct exactly a real variant-call state produced downstream of an already-homologated KyberDB alignment state?

## Inputs

- Reference: `GCA_009015325.1`
- BioSample: `SAMN12676338`
- Run: `SRR10058842`
- ReadSet: 10,000 paired reads
- Upstream alignment state SHA-256: `ae653e9d981567447e8c16922dff2b4253add2ec89e9dc3b7e83f302f456fec0`
- Alignment record count: 20,074
- Variant caller: `bcftools 1.21`
- HTSlib: `1.21`
- Ploidy: `1`

## Stage A0 — Independent variant oracle

The source alignment must be the KyberDB post-reopen reconstruction from `GENOME-ALIGNMENT-001`, not a fresh BWA run.

Required gates:

```text
ALIGNMENT_STAGE_B_REVERIFY=PASS
UPSTREAM_ALIGNMENT_SOURCE=KYBER_POST_REOPEN_STATE
BAM_REHYDRATION=PASS
ALIGNMENT_SEMANTICS_REHYDRATION=PASS
BCFTOOLS_MPILEUP=PASS
SAMPLE_IDENTITY=PASS
BCFTOOLS_CALL=PASS
BAD_VARIANT_ROWS=0
KYBER_DB_WRITES=ZERO
ENGINE_CHANGE=NO
```

A non-zero variant count is an observation, not a precondition for Kyber correctness. In the validated run the oracle was non-empty.

## Canonical variant state

Each VCF data row is frozen using the ten columns:

```text
CHROM POS ID REF ALT QUAL FILTER INFO FORMAT SAMPLE
```

The validated oracle contains 327 records:

```text
SNP_RECORD_COUNT=325
INDEL_RECORD_COUNT=2
```

Oracle identity:

```text
7bb54f1c2786ec562e68e8f77c546e6f4da8f6d3a9abd21916cdc8c105b85ff1
```

## Stage B — Kyber persistence

Experimental key layout:

```text
variant/00000000
variant/00000001
...
variant/00000326
```

Value: exact canonical VCF record.

This layout is an experimental adapter only; it is not a final product schema.

Required gates:

```text
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO
VARIANT_PUT_COUNT=327
VERIFY_PRE_CLOSE=PASS
SOURCE_ORACLE_CLOSED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
POST_REOPEN_VARIANT_COUNT=327
MISSING=0
MISMATCH=0
POST_REOPEN_VARIANT_EQUIVALENCE=PASS
```

The post-reopen reconstructed state must have the exact same SHA-256 as the frozen oracle.

## Success criterion

The case passes only if the complete canonical variant state is reproduced byte-for-byte after durable persistence and reopen.

## Non-claims

The case does not establish:

- clinical validity;
- optimal variant-calling parameters;
- comprehensive coverage of the isolate genome;
- superiority over VCF/BCF storage;
- performance superiority;
- a final genomic schema;
- production readiness.

It establishes exact workflow-state preservation for the tested data and toolchain.
