# RUNBOOK — MARKET-REGIME-LINEAGE-001

## Current state

```text
DESIGN_REVIEW=COMPLETE
PREREGISTRATION=FROZEN
PRE_A0=READY
A0=BLOCKED
A1=BLOCKED
A2=BLOCKED
B=BLOCKED
```

## PRE-A0

Script:

```text
scripts/00-pre-a0-connectivity.sh
```

Purpose:

- verify local tools;
- verify that `FRED_API_KEY` is present without printing it;
- verify current API connectivity for VIXCLS, DGS10 and NFCI;
- verify that point-in-time parameters are accepted;
- make zero Yoda writes.

PRE-A0 is repeatable because it is a connectivity check and consumes no experimental one-shot gate.

Only PRE-A0 PASS authorizes construction of A0.

## Later stages

A0 will freeze the three historical point-in-time snapshots and metadata.

A1 will build two independent classifier implementations: C11 and POSIX awk/shell.

A2 will create the Yoda Decision Lineage.

B will recover only from Yoda and replay both authorities.
