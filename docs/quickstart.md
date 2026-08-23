# 60-second quickstart

From a JSON contract to querying identifiers in XCUITest.

## 1. Define the contract

Create `automation-ids.json` (see the full [format spec](format.md)):

```json
{
  "login": {
    "username_field": "login.username_field",
    "submit_button":  "login.submit_button"
  }
}
```

## 2. Generate type-safe references

```bash
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

!!! tip "Or generate at build time"
    Add the [SwiftPM plugin](codegen.md) and drop a `*.automationids.json` file into
    your target — no manual `generate` step, nothing to check in.

## 3. Assign in your UI

=== "SwiftUI"

    ```swift
    TextField("Username", text: $username)
        .automationID(AutomationID.login.usernameField)

    Button("Sign in") { signIn() }
        .automationID(AutomationID.login.submitButton)
    ```

=== "UIKit"

    ```swift
    usernameField.setAutomationID(AutomationID.login.usernameField)
    submitButton.setAutomationID(AutomationID.login.submitButton)
    ```

=== "XIB / Storyboard"

    Set the **Automation Key** inspectable (a dot-path key, e.g. `login.submit_button`)
    in the Interface Builder attributes inspector — it resolves through the shared
    registry at nib-load time. Configure the registry once at launch:

    ```swift
    try AutomationRegistry.shared.configure(contentsOf: contractURL)
    ```

## 4. Query the same IDs in XCUITest

```swift
app.textFields[automationID: AutomationID.login.usernameField].tap()
app.buttons[automationID: AutomationID.login.submitButton].tap()
```

That's it. Rename a key in the JSON → regenerate → the compiler flags every stale
reference. See [Assigning identifiers](assigning.md) for the full binding surface.
