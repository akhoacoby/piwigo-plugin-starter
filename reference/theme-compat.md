# Theme compatibility — own your UI, integrate at the edges

How to make a plugin's gallery UI work for the client on **any** theme — by owning a self-contained UI, keeping it simple, and adapting only at integration touchpoints — with guaranteed support for the two most-used themes, `modus` and `bootstrap_darkroom` (plus the admin themes). **Read this before writing any front-end template/CSS/JS or admin settings page.** This is knowledge for building gallery UI **by hand** — there is deliberately no gallery scaffold.

Deep reference + concrete class tables: **`THEMES.md`** (this `reference/` folder). Read it before styling.

## Guiding principle (read this first)
**A plugin's UI/UX is *yours*.** You design it and **ship its own CSS/JS**, and it should look and behave **consistently no matter which theme the client runs**. You are NOT trying to mimic each theme. Make the plugin **self-contained** so it works on *every* theme by default; only **integration touchpoints** — the few places your output is injected into the theme's own chrome — need per-theme handling. **Guarantee and test on the two most-used themes: `modus` and `bootstrap_darkroom`.** If it works there, it works for the client base.

This is the fix for the classic *"works in one theme but not both"* bug: that happens when the plugin is **coupled to one theme** instead of self-contained. Own your UI → it works in both.

**…and keep it simple — simplicity is a compatibility feature.**: Prefer **a single robust action over a multi-step flow**; the fewer toolbar buttons and theme touchpoints you depend on, the more portable you are. There is **no gallery scaffold** in this starter on purpose — build gallery UI by hand from these rules so it stays small.

## Self-contained (99% of your UI) vs touchpoints (the only per-theme part)
| | Self-contained — your block/page/dialog | Touchpoints — injected into theme chrome |
|---|---|---|
| What | Everything inside your root element | Toolbar buttons; where your block attaches |
| How | Ship scoped CSS/JS; set your own surface; depend on nothing | Detect `$user['theme']`, emit the right variant |
| Themes | Works on all by default | Must handle **modus** + **darkroom** explicitly |

So: style **inside** your own scoped root freely (that's the "customizable UI"); only adapt **at the seam** where you hand HTML to the theme.

## Rules that make it work everywhere
1. **Ship your own CSS *and* JS** (`combine_css` / `combine_script`). **Depend on nothing the theme might provide** — modus has **no Bootstrap/FontAwesome**; darkroom has **no fontello pwg-icons** and doesn't style plugin `.pwg-button`. If you need a library, a font, or an icon, bundle it.
2. **Scope every selector** under one root id/class (`#yourPluginBlock`). Never style bare tags or theme selectors; never let your CSS leak out.
3. **Be visually self-sufficient.** Your UI can look however you want, but it must stay **legible on light *and* dark** — set your own surface (a neutral/translucent panel) or inherit deliberately. Don't assume the theme's background is light or dark.
4. **Touchpoints only:** detect `global $user; $user['theme']` and branch **just** the injected markup. Add your own wrapper modifier class (`yourplugin--modus` / `yourplugin--bootstrap`) for small per-theme nudges — never reach into theme internals.
5. **Toolbar buttons** (`add_index_button`/`add_picture_button`): the slot lands in a different container per theme — `#imageToolBar` (default/modus) vs `<ul class="navbar-nav">` (darkroom). Bare `.pwg-button` anchor → mis-positioned in darkroom. Branch: bare `.pwg-button` for default/modus, `<li class="nav-item"><a class="nav-link"><i class="fas …">` for darkroom; always set `title`. Helper + slot table: `THEMES.md` §4b.
   - **Don't make a toolbar button load-bearing.** On the photo page **modus runs a prefilter that collapses the action buttons behind a "…" (more-actions) toggle** (`THEMES.md` §3/§4b). The button still exists, but it's hidden until the user expands the menu — so a feature that *requires* clicking your `add_picture_button` (e.g. to add items to a panel) can look broken on modus. Make the one button do the whole job, or put the primary entry point inside your **own** self-contained element rather than the theme toolbar.
6. **Custom page / injected block:** don't assume the theme's wrapper width or background. Give your block its own width and self-sufficient styling.
7. Degrade without JS; respect `prefers-reduced-motion`; accessible markup (real `<button>`, visible focus).

## "Works in one theme but not both?" — quick triage
Open the failing theme, View Source / DevTools:
- **Your CSS/JS file isn't loaded at all** → wiring: not using `combine_css`/`combine_script`, or asset injected after `<head>` flush. Fix the loading.
- **Loaded but ignored** → your selectors target the *other* theme's DOM. Grep your plugin: `#imageToolBar`/`#thumbnails`/`.content` are **modus/default-only**; `.btn`/`.card`/`.container`/`data-toggle`/`fas ` are **darkroom-only**. Move that styling inside your own scoped root, or guard it behind the theme check.
- **Button is the only thing wrong** (missing label / wrong place) → touchpoint #5 (darkroom hides `.pwg-button-text`; needs the nav-item variant).
- **Feature looks dead on modus, fine on darkroom, and it's driven by a photo-page button** → modus's prefilter has tucked your `add_picture_button` into the "…" more-actions menu (rule #5). The user never sees it, so nothing happens. Don't depend on that button being visible — fold the action into your own element, or make a single self-sufficient button.
- **JS does nothing in modus** → you depended on Bootstrap/jQuery-plugin JS that only darkroom loads. Bundle your own.
- **Detection always picks one branch** → you read the wrong source. Use `$user['theme']`, not `$conf['default_theme']` (that ignores per-user theme).

## Admin settings page — different system, don't confuse it
The plugin config page is styled by the **admin theme** (`default`/`clear`/`roma`), **never** by modus/darkroom. Match admin conventions there — follow `workflows/add-admin-ui.md` + `reference/ADMIN_UI.md`.

## Must-pass checklist before you ship gallery UI
- [ ] Plugin ships its own scoped CSS **and** JS; depends on no theme-provided library/font/icon.
- [ ] All selectors scoped under your root; nothing targets `#imageToolBar`/`.card`/etc. outside a theme branch.
- [ ] Legible on **modus light**, **modus dark skin**, and **bootstrap_darkroom** — actually load the page in all three (`guidelines/11-testing.md` for switching themes).
- [ ] Toolbar buttons correct in both modus and darkroom (right place, visible label/`title`).
- [ ] HTML output escaped (auto-escape is OFF — `guidelines/05-frontend.md`).

> See also: `guidelines/05-frontend.md` (build gallery UI by hand), `reference/THEMES.md` (class tables), and `workflows/add-admin-ui.md` for the settings page.
