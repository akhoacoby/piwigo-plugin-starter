---
name: add-gallery-ui
description: Wire public/gallery UI into Piwigo the theme-safe way — buttons on album/photo pages (add_index_button/add_picture_button), a public page via a virtual section (loc_end_section_init), menu blocks (blockmanager_register_blocks/apply), photo-info fields via template prefilters, profile blocks. There is deliberately NO gallery scaffold: markup/styling rules come from the theme-compat skill (own the UI, integrate at the edges, keep it simple; must pass on modus + bootstrap_darkroom). Use when the user wants anything visitors see in the gallery.
---

# Add gallery (public) UI

The canonical, tool-neutral instructions live in **`workflows/add-gallery-ui.md`** — read and follow that, together with **`reference/theme-compat.md`** (the visual rules — canonical for anything user-facing). Working example: the skeleton demo plugin, mapped in **`reference/SKELETON.md`**.

> Canonical: `workflows/add-gallery-ui.md` + `reference/theme-compat.md`. Index of everything: `AGENTS.md`.
