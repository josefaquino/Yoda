# SEEKER-C23-SWARM-SCALING-002 — A2 Stability Preregistration

## Question

Is the single-run 4-to-8 worker throughput difference reproducible, or are 4 and 8 workers part of the same performance plateau?

## Frozen authorities

AGENT_SHA256=dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

CANONICAL_FRONTIER_SHA256=c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

TASK_COUNT=100
BIOME_COUNT=5
WORKERS=1,4,8,16
REPETITIONS_PER_WORKER=32

## Measurement design

The experiment uses a deterministic balanced four-sequence Williams-style order:

1 4 16 8
4 8 1 16
8 16 4 1
16 1 8 4

The four sequences repeat for eight cycles, giving 32 measured runs per worker count and 128 measured scenarios total.

One warmup run per worker count is performed before measured runs and excluded from statistics.

Each measured scenario:
- restores the exact canonical frontier;
- requires exactly 100 QUEUED tasks before execution;
- runs the frozen agent binary;
- requires exactly 100 PROCESSING and 0 QUEUED after execution;
- records elapsed wall-clock time and throughput.

## Statistics

For each worker count:
- n
- minimum throughput
- median throughput
- mean throughput
- p95 throughput
- maximum throughput
- sample standard deviation

The primary comparison is median throughput.

## Adjudication

A2 does not declare a statistically significant difference in the inferential-statistics sense.

Operational classification:

- 8_WORKER_CLEARLY_ABOVE_4 if median(8) >= median(4) * 1.05
- 4_WORKER_CLEARLY_ABOVE_8 if median(4) >= median(8) * 1.05
- otherwise 4_8_PLATEAU

The 5% band is preregistered as an engineering-effect threshold, not a p-value.

16-worker regression is classified relative to the best of median(4) and median(8):
- REGRESSION if median(16) < best * 0.95
- otherwise NOT_RESOLVED

## Constraints

ONE_ENGINEERING_CHANGE=NO
AGENT_CHANGE=NO
FRONTIER_CHANGE=NO
BATCHING_CHANGE=NO
SHARDING_CHANGE=NO
LOCK_INSTRUMENTATION=NO

A2 measures stability only.

NEXT_GATE=A3_LOCK_INSTRUMENTATION
