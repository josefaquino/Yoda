# A5 Batch Lock Diagnostic — PASS / Mechanism Criterion NOT_SUPPORTED

## Frozen verdict

```text
A5_BATCH_LOCK_DIAGNOSTIC=PASS
A5_BATCH_LOCK_MECHANISM=NOT_SUPPORTED
A5_THROUGHPUT_ROLE=DIAGNOSTIC_ONLY
MEASURED_SCENARIOS=32
A5_RERUN=NO
NEXT_GATE=MECHANISM_REASSESSMENT
```

The diagnostic execution itself passed. The preregistered composite mechanism claim did not.

## Frozen authorities

```text
CONTROL_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

CANDIDATE_SHA256=
0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

R2_MANIFEST_SHA256=
a35f380aa7f53e798700cd74a29d2f4a277cace5ff843196de1abccc3de2bfcc

ANALYZER_SHA256=
cfc81aa6df07533865e44c7ec4cc1bffcf15dfda922bc553533db66e4e1534d9

STRACE_VERSION=strace -- version 6.13
```

## Structural batch effect

Across all measured scenarios:

```text
CONTROL_USEFUL_ATTEMPTS_EXACT_100_ALL=PASS
CANDIDATE_USEFUL_ATTEMPTS_EXACT_25_ALL=PASS
```

The batch-size-four candidate therefore reduced useful reservation/rename invocations by exactly 75 percent for the frozen 100-task workload.

## Absolute lock-wait reduction

At 8 workers:

```text
CONTROL_MEDIAN_WAIT_SUM_US=304186.500
CANDIDATE_MEDIAN_WAIT_SUM_US=82139.000
CANDIDATE_VS_CONTROL_RATIO=0.270
ABSOLUTE_WAIT_REDUCTION=73.0%
```

At 16 workers:

```text
CONTROL_MEDIAN_WAIT_SUM_US=3040957.500
CANDIDATE_MEDIAN_WAIT_SUM_US=570704.500
CANDIDATE_VS_CONTROL_RATIO=0.188
ABSOLUTE_WAIT_REDUCTION=81.2%
```

Both absolute-wait preregistered criteria passed.

## Normalized lock-wait share

At 8 workers:

```text
CONTROL_MEDIAN_WAIT_SHARE_PCT=56.892
CANDIDATE_MEDIAN_WAIT_SHARE_PCT=56.460
DELTA_PP=-0.432
PREREGISTERED_REQUIREMENT=-20.000 pp
RESULT=FAIL
```

At 16 workers:

```text
CONTROL_MEDIAN_WAIT_SHARE_PCT=90.191
CANDIDATE_MEDIAN_WAIT_SHARE_PCT=87.237
DELTA_PP=-2.954
PREREGISTERED_REQUIREMENT=-20.000 pp
RESULT=FAIL
```

Therefore:

```text
CRITERION_8W_WAIT_SHARE_MINUS_20PP=FAIL
CRITERION_16W_WAIT_SHARE_MINUS_20PP=FAIL

A5_BATCH_LOCK_MECHANISM=NOT_SUPPORTED
```

## One-shot and evidence

```text
A5_EXECUTION_LOCK_SHA256=
84f7fec5337b84b8783def035edbac9fa1275f030a36ae3e42dd558ea6b6f4f2

A5_HARNESS_SHA256=
88265ab94b72ce027c3379afab980816b517e3db1c623b2b20d75d18c03a7963

A5_CONSOLE_SHA256=
6ccae20ce9a1b267abf02b081180416c31e00b266b52e0e5924db8fa07bd1343

A5_EVIDENCE_MANIFEST_SHA256=
6dffe3a9bd5d72324c9843103cb23ecba8cc514c1adf4fdca3ebe05a0327de1b
```

## Scientific interpretation

The batch-size-four implementation demonstrably reduced how often useful global-lock reservations occurred and materially reduced cumulative lock waiting.

However, among the remaining coordination work, waiting still occupied approximately the same dominant fraction at 8 and 16 workers. The preregistered 20-percentage-point normalized-share reduction did not occur.

This means the strongest supported mechanism statement is narrower:

> Batching reduced the frequency and absolute cost of shared-lock coordination, but did not eliminate the contention intensity of the remaining global-lock path.

This result is compatible with A3 and A4-R2. A3 established that the shared flock is a material bottleneck in the original implementation. A4-R2 established that batch-size-four materially improves end-to-end throughput. A5 shows that batching mitigates absolute lock burden without removing the underlying serialization pressure.

The A5 preregistered verdict remains NOT_SUPPORTED and must not be rewritten as PASS.
