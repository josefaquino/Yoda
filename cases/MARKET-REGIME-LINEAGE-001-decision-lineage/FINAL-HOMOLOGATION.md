# FINAL HOMOLOGATION — MARKET-REGIME-LINEAGE-001

## Verdict

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Research question

> Can Yoda preserve successive deterministic market-regime states and their derivation evidence such that independent implementations reproduce each original classification after recovery?

Within the scope of this CASE:

```text
ANSWER=YES
```

## Complete stage record

```text
PRE-A0-R1
STATUS=NOT_EVALUATED
FAILURE_CLASS=HARNESS_TRANSPORT_COMPOSITION
A0_GATE_CONSUMED=NO

PRE-A0-R2
STATUS=PASS

A0-R1
STATUS=PASS

A1-R1
STATUS=NOT_EVALUATED
ROOT_CAUSE_CLASS=NUMERIC_REPRESENTATION_CONTRACT_MISMATCH
ONE_EXECUTION_GATE_CONSUMED=YES
RERUN=NO

A1-R2
STATUS=PASS

A2-R1
STATUS=PASS

B-R1
STATUS=PASS
```

Negative and non-evaluable evidence is part of the final record and is not rewritten as PASS.

## Frozen decision sequence

```text
A
evaluation_date=2025-04-25
score=2
classification=STRESSED

B
evaluation_date=2025-08-29
score=1
classification=FRAGILE

C
evaluation_date=2025-12-26
score=1
classification=FRAGILE
```

## Demonstrated Decision Lineage

```text
A -> B
STRESSED -> FRAGILE
CLASSIFICATION_CHANGED=YES

B -> C
FRAGILE -> FRAGILE
CLASSIFICATION_CHANGED=NO
UNDERLYING_EVIDENCE_CHANGED=YES
```

The demonstrated property is therefore not merely label history.

For this controlled workflow, Yoda preserved:

```text
point-in-time input snapshots
decision states
classification contract
independent classification authorities
original evaluation evidence
successive transition evidence
decision-to-snapshot relationships
decision-to-contract relationships
authority relationships
supersession relationships
byte identities
```

## Independent replay result

B-R1 recovered the replay inputs only through the frozen A2 Yoda store.

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY

LOCAL_A0_FILES_AS_REPLAY_INPUT=FORBIDDEN
LOCAL_A1_FILES_AS_REPLAY_INPUT=FORBIDDEN
```

The recovered C11 and POSIX awk implementations independently replayed all three states.

```text
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
```

All replay result bytes matched the original canonical evaluation identity:

```text
ORIGINAL_CANONICAL_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

REPLAY_AUTHORITY_1_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba

REPLAY_AUTHORITY_2_RESULTS_SHA256=
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba
```

## Yoda state immutability

A2 frozen state:

```text
DATA_YODA_SHA256=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_BYTES=24851
```

B-R1 replay:

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_SHA256_AFTER=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_IDENTITY_UNCHANGED=PASS
YODA_WRITES=ZERO
```

## Evidence identities

```text
A0_EVIDENCE_MANIFEST_SHA256=
0440ffea6e2377fa6843f972f35d127f44727f114c2d91ae94039ff1ca4a78c8

A1_R2_EVIDENCE_MANIFEST_SHA256=
dc68f1634085ada042ab384e684e8ddbd812e7c29ab83c21d066837502c25a0a

A2_EVIDENCE_MANIFEST_SHA256=
5429ff7d771a575e9640f7d2d723daaebb084d934d2c31c26020f03be3419da5

B_EVIDENCE_MANIFEST_SHA256=
aaa6068ab848773fbf4d1d0d12feb1eba3f7c0afe7774d207c5b809a9a2a67c7
```

B-R1 execution identities:

```text
B_R1_SCRIPT_SHA256=
0013ed5e832d52436704010c20d43bd7a62a09cfa4b2a354d45f977e0cd24361

B_R1_CONSOLE_SHA256=
1edd4dff4b9b7e7a958d9405e17fcf88a1ad1286caf812c7fb4558835c5c42cd

B_R1_EXECUTION_LOCK_SHA256=
55c377d69cc7723d954b747daea8ef937756d060797bfcb9343fb48a5fefe002
```

## Permitted claim

> For one controlled deterministic public-data market-regime workflow, Yoda preserved successive evaluation states, their point-in-time public-data inputs, classification contract, transition history and evidence such that two independent implementations reproduced each original classification after recovery.

Short form:

> Yoda preserved not only the classification, but why the deterministic system produced that classification at that point in time.

## Property statement

```text
PROPERTY=DECISION_LINEAGE
STATUS=DEMONSTRATED
EVIDENCE=MARKET-REGIME-LINEAGE-001
```

Decision Lineage is a scoped extension of the broader verifiable-derivation thesis from artifact transformations to changing deterministic evaluations.

## Non-claims

This CASE does not establish that Yoda:

- predicts financial markets;
- generates alpha;
- recommends investments;
- identifies the true market regime;
- prevents financial losses;
- validates an economic theory;
- proves classifier correctness beyond the frozen deterministic contract;
- guarantees Decision Lineage for all domains or all decision systems.

The public data providers supply source data/context only and did not participate in or endorse this experiment.

## Final status

```text
CASE_STATUS=COMPLETE
NEXT_GATE=NONE
```
