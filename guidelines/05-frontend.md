# Front-end: Templates, CSS, Output

Engine: **Smarty 5.5.2** via the `$template` object. Logic in PHP, markup in `.tpl`. No inline PHP in templates.

## Output escaping (CRITICAL — auto-escape is OFF, `escape_html=false`)
Escape EVERY dynamic value at the point of output:
- HTML text: `{$x|@escape}` or `{$x|escape:'html'}`
- inside `<script>`: `{$x|escape:'javascript'}`
- URL params: `{$x|escape:'url'}`
- In PHP that emits markup: `htmlspecialchars($v, ENT_QUOTES, get_pwg_charset())`
- `{'label'|@translate}` is NOT escaped — escape separately if it can carry data.
- Escape especially: photo/album names, file names, comments, search terms, EXIF, anything reflected from `$_GET`/`$_POST`.

## Templates
- Render: PHP `set_filename($handle, $tpl)` then `assign_var_from_handle('ADMIN_CONTENT', $handle)` (admin) or `pparse($handle)` (public).
- Expose data with `$template->assign(...)` / `append(...)`.
- Translate UI strings with `{'…'|@translate}` (see `09-i18n.md`).

## CSS / JS
- Bundle/minify via `{combine_css path=$YOUR_PLUGIN_PATH|@cat:'template/public.css'}` and `{combine_script id=… path=…}` → cached in `_data/combined/`.
- Inline JS only inside `{footer_script}{literal}…{/literal}{/footer_script}`.
- Scope CSS under a plugin-specific id/class (e.g. `#theYourPluginPage`). **Inherit colors** (`color: inherit`, `currentColor`, translucent `rgba` surfaces) — never hardcode `#fff`/`#000`.
- Gallery buttons: `add_picture_button()` / `add_index_button()` — **generate the HTML per theme**. Their slot sits in `#imageToolBar` (default/modus) vs a Bootstrap `<ul class="navbar-nav">` (darkroom); a bare `.pwg-button` anchor mis-positions in darkroom. Branch: bare anchor for default/modus, `<li class="nav-item"><a class="nav-link">` for darkroom (helper in `add-gallery-ui`, details in `theme-compat` THEMES.md §4b).
- Respect `prefers-reduced-motion`; keep markup accessible (real `<button>`, `aria-label`, visible focus).

## Theme compatibility (modus + bootstrap_darkroom) — MANDATORY for gallery UI
The two most-used gallery themes render very differently, and the **admin settings page uses a different theme system entirely**:
- **Gallery output** is styled by the active gallery theme (`$user['theme']`): **modus** reskins core markup and has many **dark skins**; **bootstrap_darkroom** is Bootstrap 4 + FontAwesome, dark by default, and **does not auto-style unknown plugins** (it even hides `.pwg-button-text`). → use theme-neutral, color-inheriting, scoped CSS; detect the theme and branch only when needed; give every button a visible label/`title`.
- **Admin settings page** is styled by the **admin theme** (`default`/`clear`/`roma`), NOT modus/darkroom → use admin idioms (`.properties` form, `fieldset`/`ul`/`li`, `input.submit`, `.infos`/`.errors`), not Bootstrap.

Don't hand-roll this — use the skills: **`theme-compat`** (knowledge + `THEMES.md`), **`add-gallery-ui`** (theme-neutral public block + CSS), **`add-admin-ui`** (admin-native settings page). Always test gallery UI under `default`, `modus` (a dark skin) and `bootstrap_darkroom`.

> Reference: `theme-compat` skill, `PIWIGO_CONVENTIONS.md` §9–11.
