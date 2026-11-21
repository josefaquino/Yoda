#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
ASOF=${ASOF:-2026-11-20}
HORIZON=${HORIZON:-60}
SIMS=${SIMS:-10000}
SEED=${SEED:-20261120}
LOOKBACK=${LOOKBACK:-100}
IN=data/normalized/prices-wide.tsv
[ -s "$IN" ] || { echo "MISSING_INPUT=$IN (run ./scripts/run.sh)" >&2; exit 2; }
mkdir -p results/forecast evidence
for c in awk sort sha256sum; do command -v "$c" >/dev/null 2>&1 || exit 2; done
out=results/forecast
awk -v asof="$ASOF" -v horizon="$HORIZON" -v sims="$SIMS" -v seed="$SEED" -v lookback="$LOOKBACK" -v metadata_file="$out/model-metadata.tsv.part" -f scripts/forecast.awk "$IN" > "$out/terminal-samples.tsv.part"
mv "$out/model-metadata.tsv.part" "$out/model-metadata.tsv"
mv "$out/terminal-samples.tsv.part" "$out/terminal-samples.tsv"
awk 'NR>1{print $2}' "$out/terminal-samples.tsv" | LC_ALL=C sort -n > "$out/terminal-sorted.txt"
spot=$(awk -F '\t' '$1=="spot"{print $2}' "$out/model-metadata.tsv")
awk -v spot="$spot" -f scripts/quantiles.awk "$out/terminal-sorted.txt" > "$out/summary.tsv"
sha256sum "$IN" scripts/forecast.awk scripts/quantiles.awk scripts/forecast.sh "$out/model-metadata.tsv" "$out/terminal-samples.tsv" "$out/summary.tsv" > evidence/FORECAST-MANIFEST.sha256
printf 'FORECAST=PASS\nASOF=%s\nHORIZON_SESSIONS=%s\n' "$ASOF" "$HORIZON"
cat "$out/summary.tsv"
