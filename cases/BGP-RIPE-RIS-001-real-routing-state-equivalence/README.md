# BGP-RIPE-RIS-001 — Real Routing-State Mutation Equivalence

BGP-RIPE-RIS-001 is a KyberDB field case using real public BGP update data from RIPE NCC Routing Information Service (RIS).

It asks a narrow question:

> Can KyberDB apply a real stream of BGP announcements and withdrawals, persist the resulting state with full durability, close and reopen the database, and reconstruct exactly the same routing state as an independent oracle?

The validated experiment used the RIPE RIS `rrc00` collector and the historical update file:

    updates.20250101.0000.gz

Source time:

    2025-01-01T00:00:00Z

Public source:

https://data.ris.ripe.net/rrc00/2025.01/updates.20250101.0000.gz

## Result

**PASS**

The tested run produced:

- 386,834 MRT records parsed from the public source;
- 50,000 real BGP events selected deterministically;
- 47,838 `ANNOUNCE` events;
- 2,162 `WITHDRAW` events;
- 19,059 distinct route identities;
- route identity defined as `peer_ip + peer_asn + prefix`;
- 18,318 active routes in the independent oracle;
- 18,318 active routes reconstructed from KyberDB after close/reopen;
- exact SHA-256 equality between oracle state and KyberDB state;
- database verification before close and after reopen;
- frozen evidence with SHA-256 verification;
- no engine change required.

Oracle and KyberDB final-state SHA-256:

    edff6d9b57012b610a99c9c03dc9fd008c1632d8602186bc98c930cc1e611890

Final gate:

    POST_REOPEN_STATE_EQUIVALENCE=PASS

No LLM, Python, SQL, or internal KyberDB API was used in the tested path.

## What this case demonstrates

This case exercises a different workload from snapshot-oriented observation cases.

The state changes over time through real routing mutations:

    ANNOUNCE -> put/update
    WITHDRAW -> delete

The database is then verified, closed, reopened, verified again, and queried through the public embedded ABI to reconstruct the surviving route state.

The reconstructed state matched the independently computed oracle byte-for-byte after sorting.

This is a correctness and durability result for the tested workload. It does not claim that KyberDB is a BGP routing system, that it outperforms specialized routing databases, or that the measured throughput represents a universal performance result.

## Important window semantics

The experiment starts from a five-minute RIPE RIS updates file rather than from a complete prior RIB.

Therefore some withdrawals refer to routes that existed before the experiment window. In the validated run:

    WITHDRAW_NOT_FOUND=735

For the window-local model, these are semantic no-ops. The independent oracle uses the same rule, and exact final-state equivalence still passed.

## Performance observations

Measured in the validated run:

    INGEST_OPS_S=2579.907

    COMMIT_P50_US=1072689
    COMMIT_P95_US=1712545
    COMMIT_P99_US=1712545
    COMMIT_MAX_US=1712545

    REOPEN_NS=271938004
    DATABASE_BYTES=129483710

These values are observations, not pass/fail thresholds.

## Engine authority

The experiment used the KyberDB Public Embedded ABI with full durability.

Validated identities:

    kyber.h SHA256
    6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d

    libkyber.a SHA256
    ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4

KyberDB reported:

    0.0.1-genesis

This case exercises KyberDB directly. It should not be interpreted as a Yoda CORE-015 CLI validation case.

## Files

- `CASE.md` — hypothesis, public-data contract, identity model, method, and validation gates.
- `RESULTS.md` — validated measurements, hashes, and final classification.

## Outcome

    BGP_RIPE_RIS_REAL_001_C11=PASS
    PUBLIC_SOURCE_AUTHORITY=PASS
    SOURCE_IDENTITY_FROZEN=PASS
    MRT_PARSE=PASS
    REAL_BGP_EVENTS=PASS
    INDEPENDENT_ORACLE=PASS
    KYBER_PUBLIC_ABI=PASS
    FULL_DURABILITY=PASS
    DATABASE_VERIFY_PRE_CLOSE=PASS
    CLOSE_REOPEN=PASS
    DATABASE_VERIFY_POST_REOPEN=PASS
    POST_REOPEN_STATE_EQUIVALENCE=PASS
    EVIDENCE_INTEGRITY=PASS
    ENGINE_CHANGE=NO
