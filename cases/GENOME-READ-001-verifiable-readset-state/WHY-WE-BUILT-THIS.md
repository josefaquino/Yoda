# Why We Built GENOME-READ-001

GENOME-KMER-001 proved that KyberDB could preserve a deterministic genomic index from a real NCBI sequence.

GENOME-REFERENCE-001 then moved closer to an actual bioinformatics primitive: KyberDB reproduced 256 reference-region lookups byte-for-byte against `samtools faidx` after persistence and reopen.

The next question was deliberately not "can we scale FASTA further?"

It was:

> Can the same engine preserve the next major object in a sequencing workflow — real paired reads with quality information — without changing the engine?

## Why reads matter

A sequencing read is not only a DNA string.

A useful paired-end sequencing record carries several linked pieces of state:

```text
pair identity
    +
R1 sequence
    +
R1 quality
    +
R2 sequence
    +
R2 quality
```

The quality strings make this a richer state object than the reference sequence alone. They represent measurement confidence emitted by the sequencing process and must remain associated with the correct bases and mate identity.

GENOME-READ-001 therefore tests whether KyberDB can preserve that compound state exactly.

## What passed

Using real paired-end Illumina data from EMBL-EBI ENA, the case froze an independent deterministic oracle of 10,000 pairs.

KyberDB stored those 10,000 pairs through its public embedded ABI, committed them durably, verified the database, closed and reopened it, verified it again, and reconstructed the complete canonical ReadSet.

The result was byte-identical to the oracle:

```text
MISSING=0
MISMATCH=0
POST_REOPEN_READSET_EQUIVALENCE=PASS
```

The oracle and reconstructed state shared the exact SHA-256:

```text
2c900493cc32a0c847fb7b78421c0afeab8e21a006fa6b9415951913f9eb9ae7
```

## What this does not mean

This experiment does not mean KyberDB is a finished sequencing database.

It does not yet connect reads to genomic coordinates.

It does not establish BAM/CRAM support, alignment semantics, variant calling, assembly, or biological interpretation.

It proves one smaller property:

> Real sequencing-read state can be represented and recovered exactly by the existing engine.

## The product direction

The long-term research question is whether genomic workflows that are traditionally passed through files can increasingly be represented as durable, queryable and verifiable state.

The current progression is:

```text
GENOME-KMER-001
    exact subsequence index
          ↓
GENOME-REFERENCE-001
    reference-coordinate state
          ↓
GENOME-READ-001
    paired sequencing-read state
          ↓
GENOME-ALIGNMENT-001
    reads related to reference coordinates
```

The next step is important because alignment is the first case that joins two already validated object classes.

Instead of testing another isolated object, it asks whether the system can preserve a relation:

```text
ReadSet
   │
   │ aligned_to
   ▼
Reference
```

That transition — from isolated objects to linked workflow state — is the next milestone toward a genomic state engine rather than a collection of storage demonstrations.

The development rule remains unchanged:

> One bottleneck, one hypothesis, one small change, one test, evidence, then the next decision.
