# PRE-A0 Transport Diagnostic 001

## Purpose

Read-only diagnosis after PRE-A0-R1 stopped with:

```text
MARKET_REGIME_LINEAGE_001_PRE_A0=NOT_EVALUATED
FAILURE_CLASS=SERIES_METADATA_MISMATCH
```

No historical classification was executed and no A0 gate was consumed.

## Observed result

The same official FRED metadata endpoint was queried with a self-contained curl config request.

```text
FRED_API_KEY_PRESENT=YES
CURL_RC=0

RESPONSE_SHA256=
221d923b852ce5a399c46d9cc4270c3916f57d45feec99f6f86b610828d58ce3

RESPONSE_BYTES=657

CONTENT_TYPE_JSON=YES
SERIESS_FIELD=YES
VIXCLS_ID=YES
ERROR_OBJECT=NO

YODA_WRITES=ZERO
HISTORICAL_CLASSIFICATION_EXECUTED=NO
A0_GATE_CONSUMED=NO
DIAGNOSTIC=COMPLETE
```

The response exposed the documented metadata structure and the expected `VIXCLS` series identity.

## Adjudication

```text
FRED_METADATA_AUTHORITY_FAILURE=NO
CASE_HYPOTHESIS_FAILURE=NO
YODA_FAILURE=NO
KYBER_FAILURE=NO

PRE_A0_R1=NOT_EVALUATED
PRE_A0_R1_FAILURE_CLASS=HARNESS_TRANSPORT_COMPOSITION
```

Permitted continuation:

```text
PRE-A0-R2
same CASE
same authorities
same dates
same classifier
same thresholds
transport helper only changed
```
