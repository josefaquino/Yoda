# A0-R1 — Public Data and Temporal Authority

## Status

```text
STATUS=PRE-REGISTERED
EXECUTED=NO
EXECUTION_POLICY=ONE_EXECUTION
```

## Purpose

Freeze the public data authority and three point-in-time input states without executing any market classification.

## Frozen dates

```text
STATE_A=2025-04-25
STATE_B=2025-08-29
STATE_C=2025-12-26
EVALUATION_DAY=FRIDAY
```

These dates were frozen before historical classification results were inspected.

## Point-in-time contract

```text
realtime_start=evaluation_date
realtime_end=evaluation_date

VIXCLS_MAX_LOOKBACK_CALENDAR_DAYS=7
DGS10_MAX_LOOKBACK_CALENDAR_DAYS=7
NFCI_MAX_LOOKBACK_CALENDAR_DAYS=14

LOOKBACK_DIRECTION=BACKWARD_ONLY
INTERPOLATION=NO
FUTURE_OBSERVATION_USE=NO
FORWARD_INFORMATION_LEAKAGE=FORBIDDEN
```

## A0 artifacts

A0 must freeze:

```text
3 point-in-time metadata responses
9 point-in-time observation responses
3 canonical snapshot TSV files
3 temporal alignment records
date-selection policy
temporal-alignment contract
source/license notes
evidence manifest
```

## Non-execution boundary

```text
CLASSIFICATION_EXECUTED=NO
AUTHORITY_1_EXECUTED=NO
AUTHORITY_2_EXECUTED=NO
YODA_WRITES=ZERO
```

No CALM / FRAGILE / STRESSED label may be produced in A0.

## Frozen harness identity

```text
A0_R1_SCRIPT_SHA256=
1b52739161d3348bd875d78ee460d8f6847def18312458e948f543eb9d043617

A0_R1_CANONICAL_HARNESS_COMMIT=
0ef9b4e353dac020391007ebb390f6824cb58534
```

## Prior authority

```text
PRE_A0_R2=PASS

PRE_A0_R2_SCRIPT_SHA256=
cc582307f7e0f6b24228a0f4d8c895f04f40d4033cb7ab5f9f86fc681b4a4de1

PRE_A0_R2_CONSOLE_SHA256=
0179c82713873d94708dbc2933f7a6a987eb8681cf95ff56673ef060dd6a7088
```

## PASS condition

```text
FRED_API_AUTHORITY=PASS
VIXCLS_SOURCE_AUTHORITY=PASS
DGS10_SOURCE_AUTHORITY=PASS
NFCI_SOURCE_AUTHORITY=PASS
POINT_IN_TIME_DATA=PASS
DATE_SELECTION_POLICY=FROZEN
TEMPORAL_ALIGNMENT_CONTRACT=FROZEN
MISSING_VALUE_POLICY=FROZEN
RAW_RESPONSES_FROZEN=PASS
CANONICAL_SNAPSHOTS_FROZEN=PASS
SOURCE_LICENSE_NOTES=RECORDED
A0_EVIDENCE_INTEGRITY=PASS
CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Only PASS authorizes A1.
