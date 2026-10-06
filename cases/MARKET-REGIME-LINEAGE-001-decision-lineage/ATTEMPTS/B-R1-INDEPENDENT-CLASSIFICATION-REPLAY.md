# B-R1 - Independent Classification Replay

## Status

```text
STATUS=PASS
EXECUTED=YES
EXECUTION_COUNT=1
RUN_RC=0
EXECUTION_POLICY=ONE_EXECUTION
RERUN=NO
```

## Research question

> Can both frozen classification authorities, recovered only from the frozen Yoda A2 store together with their recovered source snapshots, reproduce the original A/B/C classifications exactly?

## Input boundary

Replay input bytes must come from Yoda only.

```text
LOCAL_A0_FILES_AS_REPLAY_INPUT=FORBIDDEN
LOCAL_A1_FILES_AS_REPLAY_INPUT=FORBIDDEN

REPLAY_INPUT_SOURCE=YODA_GET_ONLY
```

Permitted recovered keys:

```text
market/snapshot/A
market/snapshot/B
market/snapshot/C

market/contract/regime-v2

market/authority/c11-v2
market/authority/awk-v2

market/evaluation/c11-v2
market/evaluation/awk-v2
market/evaluation/canonical-v2
```

## Frozen A2 authority

```text
A2_R1_SCRIPT_SHA256=
191adf5544895bb11973836f73434c00944c5e0cb075b5c1f321acb69c397fe5

A2_R1_CONSOLE_SHA256=
aeb58ae1c671c4e439bf0d67685c420897daa37db0107b3a271b77f395ef0a94

A2_R1_EXECUTION_LOCK_SHA256=
c57ed4f850cb9c42691b8168e913762b86aae56bbc965c4d38c525d742a173d3

A2_EVIDENCE_MANIFEST_SHA256=
5429ff7d771a575e9640f7d2d723daaebb084d934d2c31c26020f03be3419da5

DATA_YODA_SHA256=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_BYTES=24851
```

## Frozen recovered identities

```text
SNAPSHOT_A_SHA256=
10ce61f2bd18d1f32191a91c317759a87ca11b993f22f630818c56a96bef9410

SNAPSHOT_B_SHA256=
d1688f9b362c84018f9fc093e8a6f7b985e56e3965bdb9bf8d2bdffa3af39a34

SNAPSHOT_C_SHA256=
b0604231b66c6d24ef7e640bb5cf423ed138984a69342eff0f2585ac446006c2

CLASSIFICATION_CONTRACT_V2_SHA256=
8516bb27a0099995ee09c4900d26477a8ff142e3e9aa6c4b496f94b21b6d09be

AUTHORITY_1_V2_SOURCE_SHA256=
29b82504373f54bb225f76be2bfd0c9e2d439268da6c7e90442a7eeb820c6573

AUTHORITY_2_V2_SOURCE_SHA256=
c48b6fe73b1ea327397b68476de9a29d8f87f5a9c0d3303b529c64757b2e6fc8

ORIGINAL_CANONICAL_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba
```

## Execution policy

Before the one-execution replay lock:

1. verify the exact frozen Yoda binary;
2. verify A2 evidence and `data.yoda` identity;
3. recover all replay inputs via `yoda get`;
4. verify recovered byte identities;
5. compile the recovered C11 authority.

The lock is created immediately before the first replay classification.

After the lock:

- any classifier execution failure is an `INDEPENDENT_REPLAY_FAILURE`;
- any C11/awk divergence is an `INDEPENDENT_REPLAY_FAILURE`;
- any replay/original byte mismatch is an `INDEPENDENT_REPLAY_FAILURE`;
- rerun is forbidden.

## Required replay

```text
Recovered C11 source
        +
Recovered snapshots A/B/C
        ->
Replay result 1

Recovered POSIX awk source
        +
Recovered snapshots A/B/C
        ->
Replay result 2
```

Required equality:

```text
Replay result 1
==
Replay result 2
==
Yoda-recovered original authority 1 result
==
Yoda-recovered original authority 2 result
==
Yoda-recovered original canonical result
```

Expected original decision sequence remains:

```text
A=STRESSED
B=FRAGILE
C=FRAGILE
```

This is an identity/equivalence target, not a reason to alter the replay implementation.

## Yoda immutability requirement

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

YODA_WRITES=ZERO
```

The same byte identity must remain after replay.

## Frozen harness identity

```text
B_R1_SCRIPT_SHA256=
0013ed5e832d52436704010c20d43bd7a62a09cfa4b2a354d45f977e0cd24361

B_R1_SCRIPT_COMMIT=
9fd4c05d2553e0dc2632e5b3373e64d6780efa55
```

## PASS condition

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY

RECOVERED_AUTHORITY_1_COMPILE=PASS
REPLAY_AUTHORITY_1=PASS
REPLAY_AUTHORITY_2=PASS

REPLAY_AUTHORITY_EQUIVALENCE=PASS

REPLAY_VS_ORIGINAL_AUTHORITY_1=PASS
REPLAY_VS_ORIGINAL_AUTHORITY_2=PASS
REPLAY_VS_ORIGINAL_CANONICAL=PASS

STATE_A_INDEPENDENT_REPLAY=PASS
STATE_B_INDEPENDENT_REPLAY=PASS
STATE_C_INDEPENDENT_REPLAY=PASS

INDEPENDENT_CLASSIFICATION_REPLAY=PASS

DATA_YODA_IDENTITY_UNCHANGED=PASS
B_EVIDENCE_INTEGRITY=PASS

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Only PASS authorizes CASE final homologation.


---

## Observed result

```text
MARKET_REGIME_LINEAGE_001_STAGE_B=PASS
B_REVISION=B-R1

REPLAY_INPUT_SOURCE=YODA_GET_ONLY

RECOVERED_AUTHORITY_1_COMPILE=PASS
REPLAY_AUTHORITY_1=PASS
REPLAY_AUTHORITY_2=PASS

REPLAY_AUTHORITY_EQUIVALENCE=PASS

REPLAY_VS_ORIGINAL_AUTHORITY_1=PASS
REPLAY_VS_ORIGINAL_AUTHORITY_2=PASS
REPLAY_VS_ORIGINAL_CANONICAL=PASS

STATE_A_INDEPENDENT_REPLAY=PASS
STATE_B_INDEPENDENT_REPLAY=PASS
STATE_C_INDEPENDENT_REPLAY=PASS

INDEPENDENT_CLASSIFICATION_REPLAY=PASS

DATA_YODA_IDENTITY_UNCHANGED=PASS
B_EVIDENCE_INTEGRITY=PASS

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Replayed decision sequence

```text
A	2025-04-25	score=2	STRESSED
B	2025-08-29	score=1	FRAGILE
C	2025-12-26	score=1	FRAGILE
```

Both replay authorities produced the exact original canonical byte identity:

```text
REPLAY_AUTHORITY_1_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

REPLAY_AUTHORITY_2_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

ORIGINAL_CANONICAL_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba
```

## Frozen execution identities

```text
B_R1_SCRIPT_SHA256=
0013ed5e832d52436704010c20d43bd7a62a09cfa4b2a354d45f977e0cd24361

B_R1_CONSOLE_SHA256=
1edd4dff4b9b7e7a958d9405e17fcf88a1ad1286caf812c7fb4558835c5c42cd

B_R1_EXECUTION_LOCK_SHA256=
55c377d69cc7723d954b747daea8ef937756d060797bfcb9343fb48a5fefe002

B_EVIDENCE_MANIFEST_SHA256=
aaa6068ab848773fbf4d1d0d12feb1eba3f7c0afe7774d207c5b809a9a2a67c7
```

Yoda state remained byte-identical before and after replay:

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_SHA256_AFTER=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_BYTES=24851
```

The B-R1 one-execution policy is consumed. Do not rerun B-R1.
