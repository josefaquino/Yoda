# A4 Batched Reservation — Preregistration

## Research question

Does reducing shared-frontier lock acquisitions by reserving up to four tasks per critical-section entry improve Seeker swarm throughput while preserving task-reservation correctness?

## Motivation from frozen evidence

A2 established the performance shape for the frozen agent:

```text
MEDIAN_1W_TPS=275.598472
MEDIAN_4W_TPS=594.324627
MEDIAN_8W_TPS=557.457678
MEDIAN_16W_TPS=513.164949

A2_4_8_CLASSIFICATION=4_WORKER_CLEARLY_ABOVE_8
A2_16W_CLASSIFICATION=REGRESSION
```

A3 directly measured shared-lock waiting:

```text
LOCK_WAIT_SHARE_1W_PCT=2.673
LOCK_WAIT_SHARE_4W_PCT=14.482
LOCK_WAIT_SHARE_8W_PCT=59.931
LOCK_WAIT_SHARE_16W_PCT=87.137

LOCK_WAIT_SUM_8W_VS_4W_RATIO=15.629
LOCK_WAIT_SUM_16W_VS_4W_RATIO=94.407

LOCK_CONTENTION_ROOT_CAUSE=SUPPORTED
```

## Frozen baseline authorities

```text
CONTROL_AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

A2_EVIDENCE_MANIFEST_SHA256=
01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621

A3_EVIDENCE_MANIFEST_SHA256=
fef59c315bc2bef4f45f47bc15e214667c6b97ae7ed4548bc4cad542233e3c29
```

## Single engineering change

```text
CHANGE_UNDER_TEST=BATCHED_RESERVATION
BATCH_SIZE=4

SHARDING_CHANGE=NO
FRONTIER_SCHEMA_CHANGE=NO
TASK_SET_CHANGE=NO
BIOME_DISTRIBUTION_CHANGE=NO
KYBER_CHANGE=NO
YODA_CHANGE=NO
```

The candidate must reserve at most four QUEUED tasks while holding one existing shared frontier lock.

The candidate must preserve the existing transition semantics:

```text
QUEUED -> PROCESSING
owner = seeker_<agent-id>
timestamp = current reservation timestamp
```

No new lock, shard, queue or frontier format may be introduced.

## Why batch size 4

For 100 tasks, batch size four creates 25 useful batches.

This is large enough to reduce successful critical-section entries by approximately four times while still providing more batches than the maximum tested concurrency of 16 workers.

A4 does not perform a batch-size sweep. Choosing among multiple batch sizes would introduce another experimental dimension.

## Stages

### A4-R0 — Source authority

Before any source modification:

1. freeze exact identities of main.c, yoda_agent_driver.c, yoda_agent_driver.h and Makefile;
2. rebuild those sources in an isolated temporary directory;
3. require the rebuilt binary to be byte-identical to the frozen control binary;
4. capture the exact source text as evidence.

If byte-identical rebuild fails:

```text
A4_SOURCE_AUTHORITY=NOT_ESTABLISHED
A4_ENGINEERING_CHANGE=BLOCKED
```

### A4-R1 — Candidate build and semantic validation

Create candidate sources from the frozen source authority.

Only the reservation API/implementation and the minimal caller adaptation required to consume up to four reserved tasks may change.

Require:

```text
CONTROL_SOURCE_UNCHANGED=YES
CANDIDATE_BUILDS=YES
BATCH_SIZE=4
100_TASKS_RESERVED_EXACTLY_ONCE=YES
FINAL_PROCESSING=100
FINAL_QUEUED=0
TASK_IDENTITY_PRESERVED=YES
BIOME_COUNTS_PRESERVED=YES
```

No performance conclusion is drawn from R1.

### A4-R2 — Same-session controlled performance

Compare frozen control and candidate in the same session.

```text
ARMS=CONTROL,CANDIDATE
WORKERS=1,4,8,16
REPETITIONS_PER_ARM_PER_WORKER=16
TASKS_PER_SCENARIO=100
```

Use a deterministic balanced interleaving so both arms and worker counts experience comparable run-order effects.

Primary metric:

```text
median throughput tasks/s
```

Secondary metrics:

```text
mean
p95
sample standard deviation
```

## A4 performance adjudication

Candidate is classified:

```text
BATCHED_RESERVATION_PERFORMANCE=SUPPORTED
```

if all are true:

1. semantic correctness passes for every measured scenario;
2. candidate median 8W throughput is at least 20 percent above same-session control 8W;
3. candidate median 16W throughput is at least 20 percent above same-session control 16W;
4. candidate median 4W throughput is not more than 5 percent below same-session control 4W;
5. candidate median 1W throughput is not more than 10 percent below same-session control 1W.

Otherwise:

```text
BATCHED_RESERVATION_PERFORMANCE=NOT_SUPPORTED
```

These are engineering-effect thresholds, not inferential-statistics claims.

## Interpretation boundary

A4 tests whether one implementation change mitigates the measured bottleneck.

A positive A4 does not prove optimal batch size.

A negative A4 does not invalidate A3; it means this particular batch-size-four implementation failed to improve the system under the preregistered criteria.

## Next gate

If supported:

```text
NEXT_GATE=A5_BATCH_LOCK_DIAGNOSTIC
```

If not supported:

```text
NEXT_GATE=BATCHED_RESERVATION_REASSESSMENT
```
