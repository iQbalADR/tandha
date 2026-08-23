# tandha — Centralized UI Automation-Identifier Toolkit for iOS

> The original design brief for tandha. Kept for context; the shipped behavior is
> documented in [the contract format](format.md) and the [README](../README.md).

---

## What this is

A Swift library + tooling that turns UI test **automation identifiers** into a
single, shared source of truth. Define every automation ID once in a JSON file;
assign it to UI elements via XIB, UIKit, or SwiftUI; and consume the exact same
IDs from XCUITest and from external Appium-based tools (Katalon, Selenium-family).

One JSON contract, consumed by both sides:
- **Developers** assign IDs to elements without inventing ad-hoc strings.
- **QA / automation engineers** query the same IDs in their test suites.

No scattered magic strings, no silent drift when someone renames one.

## The problem it solves

In large apps — especially banking/fintech with big regression suites —
automation identifiers are typically:
- hardcoded magic strings duplicated across the app code *and* the test suite,
- inconsistently named across screens and teams,
- silently broken when a developer renames one and QA's scripts still expect
  the old value, surfacing only as a red pipeline hours later.

There is no shared contract between the people who *set* IDs and the people who
*query* them. This library makes the JSON that contract.

---

## Important technical accuracy (read first — keep docs honest)

- The universal hook on iOS is **`accessibilityIdentifier`**. Set it once and
  it is visible to:
  - **XCUITest** (native) via `element.identifier` / query subscripting,
  - **Appium** via the `accessibility id` locator strategy,
  - **Katalon Studio (mobile)** and **Selenium-family** tools *through Appium* —
    they do **not** drive native iOS directly; Appium's XCUITest driver is the
    bridge.
- Therefore the library's job is precisely: manage keys, reliably set
  `accessibilityIdentifier`, and **export** the key list so any of those tools
  can consume the same contract.
- **Do NOT** claim direct Selenium/Katalon native-iOS control anywhere in the
  README or marketing. Frame it as "sets the identifier every iOS automation
  stack relies on."

---

## Scope (strict)

- **In scope (v1):** iOS/Swift — managing and assigning accessibility
  identifiers, XCUITest helpers, export for external tools, validation/lint.
- **Out of scope (v1):** the automation execution itself (this is NOT a test
  runner and not an Appium replacement), Android (possible v3 parity), web.

---

## The JSON format (single source of truth — define this first)

Namespaced keys, grouped by screen/component. Addressed by dot path.

```json
{
  "login": {
    "username_field": "login.username_field",
    "password_field": "login.password_field",
    "submit_button":  "login.submit_button"
  },
  "dashboard": {
    "balance_label":  "dashboard.balance_label"
  }
}
```

- **Value rules:** an explicit identifier string may be given; if omitted, the
  identifier is auto-derived from the dot path (so `login.submit_button` ->
  `"login.submit_button"`). Explicit values win, for legacy IDs QA already uses.
- **Optional metadata** per key (`description`, `screen`, `owner`) for QA docs
  and generated page objects — ignored at runtime.
- **One file** by default; support splitting into multiple files merged by
  namespace for large apps.

---

## Type-safe access (codegen — headline feature)

An optional CLI / SwiftPM build-tool plugin generates a Swift enum/struct tree
from the JSON so developers use compile-time-safe references with autocomplete
instead of stringly-typed keys:

```swift
// generated
enum AutomationID {
    enum login {
        static let usernameField = "login.username_field"
        static let submitButton  = "login.submit_button"
    }
}
```

Rename in JSON -> regenerate -> the compiler flags every stale reference. This is
what eliminates drift on the developer side.

---

## Assigning identifiers (three surfaces, mirror the same resolver)

- **XIB / Storyboard:** `@IBInspectable var automationKey: String?` on a
  `UIView` extension/subclass; on `awakeFromNib` it resolves the key and sets
  `accessibilityIdentifier`. Lets QA-facing IDs be set right in Interface Builder.
- **UIKit (code):** `view.setAutomationID(AutomationID.login.submitButton)`.
- **SwiftUI:** `.automationID(AutomationID.login.submitButton)` view modifier
  that wraps `.accessibilityIdentifier(_:)`.

All three funnel through one resolver so behavior is identical regardless of how
the element was built.

---

## XCUITest support

Typed accessors so the test target reads the *same* source of truth the app
ships with:

```swift
app.textFields[AutomationID.login.usernameField].tap()
app.buttons[AutomationID.login.submitButton].tap()
```

Provide a small `XCUIApplication`/`XCUIElementQuery` helper layer keyed by the
generated identifiers.

---

## Interop / export (bridge to Appium / Katalon / Selenium-family)

A `tandha export` command emits the identifier map for external QA tooling so the
cross-platform suite consumes the same contract the app ships:
- flat **JSON** / **CSV** of `key -> identifier`,
- optional generated **page-object stubs** (e.g. an Appium/Katalon-friendly
  class listing `accessibility id` locators).

This is the seam that lets a Katalon/Selenium+Appium suite stay in lockstep with
the app without hand-copying strings.

---

## Validation (CI-friendly)

`tandha lint` checks and returns a non-zero exit for CI:
- **duplicate** identifier values,
- **unused** keys (defined in JSON but never assigned in code),
- **missing** keys (referenced in tests/exports but absent from JSON),
- **naming-convention** enforcement (configurable regex, e.g. `snake_case`,
  screen-prefixed).

---

## Architecture (modular = contributor-friendly)

```
core        parser -> flattener -> resolver (key -> identifier)
codegen     JSON -> Swift enum tree (CLI + SwiftPM plugin)
bindings    XIB (@IBInspectable) . UIKit helper . SwiftUI modifier
xcuitest    typed query accessors for the test target
export      flat JSON/CSV + page-object stub generators
lint        duplicate / unused / missing / naming checks
```

- Each **binding** is a single-file contribution. Each **export format** is a
  single-file contribution. Each **lint rule** is self-contained. These are
  ideal `good first issue` tickets.

---

## Distribution

- Library: Swift Package Manager.
- Codegen: SwiftPM build-tool plugin (runs at build time) + standalone CLI.
- CLI: Homebrew formula later.
- Semantic versioning.

---

## Phased roadmap

**v1 — working core**
- JSON spec + resolver
- Set `accessibilityIdentifier` via XIB / UIKit / SwiftUI
- XCUITest typed accessors
- Basic lint (duplicates / missing)

**v2 — the differentiators**
- Codegen (type-safe enum tree) as CLI + SwiftPM plugin
- Export for Appium/Katalon (JSON/CSV + page-object stubs)
- Full lint (unused + naming conventions)

**v3 — reach**
- Android parity (Espresso/UIAutomator: `resource-id` / `contentDescription`)
- More export formats, richer metadata-driven QA docs

---

## Contributor-friendliness

- Tight scope; bindings, export formats, and lint rules are all single-file PRs.
- Ship with: `CONTRIBUTING.md`, `good first issue` labels, `hacktoberfest`
  topic, a `README` with a 60-second quickstart (define JSON -> assign in
  SwiftUI -> query in XCUITest).
- If Android is added in v3, enforce an API-parity rule in `CONTRIBUTING.md`.

## Commit conventions
- Do **NOT** add any tool-attribution line (e.g. "Generated with …") to commit
  messages.
- Do **NOT** add a `Co-Authored-By` trailer for tools/assistants.
- Write commit messages as the human author only.

---

## First batch of issues (starter backlog)

1. Define and document the JSON format spec in `/docs/format.md`.
2. Implement core: parser -> flattener -> resolver (key -> identifier).
3. SwiftUI `.automationID()` modifier wrapping `.accessibilityIdentifier()`.
4. UIKit `setAutomationID(_:)` helper + XIB `@IBInspectable automationKey`.
5. XCUITest typed query accessors.
6. Lint: duplicate identifiers + missing-key detection (CI exit codes).
7. Codegen CLI: JSON -> Swift enum tree.
8. SwiftPM build-tool plugin wrapping the codegen.
9. Export command: flat JSON/CSV of key -> identifier.
10. `README` quickstart + `CONTRIBUTING.md`.

*(v2/v3 issues — page-object export, unused/naming lint, Android parity — filed
once v1 lands.)*
