---
name: add-hook
description: Wire a Piwigo event handler correctly — pick the right event, register it in main.inc.php (with lazy-include for heavy handlers), and write a callback that respects modifier-vs-notify semantics. Use when the user wants the plugin to react to a gallery/admin/batch event, add an admin-menu link, claim a custom page, or hook image/album rendering.
---

# Add an event handler

Integrate ONLY through events — never patch core. See `guidelines/06-hooks.md`.

## 1. Pick the event and know its type
- **`trigger_change($event, $data)` = modifier** → your callback MUST `return` the (possibly modified) `$data`. Returning nothing/`null` silently wipes it.
- **`trigger_notify($event)` = action** → return value ignored.
- Don't guess the name/type — the full list is in any install at `tools/triggers_list.php` (~84 notify + ~60 change). Common ones:
  - `init` — everything loaded; load language + unserialize config.
  - `loc_begin_index` / `loc_end_index`, `loc_begin_picture` / `loc_end_picture` — gallery / photo pages.
  - `loc_end_section_init` — claim a virtual section (custom page).
  - `get_admin_plugin_menu_links` (**change**) — add the admin-menu link (return the modified array).
  - `loc_begin_element_set_global` / `element_set_global_action` — Batch Manager.

## 2. Register — `main.inc.php`
```php
add_event_handler('<event>', '<plugin_id>_<name>', EVENT_HANDLER_PRIORITY_NEUTRAL, <lazy_include?>);
```
- Priority `50` (neutral); **lower runs first**.
- Callback: `'<plugin_id>_fn'` or `array('YourClass','method')`.
- Heavy handler? Pass the include file as the 4th arg so it loads only when the event fires — keep `main.inc.php` lean.

## 3. Write the callback
- Match the type: `return $data;` for change events; side-effects only for notify.
- Reading images/albums? Apply `get_sql_condition_FandF(...)` — events do NOT pre-filter for permissions (see `guidelines/03-database.md`).
- Output to HTML/templates must be escaped (Smarty auto-escaping is OFF — `guidelines/05-frontend.md`).

## Custom page (virtual section)
In a `loc_end_section_init` handler set `$page['section']`, `$page['title']`, `$page['body_id']`, and `$page['is_external'] = true`. Don't add a standalone front-controller PHP file.

## Verify
Run the `verify-plugin` skill; confirm the handler fires (and, for change events, that `$data` survives — a blanked page/array means you forgot to `return`).

> Reference: `guidelines/06-hooks.md`, `PIWIGO_CONVENTIONS.md` §8, §10.
