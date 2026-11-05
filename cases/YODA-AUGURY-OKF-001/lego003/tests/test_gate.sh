#!/usr/bin/env bash
set -eu
export LC_ALL=C
CASE="${1:?pass case directory}"
ROOT="$CASE/lego003"
BUNDLE="$CASE/upstream/okf-industrial/bundles/northfield-plant"
BIN="$ROOT/bin/yoda-okf-gate"
TRUST="$CASE/lego002/bin/yoda-okf-trust"
test -x "$BIN" && test -x "$TRUST" && test -d "$BUNDLE"
(cd "$CASE/upstream/okf-industrial" && sha256sum -c "$CASE/evidence/source-sha256.txt" >/dev/null)
"$TRUST" "$BUNDLE" > /dev/null
printf 'UPSTREAM_DOCUMENT_TRUST=PASS\n'
OUT="$("$BIN" "$BUNDLE" "$ROOT/fixtures/scenarios.tsv")"
printf '%s\n' "$OUT"
printf '%s\n' "$OUT" | grep -Fq 'SCENARIO=fresh-confirmed CLAIM=cold-start REVIEW=CONFIRMED READING=FRESH_ASSUMED WINDOW_MIN=30 DECISION=CONTEXT_ELIGIBLE_FOR_HUMAN_REVIEW CONTROL_ACTION=FORBIDDEN DATA=SIMULATED'
printf '%s\n' "$OUT" | grep -Fq 'SCENARIO=stale-confirmed CLAIM=cold-start REVIEW=CONFIRMED READING=STALE_ASSUMED WINDOW_MIN=30 DECISION=ADVISORY_ONLY CONTROL_ACTION=FORBIDDEN DATA=SIMULATED'
printf '%s\n' "$OUT" | grep -Fq 'SCENARIO=pending-observation CLAIM=pending REVIEW=PENDING READING=FRESH_ASSUMED WINDOW_MIN=30 DECISION=HYPOTHESIS_ONLY CONTROL_ACTION=FORBIDDEN DATA=SIMULATED'
printf '%s\n' "$OUT" | grep -Fq 'SCENARIO=rejected-observation CLAIM=rejected REVIEW=REJECTED READING=FRESH_ASSUMED WINDOW_MIN=30 DECISION=IGNORE_CLAIM CONTROL_ACTION=FORBIDDEN DATA=SIMULATED'
printf '%s\n' "$OUT" | grep -Fqx 'OKF_GATE=PASS SCENARIOS=4 TELEMETRY=NOT_CONNECTED HUMAN_CONTROL=REQUIRED'
TMP="$(mktemp -d /tmp/yoda-okf-gate.XXXXXX)"
trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/heuristics" "$TMP/assets"
cp "$BUNDLE/learned.md" "$TMP/learned.md"
cp "$BUNDLE/heuristics/"*.md "$TMP/heuristics/"
cp "$BUNDLE/assets/slurry-charge-pump-101a.md" "$TMP/assets/slurry-charge-pump-101a.md"
# Simulated contract change in disposable fixture: window 30 -> 1.
sed 's/trust_window_minutes: 30/trust_window_minutes: 1/' \
  "$TMP/assets/slurry-charge-pump-101a.md" > "$TMP/changed"
mv "$TMP/changed" "$TMP/assets/slurry-charge-pump-101a.md"
"$BIN" "$TMP" "$ROOT/fixtures/scenarios.tsv" | grep -Fq 'SCENARIO=fresh-confirmed CLAIM=cold-start REVIEW=CONFIRMED READING=STALE_ASSUMED WINDOW_MIN=1 DECISION=ADVISORY_ONLY'
echo 'POLICY_WINDOW_CHANGE=PASS'
# Simulated rejection of a previously confirmed heuristic downgrades authority.
sed 's/review_status: confirmed/review_status: pending/' \
  "$TMP/heuristics/pump-101a-cold-start.md" > "$TMP/changed"
mv "$TMP/changed" "$TMP/heuristics/pump-101a-cold-start.md"
"$BIN" "$TMP" "$ROOT/fixtures/scenarios.tsv" | grep -Fq 'SCENARIO=fresh-confirmed CLAIM=cold-start REVIEW=PENDING READING=STALE_ASSUMED WINDOW_MIN=1 DECISION=HYPOTHESIS_ONLY'
echo 'KNOWLEDGE_DOWNGRADE=PASS'
# Schema corruption must fail closed.
sed 's/trust_window_minutes: 1/trust_window_minutes: NOT_A_NUMBER/' \
  "$TMP/assets/slurry-charge-pump-101a.md" > "$TMP/changed"
mv "$TMP/changed" "$TMP/assets/slurry-charge-pump-101a.md"
if "$BIN" "$TMP" "$ROOT/fixtures/scenarios.tsv" >/dev/null 2>&1; then
  echo 'TEST_FAIL=invalid trust window accepted';exit 1
fi
echo 'BAD_POLICY_REJECTION=PASS'
echo 'LEGO_003=PASS'
