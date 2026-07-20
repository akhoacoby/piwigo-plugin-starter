# Workflow: Add an event handler

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

### Which hook for which surface (tabs & UI differ — don't mix them up)
| You want | Hook(s) | Playbook |
|---|---|---|
| Tab on **your own** plugin admin page | *none* — plugin tabsheet in your `admin.php` | `workflows/add-admin-ui.md` |
| Tab on a **core** admin page (Edit Photo, …) (depreciated)| `tabsheet_before_select` (**change**) | `workflows/add-photo-tab.md` |
| Batch Manager prefilter | `get_batch_manager_prefilters` + `perform_batch_manager_prefilters` (**change**) | `workflows/add-batch-manager-ui.md` |
| Batch Manager bulk action (global mode) | `loc_end_element_set_global` + `element_set_global_action` | `workflows/add-batch-manager-ui.md` |
| Batch Manager per-photo field (unit mode) | `loc_end_element_set_unit` | `workflows/add-batch-manager-ui.md` |
| Gallery button / public page / menu block | `loc_end_index`/`loc_end_picture`, `loc_end_section_init`, `blockmanager_*` | `workflows/add-gallery-ui.md` |

Working examples of every row: `reference/SKELETON.md`.

## 2. Register — `main.inc.php`
```php
add_event_handler('<event>', '<plugin_id>_<name>', EVENT_HANDLER_PRIORITY_NEUTRAL, $handler_file);
```
- Priority `50` (neutral); **lower runs first**.
- Callback: `'<plugin_id>_fn'` or `array('YourClass','method')`.
- The optional 4th argument **lazy-loads that file only when the event actually fires** — keep `main.inc.php` lean; it should only define constants and register handlers.
- Group handlers into one file per concern. The Piwigo convention (live example: `skeleton/main.inc.php`, mapped in `reference/SKELETON.md`; names are convention, not magic — any resolvable path works):
  - `$admin_file` → `include/admin_events.inc.php` — admin-side handlers; register these inside `if (defined('IN_ADMIN'))`
  - `$public_file` → `include/public_events.inc.php` — gallery-side handlers; register in the `else` branch
  - `$ws_file` → `include/ws_functions.inc.php` — API methods; register OUTSIDE the admin/public split (`ws.php` requests must always see them)
  - `$menu_file` → `include/menu_events.class.php` — class-method menu handlers; also outside the split (the admin Menus screen needs the blocks registered too)

## 3. Write the callback
- Match the type: `return $data;` for change events; side-effects only for notify.
- Reading images/albums? Apply `get_sql_condition_FandF(...)` — events do NOT pre-filter for permissions (see `guidelines/03-database.md`).
- Output to HTML/templates must be escaped (Smarty auto-escaping is OFF — `guidelines/05-frontend.md`).

## Custom page (virtual section)
In a `loc_end_section_init` handler set `$page['section']`, `$page['title']`, `$page['body_id']`, and `$page['is_external'] = true`. Don't add a standalone front-controller PHP file.

## Verify
Follow `workflows/verify-plugin.md`; confirm the handler fires (and, for change events, that `$data` survives — a blanked page/array means you forgot to `return`).

> Reference: `guidelines/06-hooks.md`, `PIWIGO_CONVENTIONS.md` §8, §10.
