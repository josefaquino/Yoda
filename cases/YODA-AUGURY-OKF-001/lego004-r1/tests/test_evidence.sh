#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
CASE=${1:?Usage: test_evidence.sh CASE_DIR}
BIN="$CASE/lego004-r1/bin/yoda-ai-evidence"
[[ -x "$BIN" ]] || { echo 'R1_TEST=FAIL missing binary' >&2; exit 1; }
TMP=$(mktemp -d /tmp/yoda-evidence-test.XXXXXXXX)
trap 'rm -rf -- "$TMP"' EXIT
for spec in \
 'fresh-confirmed|Give it about 90 seconds|CONTEXT_ELIGIBLE_FOR_HUMAN_REVIEW' \
 'stale-confirmed|Give it about 90 seconds|ADVISORY_ONLY' \
 'pending-observation|Across three M-201 restarts this week|HYPOTHESIS_ONLY' \
 'rejected-observation|M-201 line-current spikes|IGNORE_CLAIM'
do
  IFS='|' read -r SCENARIO QUOTE EXPECTED_DECISION <<< "$spec"
  jq -n --arg q "$QUOTE" '{evidence_quote:$q}' > "$TMP/valid.json"
  OUTPUT=$("$BIN" "$CASE" "$SCENARIO" --fixture-response "$TMP/valid.json") || { echo "TEST_FAIL=$SCENARIO"; exit 1; }
  printf '%s\n' "$OUTPUT" | grep -Fqx "HOST_DECISION=$EXPECTED_DECISION DECISION_OWNER=C11_GATE CONTROL_ACTION=FORBIDDEN DATA=SIMULATED" || { echo "TEST_FAIL=authority_$SCENARIO"; exit 1; }
  printf '%s\n' "$OUTPUT" | grep -Fqx 'AI_GUARD=PASS TELEMETRY=NOT_CONNECTED HUMAN_CONTROL=REQUIRED' || { echo "TEST_FAIL=guard_$SCENARIO"; exit 1; }
  echo "FIXTURE_$SCENARIO=PASS"
done
jq -n '{evidence_quote:"Invented machine fault evidence not in source"}' > "$TMP/false.json"
if "$BIN" "$CASE" fresh-confirmed --fixture-response "$TMP/false.json" >/dev/null 2>&1; then echo 'TEST_FAIL=false_quote_accepted'; exit 1; fi
echo 'REJECT_false_quote=PASS'
jq -n '{evidence_quote:"Across three M-201 restarts this week"}' > "$TMP/wrong.json"
if "$BIN" "$CASE" rejected-observation --fixture-response "$TMP/wrong.json" >/dev/null 2>&1; then echo 'TEST_FAIL=wrong_claim_quote_accepted'; exit 1; fi
echo 'REJECT_cross_claim_quote=PASS'
jq -n '{evidence_quote:"Give it about 90 seconds",suggested_decision:"ALLOW_TRIP"}' > "$TMP/permission.json"
if "$BIN" "$CASE" fresh-confirmed --fixture-response "$TMP/permission.json" >/dev/null 2>&1; then echo 'TEST_FAIL=extra_field_accepted'; exit 1; fi
echo 'REJECT_llm_permission_field=PASS'
printf 'not json\n' > "$TMP/invalid.json"
if "$BIN" "$CASE" fresh-confirmed --fixture-response "$TMP/invalid.json" >/dev/null 2>&1; then echo 'TEST_FAIL=invalid_json_accepted'; exit 1; fi
echo 'REJECT_invalid_json=PASS'
echo 'LEGO_004_R1_OFFLINE=PASS'
