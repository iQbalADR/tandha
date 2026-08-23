# Contributing

Thanks for helping build tandha! The architecture is deliberately modular so most
contributions are **single-file** and easy to review.

## Architecture

```
TandhaCore     parser -> flattener -> resolver (key -> identifier)
TandhaCodegen  JSON -> Swift enum tree (CLI + SwiftPM plugin)
TandhaUIKit    UIKit helper + XIB @IBInspectable
TandhaSwiftUI  .automationID() view modifier
TandhaXCUITest typed query accessors for the test target
TandhaExport   flat JSON/CSV + page-object stub generators
TandhaLint     duplicate / missing / unused / naming checks
tandha         the command-line tool
```

## Great first contributions

Each of these is self-contained:

- **A new export format** — add one type conforming to `Exporter` in
  `Sources/TandhaExport/`, then register it in `Exporters.all`. See
  `JSONExporter` / `CSVExporter` / `JavaPageObjectExporter` for the pattern.
- **A new lint rule** — add one type conforming to `LintRule` in
  `Sources/TandhaLint/Rules/`, then register it in `Linter.all`. See the existing
  rules for the pattern.
- **A binding refinement** — the UIKit / SwiftUI / XCUITest surfaces are each one
  small file.

## Ground rules

- **Keep it honest.** tandha sets the `accessibilityIdentifier` that every iOS
  automation stack relies on. Do **not** claim direct Selenium/Katalon native-iOS
  control anywhere — the bridge is always Appium's XCUITest driver.
- **Add tests.** Every new exporter, lint rule, or core behavior needs unit
  tests. Run `swift test` before opening a PR.
- **Stay deterministic.** Output is sorted by key so diffs stay stable; preserve
  that.
- **Mirror the resolver.** All three assignment surfaces must funnel through the
  same resolution so behavior is identical.
- If Android parity lands (v3), an API-parity rule will be enforced here.

## Development

```sh
swift build      # build everything (libraries, CLI, plugin)
swift test       # run the test suite
swift run tandha  # run the CLI locally
```

## Commit conventions

- Write commit messages as the human author only.
- Do **not** add any tool-attribution line (e.g. "Generated with …").
- Do **not** add a `Co-Authored-By` trailer for tools/assistants.
