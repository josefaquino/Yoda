#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
DATA="$ROOT/datasets/3rd_test/4th_test/txt"
ORIGINAL="$ROOT/src/ims_signal_reader.c"
COPY="$ROOT/src/ims_signal_reader_third_011.c"
BIN="$ROOT/bin/yoda-ims-signal-third-011"
EVIDENCE="$ROOT/evidence/CROSS-TEST-011"
ARCHIVE_EVIDENCE="$ROOT/evidence/THIRD-TEST-010/third-test-rar.sha256"

fail() {
    printf 'STOP=%s\n' "$1" >&2
    exit 1
}

echo "============================================================"
echo " YODA-TRACTIAN-NASA-001"
echo " CROSS-TEST 011 — FROZEN RULES / THIRD IMS SET"
echo "============================================================"

test -d "$DATA" || fail MISSING_THIRD_TEST_DATA
test -f "$ORIGINAL" || fail MISSING_ORIGINAL_C11_READER
test -f "$ARCHIVE_EVIDENCE" || fail MISSING_RAR_SOURCE_MANIFEST

for path in "$COPY" "$BIN" "$EVIDENCE"; do
    test ! -e "$path" || fail "ALREADY_EXISTS:$path"
done

for tool in cc sha256sum find sort xargs awk sed grep wc; do
    command -v "$tool" >/dev/null 2>&1 ||
        fail "MISSING_TOOL:$tool"
done

echo
echo "=== 1. VERIFY SOURCE AND DATASET ==="

sha256sum -c "$ROOT/evidence/nasa-ims-archive.sha256"
sha256sum -c "$ARCHIVE_EVIDENCE"

N="$(find "$DATA" -type f | wc -l | tr -d ' ')"
L="$(find "$DATA" -type l | wc -l | tr -d ' ')"

echo "CAPTURES=$N SYMLINKS=$L"

test "$N" -eq 6324 || fail UNEXPECTED_CAPTURE_COUNT
test "$L" -eq 0 || fail SYMLINKS_PRESENT

mkdir -p "$EVIDENCE" "$ROOT/bin"

echo
echo "=== 2. BUILD ISOLATED C11 COPY ==="

test "$(grep -Fxc '#define EXPECTED_FILES 984' "$ORIGINAL")" -eq 1 ||
    fail ORIGINAL_READER_CONTRACT_CHANGED

sed 's/^#define EXPECTED_FILES 984$/#define EXPECTED_FILES 6324/' \
    "$ORIGINAL" > "$COPY"

cc -std=c11 -O2 -Wall -Wextra -Werror -pedantic \
    "$COPY" -lm -o "$BIN"

echo "C11_BUILD=PASS ORIGINAL_READER=UNCHANGED"

echo
echo "=== 3. HASH ALL 6324 SOURCE SNAPSHOTS ==="

find "$DATA" -type f -print0 |
    sort -z |
    xargs -0 -r sha256sum > "$EVIDENCE/sources.sha256"

test "$(wc -l < "$EVIDENCE/sources.sha256")" -eq 6324 ||
    fail HASH_INVENTORY_MISMATCH

sha256sum -c --status "$EVIDENCE/sources.sha256"

echo "SOURCE_HASHES=PASS"

echo
echo "=== 4. EXTRACT REAL SIGNAL FEATURES IN C11 ==="

"$BIN" "$EVIDENCE/sources.sha256" \
    > "$EVIDENCE/features.tsv" \
    2> "$EVIDENCE/reader.log" || {
        cat "$EVIDENCE/reader.log"
        fail C11_READER_FAILED
    }

cat "$EVIDENCE/reader.log"

echo
echo "=== 5. REPLAY FROZEN RULES — ALL CHANNELS ==="

awk -F '\t' \
    -v summary="$EVIDENCE/channels.tsv" \
    -v alerts="$EVIDENCE/events.tsv" \
    -v commonfile="$EVIDENCE/common-mode.tsv" '
BEGIN {
    OFS="\t"

    number="^[-+]?(([0-9]+([.][0-9]*)?)|([.][0-9]+))([eE][-+]?[0-9]+)?$"

    print "channel","baseline_rms_first100","first_alert_index", \
          "first_alert_timestamp","episodes", \
          "max_rms_ratio_after_baseline" > summary

    print "index","timestamp","event","channel", \
          "rms_ratio","source_sha256" > alerts

    print "index","timestamp","ratio_ch1","ratio_ch2", \
          "ratio_ch3","ratio_ch4","source_sha256" > commonfile
}

NR == 1 {
    if (NF!=8 || $1!="timestamp" || $2!="source_file" ||
        $3!="source_sha256" || $4!="channel" || $5!="samples" ||
        $6!="rms" || $7!="peak_abs" || $8!="crest_factor")
        bad=1

    next
}

{
    c=$4+0

    if (bad || NF!=8 || c!=((NR-2)%4)+1 || $5!=20480 ||
        $6 !~ number || $7 !~ number || $8 !~ number ||
        $6+0<0 || $7+0<0 || $8+0<0 ||
        length($3)!=64 || $3 !~ /^[0-9a-f]+$/) {
        bad=1
        exit 2
    }

    if (c==1) {
        idx++

        if (previous!="" && $1<=previous) {
            bad=1
            exit 2
        }

        previous=$1
        stamp=$1
        name=$2
        hash=$3

    } else if ($1!=stamp || $2!=name || $3!=hash) {
        bad=1
        exit 2
    }

    rms[c]=$6+0

    if (idx<=100)
        sums[c]+=rms[c]

    if (c==4 && idx>100) {
        low=1

        for (k=1; k<=4; k++) {
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

                if (!(k in firstidx)) {
                    firstidx[k]=idx
                    firsttime[k]=stamp
                }

                printf \
                  "%d\t%s\tRMS_RISE_PERSISTENT\tCH%d\t%.9g\t%s\n", \
                  idx,stamp,k,ratio[k],hash > alerts
            }

            if (ratio[k]>0.10)
                low=0
        }

        if (low) {
            lowcount++

            printf \
              "%d\t%s\t%.9g\t%.9g\t%.9g\t%.9g\t%s\n", \
              idx,stamp,ratio[1],ratio[2], \
              ratio[3],ratio[4],hash > commonfile
        }
    }
}

END {
    if (bad || idx!=6324 || NR!=25297) {
        print "DATA_VALIDATION=FAIL" > "/dev/stderr"
        exit 2
    }

    for (k=1; k<=4; k++) {
        fi=(k in firstidx)?firstidx[k]:"NONE"
        ft=(k in firsttime)?firsttime[k]:"NONE"

        printf "%d\t%.12g\t%s\t%s\t%d\t%.9g\n", \
            k,sums[k]/100,fi,ft,episodes[k]+0, \
            maxratio[k] > summary
    }

    printf \
      "FROZEN_REPLAY=PASS SNAPSHOTS=%d FEATURE_ROWS=%d LOW_COMMON=%d\n", \
      idx,NR-1,lowcount+0 > "/dev/stderr"
}
' "$EVIDENCE/features.tsv" \
    2> "$EVIDENCE/replay.log" || {
        cat "$EVIDENCE/replay.log"
        fail FROZEN_REPLAY_FAILED
    }

cat "$EVIDENCE/replay.log"

echo
echo "=== 6. CHANNEL CONTRAST ==="

cat "$EVIDENCE/channels.tsv"

echo
echo "=== 7. FIRST 10 ALERT EVENTS ==="

sed -n '1,11p' "$EVIDENCE/events.tsv"

echo "TOTAL_RISE_EVENTS=$(( $(wc -l < "$EVIDENCE/events.tsv") - 1 ))"

echo
echo "=== 8. FIRST 10 COMMON-MODE EVENTS ==="

sed -n '1,11p' "$EVIDENCE/common-mode.tsv"

echo "TOTAL_LOW_ENERGY_SNAPSHOTS=$(( $(wc -l < "$EVIDENCE/common-mode.tsv") - 1 ))"

echo
echo "=== 9. VERIFY SOURCE AND SEAL ARTIFACTS ==="

sha256sum -c --status "$EVIDENCE/sources.sha256"

(
    cd "$EVIDENCE"

    sha256sum \
        sources.sha256 \
        features.tsv \
        reader.log \
        replay.log \
        channels.tsv \
        events.tsv \
        common-mode.tsv \
        > artifacts.sha256

    sha256sum -c --status artifacts.sha256
)

sha256sum "$COPY" "$BIN" > "$EVIDENCE/code.sha256"

echo "SOURCE_UNCHANGED=PASS"

echo
echo "============================================================"
echo " CROSS-TEST 011 — COMPLETE"
echo "============================================================"

echo "CROSS_TEST_011=PASS"
echo "FROZEN_PARAMETERS=100,3.0,3,0.10"
echo "FAULT_PREDICTION=NOT_VALIDATED"
echo "FUTURE_INFORMATION=NOT_USED_IN_RULES"
echo "EXISTING_YODA_COMPONENTS=UNCHANGED"
echo "EVIDENCE_DIR=$EVIDENCE"
