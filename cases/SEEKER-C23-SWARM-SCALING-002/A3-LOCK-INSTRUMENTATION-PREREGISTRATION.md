# A3 Lock Instrumentation — One-Shot Preregistration

## Research question

Is the shared POSIX flock a material coordination bottleneck beyond four workers for the frozen Seeker workload?

## Frozen authorities

```text
AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

A2_EVIDENCE_MANIFEST_SHA256=
01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621

A3_PREFLIGHT_MANIFEST_SHA256=
c049138463f19400157ecb58922c7a76e46231cdc9633c0f02630e9e037c5bac

A3_PREFLIGHT_CONSOLE_SHA256=
14cf13fcd2b794c1ba70ec0d7eeaf77ec54fa52c9a950e8d8264e5bc7cbf9d1a
```

## Worker matrix

```text
WORKERS=1,4,8,16
TASKS_PER_SCENARIO=100
REPETITIONS_PER_WORKER=1
```

A3 is a mechanism-observation stage, not a throughput stability stage. A2 already established the throughput shape with 32 repetitions per worker count.

## External instrumentation

The Seeker binary is not modified.

Each individual Seeker invocation is externally wrapped in strace with absolute timestamps and syscall durations for:

```text
flock
rename
renameat
renameat2
```

For each trace file the parser records:

```text
LOCK_EX syscall duration
LOCK_UN syscall duration
rename syscall duration
critical-section residency
successful reservation yes/no
```

Critical-section residency is defined as:

```text
LOCK_UN syscall start timestamp
minus
(LOCK_EX syscall start timestamp + LOCK_EX syscall duration)
```

## Scenario integrity

For every worker count:

```text
INITIAL_QUEUED=100
FINAL_PROCESSING=100
FINAL_QUEUED=0
SUCCESSFUL_RESERVATIONS=100
SUCCESSFUL_RENAMES=100
```

Additional lock acquisitions that find no remaining task are counted separately as futile attempts.

## Aggregates

For successful reservations, A3 computes:

```text
lock wait min/median/mean/p95/max/sum in microseconds
critical-section min/median/mean/p95/max/sum in microseconds
rename min/median/mean/p95/max/sum in microseconds
```

It also computes:

```text
all lock acquisition count
futile acquisition count
futile acquisition ratio

LOCK_WAIT_SHARE_PCT =
100 * successful_lock_wait_sum /
(successful_lock_wait_sum + successful_critical_section_sum)
```

This is a coordination-path share, not a percentage of whole-program wall-clock time.

## Root-cause adjudication

```text
LOCK_CONTENTION_ROOT_CAUSE=SUPPORTED
```

requires all of:

1. 100 successful reservations at 1W, 4W, 8W and 16W.
2. 100 successful rename syscalls at 1W, 4W, 8W and 16W.
3. LOCK_WAIT_SHARE_4W > LOCK_WAIT_SHARE_1W.
4. LOCK_WAIT_SHARE_8W >= LOCK_WAIT_SHARE_4W + 5 percentage points.
5. LOCK_WAIT_SHARE_16W >= LOCK_WAIT_SHARE_4W + 10 percentage points.
6. successful LOCK_EX cumulative wait at 8W >= 1.25 times the 4W cumulative wait.
7. successful LOCK_EX cumulative wait at 16W >= 1.50 times the 4W cumulative wait.
8. The measured direction is consistent with the frozen A2 result that 4W outperformed 8W and 16W.

If any criterion is not met:

```text
LOCK_CONTENTION_ROOT_CAUSE=NOT_CONFIRMED
```

This stage does not claim that flock is the only source of scaling loss.

## Scientific constraints

```text
AGENT_CHANGE=NO
FRONTIER_CHANGE=NO
BATCHING_CHANGE=NO
SHARDING_CHANGE=NO
KYBER_CHANGE=NO
YODA_CHANGE=NO
```

## Interpretation boundary

A3 throughput is diagnostic-only because strace perturbs execution.

A3 throughput must not replace A2 throughput.

## One-execution policy

The A3 execution lock is created immediately before the first traced Seeker invocation.

After:

```text
A3_EXECUTION_GATE=PASS
```

A3 is permanently consumed and must not be rerun.

## Next gate

If root cause is supported:

```text
NEXT_GATE=A4_BATCHED_RESERVATION
```

If root cause is not confirmed:

```text
NEXT_GATE=ROOT_CAUSE_REASSESSMENT
```
