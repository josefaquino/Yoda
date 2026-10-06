# PRE-REGISTRATION — MARKET-REGIME-LINEAGE-001

## Freeze point

```text
DESIGN_FREEZE_DATE=2026-10-06
HISTORICAL_CLASSIFICATIONS_INSPECTED_BEFORE_FREEZE=NO
EXECUTION_AUTHORIZED=PRE_A0_ONLY
```

## Frozen scientific question

```text
Can Yoda preserve successive deterministic evaluation states
and their derivation evidence such that independent implementations
reproduce each original classification after recovery?
```

## Frozen date-selection rule

```text
REFERENCE_YEAR=2025
STATE_A=2025-04-25
STATE_B=2025-08-29
STATE_C=2025-12-26
DATE_SELECTION_POLICY=FROZEN
```

Selection was calendar-derived before retrieving historical classification inputs.

## Frozen classifier

```text
VIXCLS >= 20.0000 -> VIX_FLAG=1
DGS10  >= 4.0000  -> RATE_FLAG=1
NFCI   >= 0.0000  -> NFCI_FLAG=1

SCORE=0      -> CALM
SCORE=1      -> FRAGILE
SCORE=2 or 3 -> STRESSED

FIXED_POINT_SCALE=10000
COMPARISON=>=
THRESHOLD_TUNING_AFTER_DATA=FORBIDDEN
```

## Frozen independent implementations

```text
AUTHORITY_1=C11
AUTHORITY_2=POSIX_AWK_SHELL
SHARED_CLASSIFICATION_CODE=NO
```

## Frozen point-in-time rule

```text
realtime_start=evaluation_date
realtime_end=evaluation_date
observation_date<=evaluation_date
future_observation_use=NO

VIXCLS_MAX_LOOKBACK_DAYS=7
DGS10_MAX_LOOKBACK_DAYS=7
NFCI_MAX_LOOKBACK_DAYS=14
```

## Governance

PRE-A0 may test connectivity only.

No historical snapshot may be classified until A0 evidence is frozen.

No Yoda write is permitted before A2.

Negative, unavailable and non-evaluable outcomes are evidence and must be preserved.
