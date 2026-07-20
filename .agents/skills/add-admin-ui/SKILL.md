---
name: add-admin-ui
description: Build or extend the plugin's admin settings page so it looks native in the Piwigo admin themes (default/clear/roma) — the modern fixed save-bar (.savebar-footer + .buttonLike + .badge.info-message), #configContent fieldset form with .font-checkbox switches, tabsheet, pwg-token CSRF. Use when the user wants a settings/configuration screen, a tab or extra page on the plugin's OWN admin page (per-tab router), or buttons/forms in the admin area. For a tab on a CORE admin page (Edit Photo, album edit) use add-photo-tab; for Batch Manager surfaces use add-batch-manager-ui. Extracted from the core Configuration→Search page; full class catalogue in reference/ADMIN_UI.md. The admin page is NOT styled by the gallery theme (modus/darkroom) — see reference/theme-compat.md.
---

# Add admin (settings) UI

 The canonical, tool-neutral instructions live in **`workflows/add-admin-ui.md`** — read and follow that. Supporting references: **`reference/ADMIN_UI.md`** (class + CSS catalogue) and **`reference/admin-configuration.tpl`** (ready-made template to copy).

> Canonical: `workflows/add-admin-ui.md`. Index of everything: `AGENTS.md`.
