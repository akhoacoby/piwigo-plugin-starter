# Workflow: Add a web-service (API) method

All API goes through the single `ws.php` endpoint; register methods on the `ws_add_methods` event. See `guidelines/07-api.md`.

## 1. Register (on `ws_add_methods`)
```php
add_event_handler('ws_add_methods', '<plugin_id>_ws_add_methods');

function <plugin_id>_ws_add_methods($arr) {
  $service = &$arr[0];
  $service->addMethod(
    '<plugin_id>.methodName',          // dotted, plugin-namespaced — never shadow core pwg.*
    'ws_<plugin_id>_method',           // callback
    array(                             // typed param spec — engine validates/coerces
      'ids' => array('flags' => WS_PARAM_FORCE_ARRAY, 'type' => WS_TYPE_ID),
    ),
    'Short description.',
    null,                              // include file (lazy-loaded)
    array('hidden' => false, 'post_only' => true, 'admin_only' => false)
  );
}
```
- Types: `WS_TYPE_ID|INT|FLOAT|BOOL|POSITIVE|NOTNULL`. Flags: `WS_PARAM_OPTIONAL|FORCE_ARRAY|ACCEPT_ARRAY`.
- `post_only => true` for state changes; `admin_only => true` for admin operations.
- **Admin-page saves live here, not in `admin.php`.** A plugin's admin settings save through an `admin_only+post_only` method called by AJAX (`workflows/add-admin-ui.md` "Save path", `workflows/add-config-setting.md`). `admin_only` is authorization only — such a method still declares a `pwg_token` param and its callback verifies it (`get_pwg_token() != $params['pwg_token']` → `PwgError(403)`).

## 2. Callback
```php
function ws_<plugin_id>_method($params, &$service) {
  // Type validation is NOT authorization — re-check permissions here.
  if (/* not allowed */) return new PwgError(403, 'Forbidden');
  // Any SELECT of images/albums MUST carry get_sql_condition_FandF(...).
  return array(/* serializable data */);   // or PwgNamedArray / PwgNamedStruct for collections
}
```

## Rules (do not skip)
- **Re-check object permissions inside the callback** — `get_sql_condition_FandF` / status checks. The param engine only validates shape, not access.
- Errors: `return new PwgError($code, $msg)` (e.g. `403`, `404`).
- Namespace under `<plugin_id>.*`; never override `pwg.*`.
- DB body params (not from `$_GET`/`$_POST`) aren't auto-`addslashes`-ed — escape with `pwg_db_real_escape_string()` (see `guidelines/03-database.md`).

## Verify
Follow `workflows/verify-plugin.md`, then call the method directly, e.g.:
```bash
curl -sS "<PIWIGO_URL>/ws.php?format=json&method=<plugin_id>.methodName&ids=1,2"
```
Check the forbidden path returns the `PwgError`, not data.

> Reference: `guidelines/07-api.md`, `PIWIGO_CONVENTIONS.md` §13.
