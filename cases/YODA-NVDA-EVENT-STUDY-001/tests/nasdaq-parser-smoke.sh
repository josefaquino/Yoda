#!/bin/sh
# Synthetic parser smoke test. It does not establish real Nasdaq data correctness.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
cc -std=c11 -O2 -Wall -Wextra -pedantic "$ROOT/scripts/nasdaq-json-to-csv.c" -lm -o "$tmp/parser"
cat > "$tmp/good.json" <<'JSON'
{"status":{"rCode":200},"data":{"tradesTable":{"rows":[{"date":"11/20/2026","close":"$125.53","volume":"1,200,000","open":"$126.23","high":"$128.99","low":"$124.51"},{"date":"11/19/2026","close":"$130.03","volume":"2,000,000","open":"$129.13","high":"$132.99","low":"$128.51"}]}}}
JSON
"$tmp/parser" "$tmp/good.json" > "$tmp/out.csv"
test "$(wc -l < "$tmp/out.csv")" -eq 3
test "$(tail -n 1 "$tmp/out.csv" | cut -d, -f1)" = "2026-11-20"
printf '{"data":null}\n' > "$tmp/null.json"
if "$tmp/parser" "$tmp/null.json" > /dev/null 2>&1; then echo 'BAD_NULL_ACCEPTANCE' >&2;exit 2;fi
sed 's/11\/19\/2026/11\/20\/2026/' "$tmp/good.json" > "$tmp/duplicate.json"
if "$tmp/parser" "$tmp/duplicate.json" > /dev/null 2>&1; then echo 'BAD_DUPLICATE_ACCEPTANCE' >&2;exit 2;fi
printf 'SYNTHETIC_NASDAQ_PARSER=PASS\nACTUAL_NASDAQ_VALIDATION=NOT_RUN\n'
