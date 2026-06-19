---
name: verify-plugin
description: Verify a Piwigo plugin before calling it done — runs the php -l lint sweep, then (optionally) a reversible DB-backed smoke test that activates the plugin, curls a page, greps for errors, and rolls back. Use after any change, before committing, or whenever the user says "verify", "test the plugin", "is it done", "lint", or "smoke test".
---

# Verify a plugin

The definition of done lives in `guidelines/11-testing.md`. This skill runs the mechanical parts. There is **no mock DB layer** — anything touching queries/storage needs a real MariaDB/MySQL with seeded mock data.

## 1. Lint (always — turnkey)
```bash
bash .claude/skills/verify-plugin/lint.sh
```
`php -l` across every `*.php` (excludes `.git/`). Must report zero syntax errors. If `php` isn't on PATH but Piwigo runs in Docker, run inside the container, e.g.:
```bash
docker exec <php_container> sh -c 'find /…/plugins/<id> -name "*.php" -exec php -l {} \;'
```

## 2. Manual checklist (in a running Piwigo)
- Drop the folder in `<piwigo>/plugins/`, activate via **Admin → Plugins** (runs `install`/`activate`).
- Exercise the feature with realistic input. Confirm **no PHP notices** and **no JS console errors**.
- Check BOTH permission paths: an allowed user AND a forbidden one (a private photo must stay hidden).

## 3. DB-backed smoke test (reversible — needs a real DB)
Use when you want to hit a page without clicking through the admin UI. The script INSERTs a `piwigo_plugins` row, curls the page, greps the response for error keywords, then DELETEs the row — and **refuses to clobber an already-active plugin**.

```bash
PIWIGO_URL="http://localhost:8001" \
PLUGIN_ID="<id>" \
PLUGIN_VERSION="auto" \
PAGE_PATH="index.php?/category/…"  \
DB_EXEC='docker exec <db_container> mariadb -u<user> -p<pass> <db>' \
bash .claude/skills/verify-plugin/smoke-test.sh
```
- `DB_EXEC` is the full command prefix that takes SQL on stdin / via `-e`. Creds come from `<piwigo>/local/config/database.inc.php` (`$conf['db_*']`, prefix default `piwigo_`).
- Always reverts. If it aborts mid-run, manually `DELETE FROM piwigo_plugins WHERE id='<id>';` to restore state.
- This proves the page loads without fatals — it is NOT a substitute for the manual permission test.

## 4. Storage verification (when the plugin stores anything)
After install/config, confirm your rows exist; after uninstall, confirm they're gone:
```sql
SELECT value FROM piwigo_config WHERE param='<id>';      -- your config blob
-- + any of your own tables; then re-check after uninstall (must be empty)
```

## Done when
- [ ] `lint.sh` clean; no PHP notices; no JS console errors.
- [ ] install → activate → configure → uninstall leaves ONLY `$conf['<id>']` behind.
- [ ] allowed + forbidden permission paths both checked.
- [ ] `en_UK` + `fr_FR` strings present for any new UI text.

> Reference: `guidelines/11-testing.md`, `guidelines/03-database.md`.
