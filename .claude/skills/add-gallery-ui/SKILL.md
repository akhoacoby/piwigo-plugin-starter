---
name: add-gallery-ui
description: Scaffold a plugin's public/gallery-facing UI (template + scoped CSS/JS wired through a loc_* hook) that renders natively in the default, modus, and bootstrap_darkroom themes. Use when the user wants front-end output on the gallery — a button, a panel on the album/photo page, or a custom page. Read the theme-compat skill first.
---

# Add gallery (public) UI

Builds front-end output that survives modus (incl. dark skins) and bootstrap_darkroom. **Read `theme-compat` (SKILL.md + THEMES.md) first** — it explains why the markup/CSS below is shaped this way. Output goes through a gallery hook (`06-hooks.md`), templates live under the plugin's `template/`, escaping rules in `05-frontend.md`.

## Steps

### 1. Copy the starter assets into your plugin
From this skill folder into your plugin (rename tokens as you go):
```bash
cp .claude/skills/add-gallery-ui/assets/public.css  <plugin>/template/public.css
cp .claude/skills/add-gallery-ui/assets/block.tpl   <plugin>/template/<plugin_id>_block.tpl
```
Then replace in both files: `yourplugin`/`#yourPluginBlock` → your scoped names, `YOURPLUGIN_` → `<UPPER_ID>_`.

### 2. Detect the theme in PHP (so CSS can adapt)
In your handler (the include loaded by `init`/`loc_*`):
```php
global $user, $template;
$theme = isset($user['theme']) ? $user['theme'] : '';
$template->assign(array(
  '<UPPER_ID>_PATH'         => <UPPER_ID>_PATH,            // for combine_css path
  '<UPPER_ID>_THEME'        => $theme,
  '<UPPER_ID>_IS_BOOTSTRAP' => ($theme === 'bootstrap_darkroom'),
  '<UPPER_ID>_ITEMS'        => $items,                     // your data
));
```

### 3. Emit the block from a gallery hook
- A **toolbar button** → use core helpers `add_index_button($html, $rank)` / `add_picture_button($html, $rank)`, but **generate the HTML per theme** — the `$PLUGIN_*_ACTIONS` slot lands in `#imageToolBar` (default/modus) vs a Bootstrap `<ul class="navbar-nav">` (darkroom), so a single markup mis-positions. Copy the ready helper:
  ```bash
  cp .claude/skills/add-gallery-ui/assets/toolbar_button.php <plugin>/include/toolbar_button.php
  ```
  It returns a bare `.pwg-button` anchor for default/modus and an `<li class="nav-item"><a class="nav-link">` for darkroom, with `title` always set (darkroom hides `.pwg-button-text`). Details: `theme-compat` THEMES.md §4b.
- A **panel/section** → assign + `pparse()` your handle from `loc_end_index` / `loc_end_picture`, or claim a custom page in `loc_end_section_init` (see `06-hooks.md`).

### 4. Load assets correctly
- CSS via `{combine_css path=$<UPPER_ID>_PATH|@cat:'template/public.css'}` (the asset already does this).
- JS via `{combine_script id='<plugin_id>' path=…}`; inline JS only inside `{footer_script}{literal}…{/literal}{/footer_script}`.

## The compatibility rules (baked into the assets — keep them)
- **Inherit colors** (`color: inherit`, `currentColor`, translucent `rgba` surfaces). No hardcoded `#fff`/`#000` — that breaks modus dark skins and darkroom.
- **Scope everything** under one id/class (`#yourPluginBlock`). Never style bare tags globally.
- **Visible button labels** (don't rely on `.pwg-button-text`, hidden in darkroom).
- Add Bootstrap classes (`btn btn-primary`, `card`, `fas fa-*`) **only behind the `IS_BOOTSTRAP` check** so they don't leak into default/modus.
- Accessible: real `<button>`/`<a>`, visible focus, `prefers-reduced-motion` honored.

## Verify (do this — see theme-compat checklist)
Switch the gallery theme in **Admin → Configuration → Themes** (or per-user) and load the page under:
- `default`, `modus` (pick a **dark** skin), `bootstrap_darkroom`.
Confirm: legible on dark, no clipped/invisible labels, **toolbar buttons sit in the right place under darkroom** (the classic bug — verify the button is an `<li class="nav-item">` there, not a stray anchor), layout not broken, no JS console errors. Then run the `verify-plugin` skill.

> Reference: `theme-compat` skill, `guidelines/05-frontend.md`, `guidelines/06-hooks.md`.
