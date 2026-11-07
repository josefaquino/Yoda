#!/usr/bin/env bash
set -eu
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
E2="$ROOT/evidence/CHANNEL-CONTRAST-009"
E3="$ROOT/evidence/CROSS-TEST-011"
S2="$ROOT/evidence/C11-SIGNAL-READER-005"
OUT="$ROOT/reports/CASE-REPORT-012"

fail() {
    echo "STOP=$1" >&2
    exit 1
}

echo "============================================================"
echo " YODA-TRACTIAN-NASA-001"
echo " CASE REPORT 012 — TWO INDEPENDENT NASA TRIALS"
echo "============================================================"

echo
echo "=== 1. VERIFY EXISTING EVIDENCE ==="

for d in "$E2" "$E3" "$S2"; do
    test -f "$d/artifacts.sha256" ||
        fail "MISSING_EVIDENCE:$d"

    (
        cd "$d"
        sha256sum -c --status artifacts.sha256
    ) || fail "HASH_MISMATCH:$d"
done

echo "INPUT_EVIDENCE=PASS"

for f in \
    "$E2/channels.tsv" \
    "$E3/channels.tsv" \
    "$E2/alerts.tsv" \
    "$E3/events.tsv" \
    "$E2/common-mode.tsv" \
    "$E3/common-mode.tsv" \
    "$S2/features.tsv" \
    "$E3/features.tsv"
do
    test -s "$f" || fail "MISSING_FILE:$f"
done

test "$(wc -l < "$S2/features.tsv")" -eq 3937 ||
    fail IMS2_FEATURE_COUNT

test "$(wc -l < "$E3/features.tsv")" -eq 25297 ||
    fail IMS3_FEATURE_COUNT

test ! -e "$OUT" || fail REPORT_ALREADY_EXISTS

mkdir -p "$OUT"

echo
echo "=== 2. CONSOLIDATE CHANNEL RESULTS ==="

{
    printf 'test\tchannel\tbaseline_rms_first100\t'
    printf 'first_alert_index\tfirst_alert_timestamp\t'
    printf 'episodes\tmax_rms_ratio\n'

    awk -F '\t' '
    NR==1 {
        if(NF!=7 || $1!="channel") exit 2
        next
    }
    NF!=7 || $1!~/^[1-4]$/ {exit 2}
    {
        printf "IMS2\t%s\t%s\t%s\t%s\t%s\t%s\n",
            $1,$2,$3,$4,$5,$7
    }
    END {if(NR!=5) exit 2}
    ' "$E2/channels.tsv"

    awk -F '\t' '
    NR==1 {
        if(NF!=6 || $1!="channel") exit 2
        next
    }
    NF!=6 || $1!~/^[1-4]$/ {exit 2}
    {
        printf "IMS3\t%s\t%s\t%s\t%s\t%s\t%s\n",
            $1,$2,$3,$4,$5,$6
    }
    END {if(NR!=5) exit 2}
    ' "$E3/channels.tsv"

} > "$OUT/channel-comparison.tsv"

test "$(wc -l < "$OUT/channel-comparison.tsv")" -eq 9 ||
    fail SUMMARY_COUNT

echo "CHANNEL_COMPARISON=PASS"

echo
echo "=== 3. COUNT AND VERIFY EVENTS ==="

RISE2=$(( $(wc -l < "$E2/alerts.tsv") - 1 ))
RISE3=$(( $(wc -l < "$E3/events.tsv") - 1 ))
LOW2=$(( $(wc -l < "$E2/common-mode.tsv") - 1 ))
LOW3=$(( $(wc -l < "$E3/common-mode.tsv") - 1 ))

awk -F '\t' -v expected="$RISE2" '
NR>1 {sum+=$5}
END {if(sum!=expected || NR!=5) exit 1}
' "$E2/channels.tsv" || fail IMS2_EVENT_MISMATCH

awk -F '\t' -v expected="$RISE3" '
NR>1 {sum+=$5}
END {if(sum!=expected || NR!=5) exit 1}
' "$E3/channels.tsv" || fail IMS3_EVENT_MISMATCH

{
    printf 'trial\tindex\ttimestamp\tevent\t'
    printf 'channel\trms_ratio\tsource_sha256\n'

    awk -F '\t' '
    NR>1 {
        if(NF!=5) exit 2
        print "IMS2\t"$1"\t"$2 \
              "\tRMS_RISE_PERSISTENT\t"$3 \
              "\t"$4"\t"$5
    }
    ' "$E2/alerts.tsv"

    awk -F '\t' '
    NR>1 {
        if(NF!=6) exit 2
        print "IMS3\t"$1"\t"$2 \
              "\t"$3"\t"$4"\t"$5"\t"$6
    }
    ' "$E3/events.tsv"

} > "$OUT/alerts.tsv"

{
    printf 'trial\tcaptures\trise_events\t'
    printf 'common_mode_low_snapshots\n'
    printf 'IMS2\t984\t%s\t%s\n' "$RISE2" "$LOW2"
    printf 'IMS3\t6324\t%s\t%s\n' "$RISE3" "$LOW3"
} > "$OUT/counts.tsv"

echo "EVENT_CONSOLIDATION=PASS"

echo
echo "=== 4. GENERATE TECHNICAL REPORT ==="

cat > "$OUT/REPORT.md" <<'MD'
# Yoda Industrial Bearing Evidence Replay

**Independent engineering case — NASA IMS Bearings**

## Objective

Evaluate whether a deterministic chronological replay
can identify and preserve evidence of vibration changes
in independent industrial bearing experiments.

Implementation: C11, Bash and Unix CLI.

## Frozen experimental rule

- Baseline: first 100 captures, independently per channel.
- RMS increase threshold: 3.0 times baseline.
- Persistence: three consecutive captures.
- Common-mode low energy: all four channels at
  10% or less of their respective baselines.
- No future observations used in replay decisions.

## Results

| Trial | Captures | Documented faulty bearing | First relevant alert |
|---|---:|---|---|
| IMS-2 | 984 | Bearing 1, outer race | CH1, index 966 |
| IMS-3 | 6,324 | Bearing 3, outer race | CH3, index 6256 |

### IMS-2

CH1: 2004-02-19 03:22:39.

One persistent RMS-rise episode.

No persistent RMS-rise episode in CH2, CH3 or CH4.

Two common-mode low-energy captures at the end.

### IMS-3

CH3: 2004-04-17 15:22:55.

One persistent RMS-rise episode in CH3.

CH4 also presented two persistent RMS-rise episodes,
at indices 6304 and 6309.

CH1 and CH2 had no persistent alerts.

One common-mode low-energy capture at the end.

## Interpretation

The frozen rule produced alerts in the channels
associated with the documented end-of-test faults
in both experiments.

This is a retrospective observation, not a
validated prospective fault-prediction capability.

The significance of the additional CH4 alerts
in IMS-3 remains unresolved.

Low-energy events are not interpreted as mechanical
recovery, shutdown or sensor failure.

## Limitations

- Only two independent historical experiments.
- The rule was explored on IMS-2 before application
  to IMS-3.
- No externally validated fault-onset timestamps.
- No validated sensitivity, specificity or RUL.
- No industrial control or live telemetry.
- No commercial benchmarking.
- SHA-256 checksums, not digital signatures.
- No affiliation with NASA or Tractian.

The distributed third experiment contains 6,324
captures under the directory 3rd_test/4th_test/txt.
Historical descriptions of this experiment may
refer to a shorter recording.

## Source

NASA IMS Bearings:

https://data.nasa.gov/dataset/ims-bearings

The raw dataset is not redistributed in this report.

See channel-comparison.tsv, alerts.tsv, counts.tsv
and artifacts.sha256 for the supporting results.
MD

echo "TECHNICAL_REPORT=PASS"

echo
echo "=== 5. SEAL REPORT ==="

(
    cd "$OUT"

    sha256sum \
        REPORT.md \
        counts.tsv \
        channel-comparison.tsv \
        alerts.tsv \
        > artifacts.sha256

    sha256sum -c --status artifacts.sha256
)

echo "REPORT_INTEGRITY=PASS"

echo
echo "=== 6. SUMMARY ==="

cat "$OUT/counts.tsv"

echo
echo "=== 7. RESULT ==="

echo "CASE_REPORT_012=PASS"
echo "EXPERIMENTS=2"
echo "PARAMETERS=FROZEN"
echo "SOURCE_DATA=NOT_MODIFIED"
echo "FAULT_PREDICTION=NOT_VALIDATED"
echo "EXISTING_YODA_COMPONENTS=UNCHANGED"
echo "REPORT_DIR=$OUT"
