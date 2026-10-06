#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
REVISION="PRE-A0-R1"

ROOT="$HOME/cmu/$CASE"
TMP="$ROOT/.pre-a0-tmp"

API_BASE="https://api.stlouisfed.org/fred"
PROBE_DATE="2020-01-02"
PROBE_START="2019-12-20"

SERIES="VIXCLS DGS10 NFCI"

cleanup()
{
    rm -rf "$TMP"
}

trap cleanup EXIT HUP INT TERM

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

not_evaluated()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_PRE_A0=NOT_EVALUATED"
    echo "PRE_A0_REVISION=$REVISION"
    echo "FAILURE_CLASS=$1"
    echo "YODA_WRITES=ZERO"
    echo "YODA_CHANGE=NO"
    echo "KYBER_CHANGE=NO"
    exit 1
}

require_cmd()
{
    cmd="$1"
    label="$2"

    if command -v "$cmd" >/dev/null 2>&1
    then
        echo "$label=PASS"
    else
        echo "$label=FAIL"
        not_evaluated "TOOLCHAIN_DRIFT"
    fi
}

fetch_json()
{
    outfile="$1"
    endpoint="$2"
    shift 2

    {
        printf 'data-urlencode = "api_key=%s"\\n' "$FRED_API_KEY"
        printf 'data-urlencode = "file_type=json"\\n'
    } |
    curl --config - \
        --silent \
        --show-error \
        --fail \
        --location \
        --get \
        "$API_BASE/$endpoint" \
        "$@" \
        > "$outfile"
}

section "0. LOCAL TOOLCHAIN"

require_cmd curl CURL
require_cmd cc CC
require_cmd awk AWK
require_cmd sha256sum SHA256SUM
require_cmd grep GREP
require_cmd sed SED

section "1. FRED API KEY"

if test -n "${FRED_API_KEY:-}"
then
    echo "FRED_API_KEY_PRESENT=YES"
else
    echo "FRED_API_KEY_PRESENT=NO"
    not_evaluated "API_AUTHENTICATION_FAILURE"
fi

if printf '%s' "$FRED_API_KEY" |
   grep -Eq '^[a-z0-9]{32}$'
then
    echo "FRED_API_KEY_FORMAT=PASS"
else
    echo "FRED_API_KEY_FORMAT=FAIL"
    not_evaluated "API_AUTHENTICATION_FAILURE"
fi

mkdir -p "$TMP"

section "2. CURRENT SERIES AUTHORITY CONNECTIVITY"

for series_id in $SERIES
do
    meta="$TMP/$series_id-series.json"
    obs="$TMP/$series_id-observation.json"

    fetch_json         "$meta"         "series"         --data-urlencode "series_id=$series_id" ||
        not_evaluated "PUBLIC_SOURCE_UNAVAILABLE"

    grep -Eq '"id"[[:space:]]*:[[:space:]]*"'"$series_id"'"' "$meta" ||
        not_evaluated "SERIES_METADATA_MISMATCH"

    fetch_json         "$obs"         "series/observations"         --data-urlencode "series_id=$series_id"         --data-urlencode "sort_order=desc"         --data-urlencode "limit=1" ||
        not_evaluated "PUBLIC_SOURCE_UNAVAILABLE"

    grep -Eq '"observations"[[:space:]]*:' "$obs" ||
        not_evaluated "API_RESPONSE_SCHEMA_DRIFT"

    case "$series_id" in
        VIXCLS) echo "VIXCLS_API_RESPONSE=PASS" ;;
        DGS10)  echo "DGS10_API_RESPONSE=PASS" ;;
        NFCI)   echo "NFCI_API_RESPONSE=PASS" ;;
    esac

    echo "${series_id}_METADATA_RESPONSE_SHA256=$(sha256sum "$meta" | awk '{print $1}')"
    echo "${series_id}_CURRENT_OBSERVATION_RESPONSE_SHA256=$(sha256sum "$obs" | awk '{print $1}')"
done

section "3. POINT-IN-TIME PARAMETER SUPPORT"

for series_id in $SERIES
do
    pit="$TMP/$series_id-point-in-time-probe.json"

    fetch_json         "$pit"         "series/observations"         --data-urlencode "series_id=$series_id"         --data-urlencode "realtime_start=$PROBE_DATE"         --data-urlencode "realtime_end=$PROBE_DATE"         --data-urlencode "observation_start=$PROBE_START"         --data-urlencode "observation_end=$PROBE_DATE"         --data-urlencode "sort_order=desc"         --data-urlencode "limit=1" ||
        not_evaluated "POINT_IN_TIME_DATA_UNAVAILABLE"

    grep -Eq '"realtime_start"[[:space:]]*:[[:space:]]*"'"$PROBE_DATE"'"' "$pit" ||
        not_evaluated "API_RESPONSE_SCHEMA_DRIFT"

    grep -Eq '"realtime_end"[[:space:]]*:[[:space:]]*"'"$PROBE_DATE"'"' "$pit" ||
        not_evaluated "API_RESPONSE_SCHEMA_DRIFT"

    echo "${series_id}_POINT_IN_TIME_PROBE=PASS"
    echo "${series_id}_POINT_IN_TIME_RESPONSE_SHA256=$(sha256sum "$pit" | awk '{print $1}')"
done

echo "POINT_IN_TIME_PARAMETER_SUPPORT=PASS"

section "4. SECRET HYGIENE"

# Only a boolean/format status is printed. The key itself is never emitted.
# PRE-A0 response bodies live only in the temporary directory and are removed
# by the EXIT trap. They are not CASE evidence authorities.

echo "FRED_API_KEY_PRINTED=NO"
echo "PRE_A0_RESPONSES_FROZEN_AS_CASE_EVIDENCE=NO"

section "5. YODA WRITE CONTRACT"

echo "YODA_WRITES=ZERO"
echo "YODA_STORE_CREATED=NO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"

section "6. PRE-A0 RESULT"

echo "MARKET_REGIME_LINEAGE_001_PRE_A0=PASS"
echo "PRE_A0_REVISION=$REVISION"
echo "CURL=PASS"
echo "CC=PASS"
echo "AWK=PASS"
echo "SHA256SUM=PASS"
echo "FRED_API_KEY_PRESENT=YES"
echo "FRED_API_KEY_FORMAT=PASS"
echo "VIXCLS_API_RESPONSE=PASS"
echo "DGS10_API_RESPONSE=PASS"
echo "NFCI_API_RESPONSE=PASS"
echo "POINT_IN_TIME_PARAMETER_SUPPORT=PASS"
echo "YODA_WRITES=ZERO"
echo "NEXT_GATE=A0_PUBLIC_DATA_AND_TEMPORAL_AUTHORITY"
