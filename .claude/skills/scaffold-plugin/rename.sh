#!/usr/bin/env bash
#
# Rename the example_plugin starter into a real plugin.
# Usage: bash rename.sh <plugin_id> ["Display Name"] ["Author"]
#
# Replaces tokens across the repo (EXAMPLE_PLUGIN, example_plugin, "Example plugin"),
# then renames the plugin folder. Skips .git/ and .claude/ (so the skills keep
# referring to example_plugin as documentation).
#
# The whole body is wrapped in main() and called at the very end so bash has read
# the entire file into memory before we move the directory it lives in.

set -euo pipefail

main() {
  local NEW_ID="${1:-}"
  local DISPLAY="${2:-}"
  local AUTHOR="${3:-}"

  if [ -z "$NEW_ID" ]; then
    echo "usage: bash rename.sh <plugin_id> [\"Display Name\"] [\"Author\"]" >&2
    exit 2
  fi
  if ! printf '%s' "$NEW_ID" | grep -Eq '^[a-z][a-z0-9_]*$'; then
    echo "error: plugin id must be snake_case matching ^[a-z][a-z0-9_]*\$ (got: $NEW_ID)" >&2
    exit 2
  fi

  # Plugin root = three levels up from this script (.claude/skills/scaffold-plugin/).
  local SCRIPT_DIR ROOT
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

  if [ ! -f "$ROOT/main.inc.php" ]; then
    echo "error: could not locate plugin root (no main.inc.php at $ROOT)" >&2
    exit 1
  fi

  local UPPER_ID
  UPPER_ID="$(printf '%s' "$NEW_ID" | tr '[:lower:]' '[:upper:]')"

  # Default display name: title-case the id (under_scores -> spaces).
  if [ -z "$DISPLAY" ]; then
    DISPLAY="$(printf '%s' "$NEW_ID" | tr '_' ' ' | awk '{ for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print }')"
  fi

  echo "Plugin root : $ROOT"
  echo "New id      : $NEW_ID"
  echo "Constant    : ${UPPER_ID}_*  (e.g. ${UPPER_ID}_PATH)"
  echo "Display name: $DISPLAY"
  [ -n "$AUTHOR" ] && echo "Author      : $AUTHOR"
  echo

  replace_in_files() {
    local from="$1" to="$2"
    find "$ROOT" -type f \
      \( -name '*.php' -o -name '*.tpl' -o -name '*.md' -o -name '*.css' -o -name '*.js' -o -name '*.json' \) \
      -not -path '*/.git/*' -not -path '*/.claude/*' -print0 \
      | xargs -0 -r sed -i "s/${from}/${to}/g"
  }

  # Order is case-sensitive and independent, but do UPPER first for clarity.
  replace_in_files 'EXAMPLE_PLUGIN' "$UPPER_ID"
  replace_in_files 'example_plugin' "$NEW_ID"
  # Header display name (sed-escape the replacement's & and /).
  local DISPLAY_ESC AUTHOR_ESC
  DISPLAY_ESC="$(printf '%s' "$DISPLAY" | sed 's/[&/\\]/\\&/g')"
  replace_in_files 'Example plugin' "$DISPLAY_ESC"
  if [ -n "$AUTHOR" ]; then
    AUTHOR_ESC="$(printf '%s' "$AUTHOR" | sed 's/[&/\\]/\\&/g')"
    # Replace the starter's author lines.
    find "$ROOT" -name 'main.inc.php' -not -path '*/.git/*' -not -path '*/.claude/*' -print0 \
      | xargs -0 -r sed -i "s/^Author: .*/Author: ${AUTHOR_ESC}/"
  fi

  echo "Token replacement done."

  # Rename the folder so the guard (basename == id) passes.
  local PARENT NEWPATH
  PARENT="$(dirname "$ROOT")"
  NEWPATH="$PARENT/$NEW_ID"
  if [ "$(basename "$ROOT")" = "example_plugin" ] && [ "$ROOT" != "$NEWPATH" ]; then
    if [ -e "$NEWPATH" ]; then
      echo "warning: $NEWPATH already exists — folder NOT renamed. Rename manually." >&2
    else
      mv "$ROOT" "$NEWPATH"
      echo "Folder renamed: $ROOT -> $NEWPATH"
      ROOT="$NEWPATH"
    fi
  else
    echo "Folder basename is not 'example_plugin' — leaving folder name as-is."
  fi

  echo
  echo "Leftover 'example_plugin' references (should be empty):"
  if grep -rni example_plugin "$ROOT" --exclude-dir=.git --exclude-dir=.claude 2>/dev/null; then
    echo ">> Some references remain — fix them by hand." >&2
  else
    echo "  (none)"
  fi
  echo
  echo "Next: set Version/Plugin URI/Author URI in main.inc.php, then run the verify-plugin skill."
}

main "$@"
