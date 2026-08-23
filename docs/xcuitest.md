# XCUITest

The `TandhaXCUITest` product gives your UI test target typed accessors keyed by the
same identifiers the app ships with — so tests read the source of truth, not
copy-pasted strings.

## Query by identifier

```swift
import XCTest
import TandhaXCUITest

final class LoginUITests: XCTestCase {
    func testSignIn() {
        let app = XCUIApplication()
        app.launch()

        app.textFields[automationID: AutomationID.login.usernameField].tap()
        app.textFields[automationID: AutomationID.login.usernameField].typeText("oncom")
        app.buttons[automationID: AutomationID.login.submitButton].tap()

        XCTAssertTrue(app.staticTexts[automationID: AutomationID.dashboard.balanceLabel].exists)
    }
}
```

The `[automationID:]` subscript is available on any `XCUIElementQuery`
(`app.buttons`, `app.textFields`, `app.staticTexts`, …).

## Query by element type

When you want the first descendant of a given type:

```swift
app.element(AutomationID.login.submitButton, type: .button).tap()
```

## Sharing the generated enum

The `AutomationID` enum is generated from the same JSON the app uses. Point the
[codegen](codegen.md) at your contract for both the app target and the UI test target
(or generate once into a shared file) so both sides always agree.

!!! note "Appium too"
    The identifiers you query here are the same `accessibility id` values an
    Appium / Katalon / Selenium-family suite consumes via [export](export.md). One
    contract, both stacks.
