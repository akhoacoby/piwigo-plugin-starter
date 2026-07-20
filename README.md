# Piwigo Skills — a plugin starter for building with AI

A scaffold and knowledge base for building **Piwigo 16.x plugins**, whether you work with an AI assistant or entirely by hand. It gives you a clean plugin skeleton to start from, guidelines covering each area of a plugin, step-by-step workflows for common tasks, and deep references for themes and admin pages. Everything is plain Markdown and tool-neutral, with thin adapters so any assistant — Claude Code, Codex, Cursor, Copilot, Google Antigravity, GLM, Qwen Code, Gemini CLI — can pick it up and run with it.

> **New here, or just want the friendly version?** Read [`docs/README.md`](docs/README.md) first. It explains what this project is, who it's for, and how to use it in plain language, with no code involved. This README is the developer-facing map of *how the repo is organised and why*.
>
> **If you're an AI tool:** start at [`AGENTS.md`](AGENTS.md) — it's the canonical entrypoint and the single source of truth.

## Folder architecture

```
piwigo-skills/
├── AGENTS.md              ← canonical, tool-neutral instructions (the entrypoint)
├── README.md              ← you are here (developer orientation)
├── PIWIGO_CONVENTIONS.md  ← deep "why/how it works" technical reference
├── docs/                  ← the plain-language introduction for people
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
│   ├── add-event-handler.md  add-ws-method.md
│   └── add-photo-tab.md      add-batch-manager-ui.md   add-gallery-ui.md
│
├── reference/             ← DEEP LOOKUPS: catalogues + a ready-made asset
│   ├── theme-compat.md       (cross-theme rules — read before any UI)
│   ├── THEMES.md             (modus & bootstrap_darkroom class/DOM tables)
│   ├── ADMIN_UI.md           (admin settings-page class + CSS catalogue)
│   ├── SKELETON.md           (map of the worked example below)
│   └── admin-configuration.tpl  (copy-and-rename admin form template)
│
├── template/              ← the PLUGIN SKELETON you build on (ships as `example_plugin`)
│   ├── main.inc.php  maintain.class.php  admin.php
│   ├── admin/template/configuration.tpl   (+ admin/index.php guard)
│   ├── include/functions.inc.php          (+ include/index.php guard)
│   └── index.php                          (dir-protection guard)
│       (add language/{en_UK,fr_FR}/ when you add UI strings)
│
├── skeleton/              ← a WORKED EXAMPLE: local copy of the official
│                            Piwigo "Skeleton" plugin, for seeing real wiring
│
└── tool adapters          ← thin pointers to AGENTS.md, one per assistant
    ├── CLAUDE.md                       (Claude Code)
    ├── .agents/skills/<name>/SKILL.md  (cross-tool Agent Skills ×10)
    ├── .cursor/rules/piwigo-plugin.mdc (Cursor)
    ├── .github/copilot-instructions.md (GitHub Copilot)
    ├── QWEN.md                         (Qwen Code)
    └── GEMINI.md                       (Gemini CLI)
        # OpenAI Codex & Google Antigravity read AGENTS.md directly — no shim needed
        # GLM coding clients run through CLAUDE.md
```

## The three documentation layers

The docs are split by *purpose*, so you only ever load what the task in front of you needs:

| Layer | Question it answers | Example |
|---|---|---|
| **`guidelines/`** — knowledge | "What are the rules for this area?" | `06-hooks.md`: modifier-vs-notify semantics, lazy includes |
| **`workflows/`** — procedure | "How do I do this task, step by step?" | `add-event-handler.md`: pick event → register → write callback → verify |
| **`reference/`** — deep lookup | "What's the exact class / DOM / API detail?" | `THEMES.md`: which container the toolbar button lands in per theme |

Each workflow points at the guidelines and references it depends on, so you rarely need to read everything at once. Keeping these as small, separate files is a deliberate choice: a model — or a person — can pull just the relevant piece instead of wading through one enormous document.

## Why one canonical file and many thin adapters

The Piwigo knowledge here is plain Markdown, and none of it is specific to any AI vendor. So all the real content lives **once**, in `AGENTS.md`, `guidelines/`, `workflows/` and `reference/`. There are no helper scripts either — each workflow's steps are carried out directly by whichever assistant, or person, is following it.

The wrinkle is that every AI tool looks for its own differently-named rules file. Rather than copy the same guidance into each one, every tool's file is just a **one-line pointer back to `AGENTS.md`**. That buys us three things:

- Only *one* adapter is ever loaded, by its own tool, so they never stack up in a single model's context.
- There's a single source of truth, so the guidance can't quietly drift apart between tools.
- `AGENTS.md` is a cross-tool standard that many assistants already read natively — the adapters simply cover the ones that don't.

The ten task *skills* (scaffold-plugin, verify-plugin, add-admin-ui, add-photo-tab, add-batch-manager-ui, add-gallery-ui, add-config-setting, add-event-handler, add-ws-method, theme-compat) live under `.agents/skills/<name>/SKILL.md`, following the cross-tool [Agent Skills](https://agentskills.io) convention that Codex, Cursor, OpenCode and others discover automatically. Each one is a thin wrapper pointing at the matching `workflows/` or `reference/` doc — the same canonical content, just made auto-triggerable. Tools that don't scan `.agents/skills/` yet, such as Claude Code, are told through their own adapter file to read the matching `SKILL.md` when a task fits.

## Start from `template/`, learn from `skeleton/`

`template/` is the pristine plugin skeleton, shipped as `example_plugin`. You never edit it in place. To start a real plugin you **copy it out and rename every token** (`EXAMPLE_PLUGIN` → `<UPPER_ID>`, `example_plugin` → `<plugin_id>`, `Example plugin` → your display name). Your AI assistant can perform the copy and the replacements directly.

`main.inc.php` carries a folder-name guard that keeps the plugin inert until the rename is fully consistent, so a half-renamed copy can never half-load. The full procedure lives in [`workflows/scaffold-plugin.md`](workflows/scaffold-plugin.md).

`skeleton/` is different, and it's worth knowing the distinction. It's a local copy of the official Piwigo "Skeleton" demo plugin, kept purely as a **worked example**: when a workflow says "see the skeleton", you open it to see real, working wiring for that surface. You don't build on it, and where it disagrees with our own guidelines, the guidelines win — it's upstream demo code, not our style guide. [`reference/SKELETON.md`](reference/SKELETON.md) maps out where each surface is demonstrated.

## Quick start

1. **Scaffold** — follow `workflows/scaffold-plugin.md` (copy `template/`, rename the tokens), then drop the new folder into `<piwigo>/plugins/`.
2. **Learn the area** — read the matching `guidelines/` file. Before touching *any* UI, read `reference/theme-compat.md`.
3. **Build** — follow the relevant `workflows/` playbook, whether that's a hook, a setting, an admin page or an API method.
4. **Verify** — run `workflows/verify-plugin.md` (lint plus a reversible smoke test) before calling it done.

## Where do I add…?

| I want to… | Start at |
|---|---|
| Start a new plugin | `workflows/scaffold-plugin.md` |
| React to a gallery/admin event | `workflows/add-event-handler.md` → `guidelines/06-hooks.md` |
| Add a settings page / admin tab | `workflows/add-admin-ui.md` → `reference/ADMIN_UI.md` |
| Add a config option | `workflows/add-config-setting.md` → `guidelines/08-config.md` |
| Expose an API endpoint | `workflows/add-ws-method.md` → `guidelines/07-api.md` |
| Add gallery (front-end) UI | `reference/theme-compat.md` + `guidelines/05-frontend.md` (built by hand — no scaffold) |
| Confirm it's done | `workflows/verify-plugin.md` → `guidelines/11-testing.md` |

> The conventions and non-negotiables — security guards, escaping, DB access, theme rules, i18n — are summarised as **Golden rules** in [`AGENTS.md`](AGENTS.md) and explained in depth in [`PIWIGO_CONVENTIONS.md`](PIWIGO_CONVENTIONS.md).
