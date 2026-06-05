# Search Performance

Default rules for every agent that runs `grep`, `rg`, `glob`, or shell searches. Keeps CPU low on large repos and avoids scanning noise.

## Tool Choice

- **Prefer `rg` (ripgrep) over `grep`** — 5-10× faster, respects `.gitignore` automatically.
- `rg` is available on most opencode setups; if missing, fall back to `grep -r` with explicit exclusions.
- Use `glob` (the opencode tool) for filename discovery before running a content search — it's metadata-only and cheap.

## Default Exclusions

Skip these unless the user explicitly asks for them. Apply to `rg` via `--glob '!pattern'`:

```
--glob '!node_modules'
--glob '!target'
--glob '!dist'
--glob '!build'
--glob '!.git'
--glob '!vendor'
--glob '!__pycache__'
```

Language-specific additions:

- **Go:** also `--glob '!vendor/'`
- **Node:** also `--glob '!package-lock.json' --glob '!yarn.lock' --glob '!*.min.js' --glob '!node_modules/'`
- **Python:** also `--glob '!*.pyc' --glob '!.venv/' --glob '!__pycache__/'`
- **Rust:** also `--glob '!target/'`

## Pattern Discipline

- Use `-F` (fixed/literal) when the pattern is a plain string, not a regex — faster, no escaping.
- Anchor with `^` / `$` or use word boundary `-w` to avoid scanning every line.
- Use `-l` (filenames only) when you only need to know *where* something lives, not the matching line.
- Cap with `-m N` (`--max-count N`) so a single file with thousands of matches doesn't monopolize CPU.
- Combine `-l` with `-m 1` for "does this pattern exist anywhere?" checks.

## File-Type Filtering

- `-g '*.go'`, `-g '*.ts'`, `-g '*.py'` to limit to a language.
- `-t go`, `-t ts`, `-t py` as shorthand (rg built-in types).
- For "files modified by humans", exclude generated: `-g '!*.gen.*' -g '!*.generated.*' -g '!*_pb.go' -g '!*_pb2.py'`.

## Result Size

- Pipe through `head -50` when scanning for a count or sample; don't dump thousands of lines back into the context window.
- Prefer `rg -c PATTERN` (count per file) over `-l` followed by full reads.
- If you only need context around matches, use `rg -C 3 PATTERN` (3 lines before/after) instead of full file reads.
- `rg --json PATTERN` produces structured output for downstream tooling — use only when needed (slower than text).

## Parallelism

- **Don't batch >2 parallel `rg` calls on a large tree (>100k files).** Sequential is gentler on CPU.
- For multi-area searches, prefer one `rg` with broader globs over many small calls.
- If you must run many searches, prefer `@explore` subagent (uses `deepseek-v4-flash` and runs in its own context) over doing it inline.
- Cap thread count for very large repos: `rg -j 2` to keep CPU under control.

## Examples

```bash
# Find a Go function definition (anchored, type filter, capped)
rg -t go -m 50 '^func.*HandleRequest'

# Locate all files importing a package (filenames only, fast)
rg -l '"github.com/foo/bar"' -g '*.go'

# Count occurrences per file (cheap overview, skip generated)
rg -c 'TODO' -g '!*.md' -g '!*.gen.*'

# Literal string search, skip lock files
rg -F 'ERROR_TIMEOUT' --glob '!*.lock'

# Word-boundary search across one language, sample 20 lines
rg -w -t ts -m 20 'authenticate'

# Check if a pattern exists at all (filename only, stop at first match)
rg -l -m 1 'BEGIN PRIVATE KEY' -g '!*.md'
```

## When to Break These Rules

- User explicitly asks for `grep` (legacy script, portability, teaching).
- `rg` is not installed and a single `grep` is faster than installing rg.
- Investigating `.git/` internals (rg's gitignore respect hides the data).
- Searching inside a single small file where rg/grep overhead is irrelevant.
