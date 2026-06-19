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
- Bundle/minify via `{combine_css path=$YOUR_PLUGIN_PATH|@cat:"template/style.css"}` and `{combine_script id=… path=…}` → cached in `_data/combined/`.
- Inline JS only inside `{footer_script}{literal}…{/literal}{/footer_script}`.
- Scope CSS under a plugin-specific id/class (e.g. `#theYourPluginPage`). Inherit theme styling; don't break light/dark themes (`modus`, `bootstrap_darkroom`).
- Gallery buttons: `add_picture_button()` / `add_index_button()`.
- Respect `prefers-reduced-motion`; keep markup accessible (real `<button>`, `aria-label`, visible focus).

> Reference: `PIWIGO_CONVENTIONS.md` §9–11.
