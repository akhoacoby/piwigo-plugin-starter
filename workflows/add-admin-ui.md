# Workflow: Add admin (settings) UI

The plugin config page (`admin.php?page=plugin-<id>`) renders inside the **admin theme** (`default`/`clear`/`roma`), independent of the gallery theme. So follow **admin conventions** here — do NOT use Bootstrap or modus classes (they aren't loaded in admin). Background in `reference/theme-compat.md` (§7). This pairs with `workflows/add-config-setting.md` (which handles validation + storage); this workflow is about the **page/markup**.

**Canonical reference: `reference/ADMIN_UI.md`** — extracted from the cleanest current core page, `admin.php?page=configuration&section=search` (`configuration_search.tpl`). It catalogues the real admin-theme classes + CSS. The modern shape: `form.properties` → `#configContent` → `fieldset` with a **colored, animated legend icon** (`icon-<name> icon-blue rotate-element`) → `.font-checkbox`/`.icon-check` switches (+ `.sub-setting` for dependents) → a **fixed `.savebar-footer`** holding a `.buttonLike` submit and an inline `.badge.info-message` success. The ready-made `reference/admin-configuration.tpl` already follows it. **Reuse these admin-theme classes verbatim — ship no admin CSS.**

## Wiring (in `admin.php`)
The starter already sets up a tabsheet + renders a template. To add the settings UI: 
```php
global $template, $conf;
$cfg = $conf['<plugin_id>'];                          // already unserialized in init()

// expose values + the CSRF token + the savebar state the template needs
$template->assign(array(
  'F_ACTION'     => <UPPER_ID>_ADMIN.'-config',
  'PWG_TOKEN'    => get_pwg_token(),
  'isWebmaster'  => is_webmaster() ? 1 : 0,           // savebar disables the button otherwise
  'cfg'          => $cfg,
  'mode_options' => array('a', 'b'),
));

$template->set_filename('<plugin_id>_content', <UPPER_ID>_REALPATH.'/admin/template/configuration.tpl');
$template->assign_var_from_handle('ADMIN_CONTENT', '<plugin_id>_content');
```
> **Provenance** (verified against Piwigo 17.0.0beta1 core): `PWG_TOKEN`/`F_ACTION` — `admin/configuration.php:375-380`; `isWebmaster` — `admin/configuration.php:701`; the savebar template consuming them — `admin/themes/default/template/configuration_search.tpl:227-239`. `F_ACTION => <UPPER_ID>_ADMIN.'-config'` is the plugin adaptation of core's `$action` URL, following the skeleton's `SKELETON_ADMIN.'-<tab>'` convention (`skeleton/admin.php`). `cfg` and `mode_options` are placeholders — replace with your plugin's own data. Line numbers drift between Piwigo versions; re-grep for the identifiers if they don't match.

## Save handler (top of `admin.php`, before assigning)
```php
if (isset($_POST['<plugin_id>_save']))                // unique name == the submit button's name
{
  check_pwg_token();                                  // CSRF — aborts on bad/missing token
  // validate every value (see add-config-setting / 04-security.md), then:
  conf_update_param('<plugin_id>', $cfg, true);
  $template->assign('save_success', l10n('Settings saved'));  // inline .badge.info-message in the savebar
  // (errors → $page['errors'][] = ...; the admin theme renders those at the top)
}
```
- **Success** is shown inline in the save bar via `$save_success` (the modern pattern). For **errors**, push to `$page['errors']` — the admin theme renders `.infos`/`.errors` at the top. Don't roll your own alert markup.

## Template
Copy the ready-made form and rename tokens:
```bash
cp reference/admin-configuration.tpl <plugin>/admin/template/configuration.tpl
```
It follows `reference/ADMIN_UI.md`: `<form class="properties">` → `#configContent` → `<fieldset>` with a colored `rotate-element` legend icon → `.font-checkbox` switches (+ `.sub-setting`) → fixed `.savebar-footer` with a `.buttonLike` submit and the `.badge.info-message` success. Includes the hidden `pwg_token`. **Reuse `id="configContent"`** — core CSS gives you the save-bar bottom offset (`padding-bottom`) and legend styling for free.

## Adding a settings tab / section — the button "can't be found" gotcha
> Tab on **your own plugin page** (this section) needs **no hook**. A tab on a **core page** (Edit Photo, album edit, …) is a different mechanism — `tabsheet_before_select` — see `workflows/add-photo-tab.md`.

A new admin tab needs **four things in sync**; miss one and the tab button doesn't appear or its URL falls back to the first tab (the "button not found" bug):
1. **Whitelist** the tab id: `$tab = in_array($_GET['tab'] ?? '', array('config','newtab'), true) ? $_GET['tab'] : 'config';`
2. **Register** it: `$tabsheet->add('newtab', '<span class="icon-…"></span>'.l10n('Label'), <UPPER_ID>_ADMIN.'-newtab');`
   — the URL token MUST be `<UPPER_ID>_ADMIN.'-<tabid>'` and the tab id MUST match the whitelist exactly.
3. **Select**: `$tabsheet->select($tab);` then branch the template/PHP on `$tab` to render that tab's content.
4. The page link itself only exists if `main.inc.php` has **`Has Settings: true`** and a `get_admin_plugin_menu_links` handler pointing at `<UPPER_ID>_ADMIN`.

**Growing beyond one page — the per-tab router.** When tabs stop being sections of one form and become real pages, switch to the skeleton's router pattern (`skeleton/admin.php`, see `reference/SKELETON.md`): `admin.php` whitelists `$page['tab']`, builds the tabsheet, then `include(<UPPER_ID>_PATH.'admin/'.$page['tab'].'.php')` — one file per tab under `admin/`, one template each under `admin/template/`. Each tab file assigns its own `<plugin_id>_content` handle; `admin.php` keeps the shared `assign_var_from_handle('ADMIN_CONTENT', …)`. The whitelist stays the single source of truth for which tab files are reachable — never include `$_GET['tab']` unvalidated.

Likewise, a **form's submit must have a unique `name`** that the POST handler checks — `if (isset($_POST['<plugin_id>_save']))`. If the button's `name` and the guard disagree, the save silently does nothing ("button broken"). One `name` per form/action.

## Rules
- **Reuse admin-theme classes verbatim, ship no admin CSS**: `.properties` form, `#configContent`, `fieldset`+`legend` (with `icon-<color> rotate-element`), `.font-checkbox`+`.icon-check`, `.sub-setting`, `.savebar-footer`/`.savebar-footer-block`, `.buttonLike`, `.badge.info-message`. Icons are **fontello admin/gallery glyphs** (`icon-floppy`, `icon-ok`, `icon-cog`, …) — NOT FontAwesome/Bootstrap.
- The **success badge must live inside `.savebar-footer-block`** (otherwise `.info-message`'s `display:none` keeps it hidden) — see `reference/ADMIN_UI.md`.
- **Every form carries the pwg token**; the handler calls `check_pwg_token()` first. Gate the submit for non-webmasters (`$isWebmaster`).
- **Escape output** (`{$x|@escape}`) — admin Smarty also has auto-escape OFF.
- Strings via `{'…'|@translate}`, present in en_UK + fr_FR (`guidelines/09-i18n.md`).

## Verify
Activate the plugin, open **Admin → Plugins → <plugin> → Settings**, save, and confirm: the **Settings link appears** (needs `Has Settings: true` + the menu-links handler), **every tab button shows and routes** (whitelist + `tabsheet->add` + token in sync), the form looks native, the **save bar is pinned to the bottom and nothing is hidden behind it** (the `#configContent` offset), the **green `.badge.info-message` shows on save**, values round-trip (`workflows/add-config-setting.md` verify step), and a tampered/absent token is rejected. Try admin theme `clear` too. Then run `workflows/verify-plugin.md`.

> Reference: `reference/ADMIN_UI.md`, `reference/theme-compat.md` (§7), `workflows/add-config-setting.md`, `guidelines/04-security.md`, `guidelines/05-frontend.md`.
