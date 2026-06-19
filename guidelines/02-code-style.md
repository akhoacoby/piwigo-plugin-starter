# Code Style

## Naming (match Piwigo core)
- Functions & variables: `snake_case`. **Prefix every plugin function** with the plugin id (`your_plugin_…`).
- Classes: `PascalCase` — EXCEPT the maintain class, which MUST be `{plugin_id}_maintain`.
- Constants: `UPPER_SNAKE_CASE` via `define()`.
- Name handlers for what they handle (e.g. `your_plugin_loc_end_picture`).

## Formatting
- 2-space indentation; Allman braces (`{` on its own line) — match core.
- One statement per line; no trailing whitespace.
- `php -l` MUST pass on every file (see `11-testing.md`).

## PHP target compatibility (CRITICAL)
- Floor: **PHP 7.4** (`REQUIRED_PHP_VERSION=7.4.0`); must also run on 8.x.
- ALLOWED: typed properties, param/return types, nullable `?T`, arrow fns, `??` / `??=`, spread.
- FORBIDDEN (8.0+): union types `A|B`, named arguments, constructor promotion, `mixed`/`never`, `enum`, `match`, `readonly`, first-class callable syntax.
- When unsure, choose the simpler 7.4-safe form.

## Documentation
- PHPDoc (`/** … */`) on every function: one-line summary + `@param`/`@return` with types.
- Comment WHY, not WHAT. No commented-out code.

## Philosophy
- Simplicity & readability over cleverness. **Less code = less debt.**
- Early returns over nested conditions. DRY. Descriptive names.
- **Minimal changes:** only touch code related to the task.
- Define composing functions before their components.
- Mark issues in existing code with `// TODO:`.
