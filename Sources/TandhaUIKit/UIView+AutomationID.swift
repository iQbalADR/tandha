#if canImport(UIKit)
import UIKit
import TandhaCore

private var automationKeyAssociationKey: UInt8 = 0

extension UIView {
    /// Set a QA-facing automation key directly in Interface Builder.
    ///
    /// Type the dot-path key (e.g. `login.submit_button`) in the XIB/Storyboard
    /// attributes inspector. During nib loading the key is resolved through
    /// `AutomationRegistry.shared` and written to `accessibilityIdentifier`, so
    /// XCUITest and Appium see the exact identifier the contract defines.
    @IBInspectable public var automationKey: String? {
        get {
            objc_getAssociatedObject(self, &automationKeyAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(
                self,
                &automationKeyAssociationKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            if let key = newValue, !key.isEmpty {
                accessibilityIdentifier = AutomationRegistry.shared.identifier(forKey: key)
            }
        }
    }

    /// Assign an automation identifier from code.
    ///
    /// Pass a generated constant for compile-time safety:
    /// ```swift
    /// submitButton.setAutomationID(AutomationID.login.submitButton)
    /// ```
    public func setAutomationID(_ identifier: String) {
        accessibilityIdentifier = identifier
    }

    /// Assign an automation identifier by resolving a dot-path key through the
    /// shared registry. Prefer `setAutomationID(_:)` with a generated constant.
    public func setAutomationKey(_ key: String) {
        accessibilityIdentifier = AutomationRegistry.shared.identifier(forKey: key)
    }
}
#endif
