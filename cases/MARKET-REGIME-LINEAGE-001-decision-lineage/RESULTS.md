# RESULTS — MARKET-REGIME-LINEAGE-001

## Final verdict

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Status

| Stage | Status | Meaning |
|---|---|---|
| Design | FROZEN | Research question, dates, classifier and authorities pre-registered |
| PRE-A0-R1 | NOT_EVALUATED | Harness transport composition mismatch; no A0 gate consumed |
| PRE-A0-R2 | PASS | FRED metadata/observations and point-in-time parameters reachable; zero Yoda writes |
| A0-R1 | PASS | Three point-in-time snapshots frozen; evidence manifest valid; classification not executed |
| A1-R1 | NOT_EVALUATED | One-shot consumed; C11 authority stopped at first classification with HARNESS_FAILURE; rerun forbidden |
| A1-R2 | PASS | C11 and POSIX awk produced byte-identical features/classifications for A/B/C |
| A2-R1 | PASS | 18 objects + 31 relations preserved; byte-exact recovery, relation recovery and Decision Lineage semantics passed |
| B-R1 | PASS | Yoda-only recovered C11 + awk replayed A/B/C and reproduced the original canonical bytes exactly |

Historical classifications were first observed during the frozen A1-R2 execution; no thresholds, dates, snapshots or label mappings were changed after A0.


## A1-R1 harness identity erratum

Before A1 scientific execution, the declared script hash was corrected from a non-byte text hash to the exact UTF-8 byte SHA-256:

```text
CORRECT_A1_R1_SCRIPT_SHA256=
0c891fb1565f42e01943c13def49473b9e515a66653b0f88a479ca065b89a440

A1_EXECUTION_LOCK_CONSUMED=NO
SCRIPT_CONTENT_CHANGED=NO
```


## A1-R1 root cause

```text
A1_R1_STATUS=NOT_EVALUATED
ROOT_CAUSE_CLASS=NUMERIC_REPRESENTATION_CONTRACT_MISMATCH

FIXED4_INPUT_CONTRACT_VIOLATION_COUNT=3
A1_R1_RERUN=NO
```

All three frozen NFCI inputs contain five fractional digits while the v1 parser admitted at most four.

A1-R2 is permitted as a representation-only revision. Dates, snapshot bytes, thresholds, labels and the scientific question remain frozen.


## A1-R2 observed result

```text
STATUS=PASS
EXECUTION_COUNT=1
RUN_RC=0

A=STRESSED
B=FRAGILE
C=FRAGILE

AUTHORITY_1_V2_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

AUTHORITY_2_V2_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

CANONICAL_RESULTS_V2_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

A1_R2_EVIDENCE_MANIFEST_SHA256=
dc68f1634085ada042ab384e684e8ddbd812e7c29ab83c21d066837502c25a0a
```

Observed transition structure:

```text
A -> B  STRESSED -> FRAGILE  classification_changed=YES
B -> C  FRAGILE  -> FRAGILE  classification_changed=NO
                              underlying_evidence_changed=YES
```


## A2-R1 observed result

```text
STATUS=PASS
EXECUTION_COUNT=1

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

Decision Lineage semantic recovery:

```text
A -> B  STRESSED -> FRAGILE  classification_changed=YES
B -> C  FRAGILE  -> FRAGILE  classification_changed=NO
                              underlying_evidence_changed=YES
```


## B-R1 observed result

```text
STATUS=PASS
EXECUTION_COUNT=1
RUN_RC=0

REPLAY_INPUT_SOURCE=YODA_GET_ONLY

REPLAY_AUTHORITY_1_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

REPLAY_AUTHORITY_2_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

REPLAY_VS_ORIGINAL_CANONICAL=PASS
INDEPENDENT_CLASSIFICATION_REPLAY=PASS

DATA_YODA_IDENTITY_UNCHANGED=PASS

B_R1_CONSOLE_SHA256=
1edd4dff4b9b7e7a958d9405e17fcf88a1ad1286caf812c7fb4558835c5c42cd

B_R1_EXECUTION_LOCK_SHA256=
55c377d69cc7723d954b747daea8ef937756d060797bfcb9343fb48a5fefe002

B_EVIDENCE_MANIFEST_SHA256=
aaa6068ab848773fbf4d1d0d12feb1eba3f7c0afe7774d207c5b809a9a2a67c7
```

The Yoda store remained byte-identical before and after independent replay:

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_SHA256_AFTER=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e
```

## Final scoped claim

> For one controlled deterministic public-data market-regime workflow, Yoda preserved successive evaluation states, their point-in-time public-data inputs, classification contract, transition history and evidence such that two independent implementations reproduced each original classification after recovery.

This validates the CASE and demonstrates the scoped property:

```text
PROPERTY=DECISION_LINEAGE
STATUS=DEMONSTRATED
EVIDENCE=MARKET-REGIME-LINEAGE-001
```

This does not establish market prediction, alpha, investment advice, economic truth, or universal model correctness.
