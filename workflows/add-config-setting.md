# Workflow: Add a config setting

Piwigo plugins store all settings as ONE serialized array under `$conf['<plugin_id>']` — no extra table. Wire a new key in four places. See `guidelines/08-config.md` and `guidelines/04-security.md`.

## 1. Default value — `maintain.class.php`
Add the key to the private `$default_conf` array with a sane default. `install()` seeds it via `conf_update_param('<id>', $this->default_conf, true)`; `update()` merges so existing users gain the new key without losing their values:
```php
conf_update_param('<id>', array_merge($this->default_conf, $current), true);
```

## 2. Save handler — a ws method (validate BEFORE storing)
Saves do **not** run in an `admin.php` `$_POST` handler — they go through an `admin_only+post_only` ws method called by AJAX (`workflows/add-ws-method.md`, `workflows/add-admin-ui.md` "Save path"). Inside the callback: verify the token, then **whitelist/validate every value** — never trust the raw input. The whitelist logic is the same as before; only the input source (`$params`) and the escaping differ:
```php
if (get_pwg_token() != $params['pwg_token'])                              // CSRF (admin_only is authz only)
  return new PwgError(403, l10n('Invalid security token'));
$conf['<id>']['my_flag']  = (bool)$params['my_flag'];                     // bool
$conf['<id>']['my_mode']  = in_array($params['my_mode'], array('a','b'), true)  // enum whitelist
                              ? $params['my_mode'] : $this->default... ;
$conf['<id>']['my_count'] = max(1, min(50, (int)$params['my_count']));    // clamp int
$conf['<id>']['my_text']  = pwg_db_real_escape_string(trim($params['my_text'])); // string → escape for SQL
conf_update_param('<id>', $conf['<id>'], true);
```
Reject/clamp out-of-range values; do not store unvalidated strings. **Escape string params yourself** — ws body params are NOT auto-`addslashes`-ed the way `$_POST` is (`workflows/add-ws-method.md`, `guidelines/03-database.md`).

## 3. Form field — config `.tpl`
Add the input, pre-filled from the assigned config, with a stable `id` the save JS reads (`$('#my_flag').prop('checked')` etc. — see `workflows/add-admin-ui.md` step 4). No `<form>`/hidden token needed — the token is emitted as a JS const and sent in the AJAX body. Escape any value rendered into HTML (`{$x|@escape}`) — Smarty auto-escaping is OFF.

## 4. Labels — both languages
Add the field label + help text key to **`language/en_UK/plugin.lang.php` AND `language/fr_FR/plugin.lang.php`**. Render via `{'…'|@translate}`.

## Verify
- Follow `workflows/verify-plugin.md`: lint, then confirm the value round-trips — save in the UI, then
  `SELECT value FROM piwigo_config WHERE param='<id>';` shows it.
- Confirm `uninstall()` still removes the whole key (`conf_delete_param('<id>')`) — no per-key cleanup needed.

> Reference: `guidelines/08-config.md`, `guidelines/04-security.md`, `guidelines/09-i18n.md`. Page/markup: `workflows/add-admin-ui.md`.
