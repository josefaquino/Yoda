# YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001

## Same value, distinct regulatory state

This CASE asks whether Yoda can preserve two distinct public CVM document presentations of the same accounting values without collapsing one observed state into the other.

The source authority is the Brazilian Comissão de Valores Mobiliários (CVM) public DFP dataset and the exact regulatory documents linked by the dataset.

## Research question

> **Can Yoda preserve two distinct CVM regulatory presentations of the same accounting values without collapsing one state into the other?**

The experiment deliberately does not interpret whether one presentation corrects, supersedes, restates or improves the other. It tests a smaller mechanical property: equal canonical values must not erase distinct document identity and provenance.

## Source authority

The selected real reporting context is:

```text
CNPJ=08.827.501/0001-58
CD_CVM=023396
COMPANY=AEGEA SANEAMENTO E PARTICIPAÇÕES S.A.
DT_REFER=2025-12-31
CATEGORY=DFP
SCOPE=DfConsolidadas
STATEMENT=BalancoPatrimonialAtivo
```

The CVM master dataset preserved two document presentations:

```text
VERSION=1
ID_DOC=156154
DT_RECEB=2026-04-11
PRIMARY_XML=023396DFP31-12-2025v1.xml
PRIMARY_XML_SHA256=94ecc843369bed0dcf948189d925325dafe4b5f7f5c27cb6c3d8f7d9b0751936

VERSION=2
ID_DOC=156163
DT_RECEB=2026-04-13
PRIMARY_XML=023396DFP31-12-2025v2.xml
PRIMARY_XML_SHA256=0cb9040499b1eac96a24a142495d2cb4fadc409d0b18858e29e6176e579a9684
```

The retrieved ZIP SHA256 is treated only as retrieval-capture identity because repeated downloads of the same CVM document ID can produce different generated package bytes.

```text
REGULATORY_IDENTITY=ID_DOC_PLUS_VERSION
PRIMARY_XML_SHA_ROLE=EXACT_STRUCTURED_CONTENT_IDENTITY
ZIP_SHA_ROLE=RETRIEVAL_CAPTURE_IDENTITY
```

## Frozen source property

Within `DfConsolidadas / BalancoPatrimonialAtivo`, `CodigoConta` is unique.

The complete account comparison produced:

```text
TOTAL_ACCOUNT_KEYS=564
VALUE_CHANGED=0
FORMAT_CHANGED_VALUE_SAME=82
EXACT_VALUE_SAME=482
ONLY_V1=0
ONLY_V2=0
UNPARSED_VALUE=0
DESCRIPTION_CHANGED=0
```

All 482 `EXACT_VALUE_SAME` accounts were zero-valued. The oracle therefore selected ten non-zero `FORMAT_CHANGED_VALUE_SAME` accounts.

Example:

```text
ACCOUNT=1
DESCRIPTION=Ativo Total

V1_RAW=55.373.598
V2_RAW=55373598,0000000000

V1_CANONICAL=55373598
V2_CANONICAL=55373598
```

The value stayed the same while the regulatory observation changed.

```text
same canonical value
!=
same observed state
```

## Frozen oracle

```text
SELECTED_ACCOUNTS=10
DOCUMENT_PRESENTATIONS=2
ORACLE_STATES=20
UNIQUE_ORACLE_STATE_IDS=20

EVERY_ACCOUNT_HAS_TWO_PRESENTATIONS=PASS
EVERY_ACCOUNT_CANONICAL_VALUE_EQUAL=PASS
EVERY_ACCOUNT_RAW_VALUE_DIFFERENT=PASS

TEST_PROPERTY=SAME_VALUE_DISTINCT_REGULATORY_STATE
```

## Product authority

The experiment reused the exact context-capable Yoda binary already validated in the GitHub and SEC cases:

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

No CVM-specific Yoda or Kyber engine path was introduced.

## Execution path

```text
CVM DFP + linked regulatory documents
        ↓
frozen source oracle
        ↓
20 product identities
        ↓
Frontier
        ↓
Yoda Mesh
        ↓
KyberDB
        ↓
Lakehouse
        ↓
read-only adjudication
```

Runtime intentionally isolated the state-identity property:

```text
WORKERS=1
BATCH_SIZE=20
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
```

## Result

```text
PRODUCT_RC=0

FRONTIER_FINAL_ROWS=20
FRONTIER_PROCESSING_ROWS=20
FRONTIER_QUEUED_ROWS=0
FRONTIER_STATE_MATCH=PASS

KYBER_ROWS=20
KYBER_UNIQUE_KEYS=20
KYBER_EXACT_MATCH=PASS

LAKEHOUSE_ROWS=20
LAKEHOUSE_EXACT_MATCH=PASS

TOTAL_FAILURES=0
```

Cross-layer product-key identity:

```text
EXPECTED_KEY_SHA256=
d1d54f580f2f73baf7e675d71a6dc2c36f2f4b6ef2fb570788cfd83911d92dfd

KYBER_KEY_SHA256=
d1d54f580f2f73baf7e675d71a6dc2c36f2f4b6ef2fb570788cfd83911d92dfd

CROSS_LAYER_KEY_IDENTITY=PASS
```

Final classification:

```text
YODA_CVM_REAPRESENTED_FINANCIAL_STATE_001=PASS
TEST_PROPERTY=SAME_VALUE_DISTINCT_REGULATORY_STATE
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Preserved negative evidence

The path to the valid one-shot is part of the evidence.

The first Oracle-008 was `NOT_EVALUATED` because it assumed five non-zero `EXACT_VALUE_SAME` accounts existed. A read-only count showed that all 482 exact-value matches were zeros. R1 changed the oracle selection, not the product.

Two product-preparation attempts were also `NOT_EVALUATED` because multiline awk syntax was rejected by the local `mawk`. The product was not executed in either attempt. Preparation-012-R2 removed multiline awk and passed every pre-execution gate before the one-shot lock was consumed.

No invalid attempt was converted into a product failure.

## Demonstrated property

> **Yoda preserved 20 real public financial states representing two distinct CVM document presentations across Frontier, KyberDB and Lakehouse, with exact identity and context recovery, zero mismatches, and no changes to Yoda or Kyber.**

A product-level interpretation is:

> **Same value does not mean same state. Yoda preserves what the system actually observed and the provenance that made that observation distinct.**

The claim is scoped to this CASE.

## What this CASE does not demonstrate

```text
RESTATEMENT_INTERPRETATION
CORRECTION_SEMANTICS
SUPERSESSION_SEMANTICS
ACCOUNTING_JUDGMENT
FINANCIAL_FORECASTING
TRADING_ALPHA
INVESTMENT_ADVICE
GENERAL_FINANCE_CORRECTNESS
```

The experiment preserves observed regulatory state and provenance. It does not interpret accounting meaning.
