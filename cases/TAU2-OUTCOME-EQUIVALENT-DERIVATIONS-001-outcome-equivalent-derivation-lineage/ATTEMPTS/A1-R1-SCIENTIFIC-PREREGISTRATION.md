# A1-R1 Dual Derivation External Judgment — Preregistration

## Status

```text
STATUS=READY_FOR_SINGLE_EXECUTION
A1_R1_EXECUTED=NO
A1_EXECUTION_LOCK_CONSUMED=NO
```

## A0 authority

```text
A0_R1=PASS

A0_LOCK_SHA256=
e051f5b80216a0c99005043ec90f95ca452c9f82ef677a525e2b4a9be1426449

A0_MANIFEST_SHA256=
333301ea6e61dfb6de91831eb51c9a956b5d18b006a3c3d9be518bf96b2da7bc
```

## Runtime preflight authority

```text
A1_R1_PREFLIGHT=PASS

A1_R1_PREFLIGHT_CONSOLE_SHA256=
ac32149a14eb98cd40e4329ee302fa5d5f4b8a9bfa4867af83b18fb74b17846a

UV_VERSION=uv 0.12.23 (x86_64-unknown-linux-gnu)
PYTHON_VERSION=3.12.15
TAU2_VERSION=1.0.1

A1_EXECUTION_LOCK=ABSENT
A1_STAGE=ABSENT
```

## Frozen external authority

```text
UPSTREAM_REPOSITORY=sierra-research/tau2-bench
RELEASE_TAG=v1.0.1
RELEASE_COMMIT=fc0055dc4e0a316c3f83133267fbd6faaa770992

TASK_ID=7

TRAJECTORY_A_ACTION_ORDER=0,1,2,3,4
TRAJECTORY_B_ACTION_ORDER=1,0,2,3,4

REWARD_BASIS=DB,COMMUNICATE
COMMUNICATE_INFO=1628

EVALUATION_TYPE=ALL
STRICT_REPLAY=TRUE
MODEL_ENDPOINT_CALLED=NO
USER_SIMULATOR_EXECUTED=NO
```

## Authority adapter

```text
A1_ADAPTER_SHA256=
94424c62a06f1b24cf45c1a6bacd1ce1bbb44753f9caf1281a86fb37b96cdf16

A1_ADAPTER_COMMIT=
360ab0552488ca06e9f1c2cbf1cc45d6b6b94b63

ADAPTER_LINES=529
NON_ASCII=0
MODEL_PROVIDER_REFERENCES=0
```

The adapter does not define correctness. It executes the frozen calls using the upstream Airline environment, records official ToolMessages, constructs official SimulationRun objects, and calls the upstream evaluate_simulation authority.

## Scientific harness

```text
A1_R1_SCRIPT_SHA256=
60cbd7e41a42c9cb9fcc09ee8f97e1c0dd0ec9762ab1046877296b4f7182e267

A1_R1_SCRIPT_COMMIT=
bd226b928fce1637e935dfe1223ef2e25cc07a51

SCRIPT_LINES=642
NON_ASCII=0
YODA_COMMANDS=0

ADAPTER_AUDIT_LINE=335
A1_LOCK_LINE=374
ADAPTER_EXECUTE_LINE=436

ADAPTER_AUDIT_BEFORE_LOCK=YES
LOCK_BEFORE_TRAJECTORY_EXECUTION=YES
```

## Execution-validity criteria

Each trajectory must execute exactly five frozen tool calls with zero ToolMessage errors.

This is an execution-validity requirement, not a replacement correctness judge.

## External correctness criteria

PASS requires all of:

```text
TRAJECTORY_A_FINAL_REWARD=1.0
TRAJECTORY_B_FINAL_REWARD=1.0

TRAJECTORY_A_DB_REWARD=1.0
TRAJECTORY_B_DB_REWARD=1.0

TRAJECTORY_A_DB_MATCH=true
TRAJECTORY_B_DB_MATCH=true

TRAJECTORY_A_COMMUNICATE_REWARD=1.0
TRAJECTORY_B_COMMUNICATE_REWARD=1.0

TRAJECTORY_A_TOOL_ERROR_COUNT=0
TRAJECTORY_B_TOOL_ERROR_COUNT=0

TRAJECTORY_A_FINAL_DB_HASH
==
TRAJECTORY_B_FINAL_DB_HASH

TRAJECTORY_A_LINEAGE_SHA256
!=
TRAJECTORY_B_LINEAGE_SHA256
```

## One-execution boundary

After:

```text
A1_EXECUTION_GATE=PASS
```

A1-R1 is consumed and must never be rerun.

If the frozen external authority cannot execute after the lock because of infrastructure/runtime failure, the outcome is NOT_EVALUATED with the lock consumed and no rerun.

If the external authority executes both trajectories and any frozen scientific criterion is not met, the outcome is FAIL.

If all criteria are met, the outcome is PASS.

## Yoda boundary

```text
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Yoda persistence is not tested until A2.
