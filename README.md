# Piwigo Guideline/Template for using GLLM in plugin developement 

A scaffold + knowledge base for building **Piwigo 16.x plugins** with an AI coding assistant (or by hand). It ships a pristine plugin skeleton, area-by-area guidelines, step-by-step workflows, deep theme/admin references, and runnable helper scripts — all tool-neutral, with thin adapters so any assistant (Claude Code, Cursor, Copilot, Windsurf, Aider, …) can use it.

> **Start here if you're an AI tool:** [`AGENTS.md`](AGENTS.md) is the canonical entrypoint and single source of truth. This README is the human-facing map of *how the repo is organized and why*.

## Folder architecture

```
piwigo-plugin-starter/
├── AGENTS.md              ← canonical, tool-neutral instructions (the entrypoint)
├── README.md              ← you are here (human orientation)
├── PIWIGO_CONVENTIONS.md  ← deep "why/how it works" technical reference
│
├── guidelines/            ← KNOWLEDGE: what to know per area (read before working there)
│   ├── 01-architecture.md   02-code-style.md     03-database.md
│   ├── 04-security.md       05-frontend.md       06-hooks.md
│   ├── 07-api.md            08-config.md         09-i18n.md
│   └── 10-maintenance.md    11-testing.md        12-commits.md
│
├── workflows/             ← PROCEDURES: step-by-step playbooks for a task
│   ├── scaffold-plugin.md    verify-plugin.md
│   ├── add-admin-ui.md       add-config-setting.md
│   └── add-hook.md           add-ws-method.md
│
├── reference/             ← DEEP LOOKUPS: catalogues + a ready-made asset
│   ├── theme-compat.md       (cross-theme rules — read before any UI)
│   ├── THEMES.md             (modus & bootstrap_darkroom class/DOM tables)
│   ├── ADMIN_UI.md           (admin settings-page class + CSS catalogue)
│   └── admin-configuration.tpl  (copy-and-rename admin form template)
│
├── scripts/               ← RUNNABLE helpers (plain Bash, run from repo root)
│   ├── rename.sh             (scaffolding: copy template/ + rename tokens)
│   ├── lint.sh               (php -l sweep)
│   └── smoke-test.sh         (reversible DB-backed page check)
│
├── template/              ← the PLUGIN SKELETON (ships as `example_plugin`)
│   ├── main.inc.php  maintain.class.php  admin.php
│   ├── admin/template/configuration.tpl   (+ admin/index.php guard)
│   ├── include/functions.inc.php          (+ include/index.php guard)
│   └── index.php                          (dir-protection guard)
│       (add language/{en_UK,fr_FR}/ when you add UI strings)
│
└── tool adapters          ← thin pointers to AGENTS.md, one per assistant
    ├── CLAUDE.md                       (Claude Code)
    ├── .claude/skills/<name>/SKILL.md  (Claude Code auto-invoked skills ×7)
    ├── .cursor/rules/piwigo-plugin.mdc (Cursor)
    ├── .github/copilot-instructions.md (GitHub Copilot)
    ├── .windsurfrules                  (Windsurf)
    └── CONVENTIONS.md                  (Aider)
```

## The three documentation layers

The docs are split by *purpose*, so you load only what a task needs:

| Layer | Question it answers | Example |
|---|---|---|
| **`guidelines/`** — knowledge | "What are the rules for this area?" | `06-hooks.md`: modifier-vs-notify semantics, lazy includes |
| **`workflows/`** — procedure | "How do I do this task, step by step?" | `add-hook.md`: pick event → register → write callback → verify |
| **`reference/`** — deep lookup | "What's the exact class / DOM / API detail?" | `THEMES.md`: which container the toolbar button lands in per theme |

A workflow points at the guideline(s) and reference(s) it relies on; you rarely read everything at once. (Keeping these as small, separate files is deliberate — a model or reader pulls just the relevant piece instead of one monolithic doc.)

## Why one canonical file + many thin adapters

The Piwigo *knowledge* is plain Markdown/Bash — not specific to any AI vendor. So all real content lives **once** in `AGENTS.md`, `guidelines/`, `workflows/`, `reference/`, and `scripts/`. Each AI tool, however, looks for its own differently-named rules file. Rather than copy the rules into each, every tool's file is a **one-line pointer back to `AGENTS.md`**:

- Only *one* adapter is ever loaded — by *its* tool — so they don't stack up in any single model's context.
- There's a single source of truth, so guidance can't drift between tools.
- `AGENTS.md` is a cross-tool standard many assistants read natively; the adapters just cover the ones that don't.

For **Claude Code** specifically, `.claude/skills/<name>/SKILL.md` are auto-invocable *skills* (scaffold, verify, add-admin-ui, add-config-setting, add-hook, add-ws-method, theme-compat). Each is a thin wrapper whose body points at the matching `workflows/`/`reference/` doc — same canonical content, just made auto-triggerable.

## The `template/` skeleton — scaffold first

`template/` is the pristine plugin skeleton, shipped as `example_plugin`. You never edit it in place. To start a real plugin you **copy it out and rename every token**:

```bash
bash scripts/rename.sh <plugin_id> [dest_parent_dir] ["Display Name"] ["Author"]
```

`main.inc.php` has a folder-name guard that keeps the plugin inert until the rename is consistent, so a half-renamed copy can't half-load. Full procedure: [`workflows/scaffold-plugin.md`](workflows/scaffold-plugin.md).

## Quick start

1. **Scaffold** — `workflows/scaffold-plugin.md` (runs `scripts/rename.sh`); drop the new folder in `<piwigo>/plugins/`.
2. **Learn the area** — read the matching `guidelines/` file; before *any* UI read `reference/theme-compat.md`.
3. **Build** — follow the relevant `workflows/` playbook (add a hook, a setting, an admin page, an API method).
4. **Verify** — `workflows/verify-plugin.md` (lint + reversible smoke test) before calling it done.

## Where do I add…?

| I want to… | Start at |
|---|---|
| Start a new plugin | `workflows/scaffold-plugin.md` |
| React to a gallery/admin event | `workflows/add-hook.md` → `guidelines/06-hooks.md` |
| Add a settings page / admin tab | `workflows/add-admin-ui.md` → `reference/ADMIN_UI.md` |
| Add a config option | `workflows/add-config-setting.md` → `guidelines/08-config.md` |
| Expose an API endpoint | `workflows/add-ws-method.md` → `guidelines/07-api.md` |
| Add gallery (front-end) UI | `reference/theme-compat.md` + `guidelines/05-frontend.md` (built by hand — no scaffold) |
| Confirm it's done | `workflows/verify-plugin.md` → `guidelines/11-testing.md` |

> Conventions and non-negotiables (security guards, escaping, DB access, theme rules, i18n) are summarized as **Golden rules** in [`AGENTS.md`](AGENTS.md) and explained in depth in [`PIWIGO_CONVENTIONS.md`](PIWIGO_CONVENTIONS.md).
