# A0 — Design and Selection Policy

## Status

```text
CASE=PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001
STAGE=A0-DESIGN
STATUS=FROZEN
EXECUTED=NO

DESIGN_FREEZE_DATE=2026-10-06
REFERENCE_FILING_YEAR_POLICY=LATEST_FULLY_COMPLETED_CALENDAR_YEAR_BEFORE_DESIGN_FREEZE
REFERENCE_FILING_YEAR=2025
```

This document freezes the scientific selection policy **before** issuer, accession pair, reporting period, XBRL concept or fact values are selected.

No classification is executed here.

---

## 1. Research question

> Can Yoda preserve the lineage of a deterministic evaluation as new public disclosure evidence becomes available, such that independent implementations can reproduce every original evaluation after recovery?

The CASE is a provenance, auditability and reproducibility experiment.

It is not a fraud detector, investment model or security-quality assessment.

---

## 2. Selection invariants

```text
ISSUER_SELECTED_BEFORE_POLICY_FREEZE=NO
ACCESSION_PAIR_SELECTED_BEFORE_POLICY_FREEZE=NO
REPORTING_PERIOD_SELECTED_BEFORE_POLICY_FREEZE=NO
XBRL_CONCEPT_SELECTED_BEFORE_POLICY_FREEZE=NO

SELECTION_USES_COMPANY_NOTORIETY=NO
SELECTION_USES_PRICE_ACTION=NO
SELECTION_USES_CONTROVERSY=NO
SELECTION_USES_FACT_VALUES=NO
SELECTION_USES_EVALUATION_RESULT=NO

PRE_A0_PROBE_USED_AS_CASE_SELECTION=NO
```

Selection may inspect only filing metadata and fact availability/context metadata.

Numeric fact values must not be emitted, compared or used as a selection branch until the issuer, pair and concept are frozen.

---

## 3. Public authority boundary

The selection process uses only official SEC EDGAR public authorities.

```text
FILING_INDEX_AUTHORITY=SEC_EDGAR_QUARTERLY_MASTER_INDEX
SUBMISSION_AUTHORITY=SEC_SUBMISSIONS_API
XBRL_AVAILABILITY_AUTHORITY=SEC_COMPANYFACTS_API
FILING_DOCUMENT_AUTHORITY=SEC_EDGAR_ARCHIVE
```

SEC XBRL APIs are used only for standard non-custom taxonomy facts that apply to the entire filing entity.

---

## 4. Candidate universe

The candidate universe is fixed to all EDGAR master-index rows in calendar year 2025 whose form type is exactly:

```text
10-K/A
```

Source indices:

```text
2025/QTR1/master.idx
2025/QTR2/master.idx
2025/QTR3/master.idx
2025/QTR4/master.idx
```

Candidate order is deterministic:

```text
1. amendment filing date ascending
2. CIK numeric ascending
3. accession / filing path lexical ascending
```

No issuer may be manually promoted or skipped for an interesting outcome.

---

## 5. Original / amendment pair rule

For each 10-K/A candidate in deterministic candidate order:

1. read the issuer's SEC submissions history;
2. obtain the amendment's reportDate;
3. locate prior filings for the same CIK with form exactly 10-K;
4. retain only prior 10-K filings with the exact same reportDate;
5. require original filing date < amendment filing date;
6. if more than one original qualifies, choose the latest prior filing date;
7. break any remaining tie by accession lexical ascending.

The pair must therefore satisfy:

```text
SAME_CIK=YES
ORIGINAL_FORM=10-K
SECOND_FORM=10-K/A
SAME_REPORT_DATE=YES
ORIGINAL_FILED_BEFORE_AMENDMENT=YES
```

The PRE-A0 probe pair is not a selection shortcut and receives no preference.

---

## 6. XBRL pair eligibility

A filing pair is eligible for concept selection only if:

```text
ORIGINAL_XBRL_AVAILABLE=YES
AMENDMENT_XBRL_AVAILABLE=YES
COMPANYFACTS_AVAILABLE=YES
```

The filing archive must expose filing-level XBRL evidence for both accessions.

Company Facts is used for standard, entire-entity concept availability.

---

## 7. Frozen concept priority

Concept selection uses this exact priority order:

```text
1. us-gaap:Assets
2. us-gaap:CashAndCashEquivalentsAtCarryingValue
3. us-gaap:Revenues
4. us-gaap:NetIncomeLoss
5. us-gaap:StockholdersEquity
```

The first concept satisfying the context rules below is selected.

No lower-priority concept may be chosen because its numeric values are more interesting.

If none qualifies, the filing pair is rejected and selection proceeds to the next 10-K/A candidate.

---

## 8. Frozen fact-context contract

For a concept to qualify, Company Facts must contain exactly one matching fact entry for the original accession and exactly one matching fact entry for the amendment accession after applying all metadata filters.

Required metadata:

```text
TAXONOMY=us-gaap
UNIT=USD
ORIGINAL_ACCNUM=exact original accession
AMENDMENT_ACCNUM=exact amendment accession
ORIGINAL_FORM=10-K
AMENDMENT_FORM=10-K/A
```

Context matching:

### Instant concepts

Applies to:

```text
Assets
CashAndCashEquivalentsAtCarryingValue
StockholdersEquity
```

Required:

```text
original.end = amendment.end = reportDate
start field absent or not applicable
```

### Duration concepts

Applies to:

```text
Revenues
NetIncomeLoss
```

Required:

```text
original.start = amendment.start
original.end   = amendment.end
original.end   = reportDate
```

Ambiguity rule:

```text
MATCHING_FACT_COUNT_ORIGINAL=1
MATCHING_FACT_COUNT_AMENDMENT=1
```

If either side has zero or multiple matching entries, that concept does not qualify.

Selection must not inspect the numeric val field to resolve ambiguity.

---

## 9. Selection result

The selected scientific tuple is the first tuple satisfying all frozen rules:

```text
CIK
issuer identity
reportDate
original accession
amendment accession
selected us-gaap concept
unit
context dates
```

Once selected:

```text
CIK=FROZEN
REPORT_DATE=FROZEN
ORIGINAL_ACCESSION=FROZEN
AMENDMENT_ACCESSION=FROZEN
XBRL_CONCEPT=FROZEN
FACT_CONTEXT=FROZEN
```

No reselection is allowed because the eventual values or labels are uninteresting.

---

## 10. Evaluation contract freeze

The evaluation contract is frozen before selected numeric values are revealed.

Allowed labels:

```text
UNCHANGED
CHANGED_WITHIN_THRESHOLD
CHANGED_ABOVE_THRESHOLD
NOT_COMPARABLE
NOT_EVALUABLE
```

No semantic interpretation of correctness, intent, fraud, investment quality or market impact is permitted.

### Numeric representation

No binary floating point is allowed.

Facts are represented as:

```text
sign
decimal coefficient
decimal scale
unit
period/context identity
```

Exact decimal normalization must preserve the submitted value.

### Comparison rule

After exact common-scale normalization:

```text
delta = abs(B - A)
base  = max(abs(A), abs(B))
```

Classification:

```text
if parse/context/unit is invalid or ambiguous:
    NOT_EVALUABLE

else if unit or required period/context differs:
    NOT_COMPARABLE

else if delta = 0:
    UNCHANGED

else if delta / base <= 0.0100:
    CHANGED_WITHIN_THRESHOLD

else:
    CHANGED_ABOVE_THRESHOLD
```

The comparison must be implemented without floating point.

Equivalent integer inequality for the 1.00% threshold:

```text
delta * 10000 <= base * 100
```

If delta > 0, then base > 0; therefore no nonzero-change divide-by-zero branch is required.

```text
RELATIVE_CHANGE_THRESHOLD_BASIS_POINTS=100
THRESHOLD_PERCENT=1.00
THRESHOLD_TUNING_AFTER_FACT_REVEAL=FORBIDDEN
```

---

## 11. A0 execution boundary

A0 may:

```text
fetch the four frozen 2025 quarterly master indices
identify the deterministic candidate sequence
inspect submissions metadata
inspect Company Facts metadata
select the first qualifying tuple
freeze the selected public responses
freeze filing archive identities
freeze canonical fact records
```

A0 must not:

```text
classify the fact pair
run C11 classification authority
run POSIX awk classification authority
write Yoda
change the selection policy
change the threshold
reselect because of observed values
```

Required A0 terminal state:

```text
ISSUER_SELECTION_POLICY=FROZEN
CIK=FROZEN
ORIGINAL_ACCESSION=FROZEN
SECOND_ACCESSION=FROZEN
XBRL_CONCEPT=FROZEN
FACT_CONTEXT_CONTRACT=FROZEN

RAW_RESPONSES_FROZEN=PASS
CANONICAL_FACTS_FROZEN=PASS

CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
```

---

## 12. Failure and non-evaluation rules

Environment, source-access, parser or harness inability before the scientific selection gate:

```text
NOT_EVALUATED
```

A deterministic candidate that fails the frozen pair/concept eligibility rules is simply skipped according to policy and is not a CASE failure.

If the complete 2025 candidate universe contains no qualifying tuple:

```text
A0=NOT_EVALUATED
FAILURE_CLASS=NO_AUTHORITY_COMPATIBLE_WORKLOAD_IN_FROZEN_UNIVERSE
```

The universe must not be expanded after observing this outcome without creating a separately preregistered revision.

---

## 13. Safety and claim boundary

```text
FRAUD_CLASSIFICATION=NO
MARKET_MANIPULATION_CLASSIFICATION=NO
FILING_CORRECTNESS_JUDGMENT=NO
COMPANY_QUALITY_ASSESSMENT=NO
PRICE_PREDICTION=NO
INVESTMENT_SIGNAL=NO
SEC_REPLACEMENT=NO
```

The eventual experiment tests evaluation lineage under new public evidence, not the economic or legal meaning of the disclosure.

---

## 14. Next operation

```text
NEXT_OPERATION=A0_SELECTION_HARNESS_AUDIT
A0_EXECUTED=NO
YODA_WRITES=ZERO
```

No A0 data-selection execution is authorized until the selection harness itself is audited and its identity frozen.
