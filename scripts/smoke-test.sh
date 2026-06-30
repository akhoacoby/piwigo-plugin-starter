#!/usr/bin/env bash
#
# Reversible DB-backed smoke test: activate a plugin row, curl a page, grep for
# errors, then roll back. NEVER clobbers an already-active plugin.
#
# Required env:
#   PIWIGO_URL   base URL of the running install   (e.g. http://localhost:8001)
#   PLUGIN_ID    plugin folder id / piwigo_plugins.id
#   DB_EXEC      command prefix that runs SQL via -e "…"
#                (e.g. 'docker exec db mariadb -uuser -ppass dbname')
# Optional env:
#   PLUGIN_VERSION  default "auto"
#   PAGE_PATH       page to fetch, default "index.php"
#   ERROR_GREP      regex of failure keywords, default below

set -euo pipefail

: "${PIWIGO_URL:?set PIWIGO_URL}"
: "${PLUGIN_ID:?set PLUGIN_ID}"
: "${DB_EXEC:?set DB_EXEC (SQL command prefix)}"
PLUGIN_VERSION="${PLUGIN_VERSION:-auto}"
PAGE_PATH="${PAGE_PATH:-index.php}"
ERROR_GREP="${ERROR_GREP:-Fatal error|Parse error|Warning:|Notice:|Hacking attempt|Uncaught|Deprecated:}"

sql() { eval "$DB_EXEC" -e "\"$1\""; }

# 1. Guard: bail if the plugin is already present (don't touch real state).
existing="$(sql "SELECT state FROM piwigo_plugins WHERE id='${PLUGIN_ID}';" 2>/dev/null | tail -n +2 || true)"
if [ -n "$existing" ]; then
  echo "abort: plugin '${PLUGIN_ID}' already in piwigo_plugins (state=${existing}). Not modifying it." >&2
  exit 3
fi

cleanup() {
  echo "Rolling back: DELETE FROM piwigo_plugins WHERE id='${PLUGIN_ID}'"
  sql "DELETE FROM piwigo_plugins WHERE id='${PLUGIN_ID}';" >/dev/null 2>&1 || \
    echo ">> rollback failed — run it manually to restore state." >&2
}
trap cleanup EXIT

# 2. Activate.
echo "Activating '${PLUGIN_ID}' (version ${PLUGIN_VERSION})…"
sql "INSERT INTO piwigo_plugins (id,state,version) VALUES ('${PLUGIN_ID}','active','${PLUGIN_VERSION}');" >/dev/null

# 3. Fetch the page.
url="${PIWIGO_URL%/}/${PAGE_PATH#/}"
echo "GET ${url}"
body="$(curl -sS -L "$url" || true)"

# 4. Grep for errors.
if printf '%s' "$body" | grep -Eqi "$ERROR_GREP"; then
  echo "SMOKE TEST FAILED — error keywords in response:"
  printf '%s' "$body" | grep -Eni "$ERROR_GREP" | head -n 20
  exit 1
fi

echo "SMOKE TEST OK — page loaded, no error keywords."
# trap performs rollback on exit.
