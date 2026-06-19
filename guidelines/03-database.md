# Database & SQL

**No ORM. No prepared statements.** Use the core DB layer only — it owns the connection and the dblayer is swappable (mysqli/mysql).

## Access (NEVER raw mysqli / PDO)
- Read: `query2array($sql [,$key][,$val])` (preferred), or `pwg_query()` + `pwg_db_fetch_assoc/row/array()`.
- Write: `single_insert()`, `single_update()`, `mass_inserts()`, `mass_updates()`.
- Table names ONLY via constants (`IMAGES_TABLE`, `CATEGORIES_TABLE`, `IMAGE_CATEGORY_TABLE`, …). Plugin tables: `$prefixeTable.'your_plugin'`.

## SQL safety = validate + escape (not binding)
- Request strings are globally `addslashes`-ed at bootstrap → safe to quote directly.
- Validate ids/enums: `check_input_parameter($name, $arr, $is_array, PATTERN_ID)` or `is_numeric()`. NEVER interpolate an unvalidated id.
- Escape NON-request strings (JSON body, files, re-read rows, computed) with `pwg_db_real_escape_string()`.
- Dynamic identifiers: `protect_column_name()`.
- ⚠️ `single_insert` / `single_update` / `mass_*` **quote but do NOT escape** values — escape non-request values yourself first.

## Permissions on reads (MANDATORY)
- Any SELECT of images/albums for display MUST append `get_sql_condition_FandF([... => field], 'AND')`.
- "Can the user see it?" == "did the row return?". **Fail closed** — never reveal that a hidden item exists.

```php
$rows = query2array('
SELECT id, name, file, path, width, height, representative_ext
  FROM '.IMAGES_TABLE.'
  WHERE id IN ('.implode(',', $ids).')
    '.get_sql_condition_FandF(array('forbidden_categories'=>'category_id',
                                    'visible_images'=>'id'), 'AND').'
;');
```

## Migrations
- Tables: `CREATE TABLE IF NOT EXISTS` in `install()`; idempotent `ALTER` (guard with `SHOW COLUMNS … LIKE`) in `update()`; `DROP TABLE` in `uninstall()`.
- Always `$prefixeTable`-prefixed. Config-only plugins need no tables.

> Testing queries/storage needs a **real MariaDB/MySQL** with seeded mock data (no mock layer) — see `11-testing.md`.
> Reference: `PIWIGO_CONVENTIONS.md` §4–5.
