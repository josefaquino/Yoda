# B-R0 Independent Dual Derivation Replay Preflight — Preregistration

## Status

```text
STATUS=READY_NOT_EXECUTED
B_R1_EXECUTED=NO
B_EXECUTION_LOCK_CONSUMED=NO
```

## A2 authority

```text
A2_R1=PASS

A2_LOCK_SHA256=
678d87d60c3661209b73674961afb42a8139fef66c6cdbbe57ebb51487b39bb7

A2_EVIDENCE_MANIFEST_SHA256=
d6ac6b8d4fbd61f7c210d998f8feb407759dd3df3d068c82187653c006099a2c

A2_CONSOLE_SHA256=
f37708f77cf45ce2da56e3b2d5c11601c7f9ca5a01bc881dfa3d160b4313d4f5

DATA_YODA_SHA256=
0d790fb57c3fe092a1567327f049f0b123dd143c379f4afa21692b614f40d42a

DATA_YODA_BYTES=24801
```

## Independent replay boundary

Stage B must not use A0 or A1 files as operational replay inputs.

The only scientific replay inputs are objects freshly recovered using `yoda get` from the frozen A2 store:

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

A2's frozen object map and candidate hash list may be used only as recovery-address and identity authority.

## Independent implementation

```text
B_ADAPTER_SHA256=
c63c1349e6eefc950f791382c1fc2caf9f1ae0e3a516107679ecd3dfbc1ca16a

B_ADAPTER_COMMIT=
fc2821cb9d590d35f3409d1b092cfbb29415a5c5

ADAPTER_LINES=541
NON_ASCII=0
A1_ADAPTER_REFERENCES=0
GET_TASKS_REFERENCES=0
MODEL_PROVIDER_REFERENCES=0
```

The recovered task object is parsed directly into the upstream `Task` model. The adapter does not call upstream `get_tasks`.

## Preflight behavior

The preflight may:

- read the frozen A2 store using `yoda get`;
- verify all 10 recovered object hashes;
- verify the recovered tau2 release authority;
- materialize the pinned tau2 v1.0.1 runtime;
- compile and audit the independent replay adapter.

It must not execute either derivation or the external judge.

## Read-only Yoda proof

A full manifest of every file in the frozen A2 Yoda store is computed before and after recovery.

PASS requires:

```text
STORE_BEFORE_MANIFEST_SHA256
==
STORE_AFTER_MANIFEST_SHA256

DATA_YODA_SHA256
==
0d790fb57c3fe092a1567327f049f0b123dd143c379f4afa21692b614f40d42a

YODA_STORE_MUTATED=NO
YODA_WRITES=ZERO
```

## Preflight harness identity

```text
B_R0_SCRIPT_SHA256=
88a0676f33912a3ad0fa288e76dbfdcf237e29265aeac6078bb0c91918472bde

B_R0_SCRIPT_COMMIT=
7af0ad93f3573cf284791d027ecce631ead78b0e

SCRIPT_LINES=491
NON_ASCII=0
B_LOCK_WRITES=0
B_STAGE_CREATION=0
YODA_WRITE_COMMANDS=0
ADAPTER_EXECUTE_CALLS=0
```

## Safe launcher identity

```text
B_R0_SAFE_LAUNCHER_SHA256=
b79cb7b9940678e9740ddba90e77a1eadcc5847f42ce2966845fb01b507262b3

B_R0_SAFE_LAUNCHER_COMMIT=
6b81e1649a95615887f8d42fa76c5febe385642a
```

## PASS

```text
B_R0_INDEPENDENT_REPLAY_PREFLIGHT=PASS

YODA_RECOVERY_AUTHORITY=PASS
RECOVERED_OBJECT_COUNT=10

PINNED_RUNTIME=PASS
INDEPENDENT_IMPLEMENTATION_BOUNDARY=PASS

YODA_STORE_MUTATED=NO

B_EXECUTION_LOCK=ABSENT
B_STAGE=ABSENT
INDEPENDENT_REPLAY_EXECUTED=NO
EXTERNAL_JUDGE_EXECUTED=NO
YODA_WRITES=ZERO

NEXT_GATE=B_R1_INDEPENDENT_DUAL_DERIVATION_REPLAY
```
