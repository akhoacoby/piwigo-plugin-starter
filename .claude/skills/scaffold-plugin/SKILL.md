---
name: scaffold-plugin
description: Rename the example_plugin starter into a real plugin — replaces every token (folder, EXAMPLE_PLUGIN_* constants, example_plugin_* functions, the _maintain class, the $conf['example_plugin'] key, the main.inc.php header) and the folder guard. Use this ONCE, first thing, before writing any feature code. Trigger when the user says "start a new plugin", "rename the starter", "scaffold", or gives a new plugin name.
---

# Scaffold a new plugin (rename the starter)

The starter ships as `example_plugin` and `main.inc.php` has a **folder-name guard** that keeps it inert until renamed consistently. This is always the first step. See `guidelines/01-architecture.md`.

## Inputs to collect
- **plugin id** (required): the folder name, `snake_case`, `^[a-z][a-z0-9_]*$` (e.g. `photo_compare`). This becomes the folder, the `_PLUGIN_*` constant prefix (uppercased), the `*_init`/handler function prefix, the `_maintain` class, and the `$conf[...]` key.
- **display name** (optional): human-facing `Plugin Name:` header (e.g. "Photo Compare").
- **author** / **description** (optional): for the `main.inc.php` header.

If the user only gave a name in prose, derive the id (lowercase, spaces→underscores) and confirm it back in one line — don't block on it.

## Run the rename
From anywhere, run the bundled script — it locates the plugin root from its own path:

```bash
bash .claude/skills/scaffold-plugin/rename.sh <plugin_id> ["Display Name"] ["Author"]
```

The script: replaces `EXAMPLE_PLUGIN` → `<UPPER_ID>`, `example_plugin` → `<plugin_id>`, and `Example plugin` → display name across `*.php *.tpl *.md *.css *.js *.json` (excluding `.git/` and `.claude/`); then renames the folder itself. It **skips its own `.claude/` skills** so these instructions keep referring to `example_plugin`.

## After running — verify (do not skip)
1. `grep -rni example_plugin . --exclude-dir=.git --exclude-dir=.claude` → must be empty. Anything left is a missed token; fix by hand.
2. Confirm the folder was renamed (`basename "$PWD"` of the plugin == the new id) — the guard compares against it.
3. Set the header fields the script can't infer: `Version:`, `Plugin URI:`, `Author URI:`, and confirm `Has Settings:`.
4. `php -l` the touched PHP files (or run the `verify-plugin` skill).

## Notes
- Idempotent-ish: safe to re-run only if some `example_plugin` tokens remain; once fully renamed there's nothing left to match.
- The `_maintain` class name MUST equal `{folder}_maintain` — the rename keeps them in lockstep, so never rename one without the other.
- Constants derive `ID` from `basename(dirname(__FILE__))`, so the folder name is the source of truth; the literal constant prefix just has to match.

> Reference: `guidelines/01-architecture.md`, `PIWIGO_CONVENTIONS.md` §1–2.
