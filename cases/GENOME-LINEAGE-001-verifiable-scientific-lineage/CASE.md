# CASE — GENOME-LINEAGE-001

## Objective

Test whether the frozen Yoda product can recover the lineage surrounding a real genomic Variant State without changing Yoda or KyberDB.

## Scientific authorities

Reference:

```text
GCA_009015325.1
SHA256=dca25fd7c31140ad67bbc1fd72396c9a1c228f03cd80bcb43371f19918f16af6
```

ReadSet:

```text
SRR10058842
SHA256=2c900493cc32a0c847fb7b78421c0afeab8e21a006fa6b9415951913f9eb9ae7
```

Alignment State:

```text
SHA256=ae653e9d981567447e8c16922dff2b4253add2ec89e9dc3b7e83f302f456fec0
```

Variant State:

```text
SHA256=7bb54f1c2786ec562e68e8f77c546e6f4da8f6d3a9abd21916cdc8c105b85ff1
```

BWA:

```text
SHA256=67aaef17af28066a2da77c2f1cf8a54a86eccd690ad41b4292abda29a4c53af4
```

bcftools:

```text
SHA256=a6758c48e1b092c013dfbcd23482281f0b2fd43b89d8aed2365e02c3695551b7
```

## Yoda authority

Frozen binary:

```text
SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

Required product commands:

```text
init
put
get
find
link
log
verify
context
```

## Objects

Eight evidence objects were written:

```text
genome/reference/GCA_009015325.1
genome/readset/SRR10058842
genome/alignment/SRR10058842-GCA_009015325.1
genome/variant/SRR10058842-GCA_009015325.1
tool/bwa/0.7.18
tool/bcftools/1.21
evidence/GENOME-ALIGNMENT-001
evidence/GENOME-VARIANT-001
```

## Relations

Eight relations were written:

```text
Alignment --derived-from--> ReadSet
Alignment --aligned-against--> Reference
Alignment --produced-by--> BWA
Alignment --has-evidence--> Alignment Evidence

Variant --derived-from--> Alignment
Variant --called-against--> Reference
Variant --produced-by--> bcftools
Variant --has-evidence--> Variant Evidence
```

## Retrieval contract

Yoda v0.1 provides lexical retrieval plus direct one-hop relational expansion.

The experiment therefore requires:

1. exact retrieval of the evidence objects;
2. one-hop Variant context recovery;
3. one-hop Alignment context recovery;
4. external composition of both bounded neighborhoods;
5. recovery of the scientific identities and evidence hashes;
6. successful explicit verification of `data.yoda`.

## PASS gates

```text
YODA_PRODUCT_AUTHORITY=PASS
YODA_BINARY_IDENTITY=PASS
OBJECT_COUNT=8
RELATION_COUNT=8
EXACT_EVIDENCE_RECOVERY=PASS
VARIANT_CONTEXT_1HOP=PASS
ALIGNMENT_CONTEXT_1HOP=PASS
EXTERNAL_TWO_NEIGHBORHOOD_COMPOSITION=PASS
FULL_GENOMIC_LINEAGE_RECOVERY=PASS
YODA_VERIFY=PASS
EVIDENCE_INTEGRITY=PASS
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

## Non-goals

This CASE does not test:

- biological truth;
- multi-hop graph planning inside Yoda;
- graph-database performance;
- biotech production scale;
- clinical use;
- product-market fit.
