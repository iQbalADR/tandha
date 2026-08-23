# CLI reference

The `tandha` command-line tool wraps codegen, export, and lint. It is dependency-free
and built by the package (`swift build -c release`).

```text
tandha <command> [options]

Commands:
  generate   Generate a Swift enum tree from the JSON contract
  export     Export the contract for Appium / Katalon / Selenium-family tools
  lint       Validate the contract (CI-friendly exit codes)

Other:
  --version  Print version
  --help     Show help
```

Every command accepts **one or more** JSON inputs; multiple files are merged by
namespace. Run `tandha <command> --help` for command-specific options.

## `tandha generate`

```bash
tandha generate <contract.json>... [options]
```

| Option | Default | Effect |
|--------|---------|--------|
| `--output <file>` | stdout | Write generated Swift to a file |
| `--root-name <name>` | `AutomationID` | Name of the root enum |
| `--access <level>` | `public` | `public` or `internal` |
| `--no-doc-comments` | off | Omit metadata-derived doc comments |

See [Codegen & plugin](codegen.md).

## `tandha export`

```bash
tandha export <contract.json>... --format <name> [--output <file>]
```

| Option | Effect |
|--------|--------|
| `--format <name>` | `json` \| `csv` \| `java` (required) |
| `--output <file>` | Write to a file (default: stdout) |

See [Export](export.md).

## `tandha lint`

```bash
tandha lint <contract.json>... [options]
```

| Option | Effect |
|--------|--------|
| `--sources <dir>` | Scan for references (enables unused-key). Repeatable. |
| `--naming <pattern>` | Regex or preset (`snake` \| `dotted-snake`) |
| `--expect-keys <file>` | Newline-delimited keys that must exist |
| `--basic` | Only the always-safe checks |

Exit code is non-zero when any error-level finding is present. See [Lint](lint.md).
