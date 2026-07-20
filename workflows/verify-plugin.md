# Workflow: Verify a plugin

The definition of done lives in `guidelines/11-testing.md`. This workflow runs the mechanical parts. There is **no mock DB layer** — anything touching queries/storage needs a real MariaDB/MySQL with seeded mock data.


## 1. Manual checklist (in a running Piwigo)
- **Lint first**: run `php -l` over every `.php` file in the plugin — zero syntax errors before anything else (if PHP only lives in a container, lint inside it).
- Drop the folder in `<piwigo>/plugins/`, activate via **Admin → Plugins** (runs `install`/`activate`).
- Exercise the feature with realistic input. Confirm **no PHP notices** and **no JS console errors**.
- Check BOTH permission paths: an allowed user AND a forbidden one (a private photo must stay hidden).
- **Gallery UI must pass on both priority themes** (`reference/theme-compat.md`): load it under **`modus` (a dark skin)** and **`bootstrap_darkroom`**. In DevTools confirm your CSS/JS is actually loaded and your styling is in effect, the block is legible/self-consistent, and toolbar buttons sit right (`<li class="nav-item">` in darkroom, `.pwg-button` in modus). "Works in one not both" → triage in `reference/theme-compat.md`.

## 2. DB-backed smoke test (reversible — needs a real DB)
Use when you want to hit a page without clicking through the admin UI.

1. **Guard**: `SELECT state FROM piwigo_plugins WHERE id='<id>';` — if a row already exists, do NOT insert/delete; test as-is and skip step 5.
2. **Activate**: `INSERT INTO piwigo_plugins (id, state, version) VALUES ('<id>', 'active', 'auto');`
3. **Hit the page**: `curl -sS "<PIWIGO_URL>/<page_path>"` (e.g. `index.php?/category/…` or the plugin's admin page).
4. **Scan the response** for `Fatal error|Parse error|Warning:|Hacking attempt` — any hit fails the test.
5. **Revert — always, even on failure**: `DELETE FROM piwigo_plugins WHERE id='<id>';`

This proves the page loads without fatals — it is NOT a substitute for the manual permission test.

## 3. Storage verification (when the plugin stores anything)
After install/config, confirm your rows exist; after uninstall, confirm they're gone:
```sql
SELECT value FROM piwigo_config WHERE param='<id>';      -- your config blob
-- + any of your own tables; then re-check after uninstall (must be empty)
```

## Done when
- [ ] `php -l` sweep clean; no PHP notices; no JS console errors.
- [ ] install → activate → configure → uninstall leaves ONLY `$conf['<id>']` behind.
- [ ] allowed + forbidden permission paths both checked.
- [ ] `en_UK` + `fr_FR` strings present for any new UI text.

> Reference: `guidelines/11-testing.md`, `guidelines/03-database.md`.
