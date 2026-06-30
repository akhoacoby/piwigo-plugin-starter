---
name: scaffold-plugin
description: Rename the example_plugin starter into a real plugin — replaces every token (folder, EXAMPLE_PLUGIN_* constants, example_plugin_* functions, the _maintain class, the $conf['example_plugin'] key, the main.inc.php header) and the folder guard. Use this ONCE, first thing, before writing any feature code. Trigger when the user says "start a new plugin", "rename the starter", "scaffold", or gives a new plugin name.
---

# Scaffold a new plugin

Claude Code wrapper. The canonical, tool-neutral instructions live in **`workflows/scaffold-plugin.md`** — read and follow that. It runs `scripts/rename.sh` (copies `template/` → a new plugin folder and renames every token).

> Canonical: `workflows/scaffold-plugin.md`. Index of everything: `AGENTS.md`.
