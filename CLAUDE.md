# CLAUDE.md — Piwigo plugin starter

**Canonical instructions: [`AGENTS.md`](AGENTS.md).** Read it first — it is the single, tool-neutral source of truth (layout, guidelines, workflows, reference, golden rules).

## Skills (manual activation)

Skills live under **`.agents/skills/`** (the cross-tool Agent Skills convention). Claude Code does not auto-scan that path, so activate them yourself: **when a task matches a skill below, read its `SKILL.md` before starting** and follow the canonical `workflows/`/`reference/` doc it points to.

| Skill | Use when |
|---|---|
| `.agents/skills/scaffold-plugin/` | Creating a new plugin from `template/` |
| `.agents/skills/add-hook/` | Registering an event handler / hook |
| `.agents/skills/add-config-setting/` | Adding a persisted plugin config option |
| `.agents/skills/add-admin-ui/` | Building/extending an admin settings page or tab |
| `.agents/skills/add-ws-method/` | Adding a web-service (API) method |
| `.agents/skills/theme-compat/` | Any public-facing UI — gallery theme compatibility |
| `.agents/skills/verify-plugin/` | Linting / smoke-testing a plugin before handoff |

Nothing is duplicated — each `SKILL.md` is a thin wrapper; follow the doc it names.
