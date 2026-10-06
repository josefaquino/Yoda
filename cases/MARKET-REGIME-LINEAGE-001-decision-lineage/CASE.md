# MARKET-REGIME-LINEAGE-001

## Deterministic Decision Lineage from Public Market Data

## Status

```text
DESIGN_REVIEW=COMPLETE
PRE_A0_R2=PASS
A0_R1=PASS
A1_R1=NOT_EVALUATED
A1_R2=PASS
A2_R1=PRE_REGISTERED
B=BLOCKED
YODA_CHANGE=NO
KYBER_CHANGE=NO
NEXT_GATE=A2_YODA_DECISION_LINEAGE
```

## Research question

> Can Yoda preserve successive deterministic market-regime states and their derivation evidence such that independent implementations reproduce each original classification after recovery?

The experiment does **not** ask whether the classifier discovers the true market regime.

It asks whether Yoda can preserve:

```text
what data was available
which deterministic rules were applied
which classification was produced
how the evaluation changed
which evidence supported each state
whether independent implementations can reproduce it later
```

## Primary property under test

```text
DECISION_LINEAGE
```

Model:

```text
Public Data Snapshot A
        ↓
Deterministic Evaluation
        ↓
Regime State A
        ↓
New Public Observations
        ↓
Public Data Snapshot B
        ↓
Same Deterministic Evaluation
        ↓
Regime State B
```

## Non-financial nature

This is an infrastructure and reproducibility experiment.

It is not:

```text
a trading strategy
a forecast
an alpha-generation system
an investment recommendation
a risk-management recommendation
a claim about the true market regime
```

No financial position is created, simulated, recommended, or evaluated.

## Public data authorities

Three public FRED/ALFRED series are frozen for the experiment.

### VIXCLS

```text
SERIES_ID=VIXCLS
ROLE=market-volatility-observable
FREQUENCY=DAILY
UNITS=INDEX
SOURCE=CBOE_VIA_FRED
```

### DGS10

```text
SERIES_ID=DGS10
ROLE=interest-rate-observable
FREQUENCY=DAILY
UNITS=PERCENT
SOURCE=FEDERAL_RESERVE_BOARD_VIA_FRED
```

### NFCI

```text
SERIES_ID=NFCI
ROLE=broad-financial-conditions-observable
FREQUENCY=WEEKLY_ENDING_FRIDAY
UNITS=INDEX
SOURCE=FEDERAL_RESERVE_BANK_OF_CHICAGO_VIA_FRED
```

For NFCI, the source interpretation of zero remains contextual metadata only:

```text
positive -> tighter than average
negative -> looser than average
```

## API authority

Official FRED API v1 endpoints are used for series metadata and observations.

Local secret contract:

```text
ENVIRONMENT_VARIABLE=FRED_API_KEY

MUST_NOT_ENTER_GITHUB=YES
MUST_NOT_ENTER_CONSOLE_LOGS=YES
MUST_NOT_ENTER_EVIDENCE_MANIFEST=YES
MUST_NOT_ENTER_DATA_YODA=YES
MUST_NOT_BE_PRINTED=YES
```

The harness may emit only:

```text
FRED_API_KEY_PRESENT=YES|NO
FRED_API_KEY_FORMAT=PASS|FAIL
```

## Point-in-time authority

The CASE distinguishes:

```text
observation_date
!=
date_when_information_was_available
```

Historical observations are retrieved with FRED real-time periods / ALFRED vintage semantics.

Required invariant:

```text
POINT_IN_TIME_DATA=YES
CURRENT_REVISED_HISTORY_ONLY=NO
FORWARD_INFORMATION_LEAKAGE=FORBIDDEN
```

Each frozen source row records:

```text
evaluation_date
series_id
observation_date
vintage_date
retrieval_timestamp
raw_value
units
raw_response_identity
```

## Temporal-alignment contract

Evaluation states are Fridays.

```text
EVALUATION_DAY=FRIDAY
INTERPOLATION=NO
LOOKBACK_DIRECTION=BACKWARD_ONLY
FUTURE_OBSERVATION_USE=NO
```

For VIXCLS and DGS10:

```text
use latest point-in-time available observation
observation_date <= evaluation_date
MAX_LOOKBACK_CALENDAR_DAYS=7
```

For NFCI:

```text
use latest point-in-time available weekly observation
observation_date <= evaluation_date
MAX_LOOKBACK_CALENDAR_DAYS=14
```

The longer NFCI window accounts for weekly frequency and publication timing without allowing future information.

If any required point-in-time observation is absent inside its permitted window:

```text
STATE_STATUS=NOT_EVALUABLE
```

No interpolation, forward-fill from a future date, averaging, or invented value is allowed.

## Date-selection policy

The policy is frozen before historical classification values are inspected.

```text
DESIGN_FREEZE_DATE=2026-10-06
REFERENCE_YEAR=latest fully completed calendar year before design freeze
REFERENCE_YEAR_RESOLVED=2025

PARTITION=three consecutive four-month blocks
STATE_A=last Friday of April
STATE_B=last Friday of August
STATE_C=last Friday of December

STATE_A_EVALUATION_DATE=2025-04-25
STATE_B_EVALUATION_DATE=2025-08-29
STATE_C_EVALUATION_DATE=2025-12-26

DATE_SELECTION_USES_CLASSIFICATION_RESULTS=NO
DATE_SELECTION_POLICY=FROZEN
```

All resulting classifications are accepted, including equal labels.

## Canonical snapshot

Each state is a TSV:

```text
evaluation_date
series_id
observation_date
vintage_date
value
units
```

Canonicalization:

```text
ENCODING=UTF-8
LINE_ENDING=LF
COLUMN_SEPARATOR=TAB
DECIMAL_SEPARATOR=.
DATE_FORMAT=YYYY-MM-DD
HEADER=YES
SORT_ORDER=evaluation_date,series_id
TRAILING_WHITESPACE=FORBIDDEN
FINAL_NEWLINE=REQUIRED
MISSING_VALUE_IN_EVALUABLE_STATE=FORBIDDEN
```

Required identities include:

```text
RAW_API_RESPONSE_SHA256
CANONICAL_SNAPSHOT_SHA256
SERIES_METADATA_SHA256
TEMPORAL_ALIGNMENT_RECORD_SHA256
```

## Classification contract

The classifier is experimental and exists only for this CASE.

```text
CLASSIFIER_TYPE=EXPERIMENTAL
CLASSIFIER_DETERMINISTIC=YES
MARKET_TRUTH_CLAIM=NO
FORECASTING_CLAIM=NO
INVESTMENT_CLAIM=NO
```

Inputs are canonical decimal strings.

The initial A1-R1 representation admitted at most four fractional digits and was preserved as NOT_EVALUATED when frozen NFCI inputs were observed with five fractional digits.

A1-R2 changed **numeric representation capacity only**:

```text
V1_FIXED_POINT_SCALE=10000
V1_MAX_FRACTION_DIGITS=4
A1_R1=NOT_EVALUATED

V2_FIXED_POINT_SCALE=100000
V2_MAX_FRACTION_DIGITS=5
A1_R2=PASS

DATES_CHANGED=NO
A0_SNAPSHOT_BYTES_CHANGED=NO
THRESHOLDS_CHANGED=NO
LABEL_MAPPING_CHANGED=NO
SCIENTIFIC_QUESTION_CHANGED=NO
```

The active classification contract therefore uses exact fixed-point scale 10^5. No rounding or truncation is permitted.

Indicators:

```text
VIX_FLAG  = 1 if VIXCLS >= 20.0000 else 0
RATE_FLAG = 1 if DGS10  >= 4.0000  else 0
NFCI_FLAG = 1 if NFCI   >= 0.0000  else 0

SCORE = VIX_FLAG + RATE_FLAG + NFCI_FLAG
```

Labels:

```text
SCORE=0      -> CALM
SCORE=1      -> FRAGILE
SCORE=2 or 3 -> STRESSED
```

These thresholds are pre-registered experimental constants, not official market definitions.

No threshold may be changed after historical snapshots are retrieved.

## Independent classification authorities

### Authority 1 — C11

```text
LANGUAGE=C11
NO_EXTERNAL_LIBRARY=YES
NO_SHARED_CLASSIFICATION_FUNCTION=YES
```

### Authority 2 — POSIX awk + shell

```text
LANGUAGE=POSIX_AWK_SHELL
NO_CODE_REUSE_FROM_AUTHORITY_1=YES
NO_CALL_TO_AUTHORITY_1=YES
NO_SHARED_CLASSIFICATION_FUNCTION=YES
```

For each state:

```text
AUTHORITY_1_FEATURES = AUTHORITY_2_FEATURES
AUTHORITY_1_CLASSIFICATION = AUTHORITY_2_CLASSIFICATION
```

Agreement means implementation equivalence under the frozen contract, not market truth.

## Yoda data model

Objects include:

```text
Dataset Snapshot A/B/C
Feature State A/B/C
Regime State A/B/C
Classification Contract
Authority 1 Identity
Authority 2 Identity
Evaluation Evidence A/B/C
Transition Evidence A->B
Transition Evidence B->C
Source Authority Record
```

Minimum relations:

```text
Feature State X --derived-from--> Dataset Snapshot X
Regime State X  --computed-from--> Feature State X
Regime State B  --supersedes--> Regime State A
Regime State C  --supersedes--> Regime State B
Regime State X  --classified-by--> Classification Contract
Regime State X  --has-evidence--> Evaluation Evidence X
Evaluation Evidence X --evaluated-by--> Authority 1 Identity
Evaluation Evidence X --evaluated-by--> Authority 2 Identity
```

`supersedes` is intentionally distinct from `derived-from`: a later regime state is a new evaluation using later observations under the same contract.

## Experimental stages

### PRE-A0 — connectivity and local capability

Read-only.

Required:

```text
CURL=PASS
CC=PASS
AWK=PASS
SHA256SUM=PASS
FRED_API_KEY_PRESENT=YES
FRED_API_KEY_FORMAT=PASS
VIXCLS_API_RESPONSE=PASS
DGS10_API_RESPONSE=PASS
NFCI_API_RESPONSE=PASS
POINT_IN_TIME_PARAMETER_SUPPORT=PASS
YODA_WRITES=ZERO
PRE_A0=PASS
```

PRE-A0 does not freeze source observations, run the classifier, create Yoda state, or consume an A0 one-execution gate.

### A0 — public data and temporal authority

Freeze point-in-time source data, metadata, canonical snapshots and temporal evidence.

### A1 — deterministic classification authority

A1-R1 was NOT_EVALUATED because its four-decimal representation contract rejected the frozen five-decimal NFCI values.

A1-R2 changed only representation capacity to five decimals and passed:

```text
A=STRESSED
B=FRAGILE
C=FRAGILE

AUTHORITY_FEATURE_EQUIVALENCE=PASS
AUTHORITY_CLASSIFICATION_EQUIVALENCE=PASS
```

### A2 — Yoda Decision Lineage

Persist and recover successive states, the classification contract, authorities, evidence and transitions.

### B — independent classification replay

Use only Yoda-recovered artifacts to rerun both classification authorities and compare against original evaluations.

## PASS condition

Only if all stages pass:

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Failure classes

```text
PUBLIC_SOURCE_UNAVAILABLE
API_AUTHENTICATION_FAILURE
API_RESPONSE_SCHEMA_DRIFT
SERIES_METADATA_MISMATCH
POINT_IN_TIME_DATA_UNAVAILABLE
TEMPORAL_ALIGNMENT_FAILURE
MISSING_REQUIRED_OBSERVATION
CANONICALIZATION_FAILURE
AUTHORITY_IMPLEMENTATION_DIVERGENCE
CLASSIFICATION_CONTRACT_AMBIGUITY
YODA_PERSISTENCE_FAILURE
YODA_RELATION_RECOVERY_FAILURE
BYTE_EXACT_RECOVERY_FAILURE
INDEPENDENT_REPLAY_FAILURE
HARNESS_FAILURE
TOOLCHAIN_DRIFT
```

A harness failure is never relabeled as a Yoda failure.

A missing observation is never relabeled as a market classification.

No stage may be silently rerun until a desired result appears.

## Permitted claim

If validated:

> For one controlled deterministic public-data market-regime workflow, Yoda preserved successive evaluation states, their point-in-time public-data inputs, classification contract, transition history and evidence such that two independent implementations reproduced each original classification after recovery.

Short form:

> Yoda preserved not only the classification, but why the deterministic system produced that classification at that point in time.

## Non-claims

The CASE does not establish that Yoda:

- predicts financial markets;
- generates alpha;
- recommends investments;
- identifies the true market regime;
- prevents financial losses;
- validates an economic theory;
- provides financial advice;
- guarantees model correctness.

FRED, the Federal Reserve, Chicago Fed and CBOE provide public data or source context only. They do not participate in or endorse this CASE.

## Candidate property

Only if the complete CASE passes:

```text
PROPERTY=DECISION_LINEAGE
STATUS=DEMONSTRATED
EVIDENCE=MARKET-REGIME-LINEAGE-001
```

Decision Lineage is a candidate extension of Lineage of Change from artifact transformation to changing deterministic evaluations.
