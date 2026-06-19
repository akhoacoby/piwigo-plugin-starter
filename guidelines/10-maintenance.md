# Plugin lifecycle (maintain.class.php)

Class `your_plugin_maintain extends PluginMaintain` (name MUST be `{folder}_maintain`). File: `maintain.class.php` (2.7+ pattern; core prefers it over legacy `maintain.inc.php`).

## Methods
- `install($v, &$errors)` — seed config / create tables. Idempotent.
- `activate($v, &$errors)` — runs on every (re)activation; usually delegate to `install()`.
- `update($old, $new, &$errors)` — migrate config keys / schema idempotently.
- `deactivate()` — light teardown only (rarely needed).
- `uninstall()` — remove ONLY what you created (`conf_delete_param` + `DROP` your tables).

## Rules
- Core auto-updates via the `Version:` header in `main.inc.php` — **NEVER call the deprecated `PluginMaintain::autoUpdate()`** (throws `E_USER_WARNING`).
- All operations must be idempotent — re-running `install`/`activate` must be safe.
- Touch only what you own; never alter core tables/config beyond documented APIs.
- Migrations: see `03-database.md`.
- A clean install → uninstall cycle must leave **no residue** (only your `$conf['your_plugin']` is added, then removed).

> Reference: `PIWIGO_CONVENTIONS.md` §8 (maintenance).
