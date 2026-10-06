# PRE-A0-R1 Deterministic Task Selection — R2 Preregistration

## Status

```text
STATUS=READY_FOR_SINGLE_EXECUTION
PRE_A0_R1_SELECTION_EXECUTED=NO
PRE_A0_R1_SELECTION_LOCK_CONSUMED=NO
```

## Attempt 001 preservation

Attempt 001 remains:

```text
NOT_EVALUATED
FAILURE_CLASS=PRE_A0_PREFLIGHT_LOCK_BOUNDARY_MISMATCH
SELECTION_GATE_REACHED=NO
SELECTION_LOCK_CONSUMED=NO
REAL_TASK_SELECTION_EXECUTED=NO
```

Its console identity is:

```text
ccbcdbc59bc58ea2d4f7060e9127fa7e6039d586882877b15e8268b2b28bc848
```

## Root cause of Attempt 001

The previous selection harness required a wrapper-only lock-status line to exist inside the preflight console captured before that line was printed.

The correction removes only that impossible redundant console assertion.

```text
POLICY_CHANGED=NO
UPSTREAM_RELEASE_CHANGED=NO
CORPUS_CHANGED=NO
TASK_ORDER_CHANGED=NO
SELECTOR_LOGIC_CHANGED=NO
TRANSFORMATION_CLASS_CHANGED=NO
REAL_TASK_SELECTION_EXECUTED_BEFORE_CORRECTION=NO
```

## Corrected scientific harness

```text
PRE_A0_R1_SELECTION_SCRIPT_SHA256=
f4fdf16ffd8523ae7e79e9a1ba7444c7d90a37609a545c6f9f991de2f34cc8af

PRE_A0_R1_SELECTION_SCRIPT_COMMIT=
26a59335a4fe4ee79e15825db22b8ddd1ece6960

SCRIPT_LINES=683
NON_ASCII=0
YODA_COMMANDS=0
PYTHON_INVOCATIONS=0
HARDCODED_SELECTED_TASK=0
IMPOSSIBLE_LOCK_GREP=0

LOCK_LINE=348
REAL_SELECTOR_LINE=382
LOCK_BEFORE_REAL_SELECTOR=YES
```

## Corrected safe launcher

```text
PRE_A0_R1_R2_SAFE_LAUNCHER_SHA256=
fa55b493b1a3357746dabe8c6d9ba749ee1ba1d24cf1f6ed2b06487c756f69c2

PRE_A0_R1_R2_SAFE_LAUNCHER_COMMIT=
c2ddc9e6946c8a8c54029bbfc3f736eb5bdf5849
```

## Frozen preflight authority

```text
PRE_A0_PREFLIGHT_CONSOLE_SHA256=
fdb2578012c50478978744434da03d0c29cc241ebe71dd7b5ea04ab9098c0e08

PRE_A0_PREFLIGHT=PASS
SELECTOR_SELF_TEST=PASS
REAL_TASK_SELECTION_EXECUTED=NO
FINAL_TASK_SELECTED=NO
```

The safe launcher independently checks that the real selection lock and stage are absent immediately before execution.

## One-execution boundary

After:

```text
SELECTION_GATE=PASS
```

PRE-A0-R1 is consumed.

Before that line, infrastructure/identity failures remain NOT_EVALUATED and do not consume the selection gate.
