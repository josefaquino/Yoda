# Why We Built GENOME-ALIGNMENT-001

The genomics track is intentionally cumulative.

GENOME-KMER-001 tested exact durable genomic subsequence state.

GENOME-REFERENCE-001 tested a real reference-access primitive against `samtools faidx`.

GENOME-READ-001 tested preservation of real paired-end sequencing reads, including sequence and quality scores.

Those cases still validated genomic objects separately.

GENOME-ALIGNMENT-001 asks a more important product question:

> Can durable local state preserve the relationship between a real ReadSet and its matched genomic reference?

That relationship is what turns stored objects into workflow state.

## Why alignment is the next boundary

Alignment adds semantics that neither Reference nor ReadSet contains alone:

- which reference sequence a read maps to;
- genomic coordinate;
- orientation and flags;
- mapping quality;
- CIGAR operations;
- mate location and insert geometry;
- supplementary alignment state.

The tested BWA-MEM run generated 20,074 canonical alignment records from the frozen 10K paired ReadSet. KyberDB reproduced all 20,074 records exactly after durable persistence and reopen.

The independent oracle and post-reopen Kyber state produced the same SHA-256:

```text
ae653e9d981567447e8c16922dff2b4253add2ec89e9dc3b7e83f302f456fec0
```

That means the tested system now preserves a small but real genomic workflow chain:

```text
Reference
    ↓
ReadSet
    ↓
Alignment
```

## What this does not mean

This is not a claim that KyberDB should replace BWA, samtools, BAM, CRAM or the existing bioinformatics ecosystem.

Those tools remain the scientific and interoperability boundary.

The result supports a different thesis:

> Yoda/Kyber may be useful as a local, durable and verifiable scientific-state layer underneath or beside standard genomics tools.

The product question is not whether we can invent another file format. It is whether experimentally meaningful state, identity, relationships and provenance can become directly queryable and verifiable without losing compatibility with established tools.

## Maturity interpretation

Internal research maturity after this case:

```text
GENOME-KMER-001       ~2.5/5
GENOME-REFERENCE-001   3.0/5
GENOME-READ-001        3.5/5
GENOME-ALIGNMENT-001   4.0/5
```

`4.0/5` means workflow-native genomic state has now been demonstrated for the tested chain. It does not mean product completion or production readiness.

## Next question

The next useful step should introduce a downstream derived scientific object, not simply increase scale.

The natural candidate is variant state:

```text
Reference
    +
ReadSet
    +
Alignment
    ↓
Variant calls
```

A future GENOME-VARIANT case should use a standard variant-calling toolchain as the independent oracle, freeze a deterministic canonical VCF/BCF-derived state, persist it without changing the engine, and require byte-exact or semantically canonical equivalence after reopen.

The objective remains the same:

> one new scientific property per case, with evidence before architecture.
