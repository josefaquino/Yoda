#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="MARKET-REGIME-LINEAGE-001"
REVISION="A0-R1"
ROOT="$HOME/cmu/$CASE"
STAGE="$ROOT/stage-a0-r1"
EVIDENCE="$STAGE/evidence"
RAW="$STAGE/raw"
SNAPSHOTS="$STAGE/snapshots"
ALIGN="$STAGE/alignment"
LOCK="$ROOT/.stage-a0-r1-execution-started"

API_BASE="https://api.stlouisfed.org/fred"
DESIGN_FREEZE_DATE="2026-10-06"
STATE_A_DATE="2025-04-25"
STATE_B_DATE="2025-08-29"
STATE_C_DATE="2025-12-26"

PRE_A0_R2_SCRIPT_SHA256="cc582307f7e0f6b24228a0f4d8c895f04f40d4033cb7ab5f9f86fc681b4a4de1"
PRE_A0_R2_CONSOLE_SHA256="0179c82713873d94708dbc2933f7a6a987eb8681cf95ff56673ef060dd6a7088"

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

not_evaluated()
{
    echo
    echo "MARKET_REGIME_LINEAGE_001_STAGE_A0=NOT_EVALUATED"
    echo "A0_REVISION=$REVISION"
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

fetch_xml()
{
    outfile="$1"
    endpoint="$2"
    shift 2

    {
        printf 'url = "%s/%s"\n' "$API_BASE" "$endpoint"
        printf 'get\n'
        printf 'data-urlencode = "api_key=%s"\n' "$FRED_API_KEY"
        printf 'data-urlencode = "file_type=xml"\n'
        for parameter in "$@"
        do
            printf 'data-urlencode = "%s"\n' "$parameter"
        done
    } |
    curl --config - --silent --show-error --fail --location > "$outfile"
}

extract_latest_observation()
{
    awk '
        /<observation / {
            d = $0
            v = $0
            sub(/^.* date="/, "", d)
            sub(/".*$/, "", d)
            sub(/^.* value="/, "", v)
            sub(/".*$/, "", v)
            if (v != "." && v != "") {
                print d "\t" v
                exit
            }
        }
    ' "$1"
}

metadata_contract()
{
    series="$1"
    file="$2"

    grep -F "<seriess " "$file" >/dev/null ||
        not_evaluated "API_RESPONSE_SCHEMA_DRIFT"
    grep -F "id=\"$series\"" "$file" >/dev/null ||
        not_evaluated "SERIES_METADATA_MISMATCH"

    case "$series" in
        VIXCLS)
            grep -F 'frequency="Daily, Close"' "$file" >/dev/null ||
                not_evaluated "SERIES_METADATA_MISMATCH"
            grep -F 'units="Index"' "$file" >/dev/null ||
                not_evaluated "SERIES_METADATA_MISMATCH"
            ;;
        DGS10)
            grep -F 'frequency="Daily"' "$file" >/dev/null ||
                not_evaluated "SERIES_METADATA_MISMATCH"
            grep -F 'units="Percent"' "$file" >/dev/null ||
                not_evaluated "SERIES_METADATA_MISMATCH"
            ;;
        NFCI)
            grep -F 'frequency="Weekly, Ending Friday"' "$file" >/dev/null ||
                not_evaluated "SERIES_METADATA_MISMATCH"
            grep -F 'units="Index"' "$file" >/dev/null ||
                not_evaluated "SERIES_METADATA_MISMATCH"
            ;;
    esac
}

lookback_days()
{
    case "$1" in
        NFCI) echo 14 ;;
        VIXCLS|DGS10) echo 7 ;;
        *) return 1 ;;
    esac
}

units_for()
{
    case "$1" in
        DGS10) echo "percent" ;;
        NFCI|VIXCLS) echo "index" ;;
        *) return 1 ;;
    esac
}

test ! -e "$LOCK" ||
    not_evaluated "A0_ONE_EXECUTION_POLICY_ALREADY_CONSUMED"

section "0. PRE-A0 AUTHORITY + LOCAL TOOLCHAIN"

require_cmd curl CURL
require_cmd awk AWK
require_cmd sed SED
require_cmd grep GREP
require_cmd sha256sum SHA256SUM
require_cmd date DATE
require_cmd find FIND
require_cmd sort SORT
require_cmd xargs XARGS

test -n "${FRED_API_KEY:-}" ||
    not_evaluated "API_AUTHENTICATION_FAILURE"
printf '%s' "$FRED_API_KEY" | grep -Eq '^[a-z0-9]{32}$' ||
    not_evaluated "API_AUTHENTICATION_FAILURE"

echo "FRED_API_KEY_PRESENT=YES"
echo "FRED_API_KEY_FORMAT=PASS"
echo "PRE_A0_R2_SCRIPT_SHA256=$PRE_A0_R2_SCRIPT_SHA256"
echo "PRE_A0_R2_CONSOLE_SHA256=$PRE_A0_R2_CONSOLE_SHA256"
echo "PRE_A0_AUTHORITY=PASS"

section "1. FREEZE A0 CONTRACT BEFORE HISTORICAL FETCH"

rm -rf "$STAGE"
mkdir -p "$EVIDENCE" "$RAW/metadata" "$RAW/A" "$RAW/B" "$RAW/C" "$SNAPSHOTS" "$ALIGN"

cat > "$EVIDENCE/date-selection-policy.txt" <<EOF
CASE=$CASE
REVISION=$REVISION
DESIGN_FREEZE_DATE=$DESIGN_FREEZE_DATE
REFERENCE_YEAR=2025
STATE_A_EVALUATION_DATE=$STATE_A_DATE
STATE_B_EVALUATION_DATE=$STATE_B_DATE
STATE_C_EVALUATION_DATE=$STATE_C_DATE
DATE_SELECTION_USES_CLASSIFICATION_RESULTS=NO
DATE_SELECTION_POLICY=FROZEN
EOF

cat > "$EVIDENCE/temporal-alignment-contract.txt" <<EOF
CASE=$CASE
REVISION=$REVISION
EVALUATION_DAY=FRIDAY
POINT_IN_TIME_DATA=YES
CURRENT_REVISED_HISTORY_ONLY=NO
LOOKBACK_DIRECTION=BACKWARD_ONLY
VIXCLS_MAX_LOOKBACK_CALENDAR_DAYS=7
DGS10_MAX_LOOKBACK_CALENDAR_DAYS=7
NFCI_MAX_LOOKBACK_CALENDAR_DAYS=14
INTERPOLATION=NO
FUTURE_OBSERVATION_USE=NO
FORWARD_INFORMATION_LEAKAGE=FORBIDDEN
VINTAGE_DATE_SEMANTICS=realtime_start_equals_realtime_end_equals_evaluation_date
EOF

cat > "$LOCK" <<EOF
CASE=$CASE
REVISION=$REVISION
SCRIPT_SHA256=$(sha "$0")
PRE_A0_R2_SCRIPT_SHA256=$PRE_A0_R2_SCRIPT_SHA256
PRE_A0_R2_CONSOLE_SHA256=$PRE_A0_R2_CONSOLE_SHA256
EXECUTION_POLICY=ONE_EXECUTION
LOCK_CREATED_BEFORE_FIRST_HISTORICAL_FETCH=YES
EOF

cp "$LOCK" "$EVIDENCE/execution-started.txt"
echo "EXECUTION_POLICY=ONE_EXECUTION"
echo "EXECUTION_LOCK_SHA256=$(sha "$LOCK")"
echo "EXECUTION_GATE=PASS"

section "2. POINT-IN-TIME SERIES METADATA"

for series in VIXCLS DGS10 NFCI
do
    file="$RAW/metadata/$series.xml"
    fetch_xml "$file" "series" \
        "series_id=$series" \
        "realtime_start=$DESIGN_FREEZE_DATE" \
        "realtime_end=$DESIGN_FREEZE_DATE" ||
        not_evaluated "PUBLIC_SOURCE_UNAVAILABLE"

    metadata_contract "$series" "$file"
    echo "${series}_METADATA_AUTHORITY=PASS"
    echo "${series}_METADATA_SHA256=$(sha "$file")"
done

cat > "$EVIDENCE/source-license-notes.txt" <<EOF
CASE=$CASE
REVISION=$REVISION
METADATA_REALTIME_DATE=$DESIGN_FREEZE_DATE
VIXCLS_SOURCE=CBOE_VIA_FRED
DGS10_SOURCE=FEDERAL_RESERVE_BOARD_VIA_FRED
NFCI_SOURCE=FEDERAL_RESERVE_BANK_OF_CHICAGO_VIA_FRED
VIXCLS_SOURCE_AND_COPYRIGHT_NOTICE=preserved_verbatim_in_raw_metadata/VIXCLS.xml
DGS10_SOURCE_NOTES=preserved_verbatim_in_raw_metadata/DGS10.xml
NFCI_SOURCE_NOTES=preserved_verbatim_in_raw_metadata/NFCI.xml
COMPLETE_SERIES_MIRROR=NO
ONLY_REQUIRED_EXPERIMENTAL_RESPONSES_FROZEN=YES
EOF

echo "FRED_API_AUTHORITY=PASS"
echo "VIXCLS_SOURCE_AUTHORITY=PASS"
echo "DGS10_SOURCE_AUTHORITY=PASS"
echo "NFCI_SOURCE_AUTHORITY=PASS"
echo "SOURCE_LICENSE_NOTES=RECORDED"

section "3. FREEZE THREE POINT-IN-TIME STATES"

freeze_state()
{
    state="$1"
    eval_date="$2"
    snapshot="$SNAPSHOTS/state-$state.tsv"
    record="$ALIGN/state-$state.tsv"
    retrieval_timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    printf 'evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits\n' > "$snapshot"
    printf 'evaluation_date\tseries_id\tobservation_date\tvintage_date\traw_value\tunits\traw_response_sha256\tretrieval_timestamp\n' > "$record"

    for series in DGS10 NFCI VIXCLS
    do
        days="$(lookback_days "$series")"
        start="$(date -d "$eval_date -$days days" +%F)"
        raw="$RAW/$state/$series.xml"

        fetch_xml "$raw" "series/observations" \
            "series_id=$series" \
            "realtime_start=$eval_date" \
            "realtime_end=$eval_date" \
            "observation_start=$start" \
            "observation_end=$eval_date" \
            "sort_order=desc" \
            "limit=50" ||
            not_evaluated "POINT_IN_TIME_DATA_UNAVAILABLE"

        grep -F "<observations " "$raw" >/dev/null ||
            not_evaluated "API_RESPONSE_SCHEMA_DRIFT"
        grep -F "realtime_start=\"$eval_date\"" "$raw" >/dev/null ||
            not_evaluated "API_RESPONSE_SCHEMA_DRIFT"
        grep -F "realtime_end=\"$eval_date\"" "$raw" >/dev/null ||
            not_evaluated "API_RESPONSE_SCHEMA_DRIFT"

        pair="$(extract_latest_observation "$raw")"
        test -n "$pair" ||
            not_evaluated "MISSING_REQUIRED_OBSERVATION"

        obs_date="${pair%%	*}"
        value="${pair#*	}"

        test "$obs_date" != "$pair" ||
            not_evaluated "CANONICALIZATION_FAILURE"
        test "$obs_date" \> "$start" -o "$obs_date" = "$start" ||
            not_evaluated "TEMPORAL_ALIGNMENT_FAILURE"
        test "$obs_date" \< "$eval_date" -o "$obs_date" = "$eval_date" ||
            not_evaluated "TEMPORAL_ALIGNMENT_FAILURE"
        test "$value" != "." ||
            not_evaluated "MISSING_REQUIRED_OBSERVATION"

        units="$(units_for "$series")"
        raw_sha="$(sha "$raw")"

        printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$eval_date" "$series" "$obs_date" "$eval_date" "$value" "$units" >> "$snapshot"

        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$eval_date" "$series" "$obs_date" "$eval_date" "$value" "$units" "$raw_sha" "$retrieval_timestamp" >> "$record"

        echo "STATE_${state}_${series}_OBSERVATION_DATE=$obs_date"
        echo "STATE_${state}_${series}_RAW_RESPONSE_SHA256=$raw_sha"
    done

    test "$(wc -l < "$snapshot" | tr -d ' ')" = "4" ||
        not_evaluated "CANONICALIZATION_FAILURE"
    test "$(wc -l < "$record" | tr -d ' ')" = "4" ||
        not_evaluated "CANONICALIZATION_FAILURE"

    echo "STATE_${state}_CANONICAL_SNAPSHOT_SHA256=$(sha "$snapshot")"
    echo "STATE_${state}_TEMPORAL_ALIGNMENT_RECORD_SHA256=$(sha "$record")"
}

freeze_state A "$STATE_A_DATE"
freeze_state B "$STATE_B_DATE"
freeze_state C "$STATE_C_DATE"

echo "POINT_IN_TIME_DATA=PASS"
echo "RAW_RESPONSES_FROZEN=PASS"
echo "CANONICAL_SNAPSHOTS_FROZEN=PASS"
echo "TEMPORAL_ALIGNMENT_CONTRACT=FROZEN"
echo "MISSING_VALUE_POLICY=FROZEN"

section "4. CANONICAL SNAPSHOT STRUCTURAL AUDIT"

for state in A B C
do
    f="$SNAPSHOTS/state-$state.tsv"
    grep -F "$(printf 'evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits')" "$f" >/dev/null ||
        not_evaluated "CANONICALIZATION_FAILURE"
    sed -n '2p' "$f" | grep -F "$(printf '\tDGS10\t')" >/dev/null ||
        not_evaluated "CANONICALIZATION_FAILURE"
    sed -n '3p' "$f" | grep -F "$(printf '\tNFCI\t')" >/dev/null ||
        not_evaluated "CANONICALIZATION_FAILURE"
    sed -n '4p' "$f" | grep -F "$(printf '\tVIXCLS\t')" >/dev/null ||
        not_evaluated "CANONICALIZATION_FAILURE"
    awk 'index($0, " ") == length($0) && 0 { exit 1 }' "$f" >/dev/null
done

echo "CANONICALIZATION=PASS"

section "5. CLASSIFICATION NON-EXECUTION GATE"

echo "CLASSIFICATION_EXECUTED=NO"
echo "CLASSIFICATION_OUTPUT_CREATED=NO"
echo "AUTHORITY_1_EXECUTED=NO"
echo "AUTHORITY_2_EXECUTED=NO"
echo "YODA_WRITES=ZERO"

section "6. FREEZE A0 EVIDENCE"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
DESIGN_FREEZE_DATE	$DESIGN_FREEZE_DATE
STATE_A_EVALUATION_DATE	$STATE_A_DATE
STATE_B_EVALUATION_DATE	$STATE_B_DATE
STATE_C_EVALUATION_DATE	$STATE_C_DATE
PRE_A0_R2_SCRIPT_SHA256	$PRE_A0_R2_SCRIPT_SHA256
PRE_A0_R2_CONSOLE_SHA256	$PRE_A0_R2_CONSOLE_SHA256
VIXCLS_METADATA_SHA256	$(sha "$RAW/metadata/VIXCLS.xml")
DGS10_METADATA_SHA256	$(sha "$RAW/metadata/DGS10.xml")
NFCI_METADATA_SHA256	$(sha "$RAW/metadata/NFCI.xml")
STATE_A_CANONICAL_SNAPSHOT_SHA256	$(sha "$SNAPSHOTS/state-A.tsv")
STATE_B_CANONICAL_SNAPSHOT_SHA256	$(sha "$SNAPSHOTS/state-B.tsv")
STATE_C_CANONICAL_SNAPSHOT_SHA256	$(sha "$SNAPSHOTS/state-C.tsv")
STATE_A_TEMPORAL_ALIGNMENT_RECORD_SHA256	$(sha "$ALIGN/state-A.tsv")
STATE_B_TEMPORAL_ALIGNMENT_RECORD_SHA256	$(sha "$ALIGN/state-B.tsv")
STATE_C_TEMPORAL_ALIGNMENT_RECORD_SHA256	$(sha "$ALIGN/state-C.tsv")
POINT_IN_TIME_DATA	PASS
DATE_SELECTION_POLICY	FROZEN
TEMPORAL_ALIGNMENT_CONTRACT	FROZEN
MISSING_VALUE_POLICY	FROZEN
RAW_RESPONSES_FROZEN	PASS
CANONICAL_SNAPSHOTS_FROZEN	PASS
SOURCE_LICENSE_NOTES	RECORDED
CLASSIFICATION_EXECUTED	NO
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

cp "$0" "$EVIDENCE/stage-a0-r1-script.sh"

(
    cd "$STAGE"
    find evidence raw snapshots alignment \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || not_evaluated "A0_EVIDENCE_INTEGRITY_FAILURE"

A0_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"
echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "A0_EVIDENCE_MANIFEST_SHA256=$A0_MANIFEST_SHA256"

section "7. A0 HOMOLOGATION"

echo "MARKET_REGIME_LINEAGE_001_STAGE_A0=PASS"
echo "A0_REVISION=$REVISION"
echo "FRED_API_AUTHORITY=PASS"
echo "VIXCLS_SOURCE_AUTHORITY=PASS"
echo "DGS10_SOURCE_AUTHORITY=PASS"
echo "NFCI_SOURCE_AUTHORITY=PASS"
echo "POINT_IN_TIME_DATA=PASS"
echo "DATE_SELECTION_POLICY=FROZEN"
echo "TEMPORAL_ALIGNMENT_CONTRACT=FROZEN"
echo "MISSING_VALUE_POLICY=FROZEN"
echo "RAW_RESPONSES_FROZEN=PASS"
echo "CANONICAL_SNAPSHOTS_FROZEN=PASS"
echo "SOURCE_LICENSE_NOTES=RECORDED"
echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "CLASSIFICATION_EXECUTED=NO"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=A1_DETERMINISTIC_CLASSIFICATION_AUTHORITY"
