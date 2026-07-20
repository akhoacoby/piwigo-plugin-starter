# Workflow: Extend the Batch Manager (prefilter, action mode, unit mode)

The Batch Manager (**Admin → Photos → Batch Manager**) has three plugin integration points, each with its own hooks. Working examples for all three: the skeleton demo (`reference/SKELETON.md`) — `skeleton/include/admin_events.inc.php`, `skeleton/template/batch_manager_unit.tpl`, `skeleton/js/batch_manager_unit.js`.

All registrations go in `main.inc.php` inside `if (defined('IN_ADMIN'))`, lazy-including your admin events file (4th arg of `add_event_handler`).

## A. Prefilter (a new entry in the photo-selection dropdown)
Two **change** events — both handlers must `return` their array:
```php
add_event_handler('get_batch_manager_prefilters', '<plugin_id>_add_prefilters', 50, $admin_file);
add_event_handler('perform_batch_manager_prefilters', '<plugin_id>_perform_prefilters', 50, $admin_file);
```
```php
function <plugin_id>_add_prefilters($prefilters)
{
  $prefilters[] = array('ID' => '<plugin_id>', 'NAME' => l10n('My filter'));
  return $prefilters;
}

function <plugin_id>_perform_prefilters($filter_sets, $prefilter)
{
  if ($prefilter == '<plugin_id>')
  {
    $filter_sets[] = query2array('SELECT id FROM '.IMAGES_TABLE.' WHERE …', null, 'id');
  }
  return $filter_sets;   // array of image-id sets; BM intersects them
}
```

## B. Action mode (global) — a new bulk action on the selection
One notify event to add the action + its form fragment, one to perform it:
```php
add_event_handler('loc_end_element_set_global', '<plugin_id>_register_action', 50, $admin_file);
add_event_handler('element_set_global_action', '<plugin_id>_perform_action', 50, $admin_file);
```
```php
function <plugin_id>_register_action()
{
  global $template;
  $template->append('element_set_global_plugins_actions', array(
    'ID'      => '<plugin_id>',                     // becomes the $action value
    'NAME'    => l10n('My action'),
    'CONTENT' => '…',   // optional form fields; for big content parse your own .tpl into it
    ));
}

function <plugin_id>_perform_action($action, $collection)
{
  global $page;
  if ($action != '<plugin_id>') return;
  // $collection = array of selected image ids — validate any $_POST fields you added,
  // then act; report via $page['infos'][] / $page['warnings'][] / $page['errors'][]
}
```
Core handles selection + token for the action POST; you still validate **your own** added fields.

## C. Unit mode — a custom field on each photo's edit row
One event appends your sub-template to every element row:
```php
add_event_handler('loc_end_element_set_unit', '<plugin_id>_set_unit_fields', 50, $admin_file);
```
```php
function <plugin_id>_set_unit_fields()
{
  global $template;
  $template->assign('<UPPER_ID>_PATH', <UPPER_ID>_PATH);
  $template->append('PLUGINS_BATCH_MANAGER_UNIT_ELEMENT_SUBTEMPLATE',
    'plugins/<plugin_id>/template/batch_manager_unit.tpl');   // path relative to gallery root
}
```
In the sub-template each row exposes the current photo as `$element` — columns of the `images` table are pre-loaded (`{$element.id}`, and your own `images` column comes free as `{$element.<column>}`).

**Saving unit-mode values — two methods** (both demonstrated in `skeleton/js/batch_manager_unit.js`):
1. **Own ws method per picture**: define a JS function named exactly `<plugin_id>_batchManagerSave(pictureId)` — core calls it for each photo on save. Inside, read your input from `#picture-<id>` and POST to your own `<plugin_id>.setInfo` ws method with `pwg_token` (`workflows/add-ws-method.md`).
2. **Piggyback on core's `pwg.images.setInfo`**: register your field with `pluginValues.push({api_key: '<key>', selector: '.<input-class>'})`; the value rides along in core's save request. Server-side, catch it with a `ws_invoke_allowed` handler that checks `$methodName == 'pwg.images.setInfo'` and your key's presence (see `skeleton_ws_images_setInfo`).

Method 1 is explicit and isolated; method 2 is one request per photo total. Either way the write must validate `image_id` (`PATTERN_ID`) and the value server-side.

## Rules
- Prefilter events are **change** (return the array); the action/unit `loc_end_*` events are notify.
- The Batch Manager is **admin-themed** — no gallery/theme classes; keep any CSS in your sub-template scoped to your own class names.
- Per-photo values live in your own table or an `images` column managed by your plugin — not in `$conf`.

## Verify
Batch Manager global mode: your prefilter appears and selects the right set; your action appears, runs on the selection, and reports via infos/warnings. Unit mode: your field renders on every row with the current value, saves round-trip (watch the ws call succeed), and a photo without your data still saves cleanly. Then `workflows/verify-plugin.md`.

> Reference: `reference/SKELETON.md`, `workflows/add-ws-method.md`, `guidelines/03-database.md`, `guidelines/04-security.md`, `guidelines/06-hooks.md`.
