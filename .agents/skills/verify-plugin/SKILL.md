---
name: verify-plugin
description: Verify a Piwigo plugin before calling it done — runs the php -l lint sweep, then (optionally) a reversible DB-backed smoke test that activates the plugin, curls a page, greps for errors, and rolls back. Use after any change, before committing, or whenever the user says "verify", "test the plugin", "is it done", "lint", or "smoke test".
---

# Verify a plugin

 The canonical, tool-neutral instructions live in **`workflows/verify-plugin.md`** — read and follow that. There are no verify scripts: **you run the `php -l` sweep and the reversible DB-backed smoke test yourself** — the workflow gives the exact commands/SQL, including the mandatory revert step.

> Canonical: `workflows/verify-plugin.md`. Index of everything: `AGENTS.md`.
