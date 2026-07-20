# Skeleton demo plugin — example map

`skeleton/` is a local copy of the **official Piwigo "Skeleton" plugin** (extension #543, by Mistic). It is a **worked-example reference**: when a workflow says "see the skeleton", open the file below to see the real, working wiring for that surface.

> The starter's own conventions (`guidelines/`, `PIWIGO_CONVENTIONS.md`) win where they differ — the skeleton is upstream demo code, not our style guide (e.g. it echoes debug output in `skeleton_profile_save`, and its config page predates the modern savebar pattern in `reference/ADMIN_UI.md`).

## Where each surface is demonstrated

| Surface | Registration (`skeleton/main.inc.php`) | Handler / page | Template |
|---|---|---|---|
| **Plugin's own admin pages (tabsheet router)** | — | `admin.php` (routes `$page['tab']` → `admin/<tab>.php`) | `admin/template/home.tpl`, `config.tpl` |
| **Batch Manager prefilter** | `get_batch_manager_prefilters` + `perform_batch_manager_prefilters` (both change) | `include/admin_events.inc.php` | — |
| **Batch Manager action mode (global)** | `loc_end_element_set_global` + `element_set_global_action` | `include/admin_events.inc.php` | inline `CONTENT` (or own tpl) |
| **Batch Manager unit mode** | `loc_end_element_set_unit` | `include/admin_events.inc.php` (appends to `PLUGINS_BATCH_MANAGER_UNIT_ELEMENT_SUBTEMPLATE`) | `template/batch_manager_unit.tpl` + `js/batch_manager_unit.js` (two save methods) |
| **Tab in the users modal** | `loc_end_admin` | `include/admin_events.inc.php` → `skeleton_add_tab_users_modal()` | `template/notes.tpl` + `js/notes.js` |
| **Gallery button (album + photo pages)** | `loc_end_index` / `loc_end_picture` | `include/public_events.inc.php` → `skeleton_add_button()` (`add_index_button` / `add_picture_button`) | `template/my_button.tpl` |
| **Public page (virtual section)** | `loc_end_section_init` + `loc_end_index` | `include/public_events.inc.php` + `include/skeleton_page.inc.php` | `template/skeleton_page.tpl` |
| **Menu block (new + extend existing)** | `blockmanager_register_blocks` + `blockmanager_apply` | `include/menu_events.class.php` (class-method handlers) | `template/menubar_skeleton.tpl` |
| **Picture-page template prefilter** | `loc_end_picture` | `include/public_events.inc.php``( skeleton_loc_end_picture(), skeleton_picture_prefilter())`| — |
| **Profile page block** | `load_profile_in_template` + `save_profile_from_post` | `include/public_events.inc.php` | `template/skeleton_profile_block.tpl` |
| **Web-service methods (+ piggyback on core methods)** | `ws_add_methods`, `ws_invoke_allowed`, `ws_users_getList`, `ws_setInfo` | `include/ws_functions.inc.php` | — |
| **Tab on core Edit Photo page *(depreciated)*** | `tabsheet_before_select` (change) | `include/admin_events.inc.php` → `skeleton_tabsheet_before_select()`; page: `admin/photo.php` | `admin/template/photo.tpl` |
## Patterns worth copying (beyond the hook names)

- **Lazy includes everywhere**: every `add_event_handler` call passes the handler file as the 4th argument, and the admin/public handler files are only wired inside `if (defined('IN_ADMIN')) { … } else { … }` — `main.inc.php` stays cheap on every request.
- **Reproduce the core tabsheet** when adding a tab to a core page (`admin/photo.php:20-26`): `set_id('photo')` + `select('skeleton')` — this is what keeps other plugins' tabs visible next to yours.
- **Unit-mode saving, two ways** (`js/batch_manager_unit.js`): (1) own ws method called per picture from `<plugin>_batchManagerSave(pictureId)`, or (2) `pluginValues.push({api_key, selector})` to piggyback the field onto core's `pwg.images.setInfo` call, paired with a `ws_invoke_allowed` handler.
- **Menu-block priority**: `EVENT_HANDLER_PRIORITY_NEUTRAL+10` on `blockmanager_apply` for compatibility with the Advanced Menu Manager plugin.

> Used by: `workflows/add-photo-tab.md`, `workflows/add-batch-manager-ui.md`, `workflows/add-gallery-ui.md`, `workflows/add-admin-ui.md`, `workflows/add-event-handler.md`, `workflows/add-ws-method.md`.
