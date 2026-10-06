# FINAL HOMOLOGATION — TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001

## Final verdict

```text
CASE=TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001
CASE_STATUS=PASS
CASE_SCOPE_COMPLETE=YES

PRE_A0_R1_SELECTION=PASS
A0_R1=PASS
A1_R1=PASS
A2_R0_CAPACITY_PREFLIGHT=PASS
A2_R1=PASS
B_R0_PREFLIGHT=PASS
B_R1=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Research question answered

Can Yoda preserve two distinct derivation lineages that are externally judged correct, recover them later, and support an independent replay that reproduces the original accepted outcomes?

```text
ANSWER=YES_FOR_THIS_FROZEN_CASE
```

## Frozen external authority

```text
PROJECT=sierra-research/tau2-bench
RELEASE_TAG=v1.0.1
RELEASE_COMMIT=fc0055dc4e0a316c3f83133267fbd6faaa770992
DOMAIN=airline
TASK_ID=7
```

## A1 — outcome-equivalent distinct derivations

```text
TRAJECTORY_A_FINAL_REWARD=1.0
TRAJECTORY_B_FINAL_REWARD=1.0

TRAJECTORY_A_DB_REWARD=1.0
TRAJECTORY_B_DB_REWARD=1.0

TRAJECTORY_A_COMMUNICATE_REWARD=1.0
TRAJECTORY_B_COMMUNICATE_REWARD=1.0

FINAL_DB_HASH=
0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7

LINEAGE_A_SHA256=
965417ca555dd70eff7d39e822326305b1e81b9e16864dcd7a92b43197d5d36b

LINEAGE_B_SHA256=
1933529e5aa2902bd83a45d90f2692e07f0c3ef00ac4442db98ffdd114ae8340

OUTCOME_EQUIVALENCE=PASS
DERIVATION_DISTINCTNESS=PASS
```

## A2 — Yoda persistence and recovery

```text
OBJECT_COUNT=10
RELATION_COUNT=14

BYTE_EXACT_OBJECT_RECOVERY=PASS
RELATION_RECOVERY=PASS
DUAL_DERIVATION_LINEAGE_RECOVERY=PASS
OUTCOME_EQUIVALENCE_SEMANTICS=PASS
FINAL_YODA_VERIFY=PASS

DATA_YODA_SHA256=
0d790fb57c3fe092a1567327f049f0b123dd143c379f4afa21692b614f40d42a

DATA_YODA_BYTES=24801

A2_EVIDENCE_MANIFEST_SHA256=
d6ac6b8d4fbd61f7c210d998f8feb407759dd3df3d068c82187653c006099a2c
```

## B — independent replay from Yoda-recovered inputs

```text
INDEPENDENT_IMPLEMENTATION=PASS
YODA_RECOVERED_INPUTS=PASS

TRAJECTORY_A_TOOL_RESPONSE_MATCH_COUNT=5
TRAJECTORY_B_TOOL_RESPONSE_MATCH_COUNT=5

TRAJECTORY_A_FINAL_REWARD=1.0
TRAJECTORY_B_FINAL_REWARD=1.0

TRAJECTORY_A_FINAL_DB_HASH=
0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7

TRAJECTORY_B_FINAL_DB_HASH=
0087f8266f0f2fc2091ee4fabd9c137ed8b6c8751df09ec4f650756e4ae0ccf7

TOOL_RESPONSE_REPRODUCTION=PASS
OUTCOME_REPRODUCTION=PASS
COMMON_FINAL_DB_HASH_REPRODUCTION=PASS
DISTINCT_LINEAGE_PRESERVATION=PASS

YODA_STORE_MUTATED=NO

B_EVIDENCE_MANIFEST_SHA256=
c32ad0e7609ce114453d4157a44d943405ac80b3aac51833d94f73d88344973a
```

## Scientific conclusion

For the frozen tau2 Airline task 7, two materially distinct derivation sequences were accepted by the external authority and converged to the same final database state.

Frozen Yoda preserved both derivations, their semantic relations, their judged outcomes, and the common outcome-equivalence evidence.

After recovery, a separate replay implementation reproduced all five tool responses for both trajectories, reproduced the external rewards, and reproduced the exact common final database hash while preserving distinct lineage identities.

This validates the case hypothesis for this frozen workload without changes to Yoda or Kyber.

## Boundaries

This case does not prove that every pair of reordered actions is outcome-equivalent, nor that every tau2 task is replayable in this manner.

It proves the registered claim for the selected frozen task, frozen transformation, frozen external release and frozen Yoda implementation.

## Closure

```text
CASE_STATUS=PASS
CASE_SCOPE_COMPLETE=YES
FINAL_CASE_HOMOLOGATION=PASS
NEXT_GATE=NONE
```
