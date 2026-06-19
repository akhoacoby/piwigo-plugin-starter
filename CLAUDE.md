# CLAUDE.md — Piwigo plugin starter

Starter scaffold for a Piwigo plugin. Ships as `example_plugin`; **rename it first** (see `guidelines/01-architecture.md`).

Development guidelines live in **`guidelines/`** — read the relevant file before working on that area. Deep technical reference (the "why/how it works"): **`PIWIGO_CONVENTIONS.md`**.

## Guidelines index
| File | Aspect |
|---|---|
| `guidelines/01-architecture.md` | Plugin structure, entry points, the rename step |
| `guidelines/02-code-style.md` | Naming, formatting, PHP target, PHPDoc, philosophy |
| `guidelines/03-database.md` | DB layer, SQL queries, escaping, FandF, migrations |
| `guidelines/04-security.md` | File guards, input validation, CSRF, permissions |
| `guidelines/05-frontend.md` | Smarty 5 templates, CSS, HTML output escaping, assets |
| `guidelines/06-hooks.md` | Events: `add_event_handler`, `trigger_change`/`trigger_notify` |
| `guidelines/07-api.md` | Web services (`ws.php`) method registration |
| `guidelines/08-config.md` | Configuration storage (`$conf`, `conf_update_param`) |
| `guidelines/09-i18n.md` | Languages / translations (en_UK + fr_FR) |
| `guidelines/10-maintenance.md` | Plugin lifecycle (`maintain.class.php`) |
| `guidelines/11-testing.md` | Lint, manual & smoke testing, definition of done |
| `guidelines/12-commits.md` | Commit & PR conventions |

## Dev tools (skills in `.claude/skills/`)
Invocable workflows that automate the repetitive tasks — prefer them over doing the steps by hand.
| Skill | Use it to |
|---|---|
| `scaffold-plugin` | **First step.** Rename the `example_plugin` starter into a real plugin (tokens + folder + guard). Ships `rename.sh`. |
| `verify-plugin` | Lint sweep + reversible DB-backed smoke test before "done". Ships `lint.sh` + `smoke-test.sh`. |
| `add-config-setting` | Wire a new setting end-to-end (default → validated save → form field → en_UK/fr_FR labels). |
| `add-hook` | Register an event handler correctly (right event, lazy-include, modifier-vs-notify semantics). |
| `add-ws-method` | Add a `ws.php` API method (typed param spec + permission re-check in the callback). |

## Golden rules
- **Prefer native Piwigo APIs; never modify core** or other plugins — extend via hooks only.
- Every `.php` opens with `… or die('Hacking attempt!')`; every directory ships an `index.php` redirect.
- **DB** only via `pwg_query`/`query2array`; validate ids with `PATTERN_ID`, escape non-request strings; **image reads need `get_sql_condition_FandF`**.
- **Escape ALL HTML output** — Smarty auto-escaping is OFF.
- **PHP 7.4+ floor → 8.4**; 2-space indent, Allman braces, `snake_case` functions (plugin-prefixed).
- Config via `conf_update_param`; ship **en_UK + fr_FR**; lifecycle via `maintain.class.php` (never `autoUpdate()`).
- `php -l` clean + clean install/uninstall before "done".
