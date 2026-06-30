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
- Gallery buttons: `add_picture_button()` / `add_index_button()` — **generate the HTML per theme**. Their slot sits in `#imageToolBar` (default/modus) vs a Bootstrap `<ul class="navbar-nav">` (darkroom); a bare `.pwg-button` anchor mis-positions in darkroom. Branch: bare anchor for default/modus, `<li class="nav-item"><a class="nav-link">` for darkroom (helper + slot table in `reference/THEMES.md` §4b). **Caveat:** on the photo page **modus collapses these buttons behind a "…" (more-actions) toggle** — so don't build a flow that depends on a toolbar button always being visible (see below).
- Respect `prefers-reduced-motion`; keep markup accessible (real `<button>`, `aria-label`, visible focus).

## Theme compatibility — MANDATORY for gallery UI
**Principle: own your UI, integrate at the edges — and keep it simple.** A plugin's UI is yours — ship its own scoped CSS *and* JS so it's **self-contained and works on any theme the client runs**; adapt only at **integration touchpoints** (toolbar buttons; where your block attaches). **Guarantee it on the two most-used themes: `modus` and `bootstrap_darkroom`.** Owning your UI is what prevents the "works in one theme but not both" bug — that comes from coupling to one theme's DOM/CSS/JS.

<!-- **Simplicity is a compatibility feature.** Lesson from three real builds: the leanest gallery (one button → one action, small self-contained CSS, no theme-branching beyond the button) worked on *every* theme; the most elaborate one (a multi-step selection tray + per-theme branching + a large stylesheet) broke on **modus**. Every extra step and every extra dependency on theme chrome is another thing a theme can break. Prefer a single robust action over a multi-step flow; the fewer toolbar buttons / theme touchpoints you rely on, the more portable you are. Concretely: **modus's photo-page prefilter collapses toolbar buttons behind a "…" toggle**, so if your feature *requires* clicking a `add_picture_button` (e.g. to populate a panel), it can look dead on modus — put the primary entry point inside your own self-contained element, or make the one button do the whole job. **Build gallery UI by hand from this guidance + `theme-compat`; there is deliberately no gallery scaffold.** -->

The two gallery themes are mutually incompatible systems (and the **admin settings page is a different theme system entirely**):
- **Gallery output**, themed by `$user['theme']`: **modus** reuses core `default` markup (`#imageToolBar`/`#thumbnails`/`.content`) with many **dark skins**, and loads **no Bootstrap/FontAwesome**; **bootstrap_darkroom** is its own Bootstrap 4 set (`.navbar-nav`/`.card`/`.container`), dark by default, loads **no fontello pwg-icons**, and **does not style plugin `.pwg-button`**. → keep your UI self-contained + legible on light *and* dark; depend on no theme-provided library; detect the theme and branch **only** the injected markup; give every button a visible label/`title`.
- **Admin settings page** is styled by the **admin theme** (`default`/`clear`/`roma`), NOT modus/darkroom → use the modern admin idioms (`.properties` form in `#configContent`, `fieldset` + colored `rotate-element` legend icon, `.font-checkbox` switches, a fixed `.savebar-footer` with `.buttonLike` + `.badge.info-message`), not Bootstrap. Reuse the admin-theme classes verbatim — ship no admin CSS. Full extracted catalogue: **`reference/ADMIN_UI.md`** (from the core Configuration→Search page).

Lean on the references: **`reference/theme-compat.md`** (the cross-theme rules) + **`reference/THEMES.md`** (class tables) for gallery UI, and **`workflows/add-admin-ui.md`** (admin-native settings page) for the config screen. Gallery output you build by hand — small and self-contained. Always test gallery UI under `default`, `modus` (a dark skin) and `bootstrap_darkroom`.

> Reference: `reference/theme-compat.md`, `PIWIGO_CONVENTIONS.md` §9–11.
