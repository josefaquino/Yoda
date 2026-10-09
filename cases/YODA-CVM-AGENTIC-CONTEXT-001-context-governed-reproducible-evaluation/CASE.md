# CASE — YODA-CVM-AGENTIC-CONTEXT-001

## Question

Can Yoda preserve the observed state, semantic contract and calculation rule required for an agent to reproduce a valid financial metric and refuse an incompatible calculation?

Operational form:

> Can preserved context govern a deterministic operation over preserved state — reproducing a valid calculation and refusing an incompatible one?

## Data authority

```text
SOURCE=Brazilian CVM public DFP state
CNPJ=08.827.501/0001-58
CD_CVM=023396
DT_REFER=2025-12-31
PERIOD_START=2025-01-01
PERIOD_END=2025-12-31
CURRENCY=REAL
SCALE=MIL
STATEMENT=DemonstracaoResultado
```

Document presentations:

```text
V1_ID_DOC=156154
V1_PRESENTATION_TYPE=1
V1_DOCUMENT_VERSION=1
V1_PRIMARY_XML_SHA256=94ecc843369bed0dcf948189d925325dafe4b5f7f5c27cb6c3d8f7d9b0751936

V2_ID_DOC=156163
V2_PRESENTATION_TYPE=2
V2_DOCUMENT_VERSION=2
V2_PRIMARY_XML_SHA256=0cb9040499b1eac96a24a142495d2cb4fadc409d0b18858e29e6176e579a9684
```

Frozen facts:

```text
FACT_ROWS=8
UNIQUE_FACT_IDS=8
FACT_TSV_STRUCTURE=PASS
SOURCE_VALUE_AUTHORITY=PASS

FACTS_SHA256=
5f25cb44580cfd7b515aedeef1e767021982cf619aad956d36b9c47704157900

DOCUMENT_METADATA_SHA256=
51653999ae44445dc471af2b31ac99171afc0b5e490906f366cb39c3fdace877
```

## Context Authority v1

Semantic mappings:

```text
3.01 + INDIVIDUAL   → net_revenue
3.01 + CONSOLIDATED → net_revenue

3.11 + INDIVIDUAL   → net_income
3.11 + CONSOLIDATED → net_income
```

Metric:

```text
metric_id=net_margin
formula=net_income/net_revenue
```

Compatibility contract:

```text
SAME_COMPANY
SAME_PERIOD
SAME_SCOPE
SAME_PRESENTATION
SAME_CURRENCY
SAME_SCALE
DENOMINATOR_NONZERO
```

Refusal reasons include:

```text
INCOMPATIBLE_COMPANY
INCOMPATIBLE_PERIOD
INCOMPATIBLE_SCOPE
INCOMPATIBLE_PRESENTATION
INCOMPATIBLE_CURRENCY
INCOMPATIBLE_SCALE
ZERO_DENOMINATOR
```

Frozen identities:

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

## Evaluation authority

A deterministic C11 evaluator mechanically applies the frozen context and metric contract.

```text
EVALUATOR_SOURCE_SHA256=
28e89ea8aaa7f7e9f2f67b6d6d133151d2e22eb9da2ed5de228183cd24d3bd92

SCENARIOS_SHA256=
571c3a8e9d1ec98fcc9fb0bec586a46ca57932cfd62a7cd1971ad003d90916fa
```

Pre-registered scenarios:

```text
POSITIVE_V1_CONSOLIDATED
expected: ALLOW / COMPATIBLE_CONTEXT / -0.057183

POSITIVE_V2_CONSOLIDATED
expected: ALLOW / COMPATIBLE_CONTEXT / 0.068161

NEGATIVE_SCOPE
expected: REFUSE / INCOMPATIBLE_SCOPE / NO_RESULT

NEGATIVE_PRESENTATION
expected: REFUSE / INCOMPATIBLE_PRESENTATION / NO_RESULT
```

## Product authority

```text
YODA_ENGINE=YODA_SIMPLE_CORE_CORE_014

YODA_BINARY_SHA256=
06c1d2cb98099cb2d5b44f753fa3392da4f9a2bd42d39bd0a673270b01f9bfc8

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Yoda composition

The CASE stores the required authorities as ordinary versioned evidence:

```text
data facts
document metadata
semantic mappings
metric contract
refusal policy
context authority
evaluator source
scenarios
expected outcomes
original outcomes
evaluation report
```

Relations:

```text
semantic mappings --grounded-in--> data facts
context authority --composed-of--> semantic mappings
context authority --composed-of--> metric contract
context authority --composed-of--> refusal policy
evaluator --governed-by--> context authority
scenarios --evaluated-by--> evaluator
outcomes --produced-by--> evaluator
outcomes --derived-from--> scenarios
```

No specialized Yoda subsystem is introduced.

## Product success criteria

- eleven pre-registered evidence objects are stored exactly;
- eight explicit relations are committed;
- all nineteen physical records pass Yoda verification;
- all eleven values recover byte-exactly;
- `data.yoda` remains unchanged during read adjudication;
- product executes exactly once;
- no Yoda or Kyber change occurs.

## Replay success criteria

The final replay must use:

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY
YODA_COMMANDS_USED_DURING_REPLAY=GET_ONLY
```

It must recover:

```text
STATE_USED
CONTEXT_USED
RULE_USED
EVALUATOR
RESULT_PRODUCED
```

Then it must:

- compile the recovered evaluator;
- execute the four recovered scenarios;
- reproduce both valid metric values;
- reproduce both refusal reasons;
- reproduce the original outcomes byte-exactly;
- leave `data.yoda` byte-identical.

## Non-claims

```text
ACCOUNTING_INTERPRETATION=NO
ACCOUNTING_TRUTH_AUTHORITY=NO
CVM_CORRECTION_INTERPRETATION=NO
CVM_SUPERSESSION_INTERPRETATION=NO
FINANCIAL_ANALYSIS_ENGINE=NO
GENERAL_RULES_ENGINE=NO
UNIVERSAL_CONTEXT_GOVERNANCE=NO
TRADING_CLAIM=NO
FORECASTING_CLAIM=NO
INVESTMENT_ADVICE=NO
```
