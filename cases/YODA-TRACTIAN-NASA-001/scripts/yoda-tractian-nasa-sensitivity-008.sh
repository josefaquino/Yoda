#!/usr/bin/env bash
set -eu
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
INPUT="$ROOT/evidence/C11-SIGNAL-READER-005"
SOURCE="$INPUT/features.tsv"
OUT="$ROOT/evidence/SENSITIVITY-008"

echo "============================================================"
echo " YODA-TRACTIAN-NASA-001"
echo " SENSITIVITY 008 — CHRONOLOGICAL SIGNAL RULES"
echo "============================================================"

test -f "$SOURCE"
test -f "$INPUT/artifacts.sha256"
test ! -e "$OUT" || {
    echo "STOP=EVIDENCE_ALREADY_EXISTS"
    exit 1
}

command -v awk >/dev/null
command -v sha256sum >/dev/null

mkdir -p "$OUT"

echo
echo "=== 1. VERIFY ORIGINAL FEATURES ==="

(
    cd "$INPUT"
    sha256sum -c artifacts.sha256
) > "$OUT/input-verification.log"

echo "INPUT_EVIDENCE=PASS"

echo
echo "=== 2. RUN CHRONOLOGICAL SENSITIVITY ==="

awk -F '\t' \
    -v matrix="$OUT/sensitivity.tsv" \
    -v lowfile="$OUT/common-mode.tsv" '
BEGIN {
    OFS="\t"

    base[1]=50
    base[2]=100
    base[3]=150

    threshold[1]=2.5
    threshold[2]=3.0
    threshold[3]=4.0

    persistence[1]=2
    persistence[2]=3
    persistence[3]=5

    print "index", "timestamp", \
          "ratio_ch1", "ratio_ch2", \
          "ratio_ch3", "ratio_ch4", \
          "source_sha256" > lowfile
}

NR==1 {
    if (NF!=8 ||
        $1!="timestamp" ||
        $2!="source_file" ||
        $3!="source_sha256" ||
        $4!="channel" ||
        $5!="samples" ||
        $6!="rms")
        bad=1

    next
}

{
    c=$4+0

    if (NF!=8 ||
        $5!=20480 ||
        $6+0<0 ||
        $7+0<0 ||
        $8+0<0 ||
        c<1 ||
        c>4 ||
        (NR-2)%4+1!=c)
        bad=1

    if (bad)
        exit 2

    if (c==1) {
        idx++

        if (last_stamp!="" && $1<=last_stamp) {
            bad=1
            exit 2
        }

        last_stamp=$1
        stamp=$1
        source_name=$2
        hash=$3
    } else {
        if ($1!=stamp ||
            $2!=source_name ||
            $3!=hash) {
            bad=1
            exit 2
        }
    }

    value[c]=$6+0

    if (idx<=50)
        sums[50,c]+=value[c]

    if (idx<=100)
        sums[100,c]+=value[c]

    if (idx<=150)
        sums[150,c]+=value[c]

    if (c==4) {

        for (bi=1; bi<=3; bi++) {
            b=base[bi]

            if (idx<=b)
                continue

            baseline=sums[b,1]/b

            if (baseline<=0) {
                bad=1
                exit 2
            }

            for (ti=1; ti<=3; ti++) {
                th=threshold[ti]

                for (pi=1; pi<=3; pi++) {
                    p=persistence[pi]
                    key=b ":" ti ":" p

                    if (value[1]>=th*baseline)
                        streak[key]++
                    else
                        streak[key]=0

                    if (streak[key]==p) {
                        episodes[key]++

                        if (!(key in firstidx)) {
                            firstidx[key]=idx
                            firsttime[key]=stamp
                            firsthash[key]=hash
                        }
                    }
                }
            }
        }

        if (idx>100) {
            common=1

            for (k=1; k<=4; k++) {
                ratio[k]=value[k]/(sums[100,k]/100)

                if (ratio[k]>0.10)
                    common=0
            }

            if (common) {
                low_count++

                printf \
                  "%d\t%s\t%.9g\t%.9g\t%.9g\t%.9g\t%s\n", \
                  idx,stamp,ratio[1],ratio[2], \
                  ratio[3],ratio[4],hash > lowfile

                if (low_count==1) {
                    first_low=idx
                    first_low_time=stamp
                }
            }
        }
    }
}

END {
    if (bad || NR!=3937 || idx!=984)
        exit 2

    print "baseline_n", "rise_ratio", \
          "persistence", "first_alert_index", \
          "first_alert_timestamp", "episodes", \
          "first_source_sha256" > matrix

    for (bi=1; bi<=3; bi++) {
        for (ti=1; ti<=3; ti++) {
            for (pi=1; pi<=3; pi++) {

                b=base[bi]
                th=threshold[ti]
                p=persistence[pi]
                key=b ":" ti ":" p

                first=(key in firstidx) ? \
                      firstidx[key] : "NONE"

                timestamp=(key in firsttime) ? \
                          firsttime[key] : "NONE"

                digest=(key in firsthash) ? \
                       firsthash[key] : "NONE"

                printf \
                  "%d\t%.1f\t%d\t%s\t%s\t%d\t%s\n", \
                  b,th,p,first,timestamp, \
                  episodes[key]+0,digest > matrix
            }
        }
    }

    print "SENSITIVITY_MATRIX=PASS CONFIGURATIONS=27 SNAPSHOTS=" idx > "/dev/stderr"

    print "COMMON_MODE_SNAPSHOTS=" low_count+0 \
          " FIRST_INDEX=" first_low \
          " FIRST_TIMESTAMP=" first_low_time > "/dev/stderr"
}
' "$SOURCE" > "$OUT/replay.log" 2>&1 || {
    echo "SENSITIVITY_ANALYSIS=FAIL"
    cat "$OUT/replay.log"
    exit 1
}

cat "$OUT/replay.log"

echo
echo "=== 3. ORIGINAL RULE — 100 / 3.0 / 3 ==="

awk -F '\t' '
NR==1 || ($1==100 && $2==3.0 && $3==3)
' "$OUT/sensitivity.tsv"

echo
echo "=== 4. BASELINE SENSITIVITY — 3X / 3 ==="

awk -F '\t' '
NR==1 || ($2==3.0 && $3==3)
' "$OUT/sensitivity.tsv"

echo
echo "=== 5. COMPLETE SENSITIVITY MATRIX ==="

cat "$OUT/sensitivity.tsv"

echo
echo "=== 6. COMMON-MODE LOW ENERGY ==="

cat "$OUT/common-mode.tsv"

echo
echo "=== 7. COMPARE WITH REPLAY 007 ==="

ORIGINAL="$ROOT/evidence/CAUSAL-REPLAY-007/events.tsv"

if [ -f "$ORIGINAL" ]; then

    EXPECTED="$(
        awk -F '\t' '
        NR>1 &&
        $3=="RMS_RISE_PERSISTENT" &&
        $4=="CH1" {
            print $1 "\t" $2
            exit
        }' "$ORIGINAL"
    )"

    OBSERVED="$(
        awk -F '\t' '
        NR>1 &&
        $1==100 &&
        $2==3.0 &&
        $3==3 {
            print $4 "\t" $5
            exit
        }' "$OUT/sensitivity.tsv"
    )"

    printf 'REPLAY_007=%s\n' "$EXPECTED"
    printf 'SENSITIVITY_008=%s\n' "$OBSERVED"

    if [ -n "$EXPECTED" ] &&
       [ "$EXPECTED" = "$OBSERVED" ]; then
        echo "REFERENCE_RULE_AGREEMENT=PASS"
    else
        echo "REFERENCE_RULE_AGREEMENT=FAIL"
        exit 1
    fi

else
    echo "REFERENCE_RULE_AGREEMENT=NOT_CHECKED_NO_EVENTS_FILE"
fi

echo
echo "=== 8. RECORD EVIDENCE ==="

(
    cd "$OUT"

    sha256sum \
        sensitivity.tsv \
        common-mode.tsv \
        replay.log \
        input-verification.log \
        > artifacts.sha256

    sha256sum -c --status artifacts.sha256
)

echo
echo "============================================================"
echo " SENSITIVITY 008 — COMPLETE"
echo "============================================================"

echo "SENSITIVITY_008=PASS"
echo "RULES=ILLUSTRATIVE_NOT_CALIBRATED"
echo "FUTURE_INFORMATION=NOT_USED_IN_RULES"
echo "DATASET=UNCHANGED"
echo "EXISTING_YODA_COMPONENTS=UNCHANGED"
echo "EVIDENCE_DIR=$OUT"
