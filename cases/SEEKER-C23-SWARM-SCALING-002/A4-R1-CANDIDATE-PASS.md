# A4-R1 Candidate Build and Semantic Validation — PASS

## Verdict

```text
A4_R1_CANDIDATE_BUILD=PASS
BATCH_SIZE=4

SERIAL_BATCH_CARDINALITY=PASS
CONCURRENT_16W_SEMANTICS=PASS

CONTROL_PROJECT_MUTATED=NO
CONTROL_FRONTIER_MUTATED=NO

PERFORMANCE_CONCLUSION=NONE
A4_R1_RERUN=NO
NEXT_GATE=A4_R2_CONTROLLED_PERFORMANCE
```

## Frozen identities

```text
CONTROL_AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

R0_MANIFEST_SHA256=
5a832d57b39ed3f94a680261914e6de6adde4ce25cc61801160729a544081cd3

PATCH_SHA256=
046a55cf0000110030c32bf0f3a81016d9c57fa17d4a49925714876a2f0aa3d4

CANDIDATE_BINARY_SHA256=
0970c60c22eb415b99750b8eb6384a20fc983ba0cc77f4989448b4fb1a5efd2f
```

## Candidate source identities

```text
CANDIDATE_MAIN_SHA256=
b1b2e856a77203273cf479c60b3f732bca8cf22ff91e3e55a8cb98fd8caedaa8

CANDIDATE_DRIVER_C_SHA256=
d0a83c6cbcb2fd34b3b1601d1c13e016ca76fa686141e93000d00945024b0497

CANDIDATE_DRIVER_H_SHA256=
0856b61bf64a50d1ce5c49baab3f55b0e62005aeb35b28f643537c439b83eba1
```

## Serial cardinality validation

```text
SERIAL_USEFUL_INVOCATIONS=25
SERIAL_LINES=100
SERIAL_PROCESSING=100
SERIAL_QUEUED=0
SERIAL_BAD_FIELDS=0
SERIAL_BAD_STATE=0
SERIAL_BAD_OWNER=0
SERIAL_TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

SERIAL_BATCH_CARDINALITY=PASS
EXPECTED_TASKS_PER_USEFUL_INVOCATION=4
```

## 16-worker concurrency semantics

```text
CONCURRENT_16W_LINES=100
CONCURRENT_16W_PROCESSING=100
CONCURRENT_16W_QUEUED=0
CONCURRENT_16W_BAD_FIELDS=0
CONCURRENT_16W_BAD_STATE=0
CONCURRENT_16W_BAD_OWNER=0
CONCURRENT_16W_TASK_IDENTITY_SHA256=
525a54a18c77fb5a61dc3adea8cf948abea2548fcafd350af29be7e34bafef28

CONCURRENT_16W_UNIQUE_OWNERS=15
CONCURRENT_16W_SEMANTICS=PASS
```

The 15 unique owners are not a correctness failure. With 25 useful four-task batches and 16 competing workers, one worker may legitimately receive no successful batch in a single run.

## One-shot and evidence

```text
A4_R1_EXECUTION_LOCK_SHA256=
4522f136bd407c6b08292da99e24d146adfd607a067f4fdbafe0b7b9d659e1ee

A4_R1_HARNESS_SHA256=
b0440bf4a93e5945e7722802a81c3a188bfe46d99a29051367d32273b945c0e8

A4_R1_CONSOLE_SHA256=
c30d9c5acd3eccddeba555a0e674ad3b6031cd7281603609fe58b98694bfadc3

A4_R1_EVIDENCE_MANIFEST_SHA256=
9c6a75e473295009978d3f5e1d5972d26eee1a434d8df61e58568e7a159a8c46
```

## Interpretation boundary

A4-R1 validates build identity and task-reservation semantics only. It makes no throughput claim.

The candidate changes one engineering mechanism: up to four tasks are reserved during one frontier-lock critical section and then consumed within one agent invocation.

Because that mechanism also reduces repeated process invocations and repeated frontier scans in the existing shell orchestration, a future performance gain must be attributed to the batch-4 implementation as a whole, not exclusively to reduced flock wait.
