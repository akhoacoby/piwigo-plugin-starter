# Hooks & Events

Integrate ONLY through events — never patch core.

## Register
- `add_event_handler($event, $callback, $priority=EVENT_HANDLER_PRIORITY_NEUTRAL, $lazy_include=null)`.
- Priority `50` = neutral; **lower runs first**.
- Callback: `'your_plugin_fn'` or `array('YourClass', 'method')`.
- 4th arg lazy-loads a file only when the event fires — use it for heavy handlers.

## Two trigger types (don't mix them up)
- `trigger_change($event, $data, …)` — **modifier**: your handler MUST `return` the (possibly modified) `$data`.
- `trigger_notify($event, …)` — **action**: return value ignored.

## Common hooks
- `init` — everything loaded; load language, unserialize config.
- `loc_begin_index` / `loc_end_index`, `loc_begin_picture` / `loc_end_picture` — gallery / photo pages.
- `loc_end_section_init` — claim a virtual section (custom page).
- `get_admin_plugin_menu_links` (change) — add the admin-menu link.
- `ws_add_methods` — register web services (see `07-api.md`).
- `tabsheet_before_select` (change) — add a tab to a **core** admin tabsheet (Edit Photo, …); a tab on your *own* admin page needs no hook (see `workflows/add-photo-tab.md` vs `workflows/add-admin-ui.md`).
- `get_batch_manager_prefilters` / `perform_batch_manager_prefilters` (change) — Batch Manager prefilters.
- `loc_end_element_set_global` / `element_set_global_action` — Batch Manager action (global) mode.
- `loc_end_element_set_unit` — Batch Manager unit mode (per-photo fields).
- **Full list:** `tools/triggers_list.php` in any install (~84 `trigger_notify` + ~60 `trigger_change`). Per-surface routing table: `workflows/add-event-handler.md`; worked examples: `reference/SKELETON.md`.

## Custom page (virtual section)
In `loc_end_section_init`: set `$page['section']`, `$page['title']`, `$page['body_id']`, and `$page['is_external'] = true`.

> Reference: `PIWIGO_CONVENTIONS.md` §8, §10.
