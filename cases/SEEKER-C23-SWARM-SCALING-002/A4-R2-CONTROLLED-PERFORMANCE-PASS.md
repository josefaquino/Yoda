# A4-R2 Controlled Performance — PASS

## Verdict

```text
CASE=SEEKER-C23-SWARM-SCALING-002
REVISION=A4-R2-CONTROLLED-PERFORMANCE-001

A4_R2_CONTROLLED_PERFORMANCE=PASS
BATCHED_RESERVATION_PERFORMANCE=SUPPORTED
BATCH_SIZE=4

MEASURED_SCENARIOS=128
REPETITIONS_PER_ARM_PER_WORKER=16

A4_R2_RERUN=NO
NEXT_GATE=A5_BATCH_LOCK_DIAGNOSTIC
```

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

R1_MANIFEST_SHA256=
9c6a75e473295009978d3f5e1d5972d26eee1a434d8df61e58568e7a159a8c46
```

## Same-session medians

| Workers | Control TPS | Batch-4 TPS | Delta |
| ---: | ---: | ---: | ---: |
| 1 | 245.031686 | 832.423920 | +239.721% |
| 4 | 526.567443 | 1456.784263 | +176.657% |
| 8 | 498.148900 | 1232.680834 | +147.452% |
| 16 | 451.684321 | 994.910586 | +120.267% |

## Preregistered adjudication

```text
CRITERION_1W_GE_CONTROL_MINUS_10PCT=PASS
CRITERION_4W_GE_CONTROL_MINUS_5PCT=PASS
CRITERION_8W_GE_CONTROL_PLUS_20PCT=PASS
CRITERION_16W_GE_CONTROL_PLUS_20PCT=PASS

BATCHED_RESERVATION_PERFORMANCE=SUPPORTED
```

## One-shot and evidence

```text
A4_R2_EXECUTION_LOCK_SHA256=
47a0f18422372709414e2b757fbe8e4a25672bff96ff8af74368b00df576f000

A4_R2_HARNESS_SHA256=
608ba71751191d77af6049a5f81c8f030e7b3607bd347e397eb73d17907f12fc

A4_R2_CONSOLE_SHA256=
9437b5ff2bc32790a6a913e406add520d80a097b4d63aec9c61c45ca0b36adc0

A4_R2_EVIDENCE_MANIFEST_SHA256=
a35f380aa7f53e798700cd74a29d2f4a277cace5ff843196de1abccc3de2bfcc
```

## Scientific interpretation

The batch-size-four candidate materially outperformed the frozen control in the same session at every tested worker count.

The strongest scaling comparison is at the two worker counts where A2/A3 had exposed the coordination collapse:

```text
8W_DELTA=+147.452%
16W_DELTA=+120.267%
```

This supports the batch-4 implementation as an effective engineering mitigation for the frozen workload.

The gain must be attributed to the batch-4 implementation as a whole. The implementation reduces useful global-lock acquisitions, but it also reduces repeated process invocations and repeated frontier scans in the current orchestration. A4-R2 does not partition those contributions.

The next diagnostic stage will directly compare CONTROL versus BATCH-4 under syscall tracing to determine how much the lock path changed.
