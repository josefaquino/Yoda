# A0-R1 — One-shot NOT_EVALUATED

## Observed scientific result

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A0=NOT_EVALUATED
A0_REVISION=A0-R1
FAILURE_CLASS=SELECTED_FACT_CANONICALIZATION_FAILURE

A0_R1_RUN_RC=1

A0_R1_EXECUTION_LOCK=CONSUMED
A0_R1_EXECUTION_LOCK_SHA256=
95143c814b061a68e0857eb508f7b0324bf3eabe755d872c72bc4c257f404b0f

A0_R1_SCRIPT_SHA256=
85b90c72684ce8b19392621de2d230a39259879768cae5344830d2d3a22ee35f

A0_R1_CONSOLE_SHA256=
d881c014401d76b8d84307573d62ac252ccaca34fed179d5ff64e4efc35f4098
```

The one-execution policy is consumed. A0-R1 must not be rerun and its lock must not be deleted.

## Gates reached before failure

```text
PRE_A0_AUTHORITY=PASS

A0_SELECTION_POLICY=FROZEN
A0_SELECTION_POLICY_SHA256=
390a46190a204d8c6eb2e3b249b5b875370728e8770f7c1cfdb6410a59575aff

SUBMISSIONS_PARSER_SOURCE=FROZEN
COMPANYFACTS_PARSER_SOURCE=FROZEN
EVALUATION_CONTRACT=FROZEN

SUBMISSIONS_PARSER_COMPILE=PASS
COMPANYFACTS_PARSER_COMPILE=PASS

SUBMISSIONS_PARSER_SELF_TEST=PASS
COMPANYFACTS_PARSER_SELF_TEST=PASS
SELECTION_VALUE_LEAK_TEST=PASS

EXECUTION_POLICY=ONE_EXECUTION
EXECUTION_GATE=PASS
```

The frozen 2025 SEC candidate universe contained:

```text
CANDIDATE_FORM=10-K/A
CANDIDATE_COUNT=713
```

## Frozen scientific selection

Selection completed before the failure.

```text
SELECTION_GATE=FROZEN
SELECTED_CANDIDATE_ORDINAL=1

SELECTION_SHA256=
3bff9ec5b957231543e1c9c6d45dc0d026cf2bd1113660a39056d7ffc25dc85f
```

Frozen tuple:

```text
ordinal=1
cik=0001807166
issuer=Amesite Inc.
original_filing_date=2024-09-30
amendment_filing_date=2025-01-02
report_date=2024-06-30
original_accession=0001213900-24-083458
amendment_accession=0001213900-25-000438
concept=Assets
kind=instant
unit=USD
context_start=-
context_end=2024-06-30
```

The tuple must not be reselected because of the later observed values or eventual evaluation label.

## Partial canonical output

The reveal step emitted:

```text
PARSER_STATUS=PASS
state	accession	form	concept	unit	start	end	value_raw
A	0001213900-24-083458	10-K	Assets	USD	-	2024-06-30	3314177
B	0001213900-25-000438	10-K/A	Assets	USD	-	2024-06-30	3314177
```

No classification was executed.

## Root-cause adjudication

The frozen Company Facts parser emits:

```text
PARSER_STATUS=PASS
```

before branching between `check` and `reveal`.

The reveal branch then emits the canonical TSV header plus two state rows.

Therefore the reveal output contains four lines.

The frozen A0 harness requires exactly three lines:

```text
header
state A
state B
```

and maps any other line count to:

```text
SELECTED_FACT_CANONICALIZATION_FAILURE
```

Adjudicated root cause:

```text
ROOT_CAUSE=
REVEAL_MODE_DIAGNOSTIC_PREAMBLE_VIOLATES_CANONICAL_OUTPUT_SHAPE
```

This is a harness/output-shape incompatibility after scientific selection, not a rejection of the selected SEC workload.

## Scientific integrity status

```text
SELECTION_COMPLETED_BEFORE_VALUE_REVEAL=YES
SELECTION_USES_FACT_VALUES=NO
SELECTION_USES_EVALUATION_RESULT=NO

SELECTED_TUPLE_RESELECTION=FORBIDDEN
A0_R1_RERUN=NO

CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO

A0_MANIFEST=NOT_AVAILABLE
A0_R1=NOT_EVALUATED
```

The next permitted action is a read-only adjudication of the partial A0-R1 filesystem state. Any completion must preserve the already frozen selected tuple and must not rescan the candidate universe.
