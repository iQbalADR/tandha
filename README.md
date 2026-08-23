# tandha

[![CI](https://github.com/iQbalADR/tandha/actions/workflows/ci.yml/badge.svg)](https://github.com/iQbalADR/tandha/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-tandha-blue)](https://iqbaladr.github.io/tandha/)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)](https://github.com/iQbalADR/tandha)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-brightgreen)](Tandha.podspec)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2015%2B%20%7C%20tvOS%2015%2B%20%7C%20macOS%2012%2B-lightgrey)](https://github.com/iQbalADR/tandha)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **tandha** — Javanese for "sign / mark." A single shared source of truth for the
> UI automation identifiers in your iOS app.
>
> 📖 **Docs: <https://iqbaladr.github.io/tandha/>**

Centralized **UI automation-identifier toolkit** for iOS. Define every automation
identifier once in a **shared JSON contract**; assign it to elements via XIB, UIKit,
or SwiftUI; and query the exact same identifiers from XCUITest and Appium-based tools
(Katalon, Selenium-family). Three defining capabilities:

1. **One contract, both sides** — developers *set* IDs and QA *query* them from the
   same JSON. No scattered magic strings.
2. **Type-safe codegen** — generate a Swift enum tree (CLI or SwiftPM plugin); rename a
   key and the compiler flags every stale reference.
3. **Export & lint** — emit the contract for external QA tooling, and validate it in CI
   (duplicate / missing / unused / naming) with non-zero exit codes.

Every iOS automation stack keys off one property — `accessibilityIdentifier` — so
tandha's job is to manage keys, reliably set that identifier, and export the key list.

> **Honest by design.** tandha does not claim direct Selenium/Katalon native-iOS
> control; the bridge is always Appium's XCUITest driver. It sets the identifier every
> iOS automation stack relies on — it is **not** a test runner or an Appium replacement.

## Status

| Platform | Package | Status |
|----------|---------|--------|
| iOS / tvOS / macOS · Swift | [`Package.swift`](Package.swift) | ✅ v1 + v2 — `swift test` green (31 tests) |

The [phased roadmap](docs/DESIGN.md) is: **v1** core + bindings + XCUITest + basic lint,
**v2** codegen (CLI + plugin) + export + full lint (this), **v3** Android parity and
richer exports.

## Install

Requires iOS 15+ / tvOS 15+ / macOS 12+. See the full
[installation guide](docs/installation.md).

**Swift Package Manager:**

```swift
// Package.swift
dependencies: [ .package(url: "https://github.com/iQbalADR/tandha.git", from: "0.1.0") ],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Tandha", package: "tandha"),          // assign IDs
    ]),
    .testTarget(name: "AppUITests", dependencies: [
        .product(name: "TandhaXCUITest", package: "tandha"),  // query IDs
    ]),
]
```

**CocoaPods:**

```ruby
# Podfile
pod 'Tandha'            # Core + UIKit + SwiftUI  (import Tandha)
pod 'Tandha/XCUITest'   # in the UI test target
```

## 60-second quickstart

**1. Define the contract** (`automation-ids.json` — see [docs/format.md](docs/format.md)):

```json
{
  "login": {
    "username_field": "login.username_field",
    "submit_button":  "login.submit_button"
  }
}
```

**2. Generate type-safe references:**

```bash
tandha generate automation-ids.json --output Generated/AutomationID.swift
```

```swift
public enum AutomationID {
    public enum login {
        public static let usernameField = "login.username_field"
        public static let submitButton  = "login.submit_button"
    }
}
```

**3. Assign in SwiftUI** (or UIKit / XIB):

```swift
import Tandha

TextField("Username", text: $username)
    .automationID(AutomationID.login.usernameField)
Button("Sign in") { signIn() }
    .automationID(AutomationID.login.submitButton)
```

**4. Query the same IDs in XCUITest:**

```swift
import TandhaXCUITest

app.textFields[automationID: AutomationID.login.usernameField].tap()
app.buttons[automationID: AutomationID.login.submitButton].tap()
```

Rename a key in the JSON → regenerate → the compiler flags every stale reference.
Prefer zero manual steps? Add the [build-time plugin](docs/codegen.md).

## Export & lint

```bash
tandha export automation-ids.json --format json   # flat { key: identifier }
tandha export automation-ids.json --format csv    # key,identifier,description,screen,owner
tandha export automation-ids.json --format java   # Appium AppiumBy.accessibilityId page object

tandha lint automation-ids.json --naming dotted-snake   # non-zero exit on errors (CI)
```

## Architecture

```
TandhaCore     parser -> flattener -> resolver (key -> identifier) + registry
TandhaCodegen  JSON -> Swift enum tree (CLI + SwiftPM plugin)
bindings       TandhaUIKit (XIB @IBInspectable + helper) · TandhaSwiftUI (.automationID)
TandhaXCUITest typed query accessors for the test target
TandhaExport   flat JSON/CSV + page-object stub generators
TandhaLint     duplicate / missing / unused / naming checks
tandha         the command-line tool
```

Modular per concern so a contributor can touch one thing: each **export format** is a
single-file `Exporter`, each **lint rule** a single-file `LintRule`, each **binding** a
small file. See [CONTRIBUTING.md](CONTRIBUTING.md) and the
[good first issues](docs/good-first-issues.md).

## Building & testing

The package is dependency-free — it builds and tests offline.

```bash
swift build          # libraries, CLI, and codegen plugin
swift test           # 31 unit tests
swift run tandha --help
```

## Documentation

Full docs: **<https://iqbaladr.github.io/tandha/>** — or in [`docs/`](docs/):
[installation](docs/installation.md) · [quickstart](docs/quickstart.md) ·
[JSON format](docs/format.md) · [CLI](docs/cli.md) · [design & roadmap](docs/DESIGN.md).

## License

[MIT](LICENSE) © iQbalADR
