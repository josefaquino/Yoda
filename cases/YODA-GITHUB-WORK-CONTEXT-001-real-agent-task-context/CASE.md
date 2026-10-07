# YODA-GITHUB-WORK-CONTEXT-001 — Case Contract

## Question

Can a minimally changed Yoda C23 candidate preserve both the identity and the minimal useful context of the same 100 real public GitHub tasks used in the preceding work-queue case?

## Comparison design

The workload is intentionally held constant.

Previous case:

    YODA-GITHUB-WORK-QUEUE-001
    same 100 GitHub issues
    property = task identity preservation

This case:

    YODA-GITHUB-WORK-CONTEXT-001
    same 100 GitHub issues
    property = task identity + task context preservation

The purpose is to change one product capability without changing the source domain, workload size, or task identities.

## Public authority

Authority:

    GitHub Search API

Repository:

    kubernetes/kubernetes

Query:

    repo:kubernetes/kubernetes is:issue

Ordering:

    sort=created
    order=asc

Selected workload:

    100 public issues

The selected URL identity set is the same set used by the preceding queue case.

## Task identity

Identity remains:

    source_uri = public GitHub issue URL
    species    = github_issue

Persisted Yoda key:

    obs:<species>:<source_uri>

Expected key form:

    obs:github_issue:https://github.com/kubernetes/kubernetes/issues/<number>

## Minimal task-context contract

Each selected issue carries one compact, single-line JSON object with:

    number
    title
    state
    labels
    created_at
    updated_at

Conceptually:

    {
      "number": 123,
      "title": "Example issue",
      "state": "open",
      "labels": ["bug"],
      "created_at": "...",
      "updated_at": "..."
    }

The actual representation is compact one-line JSON.

Physical constraints:

    no literal TAB inside the context field
    no literal LF inside the context field
    valid JSON
    one physical Frontier record per task

Observed workload maxima during preparation:

    MAX_CONTEXT_BYTES=295
    MAX_FRONTIER_BYTES=367

The candidate task-context buffer is:

    MAX_CONTEXT_LEN=8192

## Candidate Frontier contract

Initial:

    source_uri<TAB>species<TAB>QUEUED<TAB>compact_context

After reservation:

    source_uri<TAB>species<TAB>PROCESSING<TAB>seeker_N<TAB>timestamp<TAB>compact_context

The context must survive the state transition unchanged.

## Candidate product path

    source compact context
            ↓
    Frontier
            ↓
    Agent Driver
            ↓
    context[]
            ↓
    Yoda Mesh
            ↓
    safe_value
            ↓
    Shield
            ↓
    KyberDB WAL
            ↓
    Lakehouse NDJSON

Runtime:

    TASKS=100
    WORKERS=16
    BATCH_SIZE=10

## Change scope

Frozen baseline:

    unchanged

Candidate source changes:

    yoda_agent_driver.h
    yoda_agent_driver.c
    yoda_mesh.c
    yoda_lakehouse.c

Unchanged engine and surrounding modules:

    kyber_db.*
    yoda_shield.*
    main.c

The candidate therefore tests a narrow payload-path extension without changing KyberDB.

## Candidate source identities

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

## Binary authorities

Frozen baseline binary:

    7510fc055e1d53b0471077f4b8cb5a32c08828a0fb9f40c2e81a8859750b55c3

Candidate binary:

    8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

## Execution contract

The product candidate is executed exactly once.

Final adjudication is read-only and must not execute Yoda again.

    PRODUCT_EXECUTION_COUNT=1
    PRODUCT_RERUN=NO
    VALIDATION_MODE=READ_ONLY

## Success criteria

The case passes only if all of the following hold.

Execution:

    SYSTEM_RC=0

Source and oracle:

    SOURCE_RECORDS=100
    SOURCE_UNIQUE_IDENTITIES=100
    SOURCE_JSON_VALID=1

    EXPECTED_IDENTITIES=100
    EXPECTED_CONTEXTS=100
    ORACLE_DERIVATION_MATCH=1

Frontier:

    FRONTIER_FINAL_RECORDS=100
    FRONTIER_FINAL_PROCESSING=100
    FRONTIER_FINAL_QUEUED=0
    FRONTIER_FINAL_UNIQUE_IDENTITIES=100
    FRONTIER_FINAL_DUPLICATES=0
    FRONTIER_CONTEXT_MATCH=1

Kyber:

    KYBER_RECORDS=100
    KYBER_UNIQUE_IDENTITIES=100
    KYBER_DUPLICATES=0
    KYBER_JSON_VALID=1
    KYBER_TO_SOURCE_CONTEXT_MATCH=1
    WAL_BYTE_EXACT_ORACLE=1

Lakehouse:

    LAKEHOUSE_RECORDS=100
    LAKEHOUSE_UNIQUE_IDENTITIES=100
    LAKEHOUSE_DUPLICATES=0
    LAKEHOUSE_JSON_VALID=1
    LAKEHOUSE_INNER_CONTEXT_JSON_VALID=1
    LAKEHOUSE_TO_SOURCE_CONTEXT_MATCH=1

Global reconciliation:

    MISSING_IDENTITIES=0
    DUPLICATE_IDENTITIES=0
    EXTRA_IDENTITIES=0

    MISSING_CONTEXTS=0
    CONTEXT_MISMATCHES=0
    EXTRA_CONTEXTS=0

## Non-claims

This case does not claim semantic understanding, issue resolution, coding-agent behavior, GitHub mutation, full issue-history preservation, arbitrary binary payload support, or general distributed correctness.

It tests exact identity and compact task-context preservation for one bounded real-world agent workload.
