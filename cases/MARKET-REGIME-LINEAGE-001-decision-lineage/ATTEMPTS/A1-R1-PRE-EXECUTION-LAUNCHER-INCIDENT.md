# A1-R1 — Pre-execution launcher incident

## Adjudication

```text
A1_R1_SCIENTIFIC_EXECUTION=NOT_STARTED
A1_R1_EXECUTION_LOCK=ABSENT
STAGE_A1_R1=NOT_CREATED
CONSOLE=NOT_CREATED
CANONICAL_RESULTS=NOT_CREATED
A1_MANIFEST=NOT_CREATED
```

The local script observed during read-only adjudication had:

```text
LOCAL_SCRIPT_SHA256=
0c891fb1565f42e01943c13def49473b9e515a66653b0f88a479ca065b89a440
```

The frozen canonical GitHub authority remains:

```text
CANONICAL_A1_R1_SCRIPT_SHA256=
a9d04c9ceff162911a4a3606d68d747b82df0de69db686d47c4a6ef6115ca13c
```

Therefore the direct-shell launcher did not reach the A1 one-execution gate.

Classification:

```text
INCIDENT_CLASS=PRE_EXECUTION_SCRIPT_IDENTITY_MISMATCH
A1_R1_RESULT=NOT_EVALUATED_BECAUSE_NOT_STARTED
A1_ONE_EXECUTION_GATE_CONSUMED=NO
RERUN_OF_SCIENTIFIC_A1=NOT_APPLICABLE
FRESH_FIRST_EXECUTION_STILL_AUTHORIZED=YES
YODA_WRITES=ZERO
```

The next launcher must execute as a child shell so its own exit behavior cannot close the interactive terminal.
