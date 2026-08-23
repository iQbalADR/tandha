# tandha

**Centralized UI automation-identifier toolkit for iOS.** Define every automation
identifier once in a shared JSON contract; assign it via XIB, UIKit, or SwiftUI;
and query the exact same identifiers from XCUITest and Appium-based tools
(Katalon, Selenium-family). No scattered magic strings, no silent drift.

[Get started](installation.md){ .md-button .md-button--primary }
[60-second quickstart](quickstart.md){ .md-button }

---

## Why tandha

- **One source of truth** — every automation ID lives once in JSON, addressed by dot path.
- **Type-safe references** — generate a Swift enum tree so the compiler flags every stale key.
- **Set once, query everywhere** — one `accessibilityIdentifier` serves XCUITest and Appium.
- **Export for QA tooling** — flat JSON, CSV, and Appium/Katalon page objects stay in lockstep.
- **CI-friendly lint** — catch duplicate, missing, unused, and mis-named IDs before the pipeline does.

## Install

=== "Swift Package Manager"

    ```swift
    // Package.swift
    dependencies: [ .package(url: "https://github.com/iQbalADR/tandha.git", from: "0.1.0") ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Tandha", package: "tandha"),           // assign IDs
        ]),
        .testTarget(name: "AppUITests", dependencies: [
            .product(name: "TandhaXCUITest", package: "tandha"),   // query IDs
        ]),
    ]
    ```

    Full details on the [installation page](installation.md).

## Quick look

=== "1 · Define"

    ```json
    {
      "login": {
        "username_field": "login.username_field",
        "submit_button":  "login.submit_button"
      }
    }
    ```

=== "2 · Generate"

    ```swift
    // tandha generate automation-ids.json --output Generated/AutomationID.swift
    public enum AutomationID {
        public enum login {
            public static let usernameField = "login.username_field"
            public static let submitButton  = "login.submit_button"
        }
    }
    ```

=== "3 · Assign"

    ```swift
    TextField("Username", text: $username)
        .automationID(AutomationID.login.usernameField)
    ```

=== "4 · Query"

    ```swift
    app.textFields[automationID: AutomationID.login.usernameField].tap()
    app.buttons[automationID: AutomationID.login.submitButton].tap()
    ```

!!! note "Honest by design"
    tandha sets the `accessibilityIdentifier` that every iOS automation stack relies
    on. It does **not** claim direct Selenium/Katalon native-iOS control — the bridge
    is always Appium's XCUITest driver.

## Learn more

- [Quickstart](quickstart.md) — from empty project to querying IDs in 60 seconds.
- [Assigning identifiers](assigning.md) — SwiftUI, UIKit, and XIB.
- [JSON format](format.md) — the normative contract spec.
- [CLI](cli.md) — `generate`, `export`, `lint`.
- [Design & roadmap](DESIGN.md) — architecture and what's planned for v3.
- [GitHub repository](https://github.com/iQbalADR/tandha)
