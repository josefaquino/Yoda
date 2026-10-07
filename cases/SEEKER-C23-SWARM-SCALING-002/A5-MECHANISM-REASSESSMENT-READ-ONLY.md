# A5 Mechanism Reassessment — Read Only

## Status

```text
REASSESSMENT_MODE=READ_ONLY
NEW_SEEKER_EXECUTION=NO
NEW_PERFORMANCE_RUN=NO
A5_RERUN=NO
A5_PREREGISTERED_VERDICT_CHANGED=NO
```

## Frozen A5 verdict

```text
A5_BATCH_LOCK_DIAGNOSTIC=PASS
A5_BATCH_LOCK_MECHANISM=NOT_SUPPORTED
```

The composite A5 mechanism claim remains NOT_SUPPORTED because the preregistered normalized lock-wait-share thresholds failed.

## Decomposition of the observed mechanism

The frozen A5 evidence supports four distinct statements:

```text
BATCH_USEFUL_LOCK_FREQUENCY_REDUCTION=SUPPORTED
ABSOLUTE_LOCK_WAIT_REDUCTION=SUPPORTED
NORMALIZED_WAIT_SHARE_REDUCTION_20PP=NOT_SUPPORTED
RESIDUAL_GLOBAL_LOCK_CONTENTION=SUPPORTED
```

### 1. Useful global-lock frequency

```text
CONTROL_USEFUL_ATTEMPTS=100
CANDIDATE_USEFUL_ATTEMPTS=25
REDUCTION=75%
```

This effect held in every measured scenario.

### 2. Absolute cumulative lock waiting

At 8 workers:

```text
CONTROL_MEDIAN_WAIT_SUM_US=304186.500
CANDIDATE_MEDIAN_WAIT_SUM_US=82139.000
CANDIDATE_VS_CONTROL_RATIO=0.270
REDUCTION=73.0%
```

At 16 workers:

```text
CONTROL_MEDIAN_WAIT_SUM_US=3040957.500
CANDIDATE_MEDIAN_WAIT_SUM_US=570704.500
CANDIDATE_VS_CONTROL_RATIO=0.188
REDUCTION=81.2%
```

### 3. Normalized wait share

At 8 workers:

```text
CONTROL=56.892%
CANDIDATE=56.460%
DELTA=-0.432 pp
```

At 16 workers:

```text
CONTROL=90.191%
CANDIDATE=87.237%
DELTA=-2.954 pp
```

The preregistered requirement was a reduction of at least 20 percentage points at each worker count. It failed.

## Interpretation

There is no contradiction between a large reduction in absolute lock waiting and a nearly unchanged lock-wait share.

Batching changes the number of useful critical-section entries. It can substantially reduce total waiting across the 100-task workload while the remaining entries are still heavily serialized under high concurrency.

Therefore the strongest bounded conclusion is:

> Batch-size-four materially reduces the frequency and cumulative cost of shared-lock coordination, but does not remove the contention intensity of the remaining single-global-lock design.

This explains why A4-R2 can show large end-to-end gains while A5's normalized wait-share criterion still fails.

## Relationship to prior stages

```text
A3:
shared flock is a material bottleneck in the original implementation
= SUPPORTED

A4-R2:
batch-size-four materially improves same-session throughput
= SUPPORTED

A5:
composite criterion requiring both absolute reduction and >=20 pp share reduction
= NOT_SUPPORTED

READ-ONLY REASSESSMENT:
batch frequency reduction and absolute wait reduction
= SUPPORTED

remaining global-lock contention intensity
= STILL PRESENT
```

## Decision

No A5 rerun is justified.

No new performance benchmark is required to answer the current CASE question.

A future sharding experiment may test whether removing the single global frontier lock improves scaling further, but that is a separate engineering change and should not be folded into this CASE result.

```text
MECHANISM_REASSESSMENT=RESOLVED_MIXED
A5_VERDICT_REWRITTEN=NO
NEXT_GATE=A6_CASE_HOMOLOGATION
```
