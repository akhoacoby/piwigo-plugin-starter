---
name: theme-compat
description: Knowledge for making a Piwigo plugin's UI look native across the two most-used gallery themes (modus and bootstrap_darkroom) AND the admin themes. Read this BEFORE writing any front-end template/CSS or any admin settings page, and whenever the user mentions theme compatibility, dark mode, "looks broken in <theme>", buttons, layout, or styling. Pairs with the add-gallery-ui and add-admin-ui skills.
---

# Theme compatibility (modus + bootstrap_darkroom)

Full detail + concrete class/variable tables: **`THEMES.md`** in this folder. Read it before styling.

## The one distinction that trips everyone up
A Piwigo plugin renders into **two different theme systems**:
| Surface | Themed by | Compat target |
|---|---|---|
| **Gallery / public** output (your `loc_*` hooks, custom page) | the active **gallery theme** = `$user['theme']` (modus, bootstrap_darkroom, default, …) | this skill — modus **and** darkroom |
| **Admin settings page** (`admin.php?page=plugin-…`) | the **admin theme** (`default`/`clear`/`roma`) — independent of the gallery theme | the admin conventions in `add-admin-ui` |

So "make it work with modus and darkroom" applies to **gallery output only**. The settings page is styled by the admin theme regardless of which gallery theme is active — match admin conventions there, not Bootstrap/modus.

## How the two gallery themes differ (decides your markup)
- **modus** — reuses core `default` templates and reskins them with CSS (it has *no* `index.tpl`). Colors come from **skins**, many of them **dark** (`dark`, `dark_sky`, `glacier`, `neon_*`). It styles the **core button idiom**. → emit core markup, **inherit colors** (never hardcode bg/text).
- **bootstrap_darkroom** — its own full template set built on **Bootstrap 4 + FontAwesome 5**, **dark by default**. It does **NOT** auto-adapt unknown plugins (its `_plugin_fixes_js.tpl` only rewrites specific named plugins) and it sets `.pwg-button-text { display:none }` — so a core button's **text label disappears** here. → you must bring your own Bootstrap-friendly markup/styling or self-contained CSS.

## The strategy (what add-gallery-ui implements)
1. **Theme-neutral, self-contained, color-inheriting CSS**, scoped under one plugin id/class. Use `color: inherit`, `currentColor`, transparent/`rgba` backgrounds — legible on light *and* dark skins. Never hardcode `#fff`/`#000` backgrounds.
2. **Detect the theme in PHP** (`global $user; $user['theme']`) and add your own wrapper modifier class (`yourplugin--modus` / `yourplugin--bootstrap`) so you can apply small per-theme overrides without depending on theme internals.
3. **Toolbar buttons (`add_index_button` / `add_picture_button`):** the `$PLUGIN_*_ACTIONS` slot sits in a **different container per theme** — `#imageToolBar` (default/modus) vs a Bootstrap `<ul class="navbar-nav">` (darkroom). A bare `.pwg-button` anchor breaks darkroom's flex row → **mis-positioned button**. So **branch the markup by theme**: bare `.pwg-button` anchor for default/modus, `<li class="nav-item"><a class="nav-link"><i class="fas …">` for darkroom. Always set `title` (darkroom hides `.pwg-button-text`). Ready helper + the exact slot table: `THEMES.md` §4b.
4. **Bootstrap awareness:** under darkroom you may add `btn btn-primary`, `card`, `container/row/col-*`, and `<i class="fas …">` to inherit the active bootswatch skin — but guard it behind the theme check so those classes don't leak into default/modus.
5. **Degrade without JS**; respect `prefers-reduced-motion`; keep markup accessible (real `<button>`, visible focus).

## Quick checklist before you ship gallery UI
- [ ] No hardcoded text/background colors that break a dark skin.
- [ ] Looks right in **default**, **modus** (try a dark skin), **bootstrap_darkroom** — see `11-testing.md` for switching themes.
- [ ] Any core `.pwg-button` also has a `title`/`aria-label` (darkroom hides its text).
- [ ] All CSS scoped to your plugin; assets loaded via `combine_css`/`combine_script`.
- [ ] HTML output escaped (auto-escape is OFF — `05-frontend.md`).

> See also: `guidelines/05-frontend.md`, skills `add-gallery-ui` and `add-admin-ui`.
