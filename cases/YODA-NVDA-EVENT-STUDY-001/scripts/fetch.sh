#!/bin/sh
# Nasdaq public website endpoint, historical OHLCV: raw JSON is immutable cache.
# Never bypass server blocks; fail closed on null or schema changes.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
for cmd in cc curl awk sha256sum grep sed; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "MISSING_COMMAND=$cmd" >&2; exit 2; }
done
mkdir -p data/raw build evidence
BIN=build/nasdaq-json-to-csv
cc -std=c11 -O2 -Wall -Wextra -pedantic scripts/nasdaq-json-to-csv.c -lm -o "$BIN.part"
mv "$BIN.part" "$BIN"
FROMDATE=2016-11-21
TODATE=2026-11-20
: > evidence/NASDAQ-SOURCE-MANIFEST.sha256.part
printf 'symbol\tassetclass\tfromdate\ttodate\turl\traw_json\tparsed_csv\n' > evidence/nasdaq-fetch.tsv.part
for symbol in NVDA QQQ SOXX; do
  case "$symbol" in
    NVDA) assetclass=stocks ;;
    QQQ|SOXX) assetclass=etf ;;
  esac
  raw="data/raw/NASDAQ-${symbol}-${FROMDATE}_${TODATE}.json"
  csv="data/raw/${symbol}.csv"
  url="https://api.nasdaq.com/api/quote/$symbol/historical?assetclass=$assetclass&fromdate=$FROMDATE&todate=$TODATE&limit=9999"
  if [ -s "$raw" ]; then
    echo "NASDAQ_CACHE_HIT=$symbol"
  else
    fetched=NO
    retry=1
    while [ "$retry" -le 5 ]; do
      tmp="$raw.part"
      rm -f "$tmp"
      echo "NASDAQ_FETCH=$symbol attempt=$retry"
      if curl --fail --location --silent --show-error --compressed \
          --connect-timeout 15 --max-time 60 \
          -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36' \
          -H 'Accept: application/json, text/plain, */*' \
          -H 'Accept-Language: en-US,en;q=0.9' \
          -o "$tmp" "$url" && "$BIN" "$tmp" >/dev/null 2>"$tmp.check"; then
        mv "$tmp" "$raw"
        rm -f "$tmp.check"
        fetched=YES
        break
      fi
      [ ! -f "$tmp.check" ] || sed -n '1,2p' "$tmp.check" >&2
      rm -f "$tmp" "$tmp.check"
      if [ "$retry" -lt 5 ]; then sleep "$((retry * 2))"; fi
      retry=$((retry + 1))
    done
    [ "$fetched" = YES ] || { echo "NASDAQ_SOURCE_UNAVAILABLE=$symbol" >&2; exit 3; }
  fi
  "$BIN" "$raw" > "$csv.part" || { rm -f "$csv.part"; echo "NASDAQ_PARSE_FAIL=$symbol" >&2; exit 3; }
  # Complete training and observation coverage, no silent truncation.
  if ! awk -F, 'NR==2 {first=$1} NR>1 {last=$1;n++} END {if(n<300 || first>"2025-06-02" || last!="2026-11-20") {printf "INCOMPLETE_SERIES n=%d first=%s last=%s\n",n,first,last > "/dev/stderr";exit 1}}' "$csv.part"; then
    rm -f "$csv.part";echo "NASDAQ_COVERAGE_FAIL=$symbol" >&2;exit 3
  fi
  if [ "$symbol" = NVDA ]; then
    # Sanity check on 10:1 split; this is a test, not a license guarantee.
    if ! awk -F, '
      $1=="2024-06-07" {before=$5}
      $1=="2024-06-10" {after=$5}
      END {if(before<=0 || after<=0 || after/before<0.5 || after/before>1.5) {print "SPLIT_ADJUSTMENT_UNVERIFIED" > "/dev/stderr";exit 1}}
    ' "$csv.part"; then
      rm -f "$csv.part";echo "NASDAQ_SPLIT_VALIDATION_FAIL" >&2;exit 4
    fi
  fi
  mv "$csv.part" "$csv"
  sha256sum "$raw" "$csv" >> evidence/NASDAQ-SOURCE-MANIFEST.sha256.part
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$symbol" "$assetclass" "$FROMDATE" "$TODATE" "$url" "$raw" "$csv" >> evidence/nasdaq-fetch.tsv.part
  echo "NASDAQ_PRICE_SERIES=PASS symbol=$symbol"
done
mv evidence/NASDAQ-SOURCE-MANIFEST.sha256.part evidence/NASDAQ-SOURCE-MANIFEST.sha256
mv evidence/nasdaq-fetch.tsv.part evidence/nasdaq-fetch.tsv
printf 'SOURCE_NASDAQ=PASS\nJSON_CACHE=YES\nSYMBOLS=NVDA,QQQ,SOXX\n'
