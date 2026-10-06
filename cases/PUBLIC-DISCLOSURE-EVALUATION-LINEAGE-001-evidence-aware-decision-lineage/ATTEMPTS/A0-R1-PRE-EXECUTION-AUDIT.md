# A0-R1 — Pre-execution Audit Contract

## Status

```text
STATUS=READY_FOR_PREFLIGHT
SCIENTIFIC_EXECUTION_STARTED=NO
A0_EXECUTION_LOCK_CONSUMED=NO
A0_EXECUTED=NO
```

## Frozen authorities

```text
A0_SELECTION_POLICY_SHA256=
976e5b2ef7e4d345c128e83a37a6833174cd17db8e521a22136b38fcfda673d9

EVALUATION_CONTRACT_V1_SHA256=
ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd

SUBMISSIONS_PARSER_V1_SHA256=
44efbbe85b4061fdee796a37ff2e291e9ad5697941f4ad2581093a321a7b0584

COMPANYFACTS_PARSER_V1_SHA256=
64bca9c530ed653970af3e5715bbea52f9bdf30f7a2bbaf4e703c8b75da50775
```

## A0 harness identity

```text
A0_R1_SCRIPT_SHA256=
50d39563841e32559355b97b0c6fb2659d43a7eb26ca03ee529849e35e7c86eb

A0_R1_SCRIPT_COMMIT=
17225c886d834b0cd879dc84cb2580a273df82f8
```

Structural audit:

```text
NON_ASCII=0
YODA_COMMANDS=0
ONE_EXECUTION_LOCK_MARKERS=1
FINAL_PASS_MARKERS=1
SELECTION_VALUE_LEAK_SELF_TEST=1
PREFLIGHT_ONLY_MODE=1
```

## Safe preflight launcher

```text
A0_R1_PREFLIGHT_LAUNCHER_SHA256=
4a5310902ab5e01331bb6c8538cf1242cbfa5200bf8349ab5716f4e9dce27bd2

A0_R1_PREFLIGHT_LAUNCHER_COMMIT=
4b701cdff6b82aeffca2275c920cb62eab02c166
```

The preflight launcher runs:

```text
bash -n
parser source identity checks
C11 compilation
synthetic submissions parser test
synthetic Company Facts instant-context test
synthetic Company Facts duration-context test
selection-value non-leak test
synthetic reveal test
```

It must terminate before the scientific one-execution gate.

Required preflight result:

```text
A0_PREFLIGHT=PASS
A0_PREFLIGHT_ONLY=PASS
SCIENTIFIC_EXECUTION_STARTED=NO
A0_EXECUTION_LOCK_CONSUMED=NO
SEC_A0_REQUESTS=ZERO
A0_R1_EXECUTION_LOCK=ABSENT
A0_R1_STAGE=ABSENT
YODA_WRITES=ZERO
```

Only a passing preflight authorizes creation of the scientific A0 safe launcher.

## Scientific boundary

No A0 selection is authorized by this document.

```text
ISSUER_SELECTED=NO
ACCESSION_PAIR_SELECTED=NO
XBRL_CONCEPT_SELECTED=NO
FACT_VALUES_REVEALED_FOR_SCIENTIFIC_WORKLOAD=NO
CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
```
