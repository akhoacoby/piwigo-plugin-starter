# Modern admin config-page reference (Configuration → Search)

The cleanest, most up-to-date admin settings UI in current Piwigo is
`admin.php?page=configuration&section=search`
(`admin/themes/default/template/configuration_search.tpl`). Match it.

**All classes below are provided by the ADMIN theme** (`admin/themes/default/theme.css`
+ `css/components/general.css`), present in `default`/`clear`/`roma`. Your plugin
template just **reuses them — ship no admin CSS.** (Gallery themes like modus/darkroom
are irrelevant here; the admin page is never styled by them.)

---

## Page skeleton (copy this shape)
```smarty
<form method="post" action="{$F_ACTION}" class="properties">
<div id="configContent">                          {* reuse this id — see "free wins" below *}

  <fieldset class="yourpluginConf">
    <legend><span class="icon-equalizer icon-blue rotate-element"></span>{'Filters'|translate}</legend>
    <ul>
      <li>
        <label class="font-checkbox">
          <span class="icon-check"></span>
          <input type="checkbox" name="opt" {if $cfg.opt}checked="checked"{/if}> {'Option'|translate}
        </label>
        <span class="icon-help-circled tiptip" title="{'Helps the user'|translate}" style="cursor:help"></span>
      </li>
    </ul>
  </fieldset>

</div>{* #configContent *}

<div class="savebar-footer">
  <div class="savebar-footer-start"></div>
  <div class="savebar-footer-end">
{if isset($save_success)}
    <div class="savebar-footer-block">
      <div class="badge info-message"><i class="icon-ok"></i>{$save_success}</div>
    </div>
{/if}
    <div class="savebar-footer-block">
      <button class="buttonLike" type="submit" name="yourplugin_save"{if $isWebmaster != 1} disabled{/if}>
        <i class="icon-floppy"></i> {'Save Settings'|@translate}
      </button>
    </div>
  </div>
  <input type="hidden" name="pwg_token" value="{$PWG_TOKEN}">
</div>
</form>
```

## Three "free wins" — don't reinvent them
1. **`id="configContent"`** — core CSS adds `padding-bottom: 62px` to `#configContent` so the fixed save bar never hides your last field, and styles `#configContent legend` (negative margin so the legend hangs into the gutter). Reuse the id and you inherit both.
2. **`.savebar-footer`** is `position: fixed; bottom: 0; width: 100%` — a persistent bottom save bar (the modern replacement for an inline `.formButtons` row). `.savebar-footer-start` is left-offset for the admin sidebar; the **submit lives in `.savebar-footer-end`**.
3. **Success badge must sit inside `.savebar-footer-block`** — `.info-message` is `display:none` by default; the rule `.savebar-footer-block .badge { display:block }` is what reveals it. Put the badge anywhere else and it stays hidden.

## Class catalogue (what to use, with the real CSS)

### Save button — `.buttonLike` (replaces `input.submit`)
```css
.buttonLike, input[type=submit] { font-size:12px; border:none; padding:13px 20px;
  font-weight:bold; color:#493C21; background-color:#FFA646; transition:all 125ms ease-out; }
.buttonLike:hover { cursor:pointer; background-color:#ff7700; text-decoration:none; }
```
- Use a `<button class="buttonLike">` with a leading fontello icon: `<i class="icon-floppy"></i>`.
- **Gate writes**: core disables it for non-webmasters — `{if $isWebmaster != 1}disabled{/if}` (assign `$isWebmaster`).

### Inline feedback — `.badge.info-message` / `.info-warning` / `.info-error`
```css
.info-message,.info-warning,.info-error { height:35px; border-radius:20px; display:flex;
  font-weight:bold; padding:0 10px 0 0; }
.info-message { background-color:#c2f5c2; color:#0a0; }   /* green success */
.info-warning { background-color:#ffdd99; color:#ee8800; }
.info-error   { background-color:#ffd5dc; color:#f22; }
.savebar-footer-block .badge { display:block; border-radius:15px; padding:5px 10px;
  font-size:12px; font-weight:700; }
```
- Success path: assign `$save_success` (a translated string) → render the badge in the savebar. This is the modern, in-place confirmation. (`$page['infos']`/`$page['errors']` still render at the top of the admin page and are fine for errors.)

### Fieldset + colored, animated legend icon
```css
FIELDSET { padding:1em; margin:1em; }
#configContent legend { padding-left:0; margin-left:-20px; }
.rotate-element { display:inline-block; transform: rotate(90deg); }
```
- Pattern: `<legend><span class="icon-<name> icon-<color> rotate-element"></span>{label}</legend>`.
- Colored helpers used by core: `icon-blue`, `icon-green`, `icon-purple`, `icon-yellow` (theme-provided tints for the fontello legend glyph). `rotate-element` turns the equalizer glyph 90°.

### Checkbox / radio switch — `.font-checkbox` + `.icon-check`
```css
.font-checkbox input[type=checkbox], .font-checkbox input[type=radio] { display:none; }
.font-checkbox [class*=icon-check]:before { font-size:145%; margin-right:5px; }
```
- Markup: `<label class="font-checkbox"><span class="icon-check"></span><input type="checkbox" …> {label}</label>`. The real checkbox is hidden; the fontello check glyph is the visible control.
- Nested/dependent option: wrap it in `<div class="sub-setting">` and toggle visibility from the parent checkbox (core shows/hides with a tiny `{footer_script}`).
- Bold labels come free: `#configContent label:not(.no-bold) { font-weight:bold }` — add `.no-bold` for sub-labels.

### Help tooltip — `.tiptip`
`<span class="icon-help-circled tiptip" title="…" style="cursor:help"></span>` — core wires `.tiptip` to a hover tooltip from the `title`.

### Chip toggle (optional, for compact multi-toggles) — `.filter-manager-options-container`
```css
.filter-manager-options-container { display:inline-block; border:1px solid #777;
  border-radius:20px; padding:4px 10px; cursor:pointer; margin:0 7.5px 7.5px 0; font-size:11px; }
.mcs-icon-options::before { margin-right:5px; }
```
- A `<label class="filter-manager-options-container">` wraps a `hidden` checkbox + an icon’d `<span class="mcs-icon-options gallery-icon-…">`. JS flips a `selected-filter-container` class on the label for the on-state (style that class yourself if you want a filled look — core only adds the class).
- `gallery-icon-*` glyphs need `{combine_css path="themes/default/vendor/fontello/css/gallery-icon.css" order=-10}` (as the search page does).

### Grid row (optional) — `.filters-grid`
```css
.filters-grid { display:grid; grid-template-columns:200px 150px 25px; }
```
- For aligning label + control + trailing icon in a row. Use a plain `<li>` if you don't need columns.

## Rules of thumb
- Reuse `id="configContent"`, `.savebar-footer*`, `.buttonLike`, `.font-checkbox`, `.badge.info-message` **verbatim** — no custom admin CSS, no Bootstrap/modus.
- Icons are **fontello admin glyphs** (`icon-floppy`, `icon-ok`, `icon-cog`, `icon-equalizer`, `icon-help-circled`) and the `gallery-icon-*` set — never FontAwesome.
- Keep the pwg token hidden input inside the form; `check_pwg_token()` in the handler.
- Escape every dynamic value (`{$x|@escape}`) — admin Smarty auto-escape is OFF.

> Source: `admin/themes/default/template/configuration_search.tpl`, `theme.css`, `css/components/general.css`.
