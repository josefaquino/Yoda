# RUNBOOK — MARKET-REGIME-LINEAGE-001

## Current state

```text
DESIGN_REVIEW=COMPLETE
PREREGISTRATION=FROZEN
PRE_A0=PASS
A0_R1=PRE_REGISTERED
A1=BLOCKED
A2=BLOCKED
B=BLOCKED
```

## PRE-A0

Script:

```text
scripts/00-pre-a0-connectivity-r2.sh

PRE_A0_R2_SCRIPT_SHA256=
cc582307f7e0f6b24228a0f4d8c895f04f40d4033cb7ab5f9f86fc681b4a4de1
```

Purpose:

- verify local tools;
- verify that `FRED_API_KEY` is present without printing it;
- verify current API connectivity for VIXCLS, DGS10 and NFCI;
- verify that point-in-time parameters are accepted;
- make zero Yoda writes.

PRE-A0 is repeatable because it is a connectivity check and consumes no experimental one-shot gate.

PRE-A0-R1 remains preserved as NOT_EVALUATED due to HARNESS_TRANSPORT_COMPOSITION. PRE-A0-R2 changes only request transport composition.

Only PRE-A0 PASS authorizes construction of A0.

## Later stages

A0 will freeze the three historical point-in-time snapshots and metadata.

A1 will build two independent classifier implementations: C11 and POSIX awk/shell.

A2 will create the Yoda Decision Lineage.

B will recover only from Yoda and replay both authorities.


## A0-R1

```text
SCRIPT=scripts/01-a0-public-data-temporal-authority.sh

A0_R1_SCRIPT_SHA256=
1b52739161d3348bd875d78ee460d8f6847def18312458e948f543eb9d043617

EXECUTION_POLICY=ONE_EXECUTION
LOCK_BEFORE_FIRST_HISTORICAL_FETCH=YES
```

A0-R1 freezes public point-in-time input authority only. It does not classify any market state and does not write to Yoda.
