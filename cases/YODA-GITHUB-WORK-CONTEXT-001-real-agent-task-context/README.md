# YODA-GITHUB-WORK-CONTEXT-001 — Real GitHub Agent Task Context

YODA-GITHUB-WORK-CONTEXT-001 extends the previous real GitHub work-queue case with one new product question:

> Can Yoda preserve not only the identity of a real agent task, but also the minimal useful context required to understand what that task is?

The workload deliberately reused the same 100 public GitHub issues from `kubernetes/kubernetes` used by `YODA-GITHUB-WORK-QUEUE-001`.

This keeps the comparison narrow:

    previous case
    identity preservation

            ↓ one small product change

    this case
    identity + useful context preservation

The context preserved for each issue was:

    issue URL
    issue number
    title
    state
    labels
    created_at
    updated_at

The compact context was represented as one-line JSON and moved through:

    GitHub issue snapshot
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

Runtime:

    TASKS=100
    WORKERS=16
    BATCH_SIZE=10

## Result

**PASS**

Final independent read-only adjudication:

    YODA_GITHUB_WORK_CONTEXT_001=PASS
    VALIDATION_MODE=READ_ONLY
    PRODUCT_EXECUTION_COUNT=1
    PRODUCT_RERUN=NO
    TOTAL_FAILURES=0
    ADJUDICATION_RC=0

Identity reconciliation:

    EXPECTED_IDENTITIES=100

    FRONTIER_FINAL_UNIQUE_IDENTITIES=100
    KYBER_UNIQUE_IDENTITIES=100
    LAKEHOUSE_UNIQUE_IDENTITIES=100

    MISSING_IDENTITIES=0
    DUPLICATE_IDENTITIES=0
    EXTRA_IDENTITIES=0

Context reconciliation:

    EXPECTED_CONTEXTS=100

    FRONTIER_CONTEXT_MATCH=1
    KYBER_TO_SOURCE_CONTEXT_MATCH=1
    LAKEHOUSE_TO_SOURCE_CONTEXT_MATCH=1

    MISSING_CONTEXTS=0
    CONTEXT_MISMATCHES=0
    EXTRA_CONTEXTS=0

## Strongest evidence

The independently derived expected key/context oracle and the Kyber WAL were byte-for-byte identical:

    EXPECTED_CONTEXT_SHA256=
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

    KYBER_WAL_SHA256=
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

Therefore, for the tested 100-task workload:

> **The context persisted by Kyber was exactly the independently expected task-context state.**

The Lakehouse also preserved the same context after JSON-safe materialization:

    LAKEHOUSE_JSON_VALID=1
    LAKEHOUSE_INNER_CONTEXT_JSON_VALID=1
    LAKEHOUSE_TO_SOURCE_CONTEXT_MATCH=1

## Product change

The frozen baseline was not modified.

The candidate changed only:

    yoda_agent_driver.h
    yoda_agent_driver.c
    yoda_mesh.c
    yoda_lakehouse.c

Unchanged:

    kyber_db.*
    yoda_shield.*
    main.c
    frozen baseline

The candidate added one context path:

    Frontier context
        ↓
    Driver context[]
        ↓
    Mesh safe_value
        ↓
    Kyber value

The Lakehouse candidate also added JSON-string escaping so an embedded compact JSON payload could be transported as valid NDJSON without changing the underlying Kyber value.

    KYBER_CHANGE=NO
    BASELINE_CHANGED=NO

## Candidate authority

Frozen baseline binary:

    7510fc055e1d53b0471077f4b8cb5a32c08828a0fb9f40c2e81a8859750b55c3

Executed candidate binary:

    8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

The candidate executed exactly once.

    PRODUCT_EXECUTION_COUNT=1
    PRODUCT_RERUN=NO

## What this case demonstrates

This case demonstrates a bounded product capability:

> **Yoda preserved both the identity and the minimal useful context of 100 real public agent tasks across concurrent execution, local persistence, and materialization, with zero missing, duplicate, extra, or mismatched records.**

The result is stronger than the previous queue case because the system no longer preserves only:

    which task?

It now preserves:

    which task?
    +
    what minimal context describes that task?

## What this case does not demonstrate

This case does **not** claim that Yoda:

- solved the GitHub issues;
- understood the issue semantically;
- prioritized or classified the issues;
- modified the Kubernetes repository;
- acted as a coding agent;
- preserved full issue bodies, comments, attachments, or complete GitHub history;
- proves arbitrary-payload support beyond the tested compact single-line JSON contract;
- proves general distributed-systems correctness.

The validated property is exact preservation of a bounded, useful task-context payload through one real local C23 agent workload.

## Evidence identities

    frontier.initial.tsv
    bf55043ae6bc0f54dcb61362b6164ed01a8fde6a6abec56d80ee0229c5f3213a

    frontier.tsv
    f162a3b01b85df80fb05e8b1d54b4b46330164925a85b57d2fefbf83a39aca7f

    source-context.tsv
    b67bab673c7d87159c06cacc4e50d9cb4232d15dca50183c9dfe49e0d4a5ef51

    expected.keys
    eedf2f9c544f843965d15d9aadbfeaa095ac4af9cf954064bf18bc0e6da7c204

    expected-context.tsv
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

    kyber_wal.db
    c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

    lakehouse.ndjson
    61787639eadbc6b25bfca896e0c41561c1e0261a14b2129d9003dfe7c3aac1e5

    yoda.rc
    9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa

    independent-context-validation.report
    84870b8f2021dd196c40080fabf612bc6fc71cf6da719a76ede43ba3e429c674

## Files

- `CASE.md` — source, context contract, candidate change, execution path, and success criteria.
- `RESULTS.md` — validated counts, exact reconciliation, hashes, and final classification.

## Outcome

    YODA_GITHUB_WORK_CONTEXT_001=PASS

    REAL_GITHUB_ISSUES=100
    WORKERS=16
    BATCH_SIZE=10
    SYSTEM_RC=0

    EXPECTED_IDENTITIES=100
    EXPECTED_CONTEXTS=100

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
