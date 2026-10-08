# CASE — YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001

## Question

Can Yoda preserve two distinct CVM regulatory presentations of the same accounting values without collapsing one state into the other?

## Authority

```text
SOURCE=Portal Dados Abertos CVM + linked DFP regulatory documents
CNPJ=08.827.501/0001-58
CD_CVM=023396
DT_REFER=2025-12-31
CATEGORY=DFP
SCOPE=DfConsolidadas
STATEMENT=BalancoPatrimonialAtivo
```

Document authority:

```text
V1_ID_DOC=156154
V1_DT_RECEB=2026-04-11
V1_PRIMARY_XML_SHA256=94ecc843369bed0dcf948189d925325dafe4b5f7f5c27cb6c3d8f7d9b0751936

V2_ID_DOC=156163
V2_DT_RECEB=2026-04-13
V2_PRIMARY_XML_SHA256=0cb9040499b1eac96a24a142495d2cb4fadc409d0b18858e29e6176e579a9684
```

## Frozen source property

```text
CONSOLIDATED_BPA_ACCOUNTS=564
VALUE_CHANGED=0
FORMAT_CHANGED_VALUE_SAME=82
EXACT_VALUE_SAME_ZERO=482
UNPARSED_VALUE=0
```

Oracle:

```text
SELECTED_NONZERO_ACCOUNTS=10
DOCUMENT_PRESENTATIONS=2
ORACLE_STATES=20
UNIQUE_ORACLE_STATE_IDS=20
```

For every selected account:

```text
CANONICAL_VALUE_V1 == CANONICAL_VALUE_V2
RAW_VALUE_V1 != RAW_VALUE_V2
DOCUMENT_V1 != DOCUMENT_V2
```

## Identity contract

Regulatory identity is document-specific:

```text
ID_DOC + VERSAO
        ↓
document-specific source URI
        ↓
account scope
        ↓
Yoda observation key
```

The product key is mechanically derived as:

```text
obs:cvm_dfp_state:<document-specific-source-uri>#scope=DfConsolidadas&statement=BalancoPatrimonialAtivo&account=<CodigoConta>
```

ZIP capture SHA256 is not used as regulatory identity.

## Product authority

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Pre-execution gates

```text
FRONTIER_ROWS=20
EXPECTED_KEYS=20
UNIQUE_EXPECTED_KEYS=20
EXPECTED_KYBER_ROWS=20

MAX_SOURCE_URI_BYTES=194
MAX_SPECIES_BYTES=13
MAX_CONTEXT_BYTES=911
MAX_KYBER_KEY_BYTES=212

BAD_SOURCE_URI_LENGTH=0
BAD_SPECIES_LENGTH=0
BAD_CONTEXT_LENGTH=0
BAD_KYBER_KEY_LENGTH=0

SHIELD_PATTERN_FAILURES=0
PAIR_FAILURES=0
PRODUCT_EXECUTION_LOCK_FREE=YES
```

## Method

```text
frozen CVM oracle
        ↓
20 exact state identities
        ↓
Frontier
        ↓
Yoda C23 context-capable binary
        ↓
Kyber WAL
        ↓
Lakehouse NDJSON
        ↓
read-only exact reconciliation
```

Runtime:

```text
WORKERS=1
BATCH_SIZE=20
```

Concurrency was not the variable under test.

## Success criteria

- 20 oracle states remain 20 unique product identities;
- each of the ten accounts retains two document-specific states;
- canonical values remain equal within each account pair;
- document identity and provenance remain distinct;
- Frontier reaches 20 processed states with no queued residue;
- Kyber matches the expected key/context oracle exactly;
- Lakehouse matches the expected NDJSON exactly;
- expected and observed sorted key identities hash identically;
- product executes exactly once;
- no Yoda or Kyber change is introduced.

## Non-claims

```text
RESTATEMENT_CLAIM=NO
CORRECTION_CLAIM=NO
SUPERSESSION_CLAIM=NO
ACCOUNTING_INTERPRETATION=NO
TRADING_CLAIM=NO
FORECASTING_CLAIM=NO
INVESTMENT_ADVICE=NO
```
