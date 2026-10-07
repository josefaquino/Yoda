# A4-R2 Controlled Performance — Execution Contract

## Frozen arms

```text
CONTROL_BINARY_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

CANDIDATE_BINARY_SHA256=
0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f

CANDIDATE_BATCH_SIZE=4

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

A4_R1_EVIDENCE_MANIFEST_SHA256=
9c6a75e473295009978d3f5e1d5972d26eee1a434d8df61e58568e7a159a8c46
```

## Matrix

```text
ARMS=CONTROL,CANDIDATE
WORKERS=1,4,8,16
REPETITIONS_PER_ARM_PER_WORKER=16
MEASURED_SCENARIOS=128
WARMUPS=8
TASKS_PER_SCENARIO=100
```

## Balanced order

Worker order rotates through four sequences:

```text
S1 = 1 4 16 8
S2 = 4 8 1 16
S3 = 8 16 4 1
S4 = 16 1 8 4
```

The sequences repeat for 16 rounds, so each worker count appears in each position four times.

Arm order alternates by round:

```text
odd rounds  = CONTROL then CANDIDATE
even rounds = CANDIDATE then CONTROL
```

Therefore every worker count receives eight CONTROL-first and eight CANDIDATE-first pairings.

## Isolation

Every scenario runs in its own directory with its own byte-identical frontier copy.

The frozen project frontier is read only and must remain unchanged.

No strace, perf or profiler is used in R2.

## Per-scenario correctness gate

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

Any semantic failure makes R2 NOT_EVALUATED after the one-shot gate; the stage is not rerun.

## Primary statistic

Median throughput in tasks per second for each arm/worker pair.

Secondary descriptive statistics:

```text
minimum
mean
p95
maximum
sample standard deviation
```

## Preregistered engineering adjudication

```text
C8  = candidate median 8W  >= control median 8W  * 1.20
C16 = candidate median 16W >= control median 16W * 1.20
C4  = candidate median 4W  >= control median 4W  * 0.95
C1  = candidate median 1W  >= control median 1W  * 0.90
```

If all four pass:

```text
BATCHED_RESERVATION_PERFORMANCE=SUPPORTED
```

Otherwise:

```text
BATCHED_RESERVATION_PERFORMANCE=NOT_SUPPORTED
```

These are engineering-effect thresholds, not inferential-statistics claims.

## Interpretation boundary

A positive result supports the batch-size-four implementation as a performance improvement for this frozen workload.

It does not establish batch size four as globally optimal.

Because batching also reduces repeated process launches and frontier scans in the current shell orchestration, R2 does not partition the gain into flock-wait reduction versus launch/scan reduction.

## One-shot

After:

```text
A4_R2_EXECUTION_GATE=PASS
```

the R2 execution is permanently consumed.

## Next gate

If supported:

```text
NEXT_GATE=A5_BATCH_LOCK_DIAGNOSTIC
```

If not supported:

```text
NEXT_GATE=BATCHED_RESERVATION_REASSESSMENT
```
