---
name: add-photo-tab
description: Add a plugin tab to the core Edit Photo admin page (admin.php?page=photo-<id>) — register it via the tabsheet_before_select change event, route it through the plugin's admin.php, reproduce the core 'photo' tabsheet on the tab page, and save per-photo data via POST+pwg_token or a ws method. Use when the user wants a tab/panel/fields on the photo edit screen (or another core admin tabsheet like album edit). For a tab on the plugin's OWN admin page use add-admin-ui instead — that one needs no hook.
---

# Add a tab to the Edit Photo page

The canonical, tool-neutral instructions live in **`workflows/add-photo-tab.md`** — read and follow that. Working example: the skeleton demo plugin, mapped in **`reference/SKELETON.md`**.

> Canonical: `workflows/add-photo-tab.md`. Index of everything: `AGENTS.md`.
