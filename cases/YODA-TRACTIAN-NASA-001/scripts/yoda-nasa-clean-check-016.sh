#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
BASE="$HOME/Yoda-Workspace/releases/YODA-NASA-CLEAN-CHECK-016"
REPO="$BASE/repo"
OUT="$BASE/evidence"
CASE="$REPO/cases/YODA-TRACTIAN-NASA-001"
PIN="e16ad1131427d08b9e29f9b9b03826e6b7c720bd"
REMOTE="https://github.com/josefaquino/Yoda.git"
RAW2="$ROOT/datasets/2nd_test"
RAW3="$ROOT/datasets/3rd_test/4th_test/txt"

fail() { printf 'CLEAN_CLONE_016=FAIL REASON=%s\n' "$1" >&2; exit 1; }

echo '============================================================'
echo ' YODA-TRACTIAN-NASA-001'
echo ' CLEAN CLONE 016 — RECOMPUTE FROM ORIGINAL NASA SIGNALS'
echo '============================================================'

for x in git cc sha256sum find sort xargs awk wc cmp tr; do
    command -v "$x" >/dev/null 2>&1 || fail "MISSING_TOOL:$x"
done
[ ! -e "$BASE" ] || fail 'AUDIT_DIR_ALREADY_EXISTS'
[ -d "$RAW2" ] && [ -d "$RAW3" ] || fail 'NASA_SIGNALS_MISSING'
[ -f "$ROOT/datasets/nasa-ims-bearings.zip" ] || fail 'NASA_ZIP_MISSING'

mkdir -p "$BASE"

echo
echo '=== 1. CLEAN CHECKOUT AT PUBLICATION COMMIT ==='
git clone --quiet --depth 1 --branch main "$REMOTE" "$REPO" || fail GIT_CLONE
if [ "$(git -C "$REPO" rev-parse HEAD)" != "$PIN" ]; then
    git -C "$REPO" fetch --quiet --depth 1 origin "$PIN" || fail PIN_FETCH
fi
git -C "$REPO" checkout --quiet --detach "$PIN" || fail PIN_CHECKOUT
[ "$(git -C "$REPO" rev-parse HEAD)" = "$PIN" ] || fail COMMIT_MISMATCH
[ -f "$CASE/MANIFEST.sha256" ] || fail CASE_NOT_IN_PINNED_COMMIT
(
    cd "$CASE"
    sha256sum -c --status MANIFEST.sha256
    cd results
    sha256sum -c --status artifacts.sha256
) || fail PUBLIC_MANIFEST_MISMATCH
echo "PUBLIC_COMMIT=PASS SHA=$PIN"
echo 'PUBLIC_MANIFESTS=PASS'

mkdir -p "$OUT/bin" "$OUT/ims2-c11"

echo
echo '=== 2. VERIFY NASA ZIP AND RAW CAPTURE INVENTORIES ==='
printf '%s  %s\n' \
  '21001ac266c465f5d345ec42d7b508c6a6328487fd9d4d7774422dd5ea10ad83' \
  "$ROOT/datasets/nasa-ims-bearings.zip" | sha256sum -c --status || fail NASA_ZIP_HASH
for spec in "IMS2:$RAW2:984" "IMS3:$RAW3:6324"; do
    IFS=: read -r trial path expected <<< "$spec"
    n="$(find "$path" -type f | wc -l | tr -d ' ')"
    links="$(find "$path" -type l | wc -l | tr -d ' ')"
    [ "$n" -eq "$expected" ] && [ "$links" -eq 0 ] || fail "RAW_INVENTORY:$trial"
    echo "RAW_INVENTORY=PASS TRIAL=$trial CAPTURES=$n"
done

# Files are referenced in place, read-only; never copied to the clone.
find "$RAW2" -type f -print0 | sort -z | xargs -0 -r sha256sum > "$OUT/ims2-sources.sha256"
find "$RAW3" -type f -print0 | sort -z | xargs -0 -r sha256sum > "$OUT/ims3-sources.sha256"
[ "$(wc -l < "$OUT/ims2-sources.sha256")" -eq 984 ] || fail IMS2_MANIFEST_SIZE
[ "$(wc -l < "$OUT/ims3-sources.sha256")" -eq 6324 ] || fail IMS3_MANIFEST_SIZE

echo
echo '=== 3. BUILD PUBLISHED C11 SOURCES, NOT LOCAL BINARIES ==='
cc -std=c11 -O2 -Wall -Wextra -Werror -pedantic \
    "$CASE/src/ims_signal_reader.c" -lm -o "$OUT/bin/reader-ims2" || fail BUILD_IMS2
cc -std=c11 -O2 -Wall -Wextra -Werror -pedantic \
    "$CASE/src/ims_signal_reader_third_011.c" -lm -o "$OUT/bin/reader-ims3" || fail BUILD_IMS3
cc -std=c11 -O2 -Wall -Wextra -Werror -pedantic \
    "$CASE/src/ims_causal_replay.c" -lm -o "$OUT/bin/replay-ims2" || fail BUILD_REPLAY
printf '%s\n' 'PUBLISHED_C11_BUILD=PASS BINARIES=3'

echo
echo '=== 4. RECOMPUTE EVERY CHANNEL FROM RAW SIGNALS ==='
"$OUT/bin/reader-ims2" "$OUT/ims2-sources.sha256" \
    > "$OUT/ims2-features.tsv" 2> "$OUT/ims2-reader.log" || fail READER_IMS2
"$OUT/bin/reader-ims3" "$OUT/ims3-sources.sha256" \
    > "$OUT/ims3-features.tsv" 2> "$OUT/ims3-reader.log" || fail READER_IMS3
cat "$OUT/ims2-reader.log" "$OUT/ims3-reader.log"
[ "$(wc -l < "$OUT/ims2-features.tsv")" -eq 3937 ] || fail FEATURES_IMS2
[ "$(wc -l < "$OUT/ims3-features.tsv")" -eq 25297 ] || fail FEATURES_IMS3
"$OUT/bin/replay-ims2" "$OUT/ims2-features.tsv" "$OUT/ims2-c11" \
    > "$OUT/ims2-c11.log" || fail REPLAY_IMS2
cat "$OUT/ims2-c11.log"

# The frozen cross-channel rule is recomputed independently from the
# newly extracted features. The code and parameters are not retuned.
cat > "$OUT/frozen-rule.awk" <<'AWK'
BEGIN { OFS="\t"; valid=1 }
NR==1 {
    if (NF!=8 || $1!="timestamp" || $2!="source_file" ||
        $3!="source_sha256" || $4!="channel" || $5!="samples" ||
        $6!="rms" || $7!="peak_abs" || $8!="crest_factor") valid=0
    next
}
{
    c=$4+0
    if (!valid || NF!=8 || c!=((NR-2)%4)+1 || $5!=20480 ||
        length($3)!=64 || $6+0<0 || $7+0<0 || $8+0<0) { valid=0; exit 2 }
    if (c==1) {
        idx++
        if (prior!="" && $1<=prior) { valid=0; exit 2 }
        prior=$1; stamp=$1; source=$2; hash=$3
    } else if ($1!=stamp || $2!=source || $3!=hash) { valid=0; exit 2 }
    rms[c]=$6+0
    if (idx<=100) sums[c]+=rms[c]
    if (c==4 && idx>100) {
        low=1
        for (k=1;k<=4;k++) {
            base=sums[k]/100
            if (base<=0) { valid=0; exit 2 }
            ratio[k]=rms[k]/base
            if (ratio[k]>maximum[k]) maximum[k]=ratio[k]
            if (ratio[k]>=3.0) streak[k]++
            else streak[k]=0
            if (streak[k]==3) {
                episodes[k]++
                if (!(k in first)) { first[k]=idx; when[k]=stamp }
                print trial,idx,stamp,"RMS_RISE_PERSISTENT","CH" k, \
                    sprintf("%.9g",ratio[k]),hash >> alerts
            }
            if (ratio[k]>0.10) low=0
        }
        if (low) lowcount++
    }
}
END {
    if (!valid || idx!=expected || NR!=expected*4+1) {
        print "FROZEN_RULE=FAIL trial=" trial > "/dev/stderr"
        exit 2
    }
    for (k=1;k<=4;k++) {
        fi=(k in first)?first[k]:"NONE"
        ft=(k in when)?when[k]:"NONE"
        print trial,k,sprintf("%.12g",sums[k]/100),fi,ft, \
            episodes[k]+0,sprintf("%.9g",maximum[k]+0) >> channels
    }
    total=0
    for (k=1;k<=4;k++) total+=episodes[k]
    print trial,expected,total,lowcount+0 >> counts
    print "FROZEN_RULE=PASS trial=" trial " CAPTURES=" idx \
          " RISE_EVENTS=" total " LOW_COMMON=" lowcount+0 > "/dev/stderr"
}
AWK

printf 'trial\tindex\ttimestamp\tevent\tchannel\trms_ratio\tsource_sha256\n' > "$OUT/alerts.tsv"
printf 'test\tchannel\tbaseline_rms_first100\tfirst_alert_index\tfirst_alert_timestamp\tepisodes\tmax_rms_ratio\n' > "$OUT/channel-comparison.tsv"
printf 'trial\tcaptures\trise_events\tcommon_mode_low_snapshots\n' > "$OUT/counts.tsv"

echo
echo '=== 5. FROZEN RULE, TWO TRIALS ==='
for spec in 'IMS2:984' 'IMS3:6324'; do
    IFS=: read -r trial expected <<< "$spec"
    awk -F '\t' -v trial="$trial" -v expected="$expected" \
        -v alerts="$OUT/alerts.tsv" \
        -v channels="$OUT/channel-comparison.tsv" \
        -v counts="$OUT/counts.tsv" \
        -f "$OUT/frozen-rule.awk" \
        "$OUT/$(printf %s "$trial" | tr '[:upper:]' '[:lower:]')-features.tsv" \
        || fail "FROZEN_RULE:$trial"
done

echo
echo '=== 6. EXACT COMPARISON AGAINST PUBLISHED RESULTS ==='
for file in alerts.tsv channel-comparison.tsv counts.tsv; do
    if ! cmp -s "$OUT/$file" "$CASE/results/$file"; then
        echo "BYTE_COMPARISON=FAIL FILE=$file"
        diff -u "$CASE/results/$file" "$OUT/$file" | head -60 || true
        fail "PUBLIC_RESULT_MISMATCH:$file"
    fi
    echo "BYTE_COMPARISON=PASS FILE=$file"
done

# C11 and AWK independently confirm the first event in IMS-2.
awk -F '\t' 'NR>1 && $3=="RMS_RISE_PERSISTENT" {print $1,$2,$4,$9}' \
    "$OUT/ims2-c11/events.tsv" > "$OUT/c11-event-identity.txt"
awk -F '\t' 'NR>1 && $1=="IMS2" {print $2,$3,$5,$7}' \
    "$CASE/results/alerts.tsv" > "$OUT/published-ims2-identity.txt"
cmp -s "$OUT/c11-event-identity.txt" "$OUT/published-ims2-identity.txt" \
    || fail C11_AWK_EVENT_IDENTITY_MISMATCH
echo 'C11_VS_PUBLIC_EVENT=PASS TRIAL=IMS2'

# Rehash raw files after processing, detecting modifications during the run.
sha256sum -c --status "$OUT/ims2-sources.sha256" || fail IMS2_RAW_CHANGED
sha256sum -c --status "$OUT/ims3-sources.sha256" || fail IMS3_RAW_CHANGED
echo 'NASA_SIGNALS_UNCHANGED=PASS'

[ -z "$(git -C "$REPO" status --porcelain)" ] || fail CHECKOUT_DIRTY
printf 'commit=%s\nsource=published-C11\ndata=local-verified-NASA\n' "$PIN" > "$OUT/PROVENANCE.txt"
(
    cd "$OUT"
    sha256sum alerts.tsv channel-comparison.tsv counts.tsv \
        ims2-reader.log ims3-reader.log ims2-c11.log PROVENANCE.txt \
        > CHECKSUMS.sha256
    sha256sum -c --status CHECKSUMS.sha256
) || fail AUDIT_ARTIFACT_HASH

echo
echo '============================================================'
echo ' CLEAN CLONE 016 — COMPLETE'
echo '============================================================'
echo 'CLEAN_CLONE_016=PASS'
echo 'PUBLISHED_COMMIT=VERIFIED'
echo 'SOURCE=GITHUB_PINNED_C11'
echo 'NASA_DATA=EXISTING_LOCAL_READ_ONLY'
echo 'PUBLIC_RESULTS_EXACTLY_REPRODUCED=YES'
echo 'CLEAN_MACHINE_FROM_SCRATCH=NOT_TESTED'
echo 'CASE_SOURCE_UNCHANGED=YES'
echo "AUDIT_DIR=$BASE"
