#!/usr/bin/env bash
set -eu
export LC_ALL=C

HERE="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CASE="${1:-$HERE}"
SRC="$CASE/upstream/okf-industrial"
BUNDLE="$SRC/bundles/northfield-plant"
MANIFEST="$CASE/evidence/source-sha256.txt"
BIN="$HERE/bin/yoda-okf"

fail() { printf 'LEGO_001=FAIL | %s\n' "$1" >&2; exit 1; }
[ -x "$BIN" ] || fail 'bin/yoda-okf not found: run make'
[ -r "$MANIFEST" ] || fail 'source hash manifest missing'
[ -d "$BUNDLE" ] || fail 'Northfield bundle missing'

COMMIT="$(git -C "$SRC" rev-parse HEAD 2>/dev/null || true)"
[ "$COMMIT" = '72bbcc40aa729d4b929314c2e20c0961ad04843c' ] ||
    fail "unexpected upstream commit: $COMMIT"
(cd "$SRC" && sha256sum -c "$MANIFEST" >/dev/null) ||
    fail 'upstream source SHA-256 changed'
printf 'SOURCE_SHA256=PASS\n'

INV="$($BIN inventory "$BUNDLE")" || fail 'inventory command'
printf '%s\n' "$INV" | grep -Fqx 'BUNDLE_FILES=18' || fail 'expected 18 Markdown files'
for expected in \
    'TYPE=Asset COUNT=4' \
    'TYPE=Heuristic COUNT=2' \
    'TYPE=Policy COUNT=2' \
    'TYPE=Reference COUNT=5' \
    'TYPE=Relations COUNT=1' \
    'TYPE=Skill COUNT=1' \
    'TYPE=Tag Directory COUNT=1'
do
    printf '%s\n' "$INV" | grep -Fqx "$expected" || fail "inventory mismatch: $expected"
done
printf 'INVENTORY=PASS\n'

CHECK="$($BIN check "$BUNDLE")" || fail 'bundle references failed'
printf '%s\n' "$CHECK" | grep -Fq 'OKF_CHECK=PASS' || fail 'bundle check not PASS'
printf '%s\n' "$CHECK"

INFO="$($BIN inspect "$BUNDLE" P-101A)" || fail 'asset inspection'
for expected in \
    'ASSET=P-101A' \
    'RESOURCE=/assets/slurry-charge-pump-101a.md' \
    'TRUST_WINDOW_MINUTES=30' \
    'LIVE_SENSOR_STATE=NOT_AVAILABLE_IN_OKF'
do
    printf '%s\n' "$INFO" | grep -Fqx "$expected" || fail "inspect missing: $expected"
done
printf '%s\n' "$INFO" | grep -Fq 'RELATION=/assets/slurry-charge-pump-101a.md FLOWS_TO /assets/clarifier-tank-101.md' || fail 'relation missing'
if "$BIN" inspect "$BUNDLE" NOT-A-REAL-ASSET >/dev/null 2>&1; then
    fail 'unknown asset was accepted'
fi
printf 'INSPECT=PASS\n'

TMP="$(mktemp -d /tmp/yoda-okf-test.XXXXXX)" || fail 'mktemp failed'
trap 'rm -rf -- "$TMP"' EXIT
cp -R "$BUNDLE" "$TMP/northfield-plant" || fail 'fixture copy failed'

sed 's@/assets/clarifier-tank-101.md@/assets/missing-asset.md@' \
    "$TMP/northfield-plant/relations.md" > "$TMP/rewrite.md"
mv "$TMP/rewrite.md" "$TMP/northfield-plant/relations.md"
if "$BIN" check "$TMP/northfield-plant" >/dev/null 2>&1; then
    fail 'broken reference was accepted'
fi
printf 'BROKEN_REFERENCE_REJECTION=PASS\n'
printf 'LEGO_001=PASS\n'
