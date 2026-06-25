---
name: scaffold-plugin
description: Rename the example_plugin starter into a real plugin — replaces every token (folder, EXAMPLE_PLUGIN_* constants, example_plugin_* functions, the _maintain class, the $conf['example_plugin'] key, the main.inc.php header) and the folder guard. Use this ONCE, first thing, before writing any feature code. Trigger when the user says "start a new plugin", "rename the starter", "scaffold", or gives a new plugin name.
---

# Scaffold a new plugin (copy `template/` + rename)

The starter keeps the pristine skeleton in **`template/`** (named `example_plugin`). Scaffolding **copies `template/` to a new plugin folder** and renames every token — the skeleton stays untouched for next time. `main.inc.php` has a **folder-name guard** that keeps the plugin inert until the rename is consistent. This is always the first step. See `guidelines/01-architecture.md`.

## Inputs to collect
- **plugin id** (required): the folder name, `snake_case`, `^[a-z][a-z0-9_]*$` (e.g. `photo_compare`). This becomes the folder, the `_PLUGIN_*` constant prefix (uppercased), the `*_init`/handler function prefix, the `_maintain` class, and the `$conf[...]` key.
- **display name** (optional): human-facing `Plugin Name:` header (e.g. "Photo Compare").
- **author** / **description** (optional): for the `main.inc.php` header.

If the user only gave a name in prose, derive the id (lowercase, spaces→underscores) and confirm it back in one line — don't block on it.

## Run it
From anywhere, run the bundled script — it locates the starter's `template/` from its own path:

```bash
bash .claude/skills/scaffold-plugin/rename.sh <plugin_id> [dest_parent_dir] ["Display Name"] ["Author"]
```

- **`dest_parent_dir`** (optional): where to create the plugin folder. Default = the starter repo root, producing `<repo>/<plugin_id>/`. For a live dev install, pass your `<piwigo>/plugins` path so the plugin lands ready to activate.
- The script **copies `template/` → `<dest>/<plugin_id>/`** (skeleton untouched), then replaces `EXAMPLE_PLUGIN` → `<UPPER_ID>`, `example_plugin` → `<plugin_id>`, and `Example plugin` → display name across `*.php *.tpl *.md *.css *.js *.json` in the copy.

## After running — verify (do not skip)
1. `grep -rni example_plugin <dest>/<plugin_id>` → must be empty. Anything left is a missed token; fix by hand.
2. Confirm the new folder is named exactly `<plugin_id>` — the guard compares against it.
3. Set the header fields the script can't infer: `Version:`, `Plugin URI:`, `Author URI:`, and confirm `Has Settings:`.
4. `php -l` the new files (or run the `verify-plugin` skill against the new folder).

## Notes
- The skeleton in `template/` is never modified — re-run for each new plugin.
- The `_maintain` class name MUST equal `{folder}_maintain` — the rename keeps them in lockstep.
- Constants derive `ID` from `basename(dirname(__FILE__))`, so the folder name is the source of truth; the literal constant prefix just has to match.
- Refuses to overwrite an existing `<dest>/<plugin_id>`.

> Reference: `guidelines/01-architecture.md`, `PIWIGO_CONVENTIONS.md` §1–2.
