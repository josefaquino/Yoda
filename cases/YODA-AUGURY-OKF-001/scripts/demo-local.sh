#!/usr/bin/env bash
set -euo pipefail
ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
BUNDLE="$ROOT/upstream/okf-industrial/bundles/northfield-plant"
MODEL=${1:-qwen2.5:3b}
[[ -d "$BUNDLE" ]] || { echo 'Run scripts/setup-upstream.sh first' >&2; exit 1; }
"$ROOT/bin/yoda-okf" inventory "$BUNDLE"
"$ROOT/bin/yoda-okf" check "$BUNDLE"
"$ROOT/bin/yoda-okf" inspect "$BUNDLE" P-101A
for scenario in fresh-confirmed stale-confirmed pending-observation rejected-observation; do
    echo "=== $scenario ==="
    "$ROOT/lego004-r1/bin/yoda-ai-evidence" "$ROOT" "$scenario" --model "$MODEL"
done
