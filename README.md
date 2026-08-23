# tandha

**One JSON contract for every UI automation identifier in your iOS app — set once,
queried by XCUITest and Appium-based tools (Katalon, Selenium-family) alike.**

Define each automation identifier once in JSON. Assign it to elements via XIB,
UIKit, or SwiftUI. Consume the exact same identifiers from XCUITest and export
them for external QA tooling. No scattered magic strings; no silent drift when
someone renames one.

## Why

In large apps — especially banking/fintech with big regression suites —
automation identifiers are usually hardcoded magic strings duplicated across app
code *and* the test suite, inconsistently named, and silently broken when a
developer renames one while QA's scripts still expect the old value. There is no
shared contract between the people who *set* IDs and the people who *query* them.

**This library makes the JSON that contract.**

## How it works

Every iOS automation stack keys off one property: `accessibilityIdentifier`. Set
it once and it is visible to:

- **XCUITest** (native) via `element.identifier` / query subscripting,
- **Appium** via the `accessibility id` locator strategy,
- **Katalon Studio (mobile)** and **Selenium-family** tools *through Appium* —
  the Appium XCUITest driver is the bridge; they do not drive native iOS directly.

tandha's job is exactly this: manage keys, reliably set `accessibilityIdentifier`,
and export the key list so any of those tools consume the same contract.

## 60-second quickstart

**1. Define the contract** (`automation-ids.json`):

```json
{
  "login": {
    "username_field": "login.username_field",
    "submit_button":  "login.submit_button"
  }
}
```

**2. Generate type-safe references:**

```sh
tandha generate automation-ids.json --output Generated/AutomationID.swift
```

```swift
// generated
public enum AutomationID {
    public enum login {
        public static let usernameField = "login.username_field"
        public static let submitButton  = "login.submit_button"
    }
}
```

**3. Assign in SwiftUI (or UIKit / XIB):**

```swift
TextField("Username", text: $username)
    .automationID(AutomationID.login.usernameField)

Button("Sign in") { signIn() }
    .automationID(AutomationID.login.submitButton)
```

**4. Query the same IDs in XCUITest:**

```swift
app.textFields[automationID: AutomationID.login.usernameField].tap()
app.buttons[automationID: AutomationID.login.submitButton].tap()
```

Rename a key in the JSON → regenerate → the compiler flags every stale reference.
That is what eliminates drift on the developer side.

## Installation

Add the package in `Package.swift`:

```swift
.package(url: "https://github.com/iQbalADR/tandha.git", from: "0.1.0")
```

Then depend on what each target needs:

```swift
// App target — assign identifiers
.product(name: "Tandha", package: "tandha"),
// UI test target — query identifiers
.product(name: "TandhaXCUITest", package: "tandha"),
```

The `tandha` CLI is also built by the package; a Homebrew formula will follow.

## Assigning identifiers

Three surfaces, one shared resolver — behavior is identical however the element
was built.

- **SwiftUI:** `.automationID(AutomationID.login.submitButton)` (wraps
  `.accessibilityIdentifier(_:)`).
- **UIKit:** `view.setAutomationID(AutomationID.login.submitButton)`.
- **XIB / Storyboard:** set the `automationKey` inspectable (a dot-path key) in
  Interface Builder; it resolves through `AutomationRegistry.shared` and sets
  `accessibilityIdentifier` during nib loading.

Key-based surfaces (XIB and the `*Key` helpers) resolve through a shared
registry. Configure it once at launch:

```swift
try AutomationRegistry.shared.configure(contentsOf: contractURL)
```

## Build-time codegen (SwiftPM plugin)

Skip the manual `generate` step. Add the plugin and drop a
`*.automationids.json` file into a target's sources:

```swift
.target(
    name: "App",
    plugins: [.plugin(name: "TandhaCodegenPlugin", package: "tandha")]
)
```

The `AutomationID` enum is regenerated and compiled in on every build. Nothing to
check in.

## Export for Appium / Katalon / Selenium-family

Keep a cross-platform suite in lockstep with the app:

```sh
tandha export automation-ids.json --format json   # flat { key: identifier }
tandha export automation-ids.json --format csv    # key,identifier,description,screen,owner
tandha export automation-ids.json --format java   # Appium AppiumBy.accessibilityId page object
```

## Validation (CI-friendly)

`tandha lint` returns a non-zero exit code when it finds problems:

```sh
tandha lint automation-ids.json \
  --sources Sources \
  --naming dotted-snake \
  --expect-keys qa-owned-keys.txt
```

- **duplicate** identifier values (error),
- **missing** keys expected but absent (error),
- **unused** keys defined but never referenced in scanned sources (warning),
- **naming-convention** enforcement via regex or a preset (`snake`, `dotted-snake`).

Use `--basic` for the always-safe subset (duplicates only).

## Scope

- **In scope (v1/v2):** managing and assigning accessibility identifiers,
  XCUITest helpers, codegen, export for external tools, validation/lint.
- **Out of scope:** the automation execution itself (this is **not** a test
  runner and not an Appium replacement), Android (possible v3), web.

## Documentation

- [The contract format](docs/format.md) — the normative JSON spec.
- [Contributing](CONTRIBUTING.md) — bindings, export formats, and lint rules are
  all single-file contributions.

## License

MIT — see [LICENSE](LICENSE).
