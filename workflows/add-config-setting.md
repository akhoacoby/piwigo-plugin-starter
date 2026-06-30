# Workflow: Add a config setting

Piwigo plugins store all settings as ONE serialized array under `$conf['<plugin_id>']` — no extra table. Wire a new key in four places. See `guidelines/08-config.md` and `guidelines/04-security.md`.

## 1. Default value — `maintain.class.php`
Add the key to the private `$default_conf` array with a sane default. `install()` seeds it via `conf_update_param('<id>', $this->default_conf, true)`; `update()` merges so existing users gain the new key without losing their values:
```php
conf_update_param('<id>', array_merge($this->default_conf, $current), true);
```

## 2. Save handler — admin page (validate BEFORE storing)
On the config-form POST: `check_pwg_token()` first, then **whitelist/validate every value** — never trust the raw input:
```php
$conf['<id>']['my_flag']  = isset($_POST['my_flag']);                       // bool
$conf['<id>']['my_mode']  = in_array($_POST['my_mode'], array('a','b'))     // enum whitelist
                              ? $_POST['my_mode'] : $this->default... ;
$conf['<id>']['my_count'] = max(1, min(50, (int)$_POST['my_count']));       // clamp int
conf_update_param('<id>', $conf['<id>'], true);
```
Reject/clamp out-of-range values; do not store unvalidated strings.

## 3. Form field — config `.tpl`
Add the input, pre-filled from the assigned config, inside the existing `{$ADMIN_CONTENT}` form (which already carries the pwg token). Escape any value rendered into HTML (`{$x|@escape}`) — Smarty auto-escaping is OFF.

## 4. Labels — both languages
Add the field label + help text key to **`language/en_UK/plugin.lang.php` AND `language/fr_FR/plugin.lang.php`**. Render via `{'…'|@translate}`.

## Verify
- Follow `workflows/verify-plugin.md`: lint, then confirm the value round-trips — save in the UI, then
  `SELECT value FROM piwigo_config WHERE param='<id>';` shows it.
- Confirm `uninstall()` still removes the whole key (`conf_delete_param('<id>')`) — no per-key cleanup needed.

> Reference: `guidelines/08-config.md`, `guidelines/04-security.md`, `guidelines/09-i18n.md`. Page/markup: `workflows/add-admin-ui.md`.
