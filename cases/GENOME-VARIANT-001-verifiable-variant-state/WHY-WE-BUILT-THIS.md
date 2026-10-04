# Why We Built GENOME-VARIANT-001

The previous genomics cases established three increasingly useful state primitives:

```text
Reference
ReadSet
Alignment
```

That was enough to demonstrate exact storage and exact workflow relationship state, but it still stopped before a downstream scientific result.

GENOME-VARIANT-001 asks whether a state reconstructed from KyberDB can participate in the next real computation and whether the result of that computation can also be preserved exactly.

## The key transition

Instead of rerunning BWA from the original reads, the experiment intentionally begins from the homologated KyberDB post-reopen alignment state.

```text
Kyber alignment state
      ↓
rehydrated BAM
      ↓
bcftools
      ↓
variant state
      ↓
KyberDB
```

This tests composition with existing scientific software, not just storage.

## Why variants

Variant calls are a useful next state because they are derived from multiple upstream authorities:

- reference identity;
- read evidence;
- alignment coordinates and CIGAR state;
- caller/toolchain configuration;
- sample identity;
- ploidy.

The resulting state is therefore a compact example of scientific lineage.

## What was learned

The tested workflow produced 327 variant records:

```text
325 SNPs
2 indels
```

The canonical variant state was preserved byte-for-byte after KyberDB persistence and reopen.

More importantly, the input to variant calling was itself reconstructed from KyberDB.

That supports a product direction broader than "store genomic records":

> preserve verifiable scientific state between workflow stages so standard tools can consume it and produce the next state without losing identity or reproducibility.

## What this does not prove

The experiment does not establish that the 327 calls are clinically meaningful or optimal, nor that the tested calling parameters should be used in production.

It also does not imply that VCF/BCF should be replaced by KyberDB.

The value under test is continuity, lineage, exact reconstruction, and composability with established genomics tooling.

## Next product question

After Reference → ReadSet → Alignment → Variant State, the next important problem is not another file format.

It is lineage:

> Can Yoda represent the identities and derivation relationships across the complete validated workflow so that a developer or agent can start from the final variant state and recover the exact reference, reads, alignment, tool identities, evidence hashes, and decision history that produced it?

That is the bridge from a capable storage engine to a genomics-oriented developer product.
