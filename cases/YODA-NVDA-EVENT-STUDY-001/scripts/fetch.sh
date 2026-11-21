#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEST="$ROOT/data/raw"
mkdir -p "$DEST"
for symbol in NVDA QQQ SOXX; do
 case "$symbol" in
 NVDA) ticker=nvda.us ;;
 QQQ) ticker=qqq.us ;;
 SOXX) ticker=soxx.us ;;
 esac
 url="https://stooq.com/q/d/l/?s=$ticker&i=d&d1=20250601&d2=20261120"
 tmp="$DEST/$symbol.csv.part"
 echo "FETCH $symbol $url"
 rm -f "$tmp"
 if ! curl --fail --location --silent --show-error --retry 2 --max-time 45 -A 'Yoda-Case-Research/1.0' "$url" > "$tmp"; then
  rm -f "$tmp";echo "FETCH_FAIL symbol=$symbol" >&2;exit 1
 fi
 if ! awk -F, 'NR==1 {gsub(/\r/,"",$0);if($1!="Date"||$5!="Close")exit 1;valid=1} END{if(NR<50||!valid)exit 1}' "$tmp";then
  rm -f "$tmp";echo "BAD_CSV symbol=$symbol" >&2;exit 1
 fi
 mv "$tmp" "$DEST/$symbol.csv"
 echo "FETCH_OK symbol=$symbol"
done
