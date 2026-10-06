# A1-R1 Re-execution Attempt — Correctly Blocked

## Context

A1-R1 had already completed successfully under its one-execution policy.

Official prior scientific verdict:

```text
TAU2_OUTCOME_EQUIVALENT_DERIVATIONS_001_STAGE_A1=PASS
A1_REVISION=A1-R1

A1_EXECUTION_LOCK_SHA256=
e047439babba668a4bfa9a408e6a58afb926e7ca0e029f4526ace064611cfa2d

A1_EVIDENCE_MANIFEST_SHA256=
d9ff35821c0b69d642a42e2653b8841c919e62477e9d0867bb0556af12edb0fd

A1_R1_RERUN=NO
```

## Subsequent invocation

A later invocation of the same frozen A1-R1 script was attempted after the one-execution lock had already been consumed.

The script stopped immediately with:

```text
FAILURE_CLASS=A1_EXECUTION_POLICY_ALREADY_CONSUMED

TRAJECTORY_A_EXECUTED=NO
TRAJECTORY_B_EXECUTED=NO
EXTERNAL_JUDGE_EXECUTED=NO
MODEL_ENDPOINT_CALLED=NO
USER_SIMULATOR_EXECUTED=NO
YODA_WRITES=ZERO
```

This invocation did not execute any scientific workload and does not constitute a new A1 result.

## Adjudication

```text
REEXECUTION_ATTEMPT=BLOCKED
SCIENTIFIC_REEXECUTION=NO
ORIGINAL_A1_VERDICT=PRESERVED_PASS
ORIGINAL_A1_EVIDENCE_PRESERVED=YES
A1_R1_RERUN=NO
NEXT_GATE=A2_R0_CAPACITY_PREFLIGHT
```

## Diagnostic wording note

The frozen harness's pre-lock abort function emits:

```text
A1_EXECUTION_LOCK_CONSUMED=NO
```

even for `A1_EXECUTION_POLICY_ALREADY_CONSUMED`.

For this blocked invocation, that line means the new invocation itself did not consume a lock. It must not be interpreted as saying the existing A1 one-shot lock is absent or unconsumed.

The authoritative lock identity remains:

```text
e047439babba668a4bfa9a408e6a58afb926e7ca0e029f4526ace064611cfa2d
```
