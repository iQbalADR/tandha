#if canImport(SwiftUI)
import SwiftUI
import TandhaCore

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// Assign an automation identifier, wrapping `.accessibilityIdentifier(_:)`.
    ///
    /// Pass a generated constant for compile-time safety:
    /// ```swift
    /// TextField("User", text: $user)
    ///     .automationID(AutomationID.login.usernameField)
    /// ```
    public func automationID(_ identifier: String) -> some View {
        accessibilityIdentifier(identifier)
    }

    /// Assign an automation identifier by resolving a dot-path key through the
    /// shared registry. Prefer `automationID(_:)` with a generated constant.
    public func automationKey(_ key: String) -> some View {
        accessibilityIdentifier(AutomationRegistry.shared.identifier(forKey: key))
    }
}
#endif
