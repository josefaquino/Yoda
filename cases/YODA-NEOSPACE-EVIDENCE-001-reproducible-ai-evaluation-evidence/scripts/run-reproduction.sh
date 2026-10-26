#!/usr/bin/env bash
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
BASE="https://embeddings.neospace.ai/cortex_score"
command -v curl >/dev/null
command -v sha256sum >/dev/null
command -v duckdb >/dev/null
mkdir -p "$ROOT/scores"
for N in 000 001 002 003; do
  FILE="$ROOT/scores/$N.parquet"
  if test ! -s "$FILE"; then
    curl --fail --location --show-error --retry 3 \
      --user-agent neoldm-benchmark \
      --output "$FILE.part" "$BASE/$N.parquet"
    mv "$FILE.part" "$FILE"
  fi
done
(cd "$ROOT/scores" && sha256sum -c "$ROOT/evidence/scores.sha256")
echo "=== INDEPENDENT METRICS ==="
(cd "$ROOT" && TZ=UTC duckdb -c "$(cat scripts/reproduce.sql)")
echo "REPRODUCTION=COMPLETE"
