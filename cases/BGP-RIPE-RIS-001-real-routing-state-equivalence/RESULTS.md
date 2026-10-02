# BGP-RIPE-RIS-001 — Results

## Classification

    BGP_RIPE_RIS_REAL_001_C11=PASS

## Public source

    AUTHORITY=RIPE_NCC_RIS
    COLLECTOR=rrc00
    SOURCE_TIME=2025-01-01T00:00:00Z
    SOURCE_BYTES=4656490
    SOURCE_SHA256=00f820cfa3f48c563fc63ea7ae6c889b48f86b6187a487f74c935765b702a768

The MRT source parsed successfully into 386,834 `bgpdump` output records.

## Deterministic workload

    DATASET_EVENTS=50000
    DATASET_SHA256=3cb1599c9fbc712339cea93f6bc3f5dff2d69ad6fdf984fbd49defaddfd8f7d6

    ANNOUNCE_EVENTS=47838
    WITHDRAW_EVENTS=2162

    DISTINCT_ROUTE_KEYS=19059
    ROUTE_IDENTITY=peer_ip+peer_asn+prefix

## Oracle

    ORACLE_ACTIVE_ROUTES=18318
    ORACLE_STATE_SHA256=edff6d9b57012b610a99c9c03dc9fd008c1632d8602186bc98c930cc1e611890

## KyberDB post-reopen state

    KYBER_ACTIVE_ROUTES=18318
    KYBER_STATE_SHA256=edff6d9b57012b610a99c9c03dc9fd008c1632d8602186bc98c930cc1e611890

    POST_REOPEN_STATE_EQUIVALENCE=PASS

The sorted state reconstructed through the KyberDB public API after close/reopen was byte-for-byte identical to the independent oracle state.

## Durability and verification

    DATABASE_VERIFY_PRE_CLOSE=PASS
    CLOSE_REOPEN=PASS
    DATABASE_VERIFY_POST_REOPEN=PASS

The experiment used five full-durability commit batches of 10,000 input events each.

Window-local withdrawals that referenced no route currently present:

    WITHDRAW_NOT_FOUND=735

These are expected to be possible because the tested update window begins without loading the complete prior RIB. The oracle applies the same window-local semantics.

## Performance observations

    INGEST_OPS_S=2579.907

    COMMIT_P50_US=1072689
    COMMIT_P95_US=1712545
    COMMIT_P99_US=1712545
    COMMIT_MAX_US=1712545

    REOPEN_NS=271938004
    DATABASE_BYTES=129483710

These measurements are observations from the validated run and are not pass/fail thresholds.

## KyberDB authority

Public header:

    SHA256=6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d

Active static library:

    SHA256=ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4

Reported version:

    0.0.1-genesis

Harness identities:

    HARNESS_C_SHA256=15d19024509d897f74e96f86d21748c7c7506ab263092fd2b6025ef4ec9cd450
    HARNESS_BINARY_SHA256=6b72f609cc2fe9c917c0e0866e9fc2e497355c56fe1f6022094e99795a6a1e45

## Final gates

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
    ORACLE_RECORD_COUNT=18318
    KYBER_RECORD_COUNT=18318
    POST_REOPEN_STATE_EQUIVALENCE=PASS
    EVIDENCE_INTEGRITY=PASS
    RUN_RC=0
    ENGINE_CHANGE=NO

## Interpretation

This case adds a real mutation-heavy public-data workload to the evidence base.

Unlike snapshot preservation cases, the tested state is repeatedly changed by announcements, updates, and withdrawals. After persistence and reopen, the resulting KyberDB state remained exactly equivalent to the independently derived routing state.

No engine change was required for this case.
