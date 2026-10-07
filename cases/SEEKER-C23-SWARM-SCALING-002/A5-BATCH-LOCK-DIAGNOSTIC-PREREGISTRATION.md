# A5 Batch Lock Diagnostic — Preregistration

## Research question

Did the validated batch-size-four implementation reduce the physical shared-lock coordination path, not merely improve end-to-end throughput?

## Frozen authorities

```text
CONTROL_BINARY_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

CANDIDATE_BINARY_SHA256=
0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

A3_ANALYZER_SHA256=
cfc81aa6df07533865e44c7ec4cc1bffcf15dfda922bc553533db66e4e1534d9

A4_R2_EVIDENCE_MANIFEST_SHA256=
a35f380aa7f53e798700cd74a29d2f4a277cace5ff843196de1abccc3de2bfcc

STRACE_VERSION=
strace -- version 6.13
```

## Matrix

```text
ARMS=CONTROL,CANDIDATE
WORKERS=1,4,8,16
REPETITIONS_PER_ARM_PER_WORKER=4
MEASURED_SCENARIOS=32
TASKS_PER_SCENARIO=100
```

A5 is diagnostic-only. It does not replace A4-R2 as the performance authority.

## Instrumentation

Every direct Seeker invocation is wrapped externally with:

```text
strace -qq -ttt -T -e trace=flock,rename,renameat,renameat2
```

The frozen A3 trace analyzer is reused without modification.

For each trace file, the analyzer records:

```text
LOCK_EX duration
LOCK_UN duration
critical-section residency
rename duration
useful invocation yes/no
```

A useful invocation is one whose trace contains a successful rename operation.

## Expected structural effect

For exactly 100 tasks:

```text
CONTROL_USEFUL_INVOCATIONS_EXPECTED=100
CANDIDATE_USEFUL_INVOCATIONS_EXPECTED=25
```

because the control reserves one task per useful invocation while the candidate reserves four.

Futile invocations are counted separately and are not treated as useful work.

## Per-scenario correctness

Every scenario must end with:

```text
LINES=100
PROCESSING=100
QUEUED=0
BAD_FIELD_COUNT=0
BAD_STATE_COUNT=0
BAD_OWNER_COUNT=0
TASK_IDENTITY_SHA256=frozen identity
BIOME_COUNTS=20,20,20,20,20
```

## Per-scenario lock metrics

For all valid trace files:

```text
TOTAL_LOCK_ATTEMPTS
USEFUL_LOCK_ATTEMPTS
FUTILE_LOCK_ATTEMPTS
ALL_LOCK_WAIT_SUM_US
ALL_CRITICAL_SUM_US
ALL_LOCK_WAIT_SHARE_PCT
```

where:

```text
ALL_LOCK_WAIT_SHARE_PCT =
100 * ALL_LOCK_WAIT_SUM_US /
(ALL_LOCK_WAIT_SUM_US + ALL_CRITICAL_SUM_US)
```

This is a coordination-path share, not whole-program wall time.

## Aggregate statistics

For each arm/worker pair across four repetitions:

```text
median useful lock attempts
median futile lock attempts
median all-lock-wait sum
median all-lock-wait share
```

## Preregistered adjudication

```text
A5_BATCH_LOCK_MECHANISM=SUPPORTED
```

requires all of:

1. semantic correctness passes in all 32 scenarios;
2. control useful lock attempts = 100 in every measured scenario;
3. candidate useful lock attempts = 25 in every measured scenario;
4. at 8W, candidate median all-lock-wait sum <= 50 percent of control;
5. at 16W, candidate median all-lock-wait sum <= 50 percent of control;
6. at 8W, candidate median all-lock-wait share is at least 20 percentage points below control;
7. at 16W, candidate median all-lock-wait share is at least 20 percentage points below control.

Otherwise:

```text
A5_BATCH_LOCK_MECHANISM=NOT_SUPPORTED
```

These are engineering-effect thresholds.

## Interpretation boundary

A positive A5 supports the claim that batch-size-four materially reduces the measured shared-lock coordination path.

A5 does not claim that all A4-R2 throughput gain is caused by lower flock waiting. Batching also reduces process launches and frontier scans.

## One-shot policy

After:

```text
A5_EXECUTION_GATE=PASS
```

the stage is permanently consumed.

## Next gate

If supported:

```text
NEXT_GATE=A6_CASE_HOMOLOGATION
```

If not supported:

```text
NEXT_GATE=MECHANISM_REASSESSMENT
```
