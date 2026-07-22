# Workflow: Add admin (settings) UI

The plugin config page (`admin.php?page=plugin-<id>`) renders inside the **admin theme** (`default`/`clear`/`roma`), independent of the gallery theme. So follow **admin conventions** here — do NOT use Bootstrap or modus classes (they aren't loaded in admin). Background in `reference/theme-compat.md` (§7). This pairs with `workflows/add-config-setting.md` (which handles validation + storage); this workflow is about the **page/markup**.

**Canonical reference: `reference/ADMIN_UI.md`** — extracted from the cleanest current core page, `admin.php?page=configuration&section=search` (`configuration_search.tpl`). It catalogues the real admin-theme classes + CSS. The modern shape: `form.properties` → `#configContent` → `fieldset` with a **colored, animated legend icon** (`icon-<name> icon-blue rotate-element`) → `.font-checkbox`/`.icon-check` switches (+ `.sub-setting` for dependents) → a **fixed `.savebar-footer`** holding a `.buttonLike` save button and an inline `.badge.info-message` success. **Reuse these admin-theme classes verbatim — ship no admin CSS.**

> **Save mechanism — no `$_POST` handler in `admin.php`.** Do **not** save settings with a `$_POST['<plugin_id>_save']` block. Expose a **web-service method** (`admin_only => true`, `post_only => true`) and save by an **AJAX call to it** (`workflows/add-ws-method.md`). CSRF is **kept, not dropped**: `admin_only` is authorization only — the method still declares a `pwg_token` param and the callback still verifies it. `admin.php` becomes render-only (it only `assign`s). See "Save path" below.
>
> ⚠ The ready-made `reference/admin-configuration.tpl` and the skeleton in `reference/ADMIN_UI.md` still show the **legacy POST form** (`<form method="post">` + submit `name` + hidden `pwg_token`). Convert them to the button+AJAX shape below; a ready-made ws/AJAX template is a follow-up.

## Wiring (in `admin.php`)
The starter already sets up a tabsheet + renders a template. `admin.php` only assigns — it no longer handles a POST:
```php
global $template, $conf;
$cfg = $conf['<plugin_id>'];                          // already unserialized in init()

// expose values + the CSRF token (the JS posts it back to the ws method) + savebar state
$template->assign(array(
  'PWG_TOKEN'    => get_pwg_token(),                  // emitted as a JS const, sent in the AJAX body
  'isWebmaster'  => is_webmaster() ? 1 : 0,           // savebar disables the button otherwise
  'cfg'          => $cfg,
  'mode_options' => array('a', 'b'),
));

$template->set_filename('<plugin_id>_content', <UPPER_ID>_REALPATH.'/admin/template/configuration.tpl');
$template->assign_var_from_handle('ADMIN_CONTENT', '<plugin_id>_content');
```
> No `F_ACTION` — the form no longer posts to an action URL; the save button is bound to an AJAX call.

> **Provenance**: `PWG_TOKEN` — `admin/configuration.php:375-380`; `isWebmaster` — `admin/configuration.php:701`; the savebar template — `admin/themes/default/template/configuration_search.tpl:227-239` (Piwigo 17.0.0beta1 core). The **ws + AJAX save** shape below is verified against the `piwigo_ai` plugin: registration `include/ws_functions.inc.php:53` (`pwg.ai.config`, `admin_only+post_only`, `pwg_token` param), callback `:222` (`p_ws_ai_config` — token compare then `conf_update_param`), JS `admin/js/configuration.js:27`, token const `admin/template/configuration.tpl:3`. `cfg`/`mode_options` are placeholders. Line numbers drift between versions; re-grep the identifiers if they don't match.

## Save path — a ws method, called by AJAX (replaces the POST handler)
Four pieces; the token flows through all of them, so CSRF is preserved end-to-end.

**1. Register the method** in `include/ws_functions.inc.php`, wired on `ws_add_methods` (`workflows/add-ws-method.md`):
```php
$service->addMethod('<plugin_id>.setConfig', 'ws_<plugin_id>_set_config',
  array(
    'pwg_token' => array(),                           // CSRF token, sent by the JS
    'my_flag'   => array('type' => WS_TYPE_BOOL),
    'my_mode'   => array('flags' => WS_PARAM_OPTIONAL),
  ),
  'Save <plugin> configuration', null,
  array('hidden' => false, 'post_only' => true, 'admin_only' => true));
```

**2. Callback** — verify the token, then validate/whitelist every value (same rules as `workflows/add-config-setting.md` / `guidelines/04-security.md`, reading `$params` instead of `$_POST`):
```php
function ws_<plugin_id>_set_config($params, &$service) {
  global $conf;
  if (get_pwg_token() != $params['pwg_token'])        // CSRF — kept, not replaced by admin_only
    return new PwgError(403, l10n('Invalid security token'));
  // admin_only already gated authz; now validate + persist:
  $cfg = $conf['<plugin_id>'];
  $cfg['my_flag'] = (bool)$params['my_flag'];
  $cfg['my_mode'] = in_array($params['my_mode'], array('a','b'), true) ? $params['my_mode'] : 'a';
  conf_update_param('<plugin_id>', $cfg, true);
  return l10n('Settings saved');                      // or new PwgError(...) on failure
}
```

**3. Template** — expose the token to JS and make the save control a plain `<button>` (no `type="submit"`, no `name`, no form action), and load the JS:
```smarty
{combine_script id='<plugin_id>_config' load='footer' path="{$<UPPER_ID>_PATH}admin/js/configuration.js"}
<script>const <UPPER_ID>_TOKEN = "{$PWG_TOKEN}";</script>
...
<button class="buttonLike" id="<plugin_id>_save"{if $isWebmaster != 1} disabled{/if}>
  <i class="icon-floppy"></i> {'Save Settings'|@translate}
</button>
```

**4. JS** (`admin/js/configuration.js`) — collect the fields and POST to `ws.php`, showing feedback with no page reload:
```js
$('#<plugin_id>_save').on('click', function () {
  $.ajax({
    url: 'ws.php?format=json&method=<plugin_id>.setConfig',
    type: 'POST', dataType: 'json',
    data: { pwg_token: <UPPER_ID>_TOKEN,
            my_flag: $('#my_flag').prop('checked'),
            my_mode: $('#my_mode').val() },
    success: function (res) { res.stat === 'ok' ? showSaved() : showError(res); },
    error: showError,
  });
});
```
- **Feedback moves client-side**: on `stat === 'ok'` reveal the `.badge.info-message` in the savebar (toggle it with JS); on error reveal a `.badge.info-error`. No page reload, no server-rendered `$save_success`.

<!--
## Markup (the fieldset + savebar)
The **field/fieldset/savebar structure** is unchanged — follow `reference/ADMIN_UI.md`: `#configContent` → `<fieldset>` with a colored `rotate-element` legend icon → `.font-checkbox` switches (+ `.sub-setting`) → fixed `.savebar-footer` holding the `.buttonLike` save button and the `.badge.info-message`. **Reuse `id="configContent"`** — core CSS gives you the save-bar bottom offset and legend styling for free. Only the **save wiring** differs from that reference: drop `<form method="post">`/`{$F_ACTION}` and the hidden `pwg_token` input; make the save control a `<button id="<plugin_id>_save">` bound by JS (steps 3–4 above). The token reaches the server via the AJAX body, not a form field.
-->

## Adding a settings tab / section — the button "can't be found" gotcha
> Tab on **your own plugin page** (this section) needs **no hook**. A tab on a **core page** (Edit Photo, album edit, …) is a different mechanism — `tabsheet_before_select` — see `workflows/add-photo-tab.md`.

A new admin tab needs **four things in sync**; miss one and the tab button doesn't appear or its URL falls back to the first tab (the "button not found" bug):
1. **Whitelist** the tab id: `$tab = in_array($_GET['tab'] ?? '', array('config','newtab'), true) ? $_GET['tab'] : 'config';`
2. **Register** it: `$tabsheet->add('newtab', '<span class="icon-…"></span>'.l10n('Label'), <UPPER_ID>_ADMIN.'-newtab');`
   — the URL token MUST be `<UPPER_ID>_ADMIN.'-<tabid>'` and the tab id MUST match the whitelist exactly.
3. **Select**: `$tabsheet->select($tab);` then branch the template/PHP on `$tab` to render that tab's content.
4. The page link itself only exists if `main.inc.php` has **`Has Settings: true`** and a `get_admin_plugin_menu_links` handler pointing at `<UPPER_ID>_ADMIN`.

**Growing beyond one page — the per-tab router.** When tabs stop being sections of one form and become real pages, switch to the skeleton's router pattern (`skeleton/admin.php`, see `reference/SKELETON.md`): `admin.php` whitelists `$page['tab']`, builds the tabsheet, then `include(<UPPER_ID>_PATH.'admin/'.$page['tab'].'.php')` — one file per tab under `admin/`, one template each under `admin/template/`. Each tab file assigns its own `<plugin_id>_content` handle; `admin.php` keeps the shared `assign_var_from_handle('ADMIN_CONTENT', …)`. The whitelist stays the single source of truth for which tab files are reachable — never include `$_GET['tab']` unvalidated.

Likewise, the **save button's `id` must match the JS selector** that binds the AJAX call (`$('#<plugin_id>_save').on('click', …)`). If the button `id` and the JS selector disagree, the save silently does nothing ("button broken"). One `id` per save action.

## Rules
- **Reuse admin-theme classes verbatim, ship no admin CSS**: `.properties` form, `#configContent`, `fieldset`+`legend` (with `icon-<color> rotate-element`), `.font-checkbox`+`.icon-check`, `.sub-setting`, `.savebar-footer`/`.savebar-footer-block`, `.buttonLike`, `.badge.info-message`. Icons are **fontello admin/gallery glyphs** (`icon-floppy`, `icon-ok`, `icon-cog`, …) — NOT FontAwesome/Bootstrap.
- The **success badge must live inside `.savebar-footer-block`** (otherwise `.info-message`'s `display:none` keeps it hidden) — see `reference/ADMIN_UI.md`. The JS toggles it on an `ok` response.
- **The pwg token rides in the AJAX body** (`pwg_token: <UPPER_ID>_TOKEN`); the ws callback verifies it first (`get_pwg_token() != $params['pwg_token']` → `PwgError(403)`). Gate the button for non-webmasters (`$isWebmaster`). No `<form method="post">`, no hidden token input, no `check_pwg_token()` in `admin.php`.
- **Escape output** (`{$x|@escape}`) — admin Smarty also has auto-escape OFF.
- Strings via `{'…'|@translate}`, present in en_UK + fr_FR (`guidelines/09-i18n.md`).

## Verify
Activate the plugin, open **Admin → Plugins → <plugin> → Settings**, save, and confirm: the **Settings link appears** (needs `Has Settings: true` + the menu-links handler), **every tab button shows and routes** (whitelist + `tabsheet->add` + token in sync), the form looks native, the **save bar is pinned to the bottom and nothing is hidden behind it** (the `#configContent` offset), the **AJAX save returns `stat: ok`** (check the Network tab — `ws.php?method=<plugin_id>.setConfig`) and the **green `.badge.info-message` shows without a page reload**, values round-trip (`workflows/add-config-setting.md` verify step), and a **tampered/absent `pwg_token` yields a 403** from the ws method. Try admin theme `clear` too. Then run `workflows/verify-plugin.md`.

> Reference: `reference/ADMIN_UI.md`, `reference/theme-compat.md` (§7), `workflows/add-config-setting.md`, `guidelines/04-security.md`, `guidelines/05-frontend.md`.
