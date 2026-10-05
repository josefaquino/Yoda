# GENOME-LINEAGE-001 — Verifiable Scientific Lineage

## Question

> Given a final Variant State, can Yoda recover the verifiable scientific chain that produced it?

This CASE moves the object under test from exact state preservation to scientific lineage recovery.

The upstream scientific workflow had already been validated through:

```text
Reference
   +
ReadSet
   ↓
Alignment
   ↓
Variant State
```

GENOME-LINEAGE-001 asks whether Yoda can represent and recover the relationships around that final result.

---

## Represented lineage

```text
Variant
  ├── produced-by ─────► bcftools 1.21
  ├── called-against ──► Reference
  ├── has-evidence ────► GENOME-VARIANT-001 evidence
  └── derived-from ────► Alignment
                            ├── produced-by ─────► BWA 0.7.18
                            ├── aligned-against ─► Reference
                            ├── has-evidence ────► GENOME-ALIGNMENT-001 evidence
                            └── derived-from ────► ReadSet
```

The experiment used the frozen Yoda binary:

```text
1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

No product change and no KyberDB change were introduced.

---

## Product boundary

Yoda v0.1 currently provides:

```text
lexical retrieval
+
direct one-hop relational expansion
```

It does not claim arbitrary multi-hop graph planning.

The CASE therefore recovered two bounded neighborhoods and composed them externally:

```text
Variant context
      +
Alignment context
      ↓
Reference → ReadSet → Alignment → Variant
      +
Tools
      +
Evidence
      +
SHA-256 identities
```

This respects the current product contract rather than silently adding a stronger graph capability.

---

## Result

```text
GENOME_LINEAGE_001_STAGE_A=PASS
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
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

Frozen lineage bundle:

```text
99a4b9380e48ae703410c2bc54554c151b02475bc2f1d1e5ce64743802ed747b
```

Frozen authoritative `data.yoda` state:

```text
46022db31867eed2c2c688ea735d9c325faf0ead2abe5b9e1deca2eb93edbdb1
```

Evidence manifest:

```text
80240e8b87852e2c3f4f6711bfea8a57edcf85edd0d85782ec8622f4d391046e
```

---

## Narrow claim

This CASE supports the following narrow statement:

> **Yoda can represent and recover verifiable scientific lineage for one controlled genomic workflow using durable evidence, explicit relations, identities and bounded context.**

It does not establish:

- a general-purpose lineage engine;
- biotech-scale operation;
- arbitrary multi-project knowledge graphs;
- biological truth of the variant calls;
- clinical validity;
- product-market fit.

---

## Why it matters

Earlier CASEs asked:

```text
Can Kyber preserve this state?
```

This CASE asks:

```text
Can Yoda explain how this state came to exist?
```

That is the transition from exact storage to verifiable derivation.

See also:

- `CASE.md`
- `RESULTS.md`
- `WHY-WE-BUILT-THIS.md`
