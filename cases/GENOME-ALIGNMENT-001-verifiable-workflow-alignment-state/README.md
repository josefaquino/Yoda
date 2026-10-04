# GENOME-ALIGNMENT-001 — Verifiable Workflow Alignment State

GENOME-ALIGNMENT-001 is a KyberDB field case using a real paired-end Illumina ReadSet and the matched NCBI assembly from the same BioSample.

It asks a narrow product question:

> Can KyberDB preserve a real alignment state linking reads to a matched genomic reference and reconstruct that state exactly after durable persistence and close/reopen?

The case uses:

- run: `SRR10058842`;
- BioSample: `SAMN12676338`;
- BioProject: `PRJNA563564`;
- strain: `EK7.26`;
- assembly: `GCA_009015325.1` (`ASM901532v1`);
- aligner: BWA-MEM `0.7.18-r1243-dirty`;
- validation tooling: samtools `1.21` / HTSlib `1.21`;
- frozen ReadSet: 10,000 paired reads;
- matched assembly: 159 contigs, 4,943,364 reference bases.

## What was validated

Stage A0 froze the matched assembly authority from NCBI and verified the official FASTA MD5.

Stage A1 indexed the matched reference and aligned the exact frozen 10K ReadSet with BWA-MEM. A canonical alignment oracle was created from the 11 mandatory SAM fields:

```text
QNAME FLAG RNAME POS MAPQ CIGAR RNEXT PNEXT TLEN SEQ QUAL
```

The oracle preserved all records emitted by the tested alignment, including supplementary alignments.

Stage B persisted every canonical alignment record through the KyberDB public embedded ABI using an experimental ordinal-key layout, then verified the database, closed it, reopened it, verified it again, reconstructed all records, and compared the reconstructed state byte-for-byte with the independent oracle.

## Result

```text
GENOME_ALIGNMENT_001_STAGE_B=PASS
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO

ALIGNMENT_RECORD_COUNT=20074
POST_REOPEN_ALIGNMENT_COUNT=20074

VERIFY_PRE_CLOSE=PASS
SOURCE_ORACLE_CLOSED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS

MISSING=0
MISMATCH=0
POST_REOPEN_ALIGNMENT_EQUIVALENCE=PASS
```

The independent alignment oracle and the reconstructed KyberDB state produced exactly the same SHA-256:

```text
ae653e9d981567447e8c16922dff2b4253add2ec89e9dc3b7e83f302f456fec0
```

## Alignment evidence

The BWA-MEM run produced:

```text
SAM_RECORD_COUNT=20074
PRIMARY_RECORD_COUNT=20000
MAPPED_PRIMARY_RECORD_COUNT=19917
PROPER_PAIR_PRIMARY_RECORD_COUNT=18608
SUPPLEMENTARY_RECORDS=74

EXPECTED_PAIR_ID_COUNT=10000
ALIGNED_PAIR_ID_COUNT=10000
READSET_ALIGNMENT_IDENTITY=PASS
BAD_PRIMARY_PAIR_COUNTS=0
PAIR_RELATIONSHIP=PASS
```

The case deliberately does not impose a required mapping-rate threshold. Mapping statistics are measured evidence, not a success criterion invented after seeing the result.

## Physical evidence

```text
ORACLE_BYTES=6330259
DATABASE_BYTES=55177887
DATABASE_FILES=5
PHYSICAL_AMPLIFICATION=8.716529
```

These numbers describe the tested representation. They are not a performance-superiority claim and do not establish a final genomic storage layout.

## Why this matters

GENOME-REFERENCE-001 demonstrated a durable reference primitive. GENOME-READ-001 demonstrated durable real sequencing-read state. GENOME-ALIGNMENT-001 connects those two objects through real workflow-native alignment state.

The validated chain is now:

```text
Reference
    ↓
ReadSet
    ↓
Alignment
```

This is a KyberDB Public Embedded ABI field case. It does not claim variant calling, clinical interpretation, BAM/CRAM compatibility, pangenome support, or production readiness.
