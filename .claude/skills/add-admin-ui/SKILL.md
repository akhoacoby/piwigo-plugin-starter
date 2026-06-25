---
name: add-admin-ui
description: Build or extend the plugin's admin settings page so it looks native in the Piwigo admin themes (default/clear/roma) — tabsheet, the standard fieldset/ul/li form, pwg-token CSRF, infos/errors feedback. Use when the user wants a settings/configuration screen, an admin tab, or buttons/forms in the admin area. The admin page is NOT styled by the gallery theme (modus/darkroom) — see theme-compat.
---

# Add admin (settings) UI

The plugin config page (`admin.php?page=plugin-<id>`) renders inside the **admin theme**, independent of the gallery theme. So follow **admin conventions** here — do NOT use Bootstrap or modus classes (they aren't loaded in admin). Background in `theme-compat` (§7). This pairs with `add-config-setting` (which handles validation + storage); this skill is about the **page/markup**.

**Reference the real core page** for a polished, native look: `admin/themes/default/template/configuration_main.tpl` (Admin → Configuration → Options). Match its structure — `form.properties` → `fieldset.mainConf` → icon'd `<legend>` → `<ul><li>` → `.font-checkbox`/`.icon-check` switches, `.sub-setting` for dependent options, `.formButtons` submit row. The bundled `assets/configuration.tpl` already follows it.

## Wiring (in `admin.php`)
The starter already sets up a tabsheet + renders a template. To add the settings UI:
```php
global $template, $conf;
$cfg = $conf['<plugin_id>'];                          // already unserialized in init()

// expose values + the CSRF token the template needs
$template->assign(array(
  'F_ACTION'     => <UPPER_ID>_ADMIN.'-config',
  'PWG_TOKEN'    => get_pwg_token(),
  'cfg'          => $cfg,
  'mode_options' => array('a', 'b'),
));

$template->set_filename('<plugin_id>_content', <UPPER_ID>_REALPATH.'/admin/template/configuration.tpl');
$template->assign_var_from_handle('ADMIN_CONTENT', '<plugin_id>_content');
```

## Save handler (top of `admin.php`, before assigning)
```php
if (isset($_POST['submit']))
{
  check_pwg_token();                                  // CSRF — aborts on bad/missing token
  // validate every value (see add-config-setting / 04-security.md), then:
  conf_update_param('<plugin_id>', $cfg, true);
  $page['infos'][] = l10n('Settings saved');          // admin theme renders this
}
```
- Report success/failure via `$page['infos']` / `$page['errors']` — the admin theme styles them as `.infos` / `.errors`. Don't roll your own alert markup.

## Template
Copy the starter form and rename tokens:
```bash
cp .claude/skills/add-admin-ui/assets/configuration.tpl <plugin>/admin/template/configuration.tpl
```
It uses the canonical admin markup: `<form class="properties">` → `<fieldset><legend>` → `<ul><li>` rows, the `.font-checkbox`/`.icon-check` switch, a select, a bounded number, and `<input class="submit">`. It includes the hidden `pwg_token` field.

## Adding a settings tab / section — the button "can't be found" gotcha
A new admin tab needs **four things in sync**; miss one and the tab button doesn't appear or its URL falls back to the first tab (the "button not found" bug):
1. **Whitelist** the tab id: `$tab = in_array($_GET['tab'] ?? '', array('config','newtab'), true) ? $_GET['tab'] : 'config';`
2. **Register** it: `$tabsheet->add('newtab', '<span class="icon-…"></span>'.l10n('Label'), <UPPER_ID>_ADMIN.'-newtab');`
   — the URL token MUST be `<UPPER_ID>_ADMIN.'-<tabid>'` and the tab id MUST match the whitelist exactly.
3. **Select**: `$tabsheet->select($tab);` then branch the template/PHP on `$tab` to render that tab's content.
4. The page link itself only exists if `main.inc.php` has **`Has Settings: true`** and a `get_admin_plugin_menu_links` handler pointing at `<UPPER_ID>_ADMIN`.

Likewise, a **form's submit must have a unique `name`** that the POST handler checks — `if (isset($_POST['<plugin_id>_save']))`. If the button's `name` and the guard disagree, the save silently does nothing ("button broken"). One `name` per form/action.

## Rules
- **Match admin idioms**: `.properties` form, `fieldset.mainConf`/`legend`, `ul`/`li` rows, `.font-checkbox`+`.icon-check`, `.sub-setting` for dependents, `input.submit` in `.formButtons`, admin icon font (`.icon-cog`, `.icon-check`) — NOT FontAwesome/fontello.
- **Every form carries the pwg token**; the handler calls `check_pwg_token()` first.
- **Escape output** (`{$x|@escape}`) — admin Smarty also has auto-escape OFF.
- Strings via `{'…'|@translate}`, present in en_UK + fr_FR (`09-i18n.md`).

## Verify
Activate the plugin, open **Admin → Plugins → <plugin> → Settings**, save, and confirm: the **Settings link appears** (needs `Has Settings: true` + the menu-links handler), **every tab button shows and routes** (whitelist + `tabsheet->add` + token in sync), the form looks native, the success message shows as an admin `.infos` banner, values round-trip (`add-config-setting` verify step), and a tampered/absent token is rejected. Try admin theme `clear` too. Then run `verify-plugin`.

> Reference: `theme-compat` (§7), `add-config-setting`, `guidelines/04-security.md`, `guidelines/05-frontend.md`.
