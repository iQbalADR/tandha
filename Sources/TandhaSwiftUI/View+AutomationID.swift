#if canImport(SwiftUI)
import SwiftUI
// Separate module under SPM; folded into the single `Tandha` module under CocoaPods.
#if canImport(TandhaCore)
import TandhaCore
#endif

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
