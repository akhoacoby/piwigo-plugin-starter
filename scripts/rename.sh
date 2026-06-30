#!/usr/bin/env bash
#
# Scaffold a new Piwigo plugin from the starter's template/ skeleton.
# Usage: bash rename.sh <plugin_id> [dest_parent_dir] ["Display Name"] ["Author"]
#
# Copies <repo>/template -> <dest_parent_dir>/<plugin_id>, then replaces tokens
# (EXAMPLE_PLUGIN, example_plugin, "Example plugin") in the copy. The skeleton in
# template/ is never modified, so you can scaffold many plugins from it.

set -euo pipefail

main() {
  local NEW_ID="${1:-}"
  local DEST_PARENT="${2:-}"
  local DISPLAY="${3:-}"
  local AUTHOR="${4:-}"

  if [ -z "$NEW_ID" ]; then
    echo "usage: bash rename.sh <plugin_id> [dest_parent_dir] [\"Display Name\"] [\"Author\"]" >&2
    exit 2
  fi
  if ! printf '%s' "$NEW_ID" | grep -Eq '^[a-z][a-z0-9_]*$'; then
    echo "error: plugin id must be snake_case matching ^[a-z][a-z0-9_]*\$ (got: $NEW_ID)" >&2
    exit 2
  fi

  # Repo root = one level up from this script (scripts/).
  local SCRIPT_DIR REPO SRC
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
  SRC="$REPO/template"

  if [ ! -f "$SRC/main.inc.php" ]; then
    echo "error: skeleton not found at $SRC (expected template/main.inc.php)" >&2
    exit 1
  fi

  # Default destination parent = repo root -> <repo>/<plugin_id>.
  [ -z "$DEST_PARENT" ] && DEST_PARENT="$REPO"
  DEST_PARENT="$(cd "$DEST_PARENT" 2>/dev/null && pwd || true)"
  if [ -z "$DEST_PARENT" ]; then
    echo "error: dest_parent_dir does not exist" >&2
    exit 2
  fi
  local DEST="$DEST_PARENT/$NEW_ID"
  if [ -e "$DEST" ]; then
    echo "error: $DEST already exists — refusing to overwrite." >&2
    exit 2
  fi

  local UPPER_ID
  UPPER_ID="$(printf '%s' "$NEW_ID" | tr '[:lower:]' '[:upper:]')"
  if [ -z "$DISPLAY" ]; then
    DISPLAY="$(printf '%s' "$NEW_ID" | tr '_' ' ' | awk '{ for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print }')"
  fi

  echo "Skeleton    : $SRC"
  echo "New plugin  : $DEST"
  echo "Id          : $NEW_ID   Constant: ${UPPER_ID}_*   Display: $DISPLAY"
  [ -n "$AUTHOR" ] && echo "Author      : $AUTHOR"
  echo

  # Copy skeleton (no .git inside template/, but exclude defensively).
  cp -a "$SRC" "$DEST"
  rm -rf "$DEST/.git" 2>/dev/null || true

  replace_in_files() {
    local from="$1" to="$2"
    find "$DEST" -type f \
      \( -name '*.php' -o -name '*.tpl' -o -name '*.md' -o -name '*.css' -o -name '*.js' -o -name '*.json' \) \
      -print0 | xargs -0 -r sed -i "s/${from}/${to}/g"
  }

  replace_in_files 'EXAMPLE_PLUGIN' "$UPPER_ID"
  replace_in_files 'example_plugin' "$NEW_ID"
  local DISPLAY_ESC
  DISPLAY_ESC="$(printf '%s' "$DISPLAY" | sed 's/[&/\\]/\\&/g')"
  replace_in_files 'Example plugin' "$DISPLAY_ESC"
  if [ -n "$AUTHOR" ]; then
    local AUTHOR_ESC
    AUTHOR_ESC="$(printf '%s' "$AUTHOR" | sed 's/[&/\\]/\\&/g')"
    find "$DEST" -name 'main.inc.php' -print0 | xargs -0 -r sed -i "s/^Author: .*/Author: ${AUTHOR_ESC}/"
  fi

  echo "Created $DEST"
  echo
  echo "Leftover 'example_plugin' references (should be empty):"
  if grep -rni example_plugin "$DEST" 2>/dev/null; then
    echo ">> Some references remain — fix them by hand." >&2
  else
    echo "  (none)"
  fi
  echo
  echo "Next: set Version/Plugin URI/Author URI in $DEST/main.inc.php, then verify (scripts/lint.sh — see workflows/verify-plugin.md)."
}

main "$@"
