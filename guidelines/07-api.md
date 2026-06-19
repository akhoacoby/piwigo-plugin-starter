# Web Services / API endpoints

Single endpoint: `ws.php` (JSON/XML/PHP). Register methods on the `ws_add_methods` event.

## Register
```php
function your_plugin_ws_add_methods($arr) {
  $service = &$arr[0];
  $service->addMethod(
    'your_plugin.methodName',        // dotted, plugin-namespaced
    'ws_your_plugin_method',         // callback
    array(                           // parameter spec
      'ids' => array('flags' => WS_PARAM_FORCE_ARRAY, 'type' => WS_TYPE_ID),
    ),
    'Short description.',            // description
    null,                            // include file (lazy)
    array('hidden' => false, 'post_only' => true, 'admin_only' => false)
  );
}

function ws_your_plugin_method($params, &$service) {
  if (/* not allowed */) return new PwgError(403, 'Forbidden');
  return array(/* serializable data */);
}
```

## Rules
- Param types: `WS_TYPE_ID` / `INT` / `FLOAT` / `BOOL` / `POSITIVE` / `NOTNULL` — the engine validates/coerces.
- Param flags: `WS_PARAM_OPTIONAL` / `FORCE_ARRAY` / `ACCEPT_ARRAY`.
- Errors: `return new PwgError($code, $msg);` (e.g. `403`). Wrap collections in `PwgNamedArray` / `PwgNamedStruct`.
- Type validation is NOT authorization — **re-check object permissions** (`get_sql_condition_FandF` / status) INSIDE the callback.
- Use `post_only` for state changes; `admin_only` for admin operations.
- Namespace methods under your plugin (`your_plugin.*`); never shadow core `pwg.*` methods.

> Reference: `PIWIGO_CONVENTIONS.md` §13.
