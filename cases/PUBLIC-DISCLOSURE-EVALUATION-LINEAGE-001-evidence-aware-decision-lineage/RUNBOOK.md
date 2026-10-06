# RUNBOOK — PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001

## Current gate

```text
PRE_A0=COMPLETE
A0_AUTHORITY=COMPLETE
A1_PREFLIGHT=PASS
A1_SCIENTIFIC=PASS
A2_R1=FAIL
A2_R1_RERUN=NO
B=BLOCKED_BY_A2_FAIL
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


## Current failure boundary

```text
A2_R1=FAIL
FAILURE_CLASS=YODA_PERSISTENCE_FAILURE

A2_R1_EXECUTION_LOCK_SHA256=
32cf7138c88b381c0b3f544f9e985cfafa5c9e5c88ea5f2d75b7599d716ca6f2

A2_R1_CONSOLE_SHA256=
2db9758c01d360e4ac09d61e6d7a285202f12d5a56033c0f26ae60feab74c40a

PARTIAL_DATA_YODA_SHA256=
48700481d01777910f5976ffe8d5de755288772088856dbaf59713df960f9cea

PARTIAL_DATA_YODA_BYTES=4091828

OBSERVED_ERROR=
yoda: terms table capacity exhausted

B=BLOCKED_BY_A2_FAIL
```

Do not rerun A2-R1. Only read-only adjudication is authorized against the partial store.
