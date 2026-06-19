# Security

## File guards
- First line of EVERY `.php`: `defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');` (or `if (!defined('PHPWG_ROOT_PATH')) die('Hacking attempt!');`).
- Plugin sub-files may guard on `YOUR_PLUGIN_PATH` instead.
- Every directory ships an `index.php` redirect.

## Input validation
- `check_input_parameter($name, $_GET|$_POST, $is_array, $pattern, $mandatory=false)`; patterns: `PATTERN_ID` (`/^\d+$/`), `PATTERN_ORDER`.
- Validate BEFORE use; on mismatch core `fatal_error`s. Never trust raw input.
- Whitelist enum/string inputs against an explicit allow-list (e.g. dynamic `?tab=` / mode values) before use.

## Permissions
- Levels: `ACCESS_FREE < ACCESS_GUEST < ACCESS_CLASSIC < ACCESS_ADMINISTRATOR < ACCESS_WEBMASTER < ACCESS_CLOSED`.
- Privileged pages: `check_status(ACCESS_ADMINISTRATOR)` at the top.
- Gate features with `is_admin()` / `is_a_guest()` / `is_webmaster()`.
- Per-photo/album access: `get_sql_condition_FandF` (see `03-database.md`). Type validation is NOT authorization.

## CSRF
- Every state-changing POST: `check_pwg_token()` server-side **and** `<input type="hidden" name="pwg_token" value="{$PWG_TOKEN}">` (PHP supplies `get_pwg_token()`).

## Output & files
- Escape ALL HTML output (see `05-frontend.md`) — auto-escaping is OFF.
- NEVER emit original file paths; serve `DerivativeImage` URLs only (preserves watermark/privacy/size limits).
- NEVER use `die()`/`exit()` for control flow or error handling — the file guard is the only sanctioned use. Surface problems via `$page['errors']` / `$page['infos']` + `flush_page_messages()`.

> Reference: `PIWIGO_CONVENTIONS.md` §5–6.
