# Workflow: Add a tab to the core Edit Photo page

Adds a plugin tab to **Admin → Photo → edit** (`admin.php?page=photo-<id>`), rendered by your plugin but sitting next to the core tabs. Working example: the skeleton demo (`reference/SKELETON.md`) — `skeleton/include/admin_events.inc.php`, `skeleton/admin/photo.php`, `skeleton/admin/template/photo.tpl`.

This is a **different mechanism** from a tab on your own plugin's admin page (that one needs no hook — see `workflows/add-admin-ui.md` §tabs). Here you join a **core tabsheet** via the `tabsheet_before_select` event.

## 1. Register the tab — `main.inc.php` (admin side only)
```php
if (defined('IN_ADMIN'))
{
  $admin_file = <UPPER_ID>_PATH.'include/admin_events.inc.php';
  add_event_handler('tabsheet_before_select', '<plugin_id>_tabsheet_before_select',
    EVENT_HANDLER_PRIORITY_NEUTRAL, $admin_file);
}
```

## 2. The hook — add your sheet when the photo tabsheet builds
`tabsheet_before_select` is a **change** event: it fires for every admin tabsheet, passes `($sheets, $tabsheet_id)`, and you MUST return `$sheets` (returning nothing wipes every tab on every admin page):
```php
function <plugin_id>_tabsheet_before_select($sheets, $id)
{
  if ($id == 'photo')  // the Edit Photo tabsheet; other core ids exist (album, user, …)
  {
    $sheets['<plugin_id>'] = array(
      'caption' => l10n('My tab'),
      'url'     => <UPPER_ID>_ADMIN.'-photo&amp;image_id='.$_GET['image_id'],
      );
  }
  return $sheets;
}
```
The URL routes back into **your own admin page** with tab id `photo` — the tab is registered on the core page, but its content is served by your plugin.

## 3. Route it — your `admin.php`
Your plugin tabsheet must NOT render on this tab (it belongs to the photo tabsheet, not yours):
```php
$page['tab'] = isset($_GET['tab']) ? $_GET['tab'] : 'config';   // whitelist as usual
if ($page['tab'] != 'photo')
{
  // ... your normal plugin tabsheet (set_id('<plugin_id>'), add(), select(), assign())
}
include(<UPPER_ID>_PATH.'admin/'.$page['tab'].'.php');
```

## 4. The tab page — `admin/photo.php`
```php
defined('<UPPER_ID>_PATH') or die('Hacking attempt!');

$page['active_menu'] = get_active_menu('photo');   // keep the "Photos" menu block open
check_status(ACCESS_ADMINISTRATOR);
check_input_parameter('image_id', $_GET, false, PATTERN_ID);

$self_url = <UPPER_ID>_ADMIN.'-photo&amp;image_id='.$_GET['image_id'];

// When adding a tab to a CORE tabsheet you MUST reproduce the core tabsheet code —
// core + other plugins' tabs stay visible and compatible.
include_once(PHPWG_ROOT_PATH.'admin/include/tabsheet.class.php');
$tabsheet = new tabsheet();
$tabsheet->set_id('photo');            // <= the CORE tabsheet id, not yours
$tabsheet->select('<plugin_id>');      // <= your sheet key from step 2
$tabsheet->assign();

$query = '
SELECT * FROM '.IMAGES_TABLE.' WHERE id = '.$_GET['image_id'].';';
$picture = pwg_db_fetch_assoc(pwg_query($query));

$template->assign(array(
  'F_ACTION'  => $self_url,
  'PWG_TOKEN' => get_pwg_token(),
  'TITLE'     => render_element_name($picture),
  'TN_SRC'    => DerivativeImage::thumb_url($picture),
));
$template->set_filename('<plugin_id>_content', realpath(<UPPER_ID>_PATH.'admin/template/photo.tpl'));
```
(`admin.php` already does `assign_var_from_handle('ADMIN_CONTENT', '<plugin_id>_content')` for every tab.)

## 5. Saving per-photo data (the "+ config" part)
Two patterns — pick one:
- **Classic POST**: submit the form to `$self_url` with a unique button name + hidden `pwg_token`; at the top of `admin/photo.php`: `if (isset($_POST['<plugin_id>_save'])) { check_pwg_token(); /* validate, then write */ }`. Per-photo values go in your own table (`guidelines/03-database.md`), NOT in `$conf` (that's plugin-wide config — `workflows/add-config-setting.md`).
- **AJAX via a ws method**: post to your own `<plugin_id>.setInfo` web-service method with `pwg_token` (see `workflows/add-ws-method.md`; example: `skeleton.setInfo` in `skeleton/include/ws_functions.inc.php`). Reuse this same method for Batch Manager unit mode (`workflows/add-batch-manager-ui.md`) — one save path for both surfaces.

## Rules
- The page is **admin-themed** — reuse admin classes verbatim, ship no admin CSS (`reference/ADMIN_UI.md`).
- The hook must **return `$sheets` unconditionally** and only touch it when `$id` matches — it fires on every admin tabsheet.
- `image_id` is validated with `PATTERN_ID` before it ever reaches SQL; all output escaped (`{$x|@escape}`).
- Same recipe works for other core tabsheets (album edit, etc.) — match the right `$id` in step 2 and reproduce that tabsheet's id in step 4.

## Verify
Open any photo's edit page: your tab shows next to the core tabs; other plugins' photo tabs still show; the tab routes to your page with the photo's title/thumbnail; save round-trips and a tampered token is rejected; the core tabs still work from your page. Then `workflows/verify-plugin.md`.

> Reference: `reference/SKELETON.md`, `reference/ADMIN_UI.md`, `workflows/add-admin-ui.md`, `guidelines/04-security.md`, `guidelines/06-hooks.md`.
