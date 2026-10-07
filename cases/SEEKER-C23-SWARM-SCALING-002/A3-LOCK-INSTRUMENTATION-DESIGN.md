# A3 Lock Instrumentation — Design Freeze

## Research question

Does measured waiting on the shared POSIX flock increase with worker concurrency strongly enough to identify the global frontier lock as a material coordination bottleneck?

## Frozen scientific authorities

AGENT_SHA256=dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

A2_MEDIAN_1W_TPS=275.598472
A2_MEDIAN_4W_TPS=594.324627
A2_MEDIAN_8W_TPS=557.457678
A2_MEDIAN_16W_TPS=513.164949

A2_4_8_CLASSIFICATION=4_WORKER_CLEARLY_ABOVE_8
A2_16W_CLASSIFICATION=REGRESSION

## Instrumentation

The frozen Seeker binary is not modified.

Each agent invocation is observed externally with strace using:
- absolute timestamps;
- syscall durations;
- flock;
- rename.

For every successful reservation the analysis will derive:
- exclusive lock acquisition syscall duration;
- lock release syscall duration;
- rename syscall duration;
- critical-section residency from successful LOCK_EX completion to LOCK_UN entry.

## Worker matrix

WORKERS=1,4,8,16

A3 throughput is diagnostic only because strace perturbs execution. A3 throughput must not replace A2 throughput.

## Primary measurements

For each worker count:
- successful LOCK_EX count;
- total, mean, median and p95 LOCK_EX duration;
- critical-section total, mean, median and p95;
- rename count and duration;
- lock-wait share proxy = cumulative LOCK_EX duration / sum of observed per-reservation critical-path time.

## Root-cause adjudication

LOCK_CONTENTION_ROOT_CAUSE=SUPPORTED if:
1. exactly 100 reservations are observed at every worker count;
2. 1W LOCK_EX wait is near-zero relative to higher concurrency;
3. cumulative or median LOCK_EX duration rises materially with concurrency;
4. 8W and/or 16W show materially larger lock wait than 4W;
5. the direction is consistent with the A2 scaling regression.

Otherwise:
LOCK_CONTENTION_ROOT_CAUSE=NOT_CONFIRMED

A3 does not claim that flock is the only source of coordination loss.

## Constraints

AGENT_CHANGE=NO
FRONTIER_CHANGE=NO
BATCHING_CHANGE=NO
SHARDING_CHANGE=NO
KYBER_CHANGE=NO
YODA_CHANGE=NO

NEXT_ENGINEERING_GATE_IF_SUPPORTED=BATCHED_RESERVATION_EXPERIMENT
