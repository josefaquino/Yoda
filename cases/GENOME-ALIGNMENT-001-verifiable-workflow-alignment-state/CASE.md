# GENOME-ALIGNMENT-001 — Experiment Contract

## Scientific question

Can KyberDB preserve a real alignment state linking a frozen paired-end ReadSet to the matched NCBI assembly for the same BioSample and reconstruct that state exactly after durable persistence and close/reopen?

## Authorities

Read authority:

```text
RUN=SRR10058842
BIOSAMPLE=SAMN12676338
BIOPROJECT=PRJNA563564
PAIR_COUNT=10000
```

Matched reference authority:

```text
ASSEMBLY=GCA_009015325.1
ASSEMBLY_DIRECTORY=GCA_009015325.1_ASM901532v1
STRAIN=EK7.26
CONTIG_COUNT=159
TOTAL_REFERENCE_BASES=4943364
REFERENCE_SHA256=dca25fd7c31140ad67bbc1fd72396c9a1c228f03cd80bcb43371f19918f16af6
```

Tool authority:

```text
BWA_VERSION=0.7.18-r1243-dirty
BWA_SHA256=67aaef17af28066a2da77c2f1cf8a54a86eccd690ad41b4292abda29a4c53af4
SAMTOOLS_VERSION=1.21
SAMTOOLS_SHA256=3163fb5490fa8f3de0a358d903e2a8706ed748d46f48bd8dca1d6fbeaf2c983d
```

## Stage A0 — Matched assembly authority

Success requires:

```text
MATCHED_REFERENCE_AUTHORITY=PASS
FASTA_OFFICIAL_MD5=PASS
REFERENCE_STRUCTURE=PASS
BWA_AUTHORITY=PASS
SAMTOOLS_AUTHORITY=PASS
KYBER_DB_WRITES=ZERO
```

## Stage A1 — Independent alignment oracle

The exact frozen 10K paired ReadSet is aligned to the matched assembly with BWA-MEM using one thread for deterministic execution.

The canonical oracle contains the 11 required SAM fields:

```text
QNAME
FLAG
RNAME
POS
MAPQ
CIGAR
RNEXT
PNEXT
TLEN
SEQ
QUAL
```

Optional SAM tags and header program metadata are intentionally excluded from canonical state so that the oracle represents alignment semantics rather than tool-run decoration.

Supplementary alignments are retained. Secondary alignments are retained if emitted. The oracle is sorted canonically before hashing.

Success requires:

```text
PRIMARY_RECORD_COUNT=20000
READSET_ALIGNMENT_IDENTITY=PASS
BAD_PRIMARY_PAIR_COUNTS=0
PAIR_RELATIONSHIP=PASS
BWA_INDEX=PASS
BWA_MEM=PASS
SAM_STRUCTURE=PASS
CANONICAL_ALIGNMENT_ORACLE=PASS
KYBER_DB_WRITES=ZERO
```

No arbitrary minimum mapping-rate threshold is part of the contract.

## Stage B — Kyber alignment parity

Experimental representation:

```text
alignment/00000000 -> canonical SAM record
alignment/00000001 -> canonical SAM record
...
```

An ordinal identity is used because a single read name may legitimately produce multiple alignment records. The layout is experimental and is not a product format commitment.

The Stage B sequence is:

```text
alignment oracle
    ↓
public ABI puts
    ↓
durable commit
    ↓
kyber_verify
    ↓
close
    ↓
reopen
    ↓
kyber_verify
    ↓
reconstruct all records
    ↓
byte-exact compare
```

Success requires:

```text
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO
ALIGNMENT_PUT_COUNT=20074
POST_REOPEN_ALIGNMENT_COUNT=20074
VERIFY_PRE_CLOSE=PASS
SOURCE_ORACLE_CLOSED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
MISSING=0
MISMATCH=0
POST_REOPEN_ALIGNMENT_EQUIVALENCE=PASS
```

The final Kyber reconstruction SHA-256 must equal the frozen independent alignment-oracle SHA-256 exactly.

## Non-claims

This experiment does not establish:

- variant-calling correctness;
- BAM/CRAM native storage or API compatibility;
- biological interpretation;
- human-genome scalability;
- production readiness;
- performance superiority;
- a final Alignment data model.

Its scope is the exact durable preservation and reconstruction of the tested workflow-native alignment state.
