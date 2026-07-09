# AGENTS.md — Piwigo plugin starter

Canonical, **tool-neutral** instructions for any AI coding assistant (Claude Code, Cursor, GitHub Copilot, Windsurf, Aider, Gemini CLI, Codex, …) building a Piwigo plugin from this starter. Everything here is plain Markdown + Bash — no model- or vendor-specific features required.

> **This file is the source of truth.** Each tool's own rules file is a thin pointer back here:
> `CLAUDE.md` (Claude Code), `.cursor/rules/piwigo-plugin.mdc` (Cursor), `.github/copilot-instructions.md` (Copilot), `.windsurfrules` (Windsurf), `CONVENTIONS.md` (Aider), `GEMINI.md` (Gemini CLI). **OpenAI Codex reads this `AGENTS.md` directly — no shim needed.** Using a tool not listed? Point it at this file, or just read it.

## What this starter is
A scaffold for a Piwigo 16.x plugin. The pristine skeleton lives in **`template/`** (ships as `example_plugin`). **Scaffold from it first** — copy + rename — then build the feature. See `workflows/scaffold-plugin.md` and `guidelines/01-architecture.md`.

## How it's organized
| Path | What |
|---|---|
| `guidelines/` | **Knowledge** — read the relevant file before working on that area (the *what/why*). |
| `workflows/` | **Procedures** — step-by-step playbooks for common tasks (the *how*). |
| `reference/` | **Deep references** — theme/admin class catalogues + a ready-made admin template asset. |
| `scripts/` | **Runnable helpers** — `rename.sh`, `lint.sh`, `smoke-test.sh` (plain Bash; run from the repo root). |
| `template/` | The plugin skeleton (`example_plugin`) — copied by scaffolding, never edited in place. |
| `PIWIGO_CONVENTIONS.md` | The "why/how it works" technical deep-dive. |

> **Agent Skills note:** the same procedures are also exposed under `.agents/skills/` (the cross-tool [Agent Skills](https://agentskills.io) convention, auto-discovered by Codex, Cursor, OpenCode and others). Those `SKILL.md` files are thin wrappers that point at `workflows/` and `reference/` — the content here is canonical; they never duplicate it. If your tool does not scan `.agents/skills/`, read the matching `SKILL.md` yourself when a task fits its description.

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

## Workflows index (procedures)
Follow these instead of improvising. Each is a Markdown playbook; some run a script in `scripts/`.
| Workflow | Use it to |
|---|---|
| `workflows/scaffold-plugin.md` | **First step.** Copy `template/` into a new plugin and rename every token. Runs `scripts/rename.sh`. |
| `workflows/verify-plugin.md` | Lint sweep + reversible DB-backed smoke test before "done". Runs `scripts/lint.sh` + `scripts/smoke-test.sh`. |
| `workflows/add-admin-ui.md` | Build an admin settings page native to the admin theme (fieldset form, pwg token, infos/errors). Uses `reference/admin-configuration.tpl`. |
| `workflows/add-config-setting.md` | Wire a new setting end-to-end (default → validated save → form field → en_UK/fr_FR labels). |
| `workflows/add-hook.md` | Register an event handler correctly (right event, lazy-include, modifier-vs-notify semantics). |
| `workflows/add-ws-method.md` | Add a `ws.php` API method (typed param spec + permission re-check in the callback). |

> **No gallery scaffold on purpose.** Across three real builds, a copy-paste gallery scaffold made the gallery *worse*: it pushed each plugin toward more markup, theme-branching, and multi-step flows — exactly what breaks across themes (the leanest build worked everywhere; the most elaborate one broke on modus). Gallery UI is **guidance, not a generator**: read `reference/theme-compat.md`, keep it small and self-contained, and build it by hand. Scaffolding is reserved for the **admin** page, a single stable target.

## Reference index (deep lookups)
| File | What |
|---|---|
| `reference/theme-compat.md` | **Read before any gallery/admin UI.** How a plugin's UI survives any theme (own it, integrate at the edges, keep it simple); guaranteed on modus + bootstrap_darkroom. |
| `reference/THEMES.md` | Concrete class/DOM tables for `modus` & `bootstrap_darkroom`, the toolbar-button slot/position fix, and modus's photo-toolbar "…" collapse gotcha. |
| `reference/ADMIN_UI.md` | The admin settings-page class catalogue + real CSS, extracted from the core Configuration→Search page. |
| `reference/admin-configuration.tpl` | Ready-made admin settings template (savebar pattern) to copy + rename. |

## Golden rules
- **Prefer native Piwigo APIs; never modify core** or other plugins — extend via hooks only.
- Every `.php` opens with `… or die('Hacking attempt!')`; every directory ships an `index.php` redirect.
- **DB** only via `pwg_query`/`query2array`; validate ids with `PATTERN_ID`, escape non-request strings; **image reads need `get_sql_condition_FandF`**.
- **Escape ALL HTML output** — Smarty auto-escaping is OFF.
- **Gallery UI: own it, integrate at the edges — and keep it simple.** Ship your own scoped CSS+JS (depend on no theme library); adapt only at touchpoints; must work on **modus + bootstrap_darkroom**. Fewer steps and less theme chrome = more robust across themes; don't assume a toolbar button stays visible (**modus collapses photo-toolbar buttons behind a "…" toggle**). See `reference/theme-compat.md`.
- **PHP 7.4+ floor → 8.4**; 2-space indent, Allman braces, `snake_case` functions (plugin-prefixed).
- Config via `conf_update_param`; ship **en_UK + fr_FR**; lifecycle via `maintain.class.php` (never `autoUpdate()`).
- `php -l` clean + clean install/uninstall before "done".

## Using this with any AI tool
1. Open or scaffold a plugin (`workflows/scaffold-plugin.md`).
2. Before touching an area, read the matching `guidelines/` file; before any UI, read `reference/theme-compat.md`.
3. Use the `workflows/` playbook for the task; run the `scripts/` it names from the repo root.
4. Verify with `workflows/verify-plugin.md` before calling anything done.

The scripts are ordinary Bash and assume nothing about which assistant invoked them — a human or any tool can run them directly.
