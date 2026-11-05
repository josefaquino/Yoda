#!/usr/bin/env bash
set -eu
export LC_ALL=C
CASE="${1:?pass case path}"
ROOT="$CASE/lego002"
BIN="$ROOT/bin/yoda-okf-trust"
BUNDLE="$CASE/upstream/okf-industrial/bundles/northfield-plant"
[ -x "$BIN" ] || { echo 'TRUST_TEST=FAIL no binary'; exit 1; }
[ -d "$BUNDLE" ] || { echo 'TRUST_TEST=FAIL no upstream'; exit 1; }
(cd "$CASE/upstream/okf-industrial" && sha256sum -c "$CASE/evidence/source-sha256.txt" >/dev/null)
OUTPUT="$($BIN "$BUNDLE")"
printf '%s\n' "$OUTPUT"
printf '%s\n' "$OUTPUT" | grep -Fqx 'OKF_TRUST=PASS CONFIRMED=2 PENDING=1 REJECTED=1'
TMP="$(mktemp -d /tmp/yoda-okf-trust.XXXXXX)"
trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/heuristics" "$TMP/references"
cp "$BUNDLE/heuristics/"*.md "$TMP/heuristics/"
cp "$BUNDLE/references/"*.md "$TMP/references/"
cp "$BUNDLE/learned.md" "$TMP/learned.md"
# One-byte change in the literal evidence (only in a temporary copy).
sed 's/Give it about 90 seconds/Give it about 91 seconds/' \
    "$TMP/references/shift-handover-cold-start.md" > "$TMP/change"
mv "$TMP/change" "$TMP/references/shift-handover-cold-start.md"
if "$BIN" "$TMP" >/dev/null 2>&1; then
  echo 'TRUST_TEST=FAIL tampered receipt accepted';exit 1
fi
echo 'TAMPERED_QUOTE_REJECTION=PASS'
# Restore source; poison previously rejected claim into a fake confirmed state.
cp "$BUNDLE/references/shift-handover-cold-start.md" "$TMP/references/shift-handover-cold-start.md"
sed 's/review_status: rejected/review_status: confirmed/' \
    "$TMP/learned.md" > "$TMP/change"
mv "$TMP/change" "$TMP/learned.md"
if "$BIN" "$TMP" >/dev/null 2>&1; then
  echo 'TRUST_TEST=FAIL promoted rejected claim accepted';exit 1
fi
echo 'REJECTED_CLAIM_PROMOTION_REJECTION=PASS'
echo 'LEGO_002=PASS'
