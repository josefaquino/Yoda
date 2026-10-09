# YODA-CVM-AGENTIC-CONTEXT-001

## Context-governed reproducible evaluation

This CASE asks whether Yoda can preserve the exact observed state, versioned context, operational rule and evaluator required to reproduce a valid calculation and deterministically refuse incompatible calculations.

The validating workload uses real public Brazilian CVM DFP financial-reporting states. The financial domain is the experimental environment; the property under test is operational context preservation.

## Research question

> **Can Yoda preserve the observed state, semantic contract and calculation rule required for an agent to reproduce a valid financial metric and refuse an incompatible calculation?**

Operationally:

> **Can preserved context govern a deterministic operation over preserved state — reproducing a valid calculation and refusing an incompatible one?**

## Authority separation

Three authorities were kept separate:

```text
DATA AUTHORITY
CVM public DFP state
        ↓
what was observed

CONTEXT AUTHORITY
project-defined versioned semantic + metric contract
        ↓
how the preserved facts may be combined

EVALUATION AUTHORITY
deterministic C11 evaluator
        ↓
mechanically applies the frozen rule
```

Yoda is not the accounting authority and does not calculate the metric itself.

Yoda preserves the evidence required to run the appropriate evaluator again.

## Frozen data authority

Company and reporting context:

```text
CNPJ=08.827.501/0001-58
CD_CVM=023396
COMPANY=AEGEA SANEAMENTO E PARTICIPAÇÕES S.A.
REFERENCE_DATE=2025-12-31
PERIOD_START=2025-01-01
PERIOD_END=2025-12-31
CURRENCY=REAL
SCALE=MIL
STATEMENT=DemonstracaoResultado
```

Two distinct CVM document presentations were retained:

```text
V1
ID_DOC=156154
PRESENTATION_TYPE=1
DOCUMENT_VERSION=1
PRIMARY_XML_SHA256=94ecc843369bed0dcf948189d925325dafe4b5f7f5c27cb6c3d8f7d9b0751936

V2
ID_DOC=156163
PRESENTATION_TYPE=2
DOCUMENT_VERSION=2
PRIMARY_XML_SHA256=0cb9040499b1eac96a24a142495d2cb4fadc409d0b18858e29e6176e579a9684
```

The frozen workload contains eight exact facts:

```text
2 document presentations
×
2 scopes
×
2 source accounts
=
8 facts
```

Source account mappings:

```text
3.01
Receita de Venda de Bens e/ou Serviços
project concept candidate: net_revenue

3.11
Lucro/Prejuízo do Período
or
Lucro/Prejuízo Consolidado do Período
project concept candidate: net_income
```

Values:

```text
                    V1              V2

IND revenue         2250064         2250064
IND net income      1369580          712952

CON revenue        18780466        18780466
CON net income     -1073938         1280100
```

Frozen data identities:

```text
FACTS_SHA256=
5f25cb44580cfd7b515aedeef1e767021982cf619aad956d36b9c47704157900

DOCUMENT_METADATA_SHA256=
51653999ae44445dc471af2b31ac99171afc0b5e490906f366cb39c3fdace877
```

## Context Authority v1

The project-defined semantic contract maps source accounts into two operational roles:

```text
net_income
→ numerator

net_revenue
→ denominator
```

Metric:

```text
net_margin =
net_income / net_revenue
```

Compatibility rules:

```text
SAME_COMPANY
SAME_PERIOD
SAME_SCOPE
SAME_PRESENTATION
SAME_CURRENCY
SAME_SCALE
NONZERO_DENOMINATOR
```

Output contract:

```text
OUTPUT_FORMAT=DECIMAL
DECIMAL_PLACES=6
ROUNDING_POLICY=TRUNCATE_TOWARD_ZERO
```

Frozen context identities:

```text
SEMANTIC_MAPPINGS_SHA256=
8870b2a728ef4fb91a8f4524750347d771cf50c39a4854881d0ec0fcb38c6968

METRIC_CONTRACT_SHA256=
45fe6311e89b866a475c1050e8490a89e47790b48545de118809563586f2f1f2

REFUSAL_POLICY_SHA256=
3ac8a16f844dd30678949c2ceb4e0d1b3e87054b8fc7982cd8479136c5e8ad0e

CONTEXT_AUTHORITY_SHA256=
7f77a89514f9751116a8b9622ca6c35f63eb98a07e76dcefff02f750496534c0
```

## External deterministic evaluator

The evaluator was implemented independently of the Yoda storage engine in ISO C11.

```text
EVALUATOR_SOURCE_SHA256=
28e89ea8aaa7f7e9f2f67b6d6d133151d2e22eb9da2ed5de228183cd24d3bd92

SCENARIOS_SHA256=
571c3a8e9d1ec98fcc9fb0bec586a46ca57932cfd62a7cd1971ad003d90916fa
```

Four scenarios were pre-registered before Yoda preservation:

```text
POSITIVE_V1_CONSOLIDATED
→ ALLOW
→ -0.057183

POSITIVE_V2_CONSOLIDATED
→ ALLOW
→ 0.068161

NEGATIVE_SCOPE
→ REFUSE
→ INCOMPATIBLE_SCOPE

NEGATIVE_PRESENTATION
→ REFUSE
→ INCOMPATIBLE_PRESENTATION
```

The external baseline matched the oracle exactly:

```text
OUTCOME_ORACLE_EXACT_MATCH=PASS
OUTCOMES_SHA256=
e40e9d222320fe94324bc73225d5e69d59a89943986b57ada377534930a66324
```

## Yoda product authority

The CASE used the frozen Yoda Simple Core CORE-014 binary:

```text
YODA_BINARY_SHA256=
06c1d2cb98099cb2d5b44f753fa3392da4f9a2bd42d39bd0a673270b01f9bfc8

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

No Finance Mode, rules engine or Agentic Context subsystem was added.

The existing product surface was composed from ordinary Yoda objects and relations.

## Product preservation

The one-shot product execution stored:

```text
OBJECTS=11
RELATIONS=8
PHYSICAL_RECORDS=19
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
```

Verification and exact recovery:

```text
RECORDS_SCANNED=19
RECORDS_VERIFIED=19
YODA_VERIFY=PASS

GET_COUNT=11
GET_EXACT_MATCHES=11
YODA_EXACT_GET_RECOVERY=PASS

DATA_YODA_SHA256=
3f1ffbe56a41f71ab305a3a50cf3d18a4e5d2bb63a77d4b6efc5d04ae049fa34

DATA_YODA_IDENTITY_UNCHANGED_AFTER_READS=PASS
TOTAL_FAILURES=0
```

## Final Yoda-only replay

The final replay accepted one strict input policy:

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY
YODA_COMMANDS_USED_DURING_REPLAY=GET_ONLY
ORIGINAL_AUTHORITY_DIRECT_PATH_REFERENCES=ZERO
```

All eleven required artifacts were recovered byte-exactly:

```text
YODA_GET_EXECUTION_COUNT=11
YODA_GET_EXACT_MATCHES=11

STATE_USED_RECOVERABLE=PASS
CONTEXT_USED_RECOVERABLE=PASS
RULE_USED_RECOVERABLE=PASS
EVALUATOR_RECOVERABLE=PASS
RESULT_PRODUCED_RECOVERABLE=PASS
```

The recovered evaluator source was compiled again and the four recovered scenarios were replayed.

```text
V1_VALID_RESULT_REPRODUCED=PASS
V2_VALID_RESULT_REPRODUCED=PASS

INCOMPATIBLE_SCOPE_REFUSAL_REPRODUCED=PASS
INCOMPATIBLE_PRESENTATION_REFUSAL_REPRODUCED=PASS

REPLAY_VS_EXPECTED_EXACT_MATCH=PASS
REPLAY_VS_ORIGINAL_EXACT_MATCH=PASS
INDEPENDENT_EVALUATION_REPLAY=PASS
```

The replay outcome identity was exactly the original identity:

```text
REPLAYED_OUTCOMES_SHA256=
e40e9d222320fe94324bc73225d5e69d59a89943986b57ada377534930a66324
```

The Yoda authority remained byte-identical through replay:

```text
DATA_YODA_SHA256_BEFORE=
3f1ffbe56a41f71ab305a3a50cf3d18a4e5d2bb63a77d4b6efc5d04ae049fa34

DATA_YODA_SHA256_AFTER=
3f1ffbe56a41f71ab305a3a50cf3d18a4e5d2bb63a77d4b6efc5d04ae049fa34

DATA_YODA_IDENTITY_UNCHANGED=PASS
```

Final classification:

```text
YODA_CVM_AGENTIC_CONTEXT_REPLAY_008_R1=PASS
CONTEXT_GOVERNED_REPRODUCIBLE_EVALUATION=PASS
TOTAL_FAILURES=0

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Preserved negative evidence

Invalid attempts remain part of the record.

The first discovery harness assumed physical primary-XML filenames that did not exist at the assumed path:

```text
DISCOVERY_001=NOT_EVALUATED
FAILED_LAYER=SOURCE_LOCATION_PREFLIGHT
PRODUCT_EXECUTION=NO
```

The first eight-fact freeze was later rejected as final authority because one TSV row lost a field separator:

```text
DISCOVERY_002=NOT_EVALUATED_AS_FROZEN_AUTHORITY
FAILED_LAYER=FACT_TSV_SERIALIZATION
PRODUCT_EXECUTION=NO
```

R1 corrected serialization only and froze the valid data authority.

The first final-replay harness stopped before lock acquisition because its forbidden-path audit matched the audit regex inside its own source:

```text
REPLAY_008=NOT_EXECUTED
FAILED_LAYER=REPLAY_PREFLIGHT
ROOT_CAUSE=SELF_MATCH_IN_FORBIDDEN_PATH_AUDIT
REPLAY_EXECUTION_COUNT=0
REPLAY_EXECUTION_LOCK_PRESENT=NO
```

A subsequent local shell audit also failed before replay because a helper variable was unset. It consumed no replay lock and produced no product or replay measurement.

REPLAY-008-R1 corrected only harness mechanics. No data authority, context contract, evaluator, Yoda or Kyber behavior changed.

## Demonstrated property

> **Yoda preserved the exact observed state, versioned context, operational rule and evaluator required to reproduce two valid calculations and deterministically refuse two incompatible calculations using only Yoda-recovered evidence, without changing Yoda or Kyber.**

A product-level interpretation is:

> **Yoda preserved enough operational context to reproduce both what an autonomous system was allowed to do and what it had to refuse.**

The demonstrated property is named:

```text
CONTEXT-GOVERNED REPRODUCIBLE EVALUATION
```

## What this CASE does not demonstrate

```text
YODA_UNDERSTANDS_ACCOUNTING=NO
YODA_DETERMINES_ACCOUNTING_TRUTH=NO
YODA_INTERPRETS_CVM_FILINGS=NO
YODA_CHOOSES_FINANCIAL_METRICS=NO
YODA_IS_A_FINANCIAL_ANALYSIS_ENGINE=NO
YODA_IS_A_GENERAL_RULES_ENGINE=NO
YODA_CORRECTS_OR_SUPERSEDES_V1_V2=NO
FINANCIAL_FORECASTING=NO
TRADING_ALPHA=NO
INVESTMENT_ADVICE=NO
UNIVERSAL_CONTEXT_GOVERNANCE=NO
```

The CASE demonstrates a bounded infrastructure property, not accounting interpretation.
