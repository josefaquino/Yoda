# RUNBOOK — PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001

## Current gate

```text
PRE_A0=COMPLETE
A0_AUTHORITY=COMPLETE
A1_PREFLIGHT=PASS
A1_SCIENTIFIC=PASS
A2=NEXT
B=BLOCKED_ON_A2
```

## Immutable consumed gates

```text
A0_R1_EXECUTION_LOCK_SHA256=
95143c814b061a68e0857eb508f7b0324bf3eabe755d872c72bc4c257f404b0f

A0_C1_EXECUTION_LOCK_SHA256=
7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2

A0_R1_RERUN=NO
A0_C1_RERUN=NO
LOCK_DELETION=FORBIDDEN
```

## A1 input authority

A1 may consume only the frozen A0-C1 artifacts required by the deterministic evaluation contract.

Primary inputs:

```text
stage-a0-c1/canonical/canonical-facts.tsv

CANONICAL_FACTS_SHA256=
0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d

stage-a0-c1/contracts/evaluation-contract-v1.txt

EVALUATION_CONTRACT_SHA256=
ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd
```

A1 must not fetch SEC data, rescan candidates, reselect the tuple or write Yoda.

```text
SEC_FETCHES=ZERO
RESELECTION=FORBIDDEN
YODA_WRITES=ZERO
```
