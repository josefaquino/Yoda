# RUNBOOK — MARKET-REGIME-LINEAGE-001

## Current state

```text
DESIGN_REVIEW=COMPLETE
PREREGISTRATION=FROZEN
PRE_A0=PASS
A0_R1=PASS
A1_R1=PRE_REGISTERED
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


## A0-R1 observed authority

```text
A0_R1_CONSOLE_SHA256=
f69c7a9682078348b1451c07cfb0dc808706ad0d9122960bfdcc1802f1b38df4

A0_R1_EXECUTION_LOCK_SHA256=
e0a28a66d3e3945091b824a355b02407470b1dd40f477edd9e2203db57ac6165

A0_EVIDENCE_MANIFEST_SHA256=
0440ffea6e2377fa6843f972f35d127f44727f114c2d91ae94039ff1ca4a78c8
```

A0-R1 must not be rerun.


## A1-R1

```text
SCRIPT=scripts/02-a1-deterministic-classification-authority.sh

A1_R1_SCRIPT_SHA256=
a9d04c9ceff162911a4a3606d68d747b82df0de69db686d47c4a6ef6115ca13c

CLASSIFICATION_CONTRACT_SHA256=
955b9bde32a74c46c100bba300a7c6398606b53c13efa237b97e3f076f53a2d5

AUTHORITY_1_SOURCE_SHA256=
0e72cfbdeee214a40ba439c56f161e782719753eabe01647b5b4ddf04c0aa1f5

AUTHORITY_2_SOURCE_SHA256=
a8c43eb473f07a6c0a68ffbed4bf5022453dbd558e520dcf2889eddfdc45e5b0

EXECUTION_POLICY=ONE_EXECUTION
LOCK_BEFORE_FIRST_CLASSIFICATION=YES
```

A1-R1 is the first authorized classification of the frozen A0 snapshots.
