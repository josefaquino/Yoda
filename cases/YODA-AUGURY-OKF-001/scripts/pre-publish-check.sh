#!/usr/bin/env bash
set -euo pipefail
ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$ROOT"
echo '=== PRE-PUBLISH AUDIT ==='
for path in upstream evidence bin lego002/bin lego003/bin; do
  if [[ -e "$path" ]]; then echo "NOTE_IGNORE=$path"; fi
done
# Check only tracked/staged content, including a proposed new git repository.
files=$(git ls-files --cached 2>/dev/null || true)
if [[ -z "$files" ]]; then
  echo 'No staged files yet. Initialize git and git add only after reviewing the tree.'
  exit 0
fi
while IFS= read -r f; do
  case "$f" in upstream/*|evidence/*|*.pem|*.key|*.env|.env|.env.*) echo "UNSAFE_STAGED=$f"; exit 1;; esac
done <<< "$files"
if grep -nE '(api[_-]?key|password|token)[[:space:]]*[:=][[:space:]]*[^[:space:]]+' -- $(git ls-files --cached | grep -Ev '^LICENSE$' || true) 2>/dev/null; then
  echo 'POSSIBLE_SECRET_FOUND: manually inspect lines before publishing'
  exit 1
fi
echo 'PRE_PUBLISH=REVIEW_PASSED_BEST_EFFORT'
