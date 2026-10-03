# GENOME-KMER-001 — Verifiable Genomic K-mer Index

GENOME-KMER-001 is a KyberDB field case using the public NCBI RefSeq genome of *Escherichia coli* K-12 MG1655.

It asks a narrow product question:

> Can KyberDB turn a real genomic sequence into a local, durable and verifiable k-mer index, then reconstruct exactly the same k-mer frequencies after close/reopen?

The case uses:

- public authority: NCBI RefSeq;
- assembly: `GCF_000005845.2` (`ASM584v2`);
- sequence accession: `NC_000913.3`;
- k-mer size: `k=31`;
- key: exact 31-base nucleotide sequence;
- value: exact occurrence count.

## What the solution does

The tested pipeline transforms genomic sequence into a deterministic key/value index:

```text
NCBI FASTA
    ↓
31-base sliding windows
    ↓
k-mer → frequency
    ↓
KyberDB
    ↓
durable, reopenable, verifiable genomic index
```

This provides a foundational storage primitive for workflows that need exact local presence, identity and frequency of genomic subsequences.

The case does **not** claim variant calling, genome alignment, genome assembly, pangenome analysis or biological interpretation. It validates the durable indexing layer below those applications.

## Validated stages

### B0 — 10K qualification

The first stage intentionally used only 10,000 windows.

Result:

- 10,000 valid windows;
- 10,000 unique k-mers;
- 10 durable commits;
- pre-close verify: PASS;
- close/reopen: PASS;
- post-reopen verify: PASS;
- 10,000/10,000 k-mers recovered;
- 0 missing;
- 0 value mismatches;
- exact oracle/KyberDB SHA-256 equality;
- evidence integrity: PASS.

### B1 — 100K qualification

The same harness, source, k-mer semantics and public ABI were then run against 100,000 windows.

Result:

- 100,000 valid windows;
- 99,926 unique k-mers;
- 99,864 singleton k-mers;
- maximum observed frequency: 3;
- 100 durable commits;
- pre-close verify: PASS;
- close/reopen: PASS;
- post-reopen verify: PASS;
- 99,926/99,926 k-mers recovered;
- 0 missing;
- 0 value mismatches.

The independent oracle and the post-reopen KyberDB state produced the same canonical SHA-256:

```text
b561ab1e0d956d5108c42cf63c8c2220fee2746503027a446161f5044abb1b6a
```

Therefore:

```text
POST_REOPEN_STATE_EQUIVALENCE=PASS
ENGINE_CHANGE=NO
```

## Performance evidence

B1 also exposed an important cost curve without changing the engine:

```text
DURABLE_UNIQUE_PUTS_S=928.303
COMMIT_P50_US=446157
COMMIT_P95_US=748105
COMMIT_P99_US=778042
COMMIT_MAX_US=882931

VERIFY_PRE_CLOSE_NS=294616118180
REOPEN_NS=470210937
VERIFY_POST_REOPEN_NS=262517009970

POST_REOPEN_GET_OPS_S=50162.103
MAX_RSS_KB=68776
DATABASE_BYTES=376531967
PHYSICAL_AMPLIFICATION=96.618156
```

These measurements are evidence about the tested implementation. They are not a claim of performance superiority.

## Why this case matters

FIRMS and USGS tested preservation of scientific observations and public event identity. RIPE RIS tested mutable state with announcements and withdrawals. GENOME-KMER-001 changes the pressure again: high-cardinality, compact genomic keys with exact frequency values.

The case demonstrates that the same KyberDB public embedded API can preserve and reconstruct a deterministic genomic index exactly, while also exposing the physical cost of doing so.

## Files

- `CASE.md` — hypothesis, source contract, k-mer semantics and validation gates.
- `RESULTS.md` — measured B0/B1 results and evidence identities.

This is a KyberDB Public Embedded ABI field case, not a Yoda CORE-015 CLI validation.
