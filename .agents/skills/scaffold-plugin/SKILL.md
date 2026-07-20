---
name: scaffold-plugin
description: Rename the example_plugin starter into a real plugin — replaces every token (folder, EXAMPLE_PLUGIN_* constants, example_plugin_* functions, the _maintain class, the $conf['example_plugin'] key, the main.inc.php header) and the folder guard. Use this ONCE, first thing, before writing any feature code. Trigger when the user says "start a new plugin", "rename the starter", "scaffold", or gives a new plugin name.
---

# Scaffold a new plugin

The canonical, tool-neutral instructions live in **`workflows/scaffold-plugin.md`** — read and follow that. There is no scaffold script: **you copy `template/` → the new plugin folder and perform the token replacements yourself** with your file tools, then run the workflow's verification (leftover-token grep, folder-name check, `php -l`).

> Canonical: `workflows/scaffold-plugin.md`. Index of everything: `AGENTS.md`.
