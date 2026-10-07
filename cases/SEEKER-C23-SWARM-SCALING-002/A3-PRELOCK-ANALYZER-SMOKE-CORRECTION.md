# A3 Lock Instrumentation — Pre-lock Analyzer Smoke Correction

## Classification

```text
STATUS=NOT_EVALUATED_PRELOCK
A3_EXECUTION_GATE_REACHED=NO
A3_EXECUTION_LOCK_CONSUMED=NO
SEEKER_SCIENTIFIC_EXECUTION=NO
MEASURED_SCENARIOS=0
```

## Observed pre-lock failure

```text
ANALYZER_SMOKE_VALID_ROWS=0
ANALYZER_SMOKE_SUCCESS_ROWS=1
FAILURE_CLASS=ANALYZER_SMOKE_VALIDATION_FAILURE
```

The failed A3 launcher/harness identities were:

```text
SUPERSEDED_A3_HARNESS_SHA256=
00f9e2be1af0621895b3f78c4d6d760cbfd48b46bf0369a8d3950d2b6768b9d3

FAILED_PRELOCK_CONSOLE_SHA256=
3111f52dc0aa1229426209958b537e53eb407e56d96e708d22fa6c1062837bfd
```

## Cause

The A3 preflight smoke had been produced with `strace -ff` around a shell workflow.

Therefore the observed LOCK_EX, renameat2, and LOCK_UN syscalls were stored in different per-process trace files.

The scientific A3 analyzer intentionally treats one trace file as one direct Seeker invocation and requires LOCK_EX and LOCK_UN in the same trace file.

Applying that analyzer directly to the fragmented preflight files produced a false pre-lock validation failure.

## Correction

The pre-lock smoke validation now reassembles the already-observed preflight LOCK_EX, rename, and LOCK_UN syscall lines into one timestamp-ordered synthetic trace before validating the frozen analyzer.

No Seeker is executed by this correction.

```text
CORRECTED_A3_HARNESS_COMMIT=
64c12beac634151e1ed8a1e1942ed66fdefeba52

CORRECTED_A3_HARNESS_SHA256=
1f7354c8dd44011ed1f70da97d8cf79c8ca47094dc0daba20092fc0838c9caae

ANALYZER_SHA256=
cfc81aa6df07533865e44c7ec4cc1bffcf15dfda922bc553533db66e4e1534d9
```

## Scientific boundary

```text
SCIENTIFIC_DESIGN_CHANGE=NO
ROOT_CAUSE_CRITERIA_CHANGE=NO
ANALYZER_CHANGE=NO
AGENT_CHANGE=NO
FRONTIER_CHANGE=NO
A3_ONE_SHOT_CONSUMED=NO
```

The A3 preregistration remains unchanged.
