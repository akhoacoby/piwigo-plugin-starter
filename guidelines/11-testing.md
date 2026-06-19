# Testing & Verification

No bundled unit-test harness for plugins. Verify with **lint + manual + smoke** tests, run against a **real MariaDB/MySQL** for anything that touches queries or storage. Build iteratively: get minimal functionality working before adding complexity.

## Lint (REQUIRED, every change)
```bash
find . -name '*.php' -not -path './.git/*' -exec php -l {} \;
```
Must report no syntax errors. Use the PHP major version of the target Piwigo (stay 7.4-compatible — see `02-code-style.md`).

## Manual test (in a running Piwigo)
- Put the renamed folder in `<piwigo>/plugins/`, activate via **Admin → Plugins** (runs `install`/`activate`).
- Exercise the feature with realistic inputs. Confirm **no PHP warnings/notices** and **no JS console errors**.
- Test both permission paths: an allowed user AND a forbidden one (a private photo must stay hidden).

## Database & storage testing (needs a real MariaDB/MySQL)
Piwigo's DB layer (`pwg_query`, `query2array`, `single_*`/`mass_*`) talks to a **real database** — there is no mock/in-memory layer to stub. So anything that reads, writes, or stores data (your `$conf['your_plugin']` config + any plugin tables) can only be validated against an actual **MariaDB/MySQL** holding representative data.
- Run a Piwigo dev instance backed by MariaDB/MySQL (a Docker setup is the easy path), then **seed mock data**: a few albums + photos, and at least one **non-admin user with a private album**, so permission / `get_sql_condition_FandF` paths are exercised for real (not just as admin).
- Run SQL directly to load fixtures and inspect results. Connection details live in `<piwigo>/local/config/database.inc.php` (`$conf['db_*']`, `$prefixeTable` — default prefix `piwigo_`):
  ```bash
  # adjust host/creds to your install (MariaDB client: use `mariadb`; Docker: docker exec <db_container> mariadb …)
  mysql -u<db_user> -p <db_name> -e "SELECT VERSION(); SHOW TABLES LIKE 'piwigo_config';"
  ```
- **Verify storage explicitly:** after install/config, check your rows
  (`SELECT value FROM piwigo_config WHERE param='your_plugin';` and/or your own tables);
  after uninstall, confirm they're gone and nothing else changed.
- **Exercise query edge cases** against the mock data: empty result sets, ids the user may not access (must be filtered out by FandF), and strings with quotes / special characters (confirm escaping holds).

## Smoke-test a page without the UI (dev only — REVERT after)
- `INSERT` a row into `piwigo_plugins (id,state,version)` (optionally seed `piwigo_config`), `curl` the page, grep the response for error keywords, then `DELETE` the row(s). Never clobber already-active plugins.

## Definition of done (every change)
- [ ] `php -l` clean; no PHP notices in strict mode; no JS console errors.
- [ ] install → activate → configure → uninstall leaves ONLY your `$conf['your_plugin']` behind.
- [ ] New behavior verified manually; allowed + forbidden permission paths checked.
- [ ] `en_UK` + `fr_FR` strings present for any new UI text.
- [ ] New feature has its check; a bug fix has a regression check (manual steps documented in the PR if no automated test).
