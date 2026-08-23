# Assigning identifiers

Three surfaces — SwiftUI, UIKit, and XIB — all funnel through **one resolver**, so an
element behaves identically no matter how it was built. Each sets the element's
`accessibilityIdentifier`, which is what XCUITest and Appium read.

## SwiftUI

`automationID(_:)` wraps `.accessibilityIdentifier(_:)`:

```swift
import Tandha

TextField("Username", text: $username)
    .automationID(AutomationID.login.usernameField)

Text(balance)
    .automationID(AutomationID.dashboard.balanceLabel)
```

There is also a key-based variant that resolves through the shared registry:

```swift
Text(balance).automationKey("dashboard.balance_label")
```

## UIKit

```swift
import Tandha

// with a generated constant (recommended — compile-time safe)
submitButton.setAutomationID(AutomationID.login.submitButton)

// or resolve a dot-path key through the registry
submitButton.setAutomationKey("login.submit_button")
```

## XIB / Storyboard

Every `UIView` exposes an `@IBInspectable` **Automation Key**. Type the dot-path key
directly in the Interface Builder attributes inspector; during nib loading it resolves
through `AutomationRegistry.shared` and sets `accessibilityIdentifier`. This lets
QA-facing IDs be authored right in Interface Builder.

## The shared registry

Key-based surfaces (XIB, and the `*Key` helpers) resolve through a process-wide
registry. Configure it once at launch with the shipped contract:

```swift
import Tandha

// e.g. in application(_:didFinishLaunchingWithOptions:)
if let url = Bundle.main.url(forResource: "automation-ids", withExtension: "json") {
    try? AutomationRegistry.shared.configure(contentsOf: url)
}
```

!!! note "Fallback behavior"
    Until the registry is configured — or for keys it doesn't know — key-based
    resolution returns the key unchanged. That matches the auto-derive default
    (`key == identifier`), so nothing silently disappears.

## Which should I use?

!!! tip "Prefer generated constants"
    Use `AutomationID.*` constants (via [codegen](codegen.md)) with `automationID(_:)` /
    `setAutomationID(_:)` wherever you can — renaming a key then becomes a compile-time
    error, not a runtime surprise. Reserve the key-based `*Key` / XIB path for
    Interface Builder, where a compile-time constant isn't available.
