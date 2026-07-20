---
name: add-batch-manager-ui
description: Extend the Piwigo Batch Manager — a selection prefilter (get_batch_manager_prefilters + perform_batch_manager_prefilters), a bulk action in global/action mode (loc_end_element_set_global + element_set_global_action), or a per-photo field in unit mode (loc_end_element_set_unit + PLUGINS_BATCH_MANAGER_UNIT_ELEMENT_SUBTEMPLATE, saved via a <plugin>_batchManagerSave ws call or by piggybacking pwg.images.setInfo). Use when the user wants bulk actions, batch filters, or extra editable fields in the Batch Manager (unit or action mode).
---

# Extend the Batch Manager

The canonical, tool-neutral instructions live in **`workflows/add-batch-manager-ui.md`** — read and follow that. Working example: the skeleton demo plugin, mapped in **`reference/SKELETON.md`**.

> Canonical: `workflows/add-batch-manager-ui.md`. Index of everything: `AGENTS.md`.
