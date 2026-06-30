# Theme reference — modus & bootstrap_darkroom

Concrete details behind the `theme-compat` skill. Derived from reading the bundled themes
(`themes/modus`, `themes/bootstrap_darkroom`) and the admin themes (`admin/themes/*`).

---

## 1. How gallery theming works in Piwigo
- The active gallery theme id is `$user['theme']` (PHP) — e.g. `modus`, `bootstrap_darkroom`, `default`, `elegant`.
- A theme either **overrides core `default` templates** (modus) or **ships its own full template set** (bootstrap_darkroom). Most plugin output lands inside whatever markup the theme renders.
- Plugins almost never know which theme is active unless they check `$user['theme']`. Design to **inherit**, then branch only when necessary.

## 2. The core (theme-neutral) idioms — work in default + modus
These are styled by core/default and by modus; emit them and you get themed for free there.
- **Button (index/picture toolbars):**
  ```html
  <a class="pwg-state-default pwg-button" title="Label" rel="nofollow">
    <span class="pwg-icon pwg-icon-…"></span><span class="pwg-button-text">Label</span>
  </a>
  ```
  Prefer the PHP helpers that emit this and let themes position it:
  - `add_index_button($content, $rank)` — album/index toolbar.
  - `add_picture_button($content, $rank)` — photo page toolbar.
- **Thumbnails grid:** `ul#thumbnails > li.thumbnailCategory` (albums) / the photo thumb list. Content wrapper: `.content`, page title `.titrePage`.
- **Notifications:** core renders `$page['infos']` / `$page['errors']` (and `.notification`).

## 3. modus specifics
- **Skinned via Smarty-compiled CSS** (`css/*.css.tpl`) using a `$skin` color array; skins live in `skins/` and **many are dark** (`dark`, `dark_sky`, `dark_lagoon`, `glacier`, `neon_orange`, `neon_pink`, `cafe_latte`, …).
  → **Never hardcode** `background`/`color`. Use `inherit` / `currentColor` / `transparent` so the skin palette shows through.
- Styles the core button idiom (`.pwg-button`, `.pwg-state-default`) and uses **fontello** icons (`.pwg-icon`, `css/iconfontello.css`).
- Ships **`css/plugin_compatibility.css`** — proof that modus patches plugin markup per-plugin (e.g. User Collections `.thumbnailCategory`). If your plugin reuses `.thumbnailCategory`/`#thumbnails` it inherits modus styling.
- Hooks you can rely on: `#thumbnails`, `.content`, `.titrePage`, `.pwg-button`, `.pwg-icon`, `#comments`.

## 4. bootstrap_darkroom specifics
- **Bootstrap 4** (bundles `node_modules/bootstrap` + many **bootswatch**/**material** skins under `css/<skin>/`) + **FontAwesome 5** + **bootstrap-material-design** (`.btn-raised`). **Dark by default** (`bootstrap-darkroom` skin).
- Structural classes you should reuse for native look:
  - layout: `.container` / `.container-fluid`, `.row`, `.col-*`
  - cards/thumbs: `#thumbnails.row`, `.card`, `.card-thumbnail`, `.card-body`, `.card-title`
  - buttons: `.btn .btn-primary` (+ `.btn-raised`), groups `.btn-group`
  - nav: `.nav`, `.nav-item`, `.nav-link`, `.navbar`, `.dropdown-menu`, `.dropdown-header`
  - forms: `.form-group`, `.form-control`, `.form-inline`, `.col-form-label`
  - icons: `<i class="fas fa-… fa-fw"></i>`
- **Does NOT auto-style unknown plugins.** `template/_plugin_fixes_js.tpl` jQuery-rewrites only *named* plugins (openstreetmap, rv_gmaps, oAuth, ProtectedAlbums, user_custom_fields, BatchDownloader, User Collections). `scss/theme/_plugin-fixes.scss` only thinly styles `.pwg-icon` and **`.pwg-button-text { display:none }`**.
  → Consequence: a core `.pwg-button` shows **icon only, no label** in darkroom. Always set a `title`/`aria-label`. For richer UI, emit Bootstrap markup yourself (guarded by the theme check).

## 4b. Toolbar buttons — where they land, and the position fix (IMPORTANT)
`add_index_button()` / `add_picture_button()` feed the `$PLUGIN_*_ACTIONS` template slot. **That slot sits in a different container per theme**, so one markup does NOT fit all — this is the #1 cause of a "button positioned wrong in bootstrap" bug:

| Theme | `$PLUGIN_PICTURE_ACTIONS` lands in | Sibling markup | Your button must be |
|---|---|---|---|
| **default** | `<div id="imageToolBar">` | bare `<a class="pwg-state-default pwg-button">` | a **bare `.pwg-button` anchor** (no `<li>`) |
| **modus** | same `#imageToolBar` (styles `#imageToolBar .pwg-button`) | same | a **bare `.pwg-button` anchor** |
| **bootstrap_darkroom** | **inside `<ul class="navbar-nav">`** (`picture_nav.tpl`) | `<li class="nav-item"><a class="nav-link"><i class="fas …">` | an **`<li class="nav-item">` with `<a class="nav-link">`** |

→ A bare `.pwg-button` anchor dropped into darkroom's `navbar-nav` `<ul>` is not an `<li>`, so it breaks the flex row and floats/mis-positions. **Branch the markup by theme.** Index buttons (`$PLUGIN_INDEX_ACTIONS`) follow the same rule (default `#…Buttons`/toolbar vs darkroom `navbar-nav`).

```php
function yourplugin_toolbar_button($url, $label, $title)
{
  global $user;
  $u = htmlspecialchars($url,   ENT_QUOTES, get_pwg_charset());
  $t = htmlspecialchars($title, ENT_QUOTES, get_pwg_charset());
  $l = htmlspecialchars($label, ENT_QUOTES, get_pwg_charset());
  if (isset($user['theme']) && $user['theme'] === 'bootstrap_darkroom')
  {
    // matches darkroom's navbar-nav <li>/<a.nav-link>/FontAwesome
    return '<li class="nav-item"><a class="nav-link" href="'.$u.'" title="'.$t.'" rel="nofollow">'
         .'<i class="fas fa-clone fa-fw" aria-hidden="true"></i>'
         .'<span class="pwg-button-text ml-2">'.$l.'</span></a></li>';
  }
  // default + modus: bare .pwg-button anchor in #imageToolBar
  return '<a class="pwg-state-default pwg-button" href="'.$u.'" title="'.$t.'" rel="nofollow">'
       .'<span class="pwg-icon yourplugin-icon" aria-hidden="true">⤡</span>'
       .'<span class="pwg-button-text">'.$l.'</span></a>';
}
```
Always set `title` (darkroom hides `.pwg-button-text` on non-nav buttons). FontAwesome (`fas fa-*`) is available under darkroom only — don't emit it in the default/modus branch.

## 5. Detecting the theme & branching (PHP)
```php
global $user;
$theme = isset($user['theme']) ? $user['theme'] : '';
$is_bootstrap = ($theme === 'bootstrap_darkroom');
$is_modus     = ($theme === 'modus');
// expose to the template:
$template->assign('YOURPLUGIN_THEME', $theme);
$template->assign('YOURPLUGIN_IS_BOOTSTRAP', $is_bootstrap);
```
In the template, add a modifier class so CSS can adapt without depending on theme internals:
```smarty
<div id="yourPluginBlock" class="yourplugin{if $YOURPLUGIN_IS_BOOTSTRAP} yourplugin--bootstrap{elseif $YOURPLUGIN_THEME == 'modus'} yourplugin--modus{/if}">
```

## 6. Color rules that survive every skin
- Backgrounds: `transparent` or `rgba(127,127,127,.12)` (neutral, works on light+dark).
- Text: `color: inherit;` borders/icons: `currentColor` or `rgba(127,127,127,.35)`.
- Don't assume a white card behind you. If you need contrast, use a translucent overlay, not a solid color.
- Test on a **modus dark skin** and on **darkroom** — those break naive light-only CSS fastest.

## 7. Admin settings page (admin theme — NOT the gallery theme)
The plugin config page renders in `admin/themes/{default,clear,roma}`. Canonical markup (from core `configuration_*.tpl`):
```smarty
<form method="post" action="{$F_ACTION}" class="properties">
  <fieldset>
    <legend>{'Section'|@translate}</legend>
    <ul>
      <li>
        <label class="font-checkbox">
          <span class="icon-check"></span>
          <input type="checkbox" name="opt" {if $cfg.opt}checked="checked"{/if}> {'Option'|@translate}
        </label>
      </li>
      <li>
        <label>{'Mode'|@translate}
          <select name="mode">…</select>
        </label>
      </li>
    </ul>
  </fieldset>
  <p class="formButtons"><input class="submit" type="submit" name="submit" value="{'Save Settings'|@translate}"></p>
  {* pwg token hidden field — see add-admin-ui *}
</form>
```
- Feedback: push to `$page['infos']` / `$page['errors']` in PHP; the admin theme renders them.
- Icons are the **admin** icon font (`.icon-cog`, `.icon-check`), not FontAwesome/fontello.
- Tabs: `admin/include/tabsheet.class.php`. CSR­F: pwg token (see `04-security.md`).
- Don't pull Bootstrap/modus classes into admin templates — they aren't loaded there.
