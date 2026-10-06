# A2-R0 Yoda Capacity Preflight — Preregistration

## Status

```text
STATUS=READY_NOT_EXECUTED
A2_R1_EXECUTED=NO
A2_EXECUTION_LOCK_CONSUMED=NO
```

## Purpose

This preflight exists because a previous independent CASE reached a real Yoda persistence boundary at the frozen terms table.

A2-R0 must determine whether the minimal replay-complete bundle for this CASE has a conservative term footprint comfortably below the frozen Yoda terms capacity before any A2 scientific write is allowed.

## Frozen Yoda authority

```text
YODA_BINARY=
/home/jose/YodaCore-015-FROZEN/product/yoda

YODA_SHA256=
1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb

YODA_SOURCE=
/home/jose/YodaCore-015-FROZEN/product/yoda.c

YODA_SOURCE_SHA256=
cac855eaeabddbf27b6ffbc344de479d625956555118e6fbcb178668361fdf14
```

The preflight reads the source constants `YODA_TERMS_SLOTS` and `YODA_TERM_MAX` from this frozen source.

## Frozen A1 authority

```text
A1_R1=PASS

A1_LOCK_SHA256=
e047439babba668a4bfa9a408e6a58afb926e7ca0e029f4526ace064611cfa2d

A1_MANIFEST_SHA256=
d9ff35821c0b69d642a42e2653b8841c919e62477e9d0867bb0556af12edb0fd

FINAL_DB_HASH=
0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7

LINEAGE_A_SHA256=
965417ca555dd70eff7d39e822326305b1e81b9e16864dcd7a92b43197d5d36b

LINEAGE_B_SHA256=
1933529e5aa2902bd83a45d90f2692e07f0c3ef00ac4442db98ffdd114ae8340
```

## Minimal replay-complete candidate

Exactly 10 value objects are materialized outside Yoda:

```text
benchmark/task/7
derivation/A
derivation/B
outcome/A
outcome/B
outcome/equivalence
contract/execution
contract/communication
authority/tau2-v1.0.1
evidence/A1-R1
```

Exactly 14 semantic relations are frozen.

This bundle is intentionally minimal. Large upstream source files, complete benchmark databases, package trees and unrelated evidence are not persisted in Yoda.

## Capacity safety rule

A conservative unique-term upper bound is computed from:

- all candidate object values;
- all object keys;
- all object types;
- all relation endpoints and relation names;
- A2 case/revision metadata;
- the candidate maps themselves as an intentional overestimate.

Token boundaries conservatively follow the frozen Yoda index surface: alphanumeric, underscore and hyphen are treated as term characters.

PASS requires:

```text
CONSERVATIVE_UNIQUE_TERM_UPPER_BOUND < YODA_TERMS_SLOTS

CONSERVATIVE_TERM_LOAD_BPS <= 2500
```

That is a maximum conservative load of 25 percent of the frozen table.

The 25 percent threshold is a preregistered engineering safety margin, not a scientific outcome threshold.

## Replay completeness rule

The candidate must contain enough information to later recover from Yoda:

```text
task 7
derivation A
derivation B
execution contract
communication contract
external tau2 authority
reference outcome
```

No A2 scientific store is created during this preflight.

## Forbidden operations

```text
YODA_INIT=FORBIDDEN
YODA_PUT=FORBIDDEN
YODA_LINK=FORBIDDEN
YODA_GET=FORBIDDEN
YODA_VERIFY=FORBIDDEN

A2_LOCK_WRITE=FORBIDDEN
A2_STAGE_CREATION=FORBIDDEN

YODA_WRITES=ZERO
```

## Preflight harness

```text
A2_R0_SCRIPT_SHA256=
1dc4306ec00e25f4759aedd25ca9ceadede3d56e52db694ec0cf44036dd4535e

A2_R0_SCRIPT_COMMIT=
7f2999da05de06ba607821c26ad43660e09bc146

SCRIPT_LINES=619
NON_ASCII=0
YODA_COMMAND_INVOCATIONS=0
A2_LOCK_WRITES=0
A2_STAGE_CREATION=0
PYTHON_INVOCATIONS=0
```

## Safe launcher

```text
A2_R0_SAFE_LAUNCHER_SHA256=
177bc219e60d8f17763d490395028eced1f24a24e52ef832240a74610e5f8012

A2_R0_SAFE_LAUNCHER_COMMIT=
98d68dc4d5a234fd8e85afc3501b648e839d60da
```

## PASS

```text
A2_R0_CAPACITY_PREFLIGHT=PASS
CANDIDATE_BUNDLE=FROZEN
TERM_CAPACITY_MARGIN=PASS
REPLAY_COMPLETENESS_STATIC_AUDIT=PASS

A2_EXECUTION_LOCK=ABSENT
A2_STAGE=ABSENT
YODA_STORE_CREATED=NO
YODA_WRITES=ZERO

NEXT_GATE=A2_R1_YODA_DUAL_DERIVATION_LINEAGE
```
