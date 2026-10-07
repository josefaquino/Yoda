# YODA-GITHUB-WORK-QUEUE-001 — Case Contract

## Question

Can the frozen Yoda C23 stack process a queue built from 100 real public GitHub development tasks through its agent, persistence, and materialization path while preserving every task identity exactly once?

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

Requested page size:

    per_page=100

Validated source response:

    GITHUB_TOTAL_COUNT=49795
    GITHUB_RETURNED=100
    GITHUB_INCOMPLETE=false

The total count is a property of the source at fetch time and is not a stable future constant. The case requires the selected workload to contain exactly 100 unique public issues.

## Work identity

Each GitHub issue becomes one Frontier task.

Input Frontier fields:

    source_uri
    species
    status

Values:

    source_uri = public GitHub issue URL
    species    = github_issue
    status     = QUEUED

Example identity:

    https://github.com/kubernetes/kubernetes/issues/1

The frozen Yoda stack derives the persisted key as:

    obs:<species>:<source_uri>

Therefore the expected key form is:

    obs:github_issue:https://github.com/kubernetes/kubernetes/issues/<number>

## Frozen product path

    100 real GitHub issues
            ↓
    Frontier
            ↓
    Agent Driver / Seeker
            ↓
    Yoda Mesh
            ↓
    Shield
            ↓
    KyberDB WAL
            ↓
    Lakehouse NDJSON

Runtime configuration:

    TASKS=100
    WORKERS=16
    BATCH_SIZE=10

The case does not ask an agent to solve, comment on, or modify any GitHub issue.

## Frozen binary authority

Official binary:

    ~/cmu/yoda_system_c23/yoda_system

Required SHA-256:

    7510fc055e1d53b0471077f4b8cb5a32c08828a0fb9f40c2e81a8859750b55c3

The validated run matched this identity exactly.

    BINARY_MATCH=PASS

## Success criteria

The case passes only if all of the following hold:

    SYSTEM_RC=0

    FRONTIER_INITIAL_LINES=100
    FRONTIER_INITIAL_UNIQUE_URLS=100
    FRONTIER_INITIAL_DUPLICATES=0
    FRONTIER_INITIAL_BAD_ROWS=0

    EXPECTED_KEYS=100
    EXPECTED_UNIQUE_KEYS=100
    EXPECTED_DUPLICATES=0
    EXPECTED_DERIVATION_MATCH=1

    FRONTIER_FINAL_LINES=100
    FRONTIER_FINAL_PROCESSING=100
    FRONTIER_FINAL_QUEUED=0
    FRONTIER_FINAL_BAD_ROWS=0
    FRONTIER_FINAL_UNIQUE_URLS=100
    FRONTIER_FINAL_DUPLICATES=0
    FRONTIER_IDENTITY_MATCH=1

    WAL_RECORDS=100
    WAL_BAD_ROWS=0
    WAL_UNIQUE_KEYS=100
    WAL_DUPLICATES=0
    EXPECTED_EQUALS_WAL=1
    WAL_MISSING=0
    WAL_EXTRA=0

    LAKEHOUSE_RECORDS=100
    LAKEHOUSE_JSON_VALID=1
    LAKEHOUSE_KEYS=100
    LAKEHOUSE_UNIQUE_KEYS=100
    LAKEHOUSE_DUPLICATES=0
    EXPECTED_EQUALS_LAKEHOUSE=1
    LAKEHOUSE_MISSING=0
    LAKEHOUSE_EXTRA=0

    MISSING=0
    DUPLICATE=0
    EXTRA=0

    BINARY_MATCH=1

## Independent final validation

Final adjudication is read-only.

It must not rerun the product.

    VALIDATION_MODE=READ_ONLY
    PRODUCT_RERUN=NO

The validator reads only the existing run artifacts and compares independently derived expected identities against the Frontier, Kyber WAL, and Lakehouse outputs.

## Non-claims

This case does not claim that Yoda solved, understood, classified, prioritized, or modified the GitHub issues.

It does not claim full GitHub payload preservation.

It does not establish universal concurrency or distributed-systems correctness.

The validated property is exact work-identity preservation across one real-world local C23 execution path.
