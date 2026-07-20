# Workflow: Add gallery (public) UI

**Read `reference/theme-compat.md` first — it is the law for everything visual here.** There is deliberately **no gallery scaffold** in this starter (see `AGENTS.md`): elaborate copy-paste gallery UI is exactly what breaks across themes. This workflow only catalogues the **wiring** — the hooks that attach your UI to the gallery — with working examples in the skeleton demo (`reference/SKELETON.md`, `skeleton/include/public_events.inc.php`, `skeleton/include/menu_events.class.php`).

All registrations go in `main.inc.php` inside the `else` of `if (defined('IN_ADMIN'))` (public side), lazy-including your public events file. Menu-block handlers register **outside** that split (the Menus admin screen needs them too).

## Pick the integration point

### Button on album / photo pages
```php
add_event_handler('loc_end_index',   '<plugin_id>_add_button', 50, $public_file);
add_event_handler('loc_end_picture', '<plugin_id>_add_button', 50, $public_file);
```
In the handler, parse your own small `.tpl` and hand it to the theme's slot — never inject positioned markup:
```php
$button = $template->parse('<plugin_id>_button', true);
if (script_basename() == 'index') $template->add_index_button($button, BUTTONS_RANK_NEUTRAL);
else                              $template->add_picture_button($button, BUTTONS_RANK_NEUTRAL);
```
**Don't assume the button stays visible** — modus collapses photo-toolbar buttons behind a "…" toggle (`reference/THEMES.md`). Critical actions need a fallback surface.

### Public page (virtual section)
Claim a section in `loc_end_section_init`, render it in `loc_end_index` — no standalone front-controller file:
```php
function <plugin_id>_section_init()
{
  global $tokens, $page;
  if ($tokens[0] == '<plugin_id>')
  {
    $page['section'] = '<plugin_id>';
    $page['title'] = l10n('My page');          // section_title = breadcrumb HTML
    $page['body_id'] = 'the<CamelId>Page';
    $page['is_external'] = true;
  }
}
```
Then in the `loc_end_index` handler: `if ($page['section'] == '<plugin_id>') include(<UPPER_ID>_PATH.'include/page.inc.php');` — that include assigns + parses your own template.

### Menu block
Class-method handlers in `skeleton/include/menu_events.class.php` show both cases:
- **New block**: `blockmanager_register_blocks` (register a `RegisteredBlock` every request — the Menus screen needs it) + `blockmanager_apply` (fill + assign your `.tpl`).
- **Item inside an existing menu**: `blockmanager_apply` only — use priority `EVENT_HANDLER_PRIORITY_NEUTRAL+10` for Advanced Menu Manager compatibility.

### Photo-page info field (template prefilter)
`loc_end_picture` → `$template->set_prefilter('picture', '<plugin_id>_prefilter')`; the prefilter `str_replace`s your fragment next to a **stable core anchor** in the template source and returns the content. Keep the anchor minimal — prefilters are the most theme-fragile option; prefer a button or your own section when possible.

### Profile page block
`load_profile_in_template` → append a block array to `$template->append('PLUGINS_PROFILE', …)`; save via `save_profile_from_post`. (The skeleton's save handler echoes debug output — don't copy that part.)

## Rules (enforced by `reference/theme-compat.md` — read it)
- **Own your UI**: one scoped container (`#<plugin_id>-root`), your own CSS+JS shipped by the plugin, zero dependence on theme classes/libraries.
- **Integrate at the edges only**: the hooks above are the touchpoints; everything inside the container is yours.
- **Keep it simple** — fewer steps and less chrome survive more themes. Must work on **modus + bootstrap_darkroom**.
- Escape ALL output; strings via `{'…'|@translate}` in en_UK + fr_FR.

## Verify
Walk the must-pass checklist in `reference/theme-compat.md` on **modus and bootstrap_darkroom** (button visible or reachable, page renders, dark + light, mobile width). Then `workflows/verify-plugin.md`.

> Reference: `reference/theme-compat.md` (canonical), `reference/THEMES.md`, `reference/SKELETON.md`, `guidelines/05-frontend.md`, `guidelines/06-hooks.md`.
