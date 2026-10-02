# BGP-RIPE-RIS-001 — Case Contract

## Question

Can KyberDB apply a deterministic 50,000-event slice of real public RIPE RIS BGP updates, persist the resulting route state with full durability, close and reopen the database, and reproduce exactly the same final state as an independent oracle?

## Public authority

Authority: RIPE NCC Routing Information Service (RIS)

Collector:

    rrc00

Historical source:

    updates.20250101.0000.gz

Source time:

    2025-01-01T00:00:00Z

URL:

https://data.ris.ripe.net/rrc00/2025.01/updates.20250101.0000.gz

Frozen source identity from the validated run:

    SOURCE_BYTES=4656490
    SOURCE_SHA256=00f820cfa3f48c563fc63ea7ae6c889b48f86b6187a487f74c935765b702a768

## Transformation contract

The MRT source is parsed with `bgpdump` and normalized deterministically to the first 50,000 valid announcement/withdrawal events.

Normalized fields:

    sequence
    action
    timestamp
    peer_ip
    peer_asn
    prefix
    as_path

Event mapping:

    ANNOUNCE -> put/update
    WITHDRAW -> delete

## Route identity

A route is identified by:

    peer_ip + peer_asn + prefix

This avoids incorrectly treating the same prefix announced by different peers as one global route.

Stored value for an active route:

    last_timestamp + as_path

## Window semantics

The source is an updates window, not a complete prior RIB.

A withdrawal can therefore reference a route that existed before the beginning of the tested window. In the window-local model, deleting a key that is not currently present is a semantic no-op.

The independent oracle and KyberDB harness use the same rule.

## Independent oracle

An AWK reference model processes the normalized stream independently of KyberDB:

- `ANNOUNCE` assigns the latest value to the route identity;
- `WITHDRAW` deletes the route identity if present;
- surviving route identities and values are emitted and sorted;
- the final state is hashed with SHA-256.

## KyberDB path

The harness uses only the public embedded ABI:

- `kyber_env_open`
- `kyber_txn_begin`
- `kyber_txn_put`
- `kyber_txn_delete`
- `kyber_txn_get`
- `kyber_txn_commit`
- `kyber_txn_abort`
- `kyber_verify`
- `kyber_env_close`

Durability mode:

    KYBER_DURABILITY_FULL

No internal KyberDB API is used.

## Workload

    REAL_BGP_EVENTS=50000
    BATCH_SIZE=10000
    EXPECTED_COMMITS=5

The database is verified before close, reopened, verified again, and the state is reconstructed through public `get` operations over the complete manifest of route identities seen in the input window.

## Gates

The case passes only if all of these hold:

    PUBLIC_SOURCE_AUTHORITY=PASS
    SOURCE_IDENTITY_FROZEN=PASS
    MRT_PARSE=PASS
    REAL_BGP_EVENTS=PASS
    DATASET_CONTRACT=PASS
    INDEPENDENT_ORACLE=PASS
    KYBER_PUBLIC_ABI=PASS
    FULL_DURABILITY=PASS
    DATABASE_VERIFY_PRE_CLOSE=PASS
    CLOSE_REOPEN=PASS
    DATABASE_VERIFY_POST_REOPEN=PASS
    ORACLE_RECORD_COUNT=KYBER_RECORD_COUNT
    ORACLE_STATE_SHA256=KYBER_STATE_SHA256
    POST_REOPEN_STATE_EQUIVALENCE=PASS
    EVIDENCE_INTEGRITY=PASS
    RUN_RC=0

Performance values are measured observations, not correctness gates.

## Non-claims

This case does not claim that KyberDB is a BGP routing daemon, replaces a route collector, outperforms specialized routing databases, or provides a universal throughput number.

It tests exact mutation-state correctness and durability for one frozen real-world public routing workload.
