# Architecture & Structure

## Where the skeleton lives in the starter
The starter keeps the pristine plugin skeleton under **`template/`** (the repo root holds `AGENTS.md`, the guidelines, `PIWIGO_CONVENTIONS.md`, plus `workflows/` and `reference/`). You make a real plugin by **copying `template/` out and renaming it** — follow `workflows/scaffold-plugin.md` and perform the steps yourself. So each skeleton path below is at `template/<path>` in the starter, and at the **plugin root** once copied.

## Layout (a plugin = the renamed contents of the starter's `template/`)

```
your_plugin/                       # = renamed copy of the starter's template/
├── main.inc.php        # header + folder guard + YOUR_PLUGIN_* constants + add_event_handler('init', …)
├── maintain.class.php  # your_plugin_maintain extends PluginMaintain
├── admin.php           # admin page: tabsheet → set_filename → assign_var_from_handle('ADMIN_CONTENT', …)
├── admin/template/configuration.tpl
├── include/functions.inc.php   # your_plugin_init() and other handlers
├── index.php           # dir-protection redirect — REQUIRED in every directory
├── language/{en_UK,fr_FR}/plugin.lang.php   # add when you add UI strings
└── template/  js/       # the plugin's OWN public-UI dir (add for gallery output; build it by hand — see theme-compat + 05-frontend.md)
```
> Note the two senses of "template": the **starter's** `template/` is the skeleton store; a **plugin's** own `template/` subdir holds its public `.tpl`/CSS. In the starter that public dir would be `template/template/`.

## Rules
- `main.inc.php` ONLY: define constants, register event handlers, declare `init()`. No business logic at top level.
- Constants: `YOUR_PLUGIN_ID` / `_PATH` / `_REALPATH` / `_ADMIN`. Derive `ID` from the folder name (`basename(dirname(__FILE__))`).
- Lazy-load heavy includes inside handlers (or via `add_event_handler`'s 4th arg), not at the top of `main.inc.php`.
- One `index.php` redirect per directory (directory-listing protection).
- Don't add front controllers; reach the gallery through hooks and virtual sections (see `06-hooks.md`).

## First step — scaffold from `template/`
Follow **`workflows/scaffold-plugin.md`** (you do the copy + token replacements directly): copy `template/` to a new plugin folder and rename every token. `main.inc.php` has a **folder-name guard**, so the plugin stays inert until the rename is consistent. The rename replaces:
- folder name and the guard `!= 'example_plugin'`
- `EXAMPLE_PLUGIN_*` constants → `<UPPER_ID>_*`
- `example_plugin_*` functions and the `example_plugin_maintain` class (MUST be `{folder}_maintain`)
- `$conf['example_plugin']` config key
- `main.inc.php` header: `Plugin Name`, `Version`, `Author`, `Author URI`, `Description`, `Has Settings`

Verify: `grep -rni example_plugin <plugin>` is clean.

> Reference: `PIWIGO_CONVENTIONS.md` §1–2 (repo layout, bootstrap order, entry points).
