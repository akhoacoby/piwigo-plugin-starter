# Configuration

Store plugin settings as ONE serialized entry keyed by the plugin id. No dedicated table.

## Write / read
- Seed in `install()`: `conf_update_param('your_plugin', $default_array, true);`
  (arrays auto-serialized; 3rd arg `true` also updates `$conf` in memory now).
- Read in `init()`: `$conf['your_plugin'] = safe_unserialize($conf['your_plugin']);`
  (`safe_unserialize` is a no-op if the value is already an array).
- Update a setting: rebuild the array → `conf_update_param('your_plugin', $array, true)`.
- Defaults: a private `$default_conf` in `maintain.class.php`. `update()` merges any new keys without clobbering user values:
  `conf_update_param('your_plugin', array_merge($this->default_conf, $current), true);`

## Rules
- ONE config key per plugin (`$conf['your_plugin']`). Never write unrelated core keys.
- Validate / whitelist every value on save (see `04-security.md`) before storing.
- `uninstall()` removes ONLY your key: `conf_delete_param('your_plugin')`.
- Guard reads: `isset($conf['your_plugin'])` before unserializing.

> Reference: `PIWIGO_CONVENTIONS.md` §7.
