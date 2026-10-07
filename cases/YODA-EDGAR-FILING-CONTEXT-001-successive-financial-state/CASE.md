# CASE — YODA-EDGAR-FILING-CONTEXT-001

## Question

Can Yoda preserve successive public financial states with exact reporting context and filing provenance without destroying earlier observed states?

## Authority

```text
SOURCE=SEC EDGAR + XBRL companyfacts / filing provenance
COMPANY=NVIDIA CORP
CIK=0001045810
TAXONOMY=us-gaap
CONCEPT=OtherAccruedLiabilitiesCurrent
UNIT=USD
REPORTING_DATE=2022-01-30
```

## Frozen source property

```text
CHAIN_RECORDS=5
CHAIN_UNIQUE_ACCESSIONS=5
CHAIN_DISTINCT_VALUES=4
VALUE_469M_DISTINCT_STATES=2
```

## Product authority

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

PRODUCT_REUSED_FROM=
YODA-GITHUB-WORK-CONTEXT-001

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Identity contract

Each state identity is accession-specific.

```text
SEC accession
        ↓
accession-specific filing URL
        ↓
Yoda observation key
```

R1 admission gates required:

```text
SOURCE_TOTAL=5
SOURCE_UNIQUE_URLS=5
EXPECTED_TOTAL=5
EXPECTED_UNIQUE=5
CONTEXT_UNIQUE_ACCESSIONS=5
ACCESSION_CONTEXT_EXACT_MATCH=PASS
BAD_ACCESSION_URLS=0
```

## Method

```text
frozen SEC state chain
        ↓
5 exact source identities
        ↓
Frontier
        ↓
Yoda C23 context-capable binary
        ↓
Kyber WAL
        ↓
Lakehouse NDJSON
        ↓
read-only reconciliation against frozen oracle
```

Runtime:

```text
WORKERS=1
BATCH_SIZE=5
```

Concurrency was not the variable under test.

## Success criteria

- five source states remain five unique identities;
- all five accession numbers survive exactly;
- Frontier has five processed states and no queued residue;
- Kyber has five unique identities and exact expected context;
- Lakehouse has five unique identities and exact expected context;
- the two equal-value `469000000` states remain distinct;
- no Yoda or Kyber change is introduced;
- adjudication is read-only.

## Non-claims

```text
RESTATEMENT_CLAIM=NO
CORRECTION_CLAIM=NO
SUPERSESSION_CLAIM=NO
TRADING_CLAIM=NO
FORECASTING_CLAIM=NO
INVESTMENT_ADVICE=NO
```

The experiment preserves observed state and provenance. It does not interpret accounting semantics.
