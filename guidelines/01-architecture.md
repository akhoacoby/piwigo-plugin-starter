# Architecture & Structure

## Layout (after rename)

```
your_plugin/
├── main.inc.php        # header + folder guard + YOUR_PLUGIN_* constants + add_event_handler('init', …)
├── maintain.class.php  # your_plugin_maintain extends PluginMaintain
├── admin.php           # admin page: tabsheet → set_filename → assign_var_from_handle('ADMIN_CONTENT', …)
├── admin/template/configuration.tpl
├── include/functions.inc.php   # your_plugin_init() and other handlers
├── index.php           # dir-protection redirect — REQUIRED in every directory
├── language/{en_UK,fr_FR}/plugin.lang.php   # add when you add UI strings
└── template/  js/       # add for public-facing UI
```

## Rules
- `main.inc.php` ONLY: define constants, register event handlers, declare `init()`. No business logic at top level.
- Constants: `YOUR_PLUGIN_ID` / `_PATH` / `_REALPATH` / `_ADMIN`. Derive `ID` from the folder name (`basename(dirname(__FILE__))`).
- Lazy-load heavy includes inside handlers (or via `add_event_handler`'s 4th arg), not at the top of `main.inc.php`.
- One `index.php` redirect per directory (directory-listing protection).
- Don't add front controllers; reach the gallery through hooks and virtual sections (see `06-hooks.md`).

## First step — rename the scaffold
`main.inc.php` has a **folder-name guard**, so the plugin stays inert until you rename consistently. Replace across the repo:
- folder `example_plugin/` and the guard `!= 'example_plugin'`
- `EXAMPLE_PLUGIN_*` constants → `YOUR_PLUGIN_*`
- `example_plugin_*` functions and the `example_plugin_maintain` class (MUST be `{folder}_maintain`)
- `$conf['example_plugin']` config key
- `main.inc.php` header: `Plugin Name`, `Version`, `Author`, `Author URI`, `Description`, `Has Settings`

Verify: `grep -rni example_plugin .` is clean (this guideline aside).

> Reference: `PIWIGO_CONVENTIONS.md` §1–2 (repo layout, bootstrap order, entry points).
