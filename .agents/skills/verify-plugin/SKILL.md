---
name: verify-plugin
description: Verify a Piwigo plugin before calling it done — runs the php -l lint sweep, then (optionally) a reversible DB-backed smoke test that activates the plugin, curls a page, greps for errors, and rolls back. Use after any change, before committing, or whenever the user says "verify", "test the plugin", "is it done", "lint", or "smoke test".
---

# Verify a plugin

 The canonical, tool-neutral instructions live in **`workflows/verify-plugin.md`** — read and follow that. It runs `scripts/lint.sh` (php -l sweep) and the reversible `scripts/smoke-test.sh` (DB-backed page check).

> Canonical: `workflows/verify-plugin.md`. Index of everything: `AGENTS.md`.
