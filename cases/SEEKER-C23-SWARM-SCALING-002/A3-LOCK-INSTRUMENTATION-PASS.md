# A3 Lock Instrumentation — PASS

## Verdict

```text
CASE=SEEKER-C23-SWARM-SCALING-002
REVISION=A3-LOCK-INSTRUMENTATION-001

A3_LOCK_INSTRUMENTATION=PASS
LOCK_CONTENTION_ROOT_CAUSE=SUPPORTED

A3_THROUGHPUT_ROLE=DIAGNOSTIC_ONLY
AGENT_CHANGE=NO
FRONTIER_CHANGE=NO
BATCHING_CHANGE=NO
SHARDING_CHANGE=NO
KYBER_CHANGE=NO
YODA_CHANGE=NO

A3_RERUN=NO
NEXT_GATE=A4_BATCHED_RESERVATION
```

## Frozen authorities

```text
AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

A2_MANIFEST_SHA256=
01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621

A3_PREFLIGHT_MANIFEST_SHA256=
c049138463f19400157ecb58922c7a76e46231cdc9633c0f02630e9e037c5bac

STRACE_VERSION=strace -- version 6.13

ANALYZER_SHA256=
cfc81aa6df07533865e44c7ec4cc1bffcf15dfda922bc553533db66e4e1534d9
```

## One-shot authority

```text
A3_EXECUTION_LOCK_SHA256=
a600d27bbdbe3c45725a57544c205ddf74a8ff473bebcfb80fbb2bcf183d0a2d

A3_HARNESS_SHA256=
95b8bd1b67d40298d155ff0b2f07edc57c92673dce3060d829c4340d9bcbbbca

A3_CONSOLE_SHA256=
9cd817703e65f08c8297602cca45deb6b65677f03966d151d2d6e9544f10fae1

A3_EVIDENCE_MANIFEST_SHA256=
fef59c315bc2bef4f45f47bc15e214667c6b97ae7ed4548bc4cad542233e3c29
```

## Direct measurements

| Workers | Successful reservations | Futile attempts | Lock wait median us | Lock wait p95 us | Lock wait sum us | Lock-wait share |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 100 | 0 | 18.0 | 126.0 | 4,449 | 2.673% |
| 4 | 100 | 2 | 19.0 | 1,726.0 | 30,814 | 14.482% |
| 8 | 100 | 6 | 3,462.5 | 17,106.0 | 481,579 | 59.931% |
| 16 | 100 | 14 | 32,382.5 | 53,824.0 | 2,909,043 | 87.137% |

```text
LOCK_WAIT_SUM_8W_VS_4W_RATIO=15.629
LOCK_WAIT_SUM_16W_VS_4W_RATIO=94.407
```

## Preregistered adjudication

```text
CRITERION_3_SHARE_4_GT_1=PASS
CRITERION_4_SHARE_8_GE_4_PLUS_5PP=PASS
CRITERION_5_SHARE_16_GE_4_PLUS_10PP=PASS
CRITERION_6_SUMWAIT_8_GE_1_25X_4=PASS
CRITERION_7_SUMWAIT_16_GE_1_50X_4=PASS
A2_DIRECTION_CONSISTENCY=PASS

LOCK_CONTENTION_ROOT_CAUSE=SUPPORTED
```

## Scientific interpretation

For the frozen 100-task workload and frozen Seeker binary, direct syscall tracing supports the shared POSIX flock as a material coordination bottleneck once concurrency rises beyond four workers.

The evidence is not only a parallel-efficiency proxy: A3 directly measured flock acquisition durations.

The result does not establish flock as the only source of scaling loss. Critical-section residence also grows with concurrency and strace perturbs timing, so A3 diagnostic throughput must not replace the uninstrumented A2 throughput measurements.

The next engineering experiment is therefore one isolated change:

```text
A4_CHANGE_UNDER_TEST=BATCHED_RESERVATION
SHARDING_CHANGE=NO
```
