# Workflow: Scaffold a new plugin (copy `template/` + rename)

**Do this once, first, before writing any feature code.**

The starter keeps the pristine skeleton in **`template/`** (named `example_plugin`). Scaffolding **copies `template/` to a new plugin folder** and renames every token — the skeleton stays untouched for next time. `main.inc.php` has a **folder-name guard** that keeps the plugin inert until the rename is consistent. See `guidelines/01-architecture.md`.

## Inputs to collect
- **plugin id** (required): the folder name, `snake_case`, `^[a-z][a-z0-9_]*$` (e.g. `photo_compare`). This becomes the folder, the `_PLUGIN_*` constant prefix (uppercased), the `*_init`/handler function prefix, the `_maintain` class, and the `$conf[...]` key.
- **display name** (optional): human-facing `Plugin Name:` header (e.g. "Photo Compare").
- **author** / **description** (optional): for the `main.inc.php` header.

If only a name was given in prose, derive the id (lowercase, spaces→underscores) and confirm it back in one line — don't block on it.

## Do it

1. **Copy** `template/` → `<dest>/<plugin_id>/`. Default dest = the starter repo root; for a live dev install use `<piwigo>/plugins/` so the plugin lands ready to activate. **Refuse to overwrite** an existing destination, and never edit `template/` itself.
2. **Replace tokens** in every `*.php *.tpl *.md *.css *.js *.json` in the copy — in this order — `EXAMPLE_PLUGIN` → `<UPPER_ID>`, `example_plugin` → `<plugin_id>`, `Example plugin` → the display name.
3. If an author was given, set the `Author:` line in the `main.inc.php` header.

## After scaffolding — verify (do not skip)
1. `grep -rni example_plugin <dest>/<plugin_id>` → must be empty. Anything left is a missed token; fix by hand.
2. Confirm the new folder is named exactly `<plugin_id>` — the guard compares against it.
3. Set the header fields not covered by the token replacement: `Version:`, `Plugin URI:`, `Author URI:`, and confirm `Has Settings:`.
4. `php -l` the new files (or run `workflows/verify-plugin.md` against the new folder).

## Notes
- The skeleton in `template/` is never modified — re-run for each new plugin.
- The `_maintain` class name MUST equal `{folder}_maintain` — the rename keeps them in lockstep.
- Constants derive `ID` from `basename(dirname(__FILE__))`, so the folder name is the source of truth; the literal constant prefix just has to match.
- Never overwrite an existing `<dest>/<plugin_id>` — stop and ask.

> Reference: `guidelines/01-architecture.md`, `PIWIGO_CONVENTIONS.md` §1–2.
