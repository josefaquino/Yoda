#!/usr/bin/env bash
set -eu
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
INPUT="$ROOT/evidence/C11-SIGNAL-READER-005"
PREVIOUS="$ROOT/evidence/CAUSAL-REPLAY-007/events.tsv"
OUT="$ROOT/evidence/CHANNEL-CONTRAST-009"

echo "============================================================"
echo " YODA-TRACTIAN-NASA-001"
echo " CHANNEL CONTRAST 009 — ALL FOUR CHANNELS"
echo "============================================================"

test -f "$INPUT/features.tsv"
test -f "$INPUT/artifacts.sha256"
test -f "$PREVIOUS"
test ! -e "$OUT" || {
    echo "STOP=EVIDENCE_EXISTS"
    exit 1
}

mkdir -p "$OUT"

echo
echo "=== 1. VERIFY SOURCE FEATURES ==="

(
    cd "$INPUT"
    sha256sum -c --status artifacts.sha256
)

echo "INPUT_INTEGRITY=PASS"

echo
echo "=== 2. REPLAY SAME RULE ACROSS FOUR CHANNELS ==="

awk -F '\t' \
    -v summary="$OUT/channels.tsv" \
    -v alerts="$OUT/alerts.tsv" \
    -v low="$OUT/common-mode.tsv" '
BEGIN {
    OFS="\t"

    print "channel", "baseline_rms_first100", \
          "first_alert_index", "first_alert_timestamp", \
          "episodes", "episodes_at_or_before_900", \
          "max_rms_ratio_after_baseline" > summary

    print "index", "timestamp", "channel", \
          "rms_ratio", "source_sha256" > alerts

    print "index", "timestamp", "ratio_ch1", \
          "ratio_ch2", "ratio_ch3", "ratio_ch4", \
          "source_sha256" > low

    number="^[-+]?(([0-9]+([.][0-9]*)?)|([.][0-9]+))([eE][-+]?[0-9]+)?$"
}

NR==1 {
    if (NF!=8 ||
        $1!="timestamp" ||
        $2!="source_file" ||
        $3!="source_sha256" ||
        $4!="channel" ||
        $5!="samples" ||
        $6!="rms" ||
        $7!="peak_abs" ||
        $8!="crest_factor")
        bad=1

    next
}

{
    c=$4+0

    if (bad ||
        NF!=8 ||
        c!=((NR-2)%4)+1 ||
        $5!=20480 ||
        $6 !~ number ||
        $7 !~ number ||
        $8 !~ number ||
        $6+0<0 ||
        $7+0<0 ||
        $8+0<0 ||
        length($3)!=64 ||
        $3 !~ /^[0-9a-f]+$/) {

        bad=1
        exit 2
    }

    if (c==1) {
        idx++

        if (stamp!="" && $1<=stamp) {
            bad=1
            exit 2
        }

        stamp=$1
        filename=$2
        hash=$3
    } else if ($1!=stamp ||
               $2!=filename ||
               $3!=hash) {

        bad=1
        exit 2
    }

    rms[c]=$6+0

    if (idx<=100)
        sums[c]+=rms[c]

    if (c==4 && idx>100) {
        common=1

        for (k=1;k<=4;k++) {
            base=sums[k]/100

            if (base<=0) {
                bad=1
                exit 2
            }

            ratio[k]=rms[k]/base

            if (ratio[k]>maxratio[k])
                maxratio[k]=ratio[k]

            if (ratio[k]>=3.0)
                streak[k]++
            else
                streak[k]=0

            if (streak[k]==3) {
                episodes[k]++

                if (idx<=900)
                    early[k]++

                if (!(k in firstindex)) {
                    firstindex[k]=idx
                    firsttime[k]=stamp
                }

                printf "%d\t%s\tCH%d\t%.9g\t%s\n", \
                    idx,stamp,k,ratio[k],hash > alerts
            }

            if (ratio[k]>0.10)
                common=0
        }

        if (common) {
            lowcount++

            printf \
              "%d\t%s\t%.9g\t%.9g\t%.9g\t%.9g\t%s\n", \
              idx,stamp,ratio[1],ratio[2], \
              ratio[3],ratio[4],hash > low
        }
    }
}

END {
    if (bad || idx!=984 || NR!=3937) {
        print "DATA_VALIDATION=FAIL" > "/dev/stderr"
        exit 2
    }

    for (k=1;k<=4;k++) {
        if (sums[k]<=0)
            exit 2

        fi=(k in firstindex) ? firstindex[k] : "NONE"
        ft=(k in firsttime) ? firsttime[k] : "NONE"

        printf \
          "%d\t%.12g\t%s\t%s\t%d\t%d\t%.9g\n", \
          k,sums[k]/100,fi,ft, \
          episodes[k]+0,early[k]+0, \
          maxratio[k] > summary
    }

    printf \
      "CHANNEL_CONTRAST=PASS SNAPSHOTS=%d LOW_ENERGY_SNAPSHOTS=%d\n", \
      idx,lowcount > "/dev/stderr"
}
' "$INPUT/features.tsv" \
    > "$OUT/analysis.log" 2>&1 || {

    cat "$OUT/analysis.log"
    exit 1
}

cat "$OUT/analysis.log"

echo
echo "=== 3. CHANNEL COMPARISON — SAME RULE 100 / 3.0 / 3 ==="

cat "$OUT/channels.tsv"

echo
echo "=== 4. ALERT EVENTS — ALL CHANNELS ==="

cat "$OUT/alerts.tsv"

echo
echo "=== 5. COMMON-MODE LOW ENERGY ==="

cat "$OUT/common-mode.tsv"

echo
echo "=== 6. COMPARE CHANNEL 1 WITH REPLAY 007 ==="

EXPECTED="$(
    awk -F '\t' '
    NR>1 &&
    $3=="RMS_RISE_PERSISTENT" &&
    $4=="CH1" {
        print $1 " " $2
        exit
    }' "$PREVIOUS"
)"

OBSERVED="$(
    awk -F '\t' '
    NR>1 && $3=="CH1" {
        print $1 " " $2
        exit
    }' "$OUT/alerts.tsv"
)"

echo "REPLAY_007=$EXPECTED"
echo "CHANNEL_CONTRAST_009=$OBSERVED"

test -n "$EXPECTED"
test "$EXPECTED" = "$OBSERVED"

echo "CH1_REGRESSION=PASS"

echo
echo "=== 7. RECORD EVIDENCE ==="

(
    cd "$OUT"

    sha256sum \
        channels.tsv \
        alerts.tsv \
        common-mode.tsv \
        analysis.log \
        > artifacts.sha256
)

(
    cd "$INPUT"
    sha256sum -c --status artifacts.sha256
)

echo "SOURCE_FEATURES_UNCHANGED=PASS"

echo
echo "============================================================"
echo " CHANNEL CONTRAST 009 — COMPLETE"
echo "============================================================"

echo "CHANNEL_CONTRAST_009=PASS"
echo "INTERPRETATION=OBSERVATION_ONLY"
echo "NO_FAULT_DIAGNOSIS=YES"
echo "EXISTING_COMPONENTS=UNCHANGED"
echo "EVIDENCE_DIR=$OUT"
