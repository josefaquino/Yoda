# YODA-GITHUB-WORK-CONTEXT-001 — Results

## Classification

    YODA_GITHUB_WORK_CONTEXT_001=PASS
    VALIDATION_MODE=READ_ONLY
    PRODUCT_EXECUTION_COUNT=1
    PRODUCT_RERUN=NO
    TOTAL_FAILURES=0
    ADJUDICATION_RC=0

## Workload

    AUTHORITY=GitHub_Search_API
    REPOSITORY=kubernetes/kubernetes

    REAL_GITHUB_ISSUES=100
    WORKERS=16
    BATCH_SIZE=10

The workload reused the same 100 public GitHub issue identities used by `YODA-GITHUB-WORK-QUEUE-001`.

## Product execution

    SYSTEM_RC=0
    PRODUCT_EXECUTION_COUNT=1
    PRODUCT_RERUN=NO

Observed product output:

    Total Processado: 100 tarefas
    Registros colunares exportados para NDJSON: 100

Observed swarm elapsed time:

    0.0054 seconds

The elapsed time is an observation, not a correctness threshold.

## Source context

    SOURCE_RECORDS=100
    SOURCE_UNIQUE_IDENTITIES=100
    SOURCE_JSON_VALID=1

Minimal context fields:

    number
    title
    state
    labels
    created_at
    updated_at

Preparation observations:

    MAX_CONTEXT_BYTES=295
    MAX_FRONTIER_BYTES=367

## Independent oracle

    EXPECTED_IDENTITIES=100
    EXPECTED_CONTEXTS=100
    ORACLE_DERIVATION_MATCH=1

The expected key/context state was independently derived from the frozen source-context snapshot.

## Final Frontier

    FRONTIER_FINAL_RECORDS=100
    FRONTIER_FINAL_PROCESSING=100
    FRONTIER_FINAL_QUEUED=0
    FRONTIER_FINAL_UNIQUE_IDENTITIES=100
    FRONTIER_FINAL_DUPLICATES=0
    FRONTIER_CONTEXT_MATCH=1

The context survived the Frontier transition from `QUEUED` to `PROCESSING`.

## KyberDB

    KYBER_RECORDS=100
    KYBER_UNIQUE_IDENTITIES=100
    KYBER_DUPLICATES=0
    KYBER_JSON_VALID=1
    KYBER_TO_SOURCE_CONTEXT_MATCH=1
    WAL_BYTE_EXACT_ORACLE=1

Strongest byte-level evidence:

    EXPECTED_CONTEXT_SHA256=
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

    KYBER_WAL_SHA256=
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

The complete Kyber WAL was byte-for-byte identical to the expected key/context oracle.

KyberDB itself was unchanged:

    KYBER_CHANGE=NO

## Lakehouse

    LAKEHOUSE_RECORDS=100
    LAKEHOUSE_UNIQUE_IDENTITIES=100
    LAKEHOUSE_DUPLICATES=0
    LAKEHOUSE_JSON_VALID=1
    LAKEHOUSE_INNER_CONTEXT_JSON_VALID=1
    LAKEHOUSE_TO_SOURCE_CONTEXT_MATCH=1

The candidate Lakehouse added JSON-string escaping so compact JSON values could be transported inside NDJSON without changing the underlying payload content.

Lakehouse artifact identity:

    61787639eadbc6b25bfca896e0c41561c1e0261a14b2129d9003dfe7c3aac1e5

## Global identity reconciliation

    MISSING_IDENTITIES=0
    DUPLICATE_IDENTITIES=0
    EXTRA_IDENTITIES=0

## Global context reconciliation

    MISSING_CONTEXTS=0
    CONTEXT_MISMATCHES=0
    EXTRA_CONTEXTS=0

## Baseline and candidate authority

Frozen baseline binary:

    BASELINE_BINARY_SHA256=
    7510fc055e1d53b0471077f4b8cb5a32c08828a0fb9f40c2e81a8859750b55c3

Executed candidate:

    CANDIDATE_BINARY_SHA256=
    8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

The frozen baseline remained unchanged.

    BASELINE_CHANGED=NO

Candidate source identities:

    yoda_agent_driver.h
    256d49f8b7d0f48bc14af9ff5c4d8a8ff33a7e7f8e9596f25be5736fc6d8627c

    yoda_agent_driver.c
    553741d7190264753faf723f6494e810b2000e09dfcf67fb5bd022b35d84ab07

    yoda_mesh.c
    ffe4cab673e9ad1f7f8e9a8b490a8467bb6ddb25430b4e9ae9f412d131420a03

    yoda_lakehouse.c
    26ee2dae2be1118582ed5f6c44ea06b5070329e6a7bc8a4b215f3fbd0f1f8d22

    kyber_db.c
    c90468dd24ffb8f48478ba01b997242e32e698488a94e7cc5e6f47cfbff84696

## Evidence identities

    FRONTIER_INITIAL_SHA256=
    bf55043ae6bc0f54dcb61362b6164ed01a8fde6a6abec56d80ee0229c5f3213a

    FRONTIER_FINAL_SHA256=
    f162a3b01b85df80fb05e8b1d54b4b46330164925a85b57d2fefbf83a39aca7f

    SOURCE_CONTEXT_SHA256=
    b67bab673c7d87159c06cacc4e50d9cb4232d15dca50183c9dfe49e0d4a5ef51

    EXPECTED_KEYS_SHA256=
    eedf2f9c544f843965d15d9aadbfeaa095ac4af9cf954064bf18bc0e6da7c204

    EXPECTED_CONTEXT_SHA256=
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

    KYBER_WAL_SHA256=
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

    LAKEHOUSE_SHA256=
    61787639eadbc6b25bfca896e0c41561c1e0261a14b2129d9003dfe7c3aac1e5

    YODA_RC_SHA256=
    9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa

    INDEPENDENT_CONTEXT_VALIDATION_REPORT_SHA256=
    84870b8f2021dd196c40080fabf612bc6fc71cf6da719a76ede43ba3e429c674

## Interpretation

The previous queue case demonstrated:

    task identity preservation

This case demonstrates:

    task identity
        +
    minimal useful task context

for the same real workload.

The candidate preserved all 100 identities and all 100 contexts through concurrent Frontier processing, Kyber persistence, and Lakehouse materialization.

No expected identity was lost, duplicated, or invented.

No expected task context was missing, altered, or mismatched.

The bounded product statement is:

> **Yoda preserved both the identity and the minimal useful context of real agent tasks across concurrent execution, local persistence, and materialization.**

## Final result

    YODA_GITHUB_WORK_CONTEXT_001=PASS

    SYSTEM_RC=0

    EXPECTED_IDENTITIES=100
    EXPECTED_CONTEXTS=100

    FRONTIER_CONTEXT_MATCH=PASS
    KYBER_TO_SOURCE_CONTEXT_MATCH=PASS
    LAKEHOUSE_TO_SOURCE_CONTEXT_MATCH=PASS
    WAL_BYTE_EXACT_ORACLE=PASS

    MISSING_IDENTITIES=0
    DUPLICATE_IDENTITIES=0
    EXTRA_IDENTITIES=0

    MISSING_CONTEXTS=0
    CONTEXT_MISMATCHES=0
    EXTRA_CONTEXTS=0

    VALIDATION_MODE=READ_ONLY
    PRODUCT_EXECUTION_COUNT=1
    PRODUCT_RERUN=NO

    KYBER_CHANGE=NO
    BASELINE_CHANGED=NO
