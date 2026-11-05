#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
CASE=${1:?Usage: test_report.sh CASE_DIR}
APP="$CASE/lego005/bin/yoda-evidence-report"
VERIFY="$CASE/lego005/bin/yoda-verify-report"
[[ -x "$APP" && -x "$VERIFY" ]] || { echo 'LEGO_005=FAIL missing_executable' >&2; exit 1; }
TMP=$(mktemp -d /tmp/yoda-lego005-test.XXXXXXXX)
trap 'rm -rf -- "$TMP"' EXIT
for spec in \
 'fresh-confirmed|Give it about 90 seconds|CONTEXT_ELIGIBLE_FOR_HUMAN_REVIEW' \
 'stale-confirmed|Give it about 90 seconds|ADVISORY_ONLY' \
 'pending-observation|Across three M-201 restarts this week|HYPOTHESIS_ONLY' \
 'rejected-observation|M-201 line-current spikes|IGNORE_CLAIM'
do
  IFS='|' read -r scenario excerpt expected <<< "$spec"
  jq -n --arg quote "$excerpt" '{evidence_quote:$quote}' > "$TMP/response.json"
  "$APP" "$CASE" "$scenario" --out "$TMP/$scenario" --fixture-response "$TMP/response.json" >/dev/null
  "$VERIFY" "$TMP/$scenario" | grep -Fqx 'REPORT_VERIFY=PASS CHECKSUMS_ONLY NOT_DIGITALLY_SIGNED'
  jq -e --arg s "$scenario" --arg d "$expected" '
    .observation.scenario == $s and .authority.decision == $d and
    .authority.owner=="C11_GATE" and .authority.control_action=="FORBIDDEN" and
    .knowledge.quote_present_in_source==true and .llm.exact_model_excerpt_recorded==false' "$TMP/$scenario/report.json" >/dev/null
  printf 'REPORT_%s=PASS\n' "$scenario"
done
printf 'not a valid excerpt\n' > "$TMP/notvalid.json"
if "$APP" "$CASE" fresh-confirmed --out "$TMP/bad" --fixture-response "$TMP/notvalid.json" >/dev/null 2>&1; then
  echo 'REPORT_INVALID_EVIDENCE_REJECTION=FAIL'; exit 1
fi
[[ ! -e "$TMP/bad" ]] || { echo 'REPORT_INVALID_OUTPUT_CLEANUP=FAIL'; exit 1; }
echo 'REPORT_INVALID_EVIDENCE_REJECTION=PASS'
# Identical fixture and same inputs must generate the same semantic report bytes.
jq -n --arg quote 'Give it about 90 seconds' '{evidence_quote:$quote}' > "$TMP/repeat-response.json"
"$APP" "$CASE" fresh-confirmed --out "$TMP/repeated" --fixture-response "$TMP/repeat-response.json" >/dev/null
# First report above was built using a different fixture path but the same bytes.
cmp -s "$TMP/fresh-confirmed/report.json" "$TMP/repeated/report.json" || { echo 'REPORT_REPRODUCIBILITY=FAIL'; exit 1; }
cmp -s "$TMP/fresh-confirmed/report.md" "$TMP/repeated/report.md" || { echo 'REPORT_REPRODUCIBILITY=FAIL'; exit 1; }
echo 'REPORT_REPRODUCIBILITY=PASS'
if "$APP" "$CASE" fresh-confirmed --out "$TMP/repeated" --fixture-response "$TMP/repeat-response.json" >/dev/null 2>&1; then
  echo 'REPORT_OVERWRITE_PROTECTION=FAIL'; exit 1
fi
echo 'REPORT_OVERWRITE_PROTECTION=PASS'
printf '\nTAMPERED\n' >> "$TMP/fresh-confirmed/report.md"
if "$VERIFY" "$TMP/fresh-confirmed" >/dev/null 2>&1; then
  echo 'REPORT_TAMPER_REJECTION=FAIL'; exit 1
fi
echo 'REPORT_TAMPER_REJECTION=PASS'
echo 'LEGO_005=PASS'
