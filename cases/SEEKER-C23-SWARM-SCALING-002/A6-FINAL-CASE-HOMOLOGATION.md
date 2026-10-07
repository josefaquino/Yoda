# A6 — Final Case Homologation

## Status

```text
CASE=SEEKER-C23-SWARM-SCALING-002

FINAL_CASE_HOMOLOGATION=PASS
CASE_STATUS=COMPLETE
CASE_SCOPE_COMPLETE=YES

NEW_SCIENTIFIC_EXECUTION=NO
NEW_ENGINEERING_CHANGE=NO
READ_ONLY_HOMOLOGATION=YES
```

A6 is a documentation and adjudication freeze only. It introduces no new benchmark, workload, implementation, or engine change.

## Frozen baseline

```text
CONTROL_AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

CANONICAL_FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

TASK_COUNT=100
BIOME_COUNT=5
```

## Stage verdicts

```text
PRE_A0=PASS_AFTER_SCHEMA_RECONSTRUCTION
A1_APPLES_TO_APPLES=PASS
A2_STABILITY=PASS_CONSUMED
A3_LOCK_INSTRUMENTATION=PASS_CONSUMED
A4_R1_CANDIDATE_BUILD=PASS_CONSUMED
A4_R2_CONTROLLED_PERFORMANCE=PASS_CONSUMED
A5_BATCH_LOCK_DIAGNOSTIC=PASS_CONSUMED

A5_BATCH_LOCK_MECHANISM=NOT_SUPPORTED
A5_MECHANISM_REASSESSMENT=RESOLVED_MIXED
```

No consumed one-shot gate may be rerun.

## What the case established

### 1. Baseline scaling shape

A2 established that the frozen unit-reservation implementation does not continue scaling beyond four workers under the frozen 100-task workload.

```text
MEDIAN_1W_TPS=275.598472
MEDIAN_4W_TPS=594.324627
MEDIAN_8W_TPS=557.457678
MEDIAN_16W_TPS=513.164949

A2_4_8_CLASSIFICATION=4_WORKER_CLEARLY_ABOVE_8
A2_16W_CLASSIFICATION=REGRESSION
```

### 2. Original global-lock bottleneck

A3 directly measured flock acquisition wait and supported the shared POSIX flock as a material coordination bottleneck in the frozen original implementation.

```text
LOCK_WAIT_SHARE_1W_PCT=2.673
LOCK_WAIT_SHARE_4W_PCT=14.482
LOCK_WAIT_SHARE_8W_PCT=59.931
LOCK_WAIT_SHARE_16W_PCT=87.137

LOCK_CONTENTION_ROOT_CAUSE=SUPPORTED
```

This does not claim flock was the only source of scaling loss.

### 3. One isolated engineering change

A4 changed only reservation cardinality:

```text
ENGINEERING_CHANGE=BATCHED_RESERVATION
BATCH_SIZE=4

SHARDING_CHANGE=NO
FRONTIER_SCHEMA_CHANGE=NO
TASK_SET_CHANGE=NO
KYBER_CHANGE=NO
YODA_CHANGE=NO
```

R1 proved semantic correctness:

```text
SERIAL_USEFUL_INVOCATIONS=25
SERIAL_BATCH_CARDINALITY=PASS
CONCURRENT_16W_SEMANTICS=PASS
```

### 4. Same-session performance effect

A4-R2 supported the batch-size-four implementation as a material performance improvement over the frozen control.

```text
CONTROL_MEDIAN_1W_TPS=245.031686
CANDIDATE_MEDIAN_1W_TPS=832.423920
DELTA_1W_PCT=+239.721

CONTROL_MEDIAN_4W_TPS=526.567443
CANDIDATE_MEDIAN_4W_TPS=1456.784263
DELTA_4W_PCT=+176.657

CONTROL_MEDIAN_8W_TPS=498.148900
CANDIDATE_MEDIAN_8W_TPS=1232.680834
DELTA_8W_PCT=+147.452

CONTROL_MEDIAN_16W_TPS=451.684321
CANDIDATE_MEDIAN_16W_TPS=994.910586
DELTA_16W_PCT=+120.267

BATCHED_RESERVATION_PERFORMANCE=SUPPORTED
```

The gain belongs to the batch-size-four implementation as a whole. A4-R2 does not partition the gain among fewer flock acquisitions, fewer process launches, and fewer frontier scans.

### 5. Residual mechanism after batching

A5 directly compared CONTROL versus BATCH-4 under syscall tracing.

It proved:

```text
CONTROL_USEFUL_ATTEMPTS=100
CANDIDATE_USEFUL_ATTEMPTS=25
USEFUL_LOCK_FREQUENCY_REDUCTION=75_PERCENT

8W_CUMULATIVE_LOCK_WAIT_REDUCTION=73.0_PERCENT
16W_CUMULATIVE_LOCK_WAIT_REDUCTION=81.2_PERCENT
```

But the preregistered normalized-share requirement failed:

```text
8W_WAIT_SHARE:
CONTROL=56.892
CANDIDATE=56.460
DELTA_PP=-0.432

16W_WAIT_SHARE:
CONTROL=90.191
CANDIDATE=87.237
DELTA_PP=-2.954

REQUIRED_DELTA_PP=-20.000

A5_BATCH_LOCK_MECHANISM=NOT_SUPPORTED
```

The A5 verdict is preserved exactly and is not rewritten.

## Final bounded scientific conclusion

For the frozen Seeker binary, frozen 100-task frontier, and tested worker counts:

> The original single-global-lock reservation design exhibits a material coordination bottleneck beyond four workers. Batch-size-four reservation preserves the tested reservation semantics and materially improves same-session throughput while reducing useful global-lock reservations from 100 to 25 and cumulative lock wait by 73.0 percent at 8 workers and 81.2 percent at 16 workers. However, the remaining global-lock path remains contention dominated at high concurrency, so batching mitigates but does not eliminate the underlying serialization pressure.

This conclusion is bounded to the frozen workload and implementation under this case.

## Evidence authorities

```text
A2_EVIDENCE_MANIFEST_SHA256=
01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621

A3_EVIDENCE_MANIFEST_SHA256=
fef59c315bc2bef4f45f47bc15e214667c6b97ae7ed4548bc4cad542233e3c29

A4_R1_EVIDENCE_MANIFEST_SHA256=
9c6a75e473295009978d3f5e1d5972d26eee1a434d8df61e58568e7a159a8c46

A4_R2_EVIDENCE_MANIFEST_SHA256=
a35f380aa7f53e798700cd74a29d2f4a277cace5ff843196de1abccc3de2bfcc

A5_EVIDENCE_MANIFEST_SHA256=
6dffe3a9bd5d72324c9843103cb23ecba8cc514c1adf4fdca3ebe05a0327de1b
```

## Freeze

```text
A2_RERUN=NO
A3_RERUN=NO
A4_R1_RERUN=NO
A4_R2_RERUN=NO
A5_RERUN=NO

CASE_RERUN=NO
CASE_REINTERPRETATION=NO
```

Future experiments must use a new stage or a new CASE.

## Next program

The integrated C23 prototype in:

```text
~/cmu/yoda_system_c23
```

is not incorporated into this case because it changes multiple architectural dimensions simultaneously.

Its validation belongs to a new case:

```text
NEXT_CASE=YODA-C23-UNIFIED-SYSTEM-001
NEXT_CASE_FIRST_GATE=R0_SOURCE_AND_BUILD_AUTHORITY
```

No claim from SEEKER-C23-SWARM-SCALING-002 automatically transfers to that new architecture.
