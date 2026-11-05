#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
UP="$ROOT/upstream/okf-industrial"
COMMIT=72bbcc40aa729d4b929314c2e20c0961ad04843c
EXPECTED_MANIFEST=584e1ad725fb3fb8b45e504df642998baaf05544ddcd5c2df8b8d63568c68e74
for x in git sha256sum find sort; do command -v "$x" >/dev/null || { echo "MISSING=$x" >&2; exit 1; }; done
if [[ -e "$UP" ]]; then
    echo "STOP: upstream path exists; no overwrite: $UP" >&2
    exit 1
fi
mkdir -p "$ROOT/upstream" "$ROOT/evidence"
git clone --no-checkout --depth 1 https://github.com/augurysys/okf-industrial.git "$UP"
git -C "$UP" fetch --quiet --depth 1 origin "$COMMIT"
git -C "$UP" -c advice.detachedHead=false checkout --quiet --detach "$COMMIT"
[[ $(git -C "$UP" rev-parse HEAD) == "$COMMIT" ]] || { echo 'UPSTREAM_COMMIT=FAIL'; exit 1; }
(
 cd "$UP"
 find . -type f ! -path './.git/*' -print | sort | \
 while IFS= read -r f; do sha256sum "$f"; done
) > "$ROOT/evidence/source-sha256.txt"
printf '%s  %s\n' "$EXPECTED_MANIFEST" "$ROOT/evidence/source-sha256.txt" | sha256sum -c -
(cd "$UP" && sha256sum -c "$ROOT/evidence/source-sha256.txt" >/dev/null)
echo "UPSTREAM_COMMIT=$COMMIT"
echo 'UPSTREAM_SNAPSHOT=PASS'
