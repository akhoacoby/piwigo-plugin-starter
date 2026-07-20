# AGENTS.md — Piwigo plugin starter

Canonical, **tool-neutral** instructions for any AI coding assistant (Claude Code, Cursor, GitHub Copilot, Codex, Google Antigravity, GLM, Qwen Code, Gemini CLI, …) building a Piwigo plugin from this starter. Everything here is plain Markdown — no model- or vendor-specific features, and **no helper scripts: each workflow's steps are executed directly by you**.

> **This file is the source of truth.** Each tool's own rules file is a thin pointer back here:
> `CLAUDE.md` (Claude Code), `.cursor/rules/piwigo-plugin.mdc` (Cursor), `.github/copilot-instructions.md` (Copilot), `GEMINI.md` (Gemini CLI), `QWEN.md` (Qwen Code). **Tools that read `AGENTS.md` natively (OpenAI Codex, Google Antigravity, OpenCode, …) need no shim, and GLM coding clients run through `CLAUDE.md`.** Using a tool not listed? Point it at this file, or just read it.

## What this starter is
A scaffold for a Piwigo 16.x plugin. The pristine skeleton lives in **`template/`** (ships as `example_plugin`). **Scaffold from it first** — copy + rename — then build the feature. See `workflows/scaffold-plugin.md` and `guidelines/01-architecture.md`.

## How it's organized
| Path | What |
|---|---|
| `guidelines/` | **Knowledge** — read the relevant file before working on that area (the *what/why*). |
| `workflows/` | **Procedures** — step-by-step playbooks for common tasks (the *how*). |
| `reference/` | **Deep references** — theme/admin class catalogues + a ready-made admin template asset. |
| `template/` | The plugin skeleton (`example_plugin`) — copied by scaffolding, never edited in place. |
| `skeleton/` | Local copy of the **official Piwigo Skeleton demo plugin** — worked examples only, never copied wholesale. Map: `reference/SKELETON.md`. |
| `PIWIGO_CONVENTIONS.md` | The "why/how it works" technical deep-dive. |

> **Agent Skills note:** `.agents/skills/` exposes these same procedures as cross-tool [Agent Skills](https://agentskills.io) — thin `SKILL.md` wrappers over `workflows/` + `reference/`, auto-discovered by some tools (Codex, Cursor, OpenCode). `.claude/skills` is a **symlink view** of the same folder for Claude Code's native discovery (add further symlinks only when a real tool scans a different path; on Windows checkouts without symlink support the shim/table fallback still works). No auto-scan? Read the matching `SKILL.md` yourself when a task fits its description. This file stays canonical; skills never duplicate it. Maintenance metadata (status, review dates, vendored pins) is tracked in `.agents/skills/registry.yaml` — humans only, no tool reads it.

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
Follow these instead of improvising. Each is a Markdown playbook whose steps **you execute yourself** — there are no bundled scripts.
| Workflow | Use it to |
|---|---|
| `workflows/scaffold-plugin.md` | **First step.** Copy `template/` into a new plugin and rename every token (you do the copy + replacements directly). |
| `workflows/verify-plugin.md` | `php -l` sweep + reversible DB-backed smoke test before "done" (you run the commands directly). |
| `workflows/add-admin-ui.md` | Build an admin settings page native to the admin theme (fieldset form, pwg token, infos/errors). Uses `reference/admin-configuration.tpl`. |
| `workflows/add-config-setting.md` | Wire a new setting end-to-end (default → validated save → form field → en_UK/fr_FR labels). |
| `workflows/add-event-handler.md` | Register an event handler correctly (right event, lazy-include, modifier-vs-notify semantics) + the per-surface hook routing table. |
| `workflows/add-ws-method.md` | Add a `ws.php` API method (typed param spec + permission re-check in the callback). |
| `workflows/add-photo-tab.md` | Add a plugin tab to the **core Edit Photo** admin page (`tabsheet_before_select` + reproduced core tabsheet + per-photo save). |
| `workflows/add-batch-manager-ui.md` | Extend the Batch Manager: selection prefilter, bulk action (global mode), per-photo field (unit mode) + both unit-save methods. |
| `workflows/add-gallery-ui.md` | Wire public/gallery UI (buttons, virtual section page, menu block, prefilter, profile block) — wiring only; visuals ruled by `reference/theme-compat.md`. |

> **No gallery scaffold on purpose.** In three real builds, copy-paste gallery scaffolds bred extra markup, theme-branching, and multi-step flows — exactly what breaks across themes. Gallery UI is **guidance, not a generator**: `workflows/add-gallery-ui.md` (hook wiring) + `reference/theme-compat.md` (visual rules) + `skeleton/` (working examples). Only the **admin** page — a single stable target — gets scaffolding.

## Reference index (deep lookups)
| File | What |
|---|---|
| `reference/theme-compat.md` | **Read before any gallery/admin UI.** How a plugin's UI survives any theme (own it, integrate at the edges, keep it simple); guaranteed on modus + bootstrap_darkroom. |
| `reference/THEMES.md` | Concrete class/DOM tables for `modus` & `bootstrap_darkroom`, the toolbar-button slot/position fix, and modus's photo-toolbar "…" collapse gotcha. |
| `reference/ADMIN_UI.md` | The admin settings-page class catalogue + real CSS, extracted from the core Configuration→Search page. |
| `reference/admin-configuration.tpl` | Ready-made admin settings template (savebar pattern) to copy + rename. |
| `reference/SKELETON.md` | Map of the `skeleton/` demo plugin — which file demonstrates which surface/hook (photo tab, Batch Manager, gallery UI, menus, ws). |

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
3. Use the `workflows/` playbook for the task and execute its steps yourself.
4. Verify with `workflows/verify-plugin.md` before calling anything done.

Every playbook step is plain file edits, shell one-liners, or SQL — any assistant or human can perform them directly; nothing depends on bundled tooling.
