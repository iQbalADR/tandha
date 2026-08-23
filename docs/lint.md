# Lint

`tandha lint` validates the contract and returns a **non-zero exit code** on any
error-level finding — drop it into CI to catch drift before the pipeline goes red.

```bash
tandha lint automation-ids.json \
  --sources Sources \
  --naming dotted-snake \
  --expect-keys qa-owned-keys.txt
```

## Checks

| Rule | Severity | What it catches | Needs |
|------|----------|-----------------|-------|
| `duplicate-identifier` | error | Two keys resolving to the same identifier (ambiguous queries) | — |
| `missing-key` | error | Keys expected but absent from the contract | `--expect-keys <file>` |
| `unused-key` | warning | Keys defined but never referenced in scanned source | `--sources <dir>` |
| `naming-convention` | error | Identifiers not matching a required pattern | `--naming <pattern>` |

## Options

| Option | Effect |
|--------|--------|
| `--sources <dir>` | Scan a directory for references (enables `unused-key`). Repeatable. |
| `--naming <pattern>` | A regex, or a preset: `snake` \| `dotted-snake`. |
| `--expect-keys <file>` | Newline-delimited keys that must exist (enables `missing-key`). |
| `--basic` | Run only the always-safe subset (`duplicate-identifier`). |

## In CI

```yaml
- name: Lint automation IDs
  run: |
    swift build --product tandha
    .build/debug/tandha lint automation-ids.json --naming dotted-snake
```

Errors fail the step (exit 1); warnings are reported but do not fail (exit 0).

```text
error: [duplicate-identifier] identifier "shared_id" is used by 2 keys: login.a, login.b
error: [missing-key] expected key "login.missing" is not defined in the contract

2 error(s), 0 warning(s).
```

## Add your own rule

Each rule is a single type conforming to `LintRule`, registered in `Linter.all`. New
rules (empty-group, max-depth, screen-prefix, …) are great first contributions — see
the [good first issues](good-first-issues.md).
