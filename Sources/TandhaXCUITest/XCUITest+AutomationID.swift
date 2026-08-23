#if canImport(XCTest)
import XCTest
import TandhaCore

extension XCUIElementQuery {
    /// Look up an element in this query by automation identifier.
    ///
    /// Reads the *same* contract the app ships with:
    /// ```swift
    /// app.textFields[automationID: AutomationID.login.usernameField].tap()
    /// ```
    public subscript(automationID identifier: String) -> XCUIElement {
        self[identifier]
    }
}

extension XCUIApplication {
    /// First descendant of `type` matching `identifier`.
    ///
    /// ```swift
    /// app.element(AutomationID.login.submitButton, type: .button).tap()
    /// ```
    public func element(
        _ identifier: String,
        type: XCUIElement.ElementType = .any
    ) -> XCUIElement {
        descendants(matching: type).matching(identifier: identifier).firstMatch
    }
}
#endif
