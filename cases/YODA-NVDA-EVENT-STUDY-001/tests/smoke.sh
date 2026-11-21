#!/bin/sh
# Deterministic synthetic smoke test, NOT a market forecast.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP/scripts" "$TMP/data/raw" "$TMP/data/normalized" "$TMP/results" "$TMP/evidence" "$TMP/options" "$TMP/events"
if [ -f "$ROOT/events/candidates.tsv" ];then cp "$ROOT/events/candidates.tsv" "$TMP/events/candidates.tsv";else printf 'date\tcandidate\n' > "$TMP/events/candidates.tsv";fi
cp "$ROOT"/scripts/*.sh "$ROOT"/scripts/*.awk "$TMP/scripts/"
printf 'date\tNVDA\tQQQ\tSOXX\n' > "$TMP/data/normalized/prices-wide.synthetic.tsv"
day=$(date -u -d 2025-06-02 +%s)
last=$(date -u -d 2026-11-20 +%s)
i=0
while [ "$day" -le "$last" ];do
 dow=$(date -u -d "@$day" +%u)
 if [ "$dow" -le 5 ];then
  daystr=$(date -u -d "@$day" +%F)
  awk -v d="$daystr" -v i="$i" 'BEGIN{printf "%s\t%.8f\t%.8f\t%.8f\n",d,180*exp(i*.0002+.15*sin(i*.13)),480*exp(i*.0003+.03*sin(i*.11)),240*exp(i*.0004+.04*cos(i*.17))}' >> "$TMP/data/normalized/prices-wide.synthetic.tsv"
  i=$((i+1))
 fi
 day=$((day+86400))
done
for col in 2 3 4;do
 case "$col" in 2)sym=NVDA;;3)sym=QQQ;;4)sym=SOXX;;esac
 awk -F '\t' -v c="$col" 'BEGIN{OFS=",";print "Date,Open,High,Low,Close,Volume"} NR>1{print $1,$c,$c,$c,$c,1000000}' "$TMP/data/normalized/prices-wide.synthetic.tsv" > "$TMP/data/raw/$sym.csv"
done
(
 cd "$TMP"
 sh scripts/run.sh >/dev/null
 SIMS=1200 sh scripts/forecast.sh >/dev/null
 sh scripts/backtest.sh >/dev/null
 sha256sum -c evidence/FORECAST-MANIFEST.sha256 >/dev/null
 set +e
 output=$(sh scripts/options-evaluate.sh 2>&1);code=$?
 set -e
 [ "$code" -eq 2 ] && [ "$output" = 'NO_TRADE=YES REASON=NEED_FORECAST_AND_VERIFIED_OPTION_QUOTES' ] || exit 2
 [ -s results/forecast/backtest-report.txt ] || exit 2
)
echo 'SYNTHETIC_SMOKE_TEST=PASS'
echo 'REAL_MARKET_DATA_USED=NO'
echo 'PREDICTIVE_VALIDITY_CLAIM=NO'
