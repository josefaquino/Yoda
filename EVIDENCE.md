# Evidence

Yoda is developed through narrow, reproducible CASEs.

The project does not treat a successful demo as proof of a broad market claim.

Each CASE should answer one question, freeze its evidence and make the next question clearer.

---

## Research rule

```text
one question
one hypothesis
one controlled experiment
explicit PASS / FAIL gates
frozen evidence
no speculative engine change
```

The engineering rule remains:

> **Big vision. Small steps. Evidence always.**

---

## Cross-domain proving grounds

The project has exercised the same evidence-first discipline against multiple domains:

| Case | Domain | Property tested | Status |
|---|---|---|---|
| FIRMS-001 | Satellite observations | fact / decision equivalence | PASS |
| USGS-001 | Earthquake events | external identity + replay | PASS |
| BGP-RIPE-RIS-001 | Internet routing | mutation-state equivalence | PASS |
| AUDIT-FORENSICS-001 | Security events | exact ledger + tamper rejection | PASS |
| GENOME-KMER-001 | Genomics | exact indexed state | PASS |
| GENOME-REFERENCE-001 | Genomics | reference coordinate equivalence | PASS |
| GENOME-READ-001 | Genomics | paired-read state preservation | PASS |
| GENOME-ALIGNMENT-001 | Genomics | workflow-derived alignment state | PASS |
| GENOME-VARIANT-001 | Genomics | downstream workflow continuity | PASS |
| GENOME-LINEAGE-001 | Genomics | verifiable scientific lineage | PASS |

Negative experiments are evidence too. See the individual CASE directories for exact scope and limitations.

---

# Genomics research ladder

Genomics became the first domain where the questions progressed from storage to derivation.

```text
GENOME-KMER-001
      ↓
identity and exact reconstruction

GENOME-REFERENCE-001
      ↓
reference state and coordinate equivalence

GENOME-READ-001
      ↓
real paired-read preservation

GENOME-ALIGNMENT-001
      ↓
workflow-native derived state

GENOME-VARIANT-001
      ↓
downstream workflow continuity

GENOME-LINEAGE-001
      ↓
verifiable scientific lineage
```

The point of the ladder was not to accumulate bioinformatics formats.

Each CASE changed the property under test.

---

## GENOME-REFERENCE-001

Question:

> Can KyberDB functionally replace a small part of `FASTA + faidx` for one controlled reference, preserving exact coordinate access after persistence and reopen?

Result:

```text
GENOME_REFERENCE_001=VALIDATED
PUBLIC_ABI_ONLY=YES
ENGINE_CHANGE=NO
MISSING=0
MISMATCH=0
```

The post-reopen result reproduced the independent `samtools faidx` oracle byte-for-byte for the tested 256 deterministic coordinate queries.

See:

`cases/GENOME-REFERENCE-001-faidx-region-equivalence/`

---

## GENOME-READ-001

Question:

> Can a real paired sequencing read set, including sequence, quality and pair identity, be reconstructed exactly after persistence and reopen?

Result:

```text
GENOME_READ_001=VALIDATED
POST_REOPEN_READSET_EQUIVALENCE=PASS
MISSING=0
MISMATCH=0
ENGINE_CHANGE=NO
```

The experiment used 10,000 deterministic paired reads from ENA run `SRR10058842`.

See:

`cases/GENOME-READ-001-verifiable-readset-state/`

---

## GENOME-ALIGNMENT-001

Question:

> Can Kyber preserve workflow-native alignment state produced by BWA from a real ReadSet and its matched reference?

Result:

```text
GENOME_ALIGNMENT_001=VALIDATED
ALIGNMENT_RECORD_COUNT=20074
POST_REOPEN_ALIGNMENT_COUNT=20074
MISSING=0
MISMATCH=0
POST_REOPEN_ALIGNMENT_EQUIVALENCE=PASS
ENGINE_CHANGE=NO
```

See:

`cases/GENOME-ALIGNMENT-001-verifiable-workflow-alignment-state/`

---

## GENOME-VARIANT-001

Question:

> Can alignment state reconstructed from Kyber feed a real downstream scientific tool and produce a new state that is itself preserved exactly?

The workflow was:

```text
Kyber post-reopen Alignment State
        ↓
SAM / BAM rehydration
        ↓
bcftools mpileup / call
        ↓
Variant State
        ↓
Kyber persist / verify / reopen
```

Result:

```text
GENOME_VARIANT_001=VALIDATED
VARIANT_RECORD_COUNT=327
POST_REOPEN_VARIANT_COUNT=327
MISSING=0
MISMATCH=0
POST_REOPEN_VARIANT_EQUIVALENCE=PASS
ENGINE_CHANGE=NO
```

Frozen variant identity:

```text
7bb54f1c2786ec562e68e8f77c546e6f4da8f6d3a9abd21916cdc8c105b85ff1
```

The important property was workflow continuity, not VCF storage.

See:

`cases/GENOME-VARIANT-001-verifiable-variant-state/`

---

## GENOME-LINEAGE-001

Question:

> Given the final Variant State, can Yoda recover the verifiable chain of scientific state, tools and evidence that produced it?

The represented lineage was:

```text
Variant
  ├── produced-by ─────► bcftools
  ├── called-against ──► Reference
  ├── has-evidence ────► Variant Evidence
  └── derived-from ────► Alignment
                            ├── produced-by ─────► BWA
                            ├── aligned-against ─► Reference
                            ├── has-evidence ────► Alignment Evidence
                            └── derived-from ────► ReadSet
```

Yoda v0.1 currently provides lexical retrieval plus direct one-hop relational expansion.

The experiment therefore composed two bounded neighborhoods externally rather than pretending Yoda has arbitrary multi-hop graph planning.

Result:

```text
GENOME_LINEAGE_001_STAGE_A=PASS
OBJECT_COUNT=8
RELATION_COUNT=8
EXACT_EVIDENCE_RECOVERY=PASS
VARIANT_CONTEXT_1HOP=PASS
ALIGNMENT_CONTEXT_1HOP=PASS
EXTERNAL_TWO_NEIGHBORHOOD_COMPOSITION=PASS
FULL_GENOMIC_LINEAGE_RECOVERY=PASS
YODA_VERIFY=PASS
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

Frozen full-lineage bundle:

```text
99a4b9380e48ae703410c2bc54554c151b02475bc2f1d1e5ce64743802ed747b
```

Frozen authoritative `data.yoda` state:

```text
46022db31867eed2c2c688ea735d9c325faf0ead2abe5b9e1deca2eb93edbdb1
```

This supports a narrow claim:

> **Verifiable scientific lineage has been demonstrated for one controlled genomic workflow.**

See:

`cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/`

---

# What is not proven

The evidence does not establish:

```text
general-purpose lineage engine
biotech-scale operation
multi-project scientific knowledge graph
biological truth of the variant calls
clinical validity
product-market fit
production readiness for all workloads
```

Those remain open questions.

---

# Next external tests

The next research program deliberately moves into workflows not designed by us.

## AXIOM-YODA-PROOF-LINEAGE-001

Test whether Yoda can preserve and reconstruct the lineage of a formally verified proof such that the recovered proof artifacts can be submitted again to AXLE and reproduce the verification outcome.

## BIO-DESIGN-LINEAGE-001

Test whether Yoda can reconstruct the chain behind a real Design-Build-Test-Learn decision in biological R&D without adding biology-specific storage features.

If the same small architecture survives both formal and empirical workflows, that will be evidence for a broader cross-domain property.

It will still not be proof of a market.

That comes later.
