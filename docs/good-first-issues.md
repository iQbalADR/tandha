# Good first issues

tandha is built so most contributions are **single-file**. The original v1/v2
backlog (JSON spec, resolver, bindings, XCUITest accessors, codegen + plugin,
export, lint) is already implemented — these are the *next* opportunities.

## Add an export format (single file)

Add one type conforming to `Exporter` in `Sources/TandhaExport/`, register it in
`Exporters.all`, and add a test in `Tests/TandhaExportTests/`.

- [ ] **Java `.properties`** — `login.username_field=login.username_field` lines.
- [ ] **Python page object** — Appium `AppiumBy.accessibility_id(...)` class.
- [ ] **XML / Katalon object repository** stub.
- [ ] **TypeScript/WebdriverIO** locator map.

## Add a lint rule (single file)

Add one type conforming to `LintRule` in `Sources/TandhaLint/Rules/`, register it
in `Linter.all`, and add a test in `Tests/TandhaLintTests/`.

- [ ] **Empty-group** — a namespace with no leaves.
- [ ] **Max-depth** — warn when nesting exceeds a configurable depth.
- [ ] **Reserved-word leaf** — flag keys that need back-tick escaping in codegen.
- [ ] **Screen-prefix** — enforce that each identifier starts with its top-level namespace.

## Bindings & DX

- [ ] SwiftUI: an `automationID(_:)` overload taking a generated `KeyPath`.
- [ ] UIKit: convenience on `UIBarButtonItem` / `UIAccessibilityIdentification`.
- [ ] A `tandha init` command that scaffolds a starter `automation-ids.json`.

## v3 — reach (larger)

- [ ] **Android parity** — Espresso/UIAutomator via `resource-id` /
      `contentDescription`. Enforce API parity with the iOS surfaces (see
      `CONTRIBUTING.md`).
- [ ] Richer metadata-driven QA docs (HTML/Markdown catalog export).

## Ground rules

Every new format/rule needs a unit test; keep output deterministic (sorted by
key); never claim direct Selenium/Katalon native-iOS control — the bridge is
always Appium's XCUITest driver. See
[CONTRIBUTING.md](https://github.com/iQbalADR/tandha/blob/main/CONTRIBUTING.md).
