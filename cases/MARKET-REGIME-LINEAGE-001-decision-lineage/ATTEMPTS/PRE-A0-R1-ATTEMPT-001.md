# PRE-A0-R1 — Connectivity Attempt 001

## Result

```text
MARKET_REGIME_LINEAGE_001_PRE_A0=NOT_EVALUATED
PRE_A0_REVISION=PRE-A0-R1
FAILURE_CLASS=SERIES_METADATA_MISMATCH
PRE_A0_RUN_RC=1

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The failure occurred on the first series metadata-shape assertion, before any historical snapshot retrieval or classification.

## Passed before interruption

```text
BASH_PARSE=PASS
SCRIPT_IDENTITY=PASS

CURL=PASS
CC=PASS
AWK=PASS
SHA256SUM=PASS
GREP=PASS
SED=PASS

FRED_API_KEY_PRESENT=YES
FRED_API_KEY_FORMAT=PASS
```

## Frozen identities

```text
PRE_A0_R1_SCRIPT_SHA256=
0f056ad9e55c8af83d8e65e39c42c94a944259b01b8d861f9265216f7e7bbb49

PRE_A0_R1_CONSOLE_SHA256=
dbe7939199930b71e867139b1ae36ae596d4954b560b7388abba497ebc902f83
```

## Classification

This attempt is not a Yoda failure and not a CASE hypothesis failure.

The official FRED `fred/series` JSON schema documents a `seriess` array containing a `series.id` field. Therefore the next permitted action is a read-only transport/schema diagnostic against the same current metadata endpoint.

No historical classifications have been inspected.

```text
A0_GATE_CONSUMED=NO
HISTORICAL_CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
```
