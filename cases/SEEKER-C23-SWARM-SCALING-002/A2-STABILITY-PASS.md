# A2 Stability — PASS

## Verdict

```text
CASE=SEEKER-C23-SWARM-SCALING-002
REVISION=A2-STABILITY-001
A2_STABILITY=PASS

REPETITIONS_PER_WORKER=32
MEASURED_SCENARIOS=128

A2_4_8_CLASSIFICATION=4_WORKER_CLEARLY_ABOVE_8
A2_16W_CLASSIFICATION=REGRESSION

ENGINEERING_CHANGE=NO
LOCK_CONTENTION_ROOT_CAUSE=NOT_MEASURED_IN_A2

A2_RERUN=NO
NEXT_GATE=A3_LOCK_INSTRUMENTATION
```

## Frozen authorities

```text
AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28
```

## One-execution authority

```text
A2_EXECUTION_LOCK_SHA256=
ce1845b2d1b72171c48132c4e6a878745e8227fa4bba6887eb549a86906af852

A2_HARNESS_SHA256=
530e6852e5d8b515f163255fae1327963f39944b1aa7ad663d2791e21467e5a1

A2_CONSOLE_SHA256=
45ccb8656330d3c5a95c8a011071ddfbb1db67a6bc9b148488fb8de328d4306b

A2_EVIDENCE_MANIFEST_SHA256=
01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621
```

## Statistical summary

| Workers | N | Median TPS | Mean TPS | P95 TPS | SD TPS |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 32 | 275.598472 | 269.384365 | 286.395088 | 22.246672 |
| 4 | 32 | 594.324627 | 586.669237 | 677.667469 | 70.673960 |
| 8 | 32 | 557.457678 | 554.411113 | 616.116372 | 51.482371 |
| 16 | 32 | 513.164949 | 501.308414 | 545.494218 | 62.740108 |

```text
MEDIAN_SPEEDUP_4W=2.156x
MEDIAN_SPEEDUP_8W=2.023x
MEDIAN_SPEEDUP_16W=1.862x

MEDIAN_8W_VS_4W_DELTA_PCT=-6.203
```

## Interpretation

Under the preregistered 5 percent engineering-effect threshold, 4 workers are clearly above 8 workers for this frozen workload and binary.

16 workers are classified as a regression relative to the best 4/8 worker median.

This stage measures stability only. It does not establish flock as the root cause of the observed scaling loss.
