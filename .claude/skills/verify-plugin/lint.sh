#!/usr/bin/env bash
#
# php -l sweep across the plugin. Exit non-zero if any file fails.
# Usage: bash lint.sh   (locates the plugin root from its own path)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if ! command -v php >/dev/null 2>&1; then
  echo "error: 'php' not on PATH. If Piwigo runs in Docker, lint inside the container instead." >&2
  exit 1
fi

fail=0
count=0
while IFS= read -r -d '' f; do
  count=$((count + 1))
  if ! out="$(php -l "$f" 2>&1)"; then
    echo "FAIL: $f"
    echo "$out"
    fail=1
  fi
done < <(find "$ROOT" -name '*.php' -not -path '*/.git/*' -print0)

if [ "$fail" -eq 0 ]; then
  echo "OK: $count PHP file(s) — no syntax errors."
else
  echo "Lint failed (see above)." >&2
fi
exit "$fail"
