#!/usr/bin/env bash
set -euo pipefail
ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
[[ -f "$ROOT/evidence/source-sha256.txt" ]] || { echo 'Run scripts/setup-upstream.sh first' >&2; exit 1; }
make -C "$ROOT"
make -C "$ROOT/lego002"
make -C "$ROOT/lego003"
bash "$ROOT/tests/test_okf.sh" "$ROOT"
bash "$ROOT/lego002/tests/test_trust.sh" "$ROOT"
bash "$ROOT/lego003/tests/test_gate.sh" "$ROOT"
bash "$ROOT/lego004-r1/tests/test_evidence.sh" "$ROOT"
bash "$ROOT/lego005/tests/test_report.sh" "$ROOT"
echo 'ALL_OFFLINE_TESTS=PASS'
