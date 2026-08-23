import Foundation

/// Process-wide resolver for key-based binding surfaces (XIB `@IBInspectable`
/// and the key-based UIKit/SwiftUI helpers).
///
/// Configure it once at launch with the shipped contract:
/// ```swift
/// let model = try AutomationModel(contentsOf: url)
/// AutomationRegistry.shared.configure(with: model)
/// ```
/// Until configured, `identifier(forKey:)` returns the key unchanged, which
/// matches the auto-derive default (key == identifier).
public final class AutomationRegistry {
    public static let shared = AutomationRegistry()

    private let lock = NSLock()
    private var model: AutomationModel?

    public init() {}

    /// Install the contract used to resolve keys.
    public func configure(with model: AutomationModel) {
        lock.lock()
        defer { lock.unlock() }
        self.model = model
    }

    /// Load and install a contract from a JSON file.
    public func configure(contentsOf url: URL) throws {
        configure(with: try AutomationModel(contentsOf: url))
    }

    /// Whether a contract has been installed.
    public var isConfigured: Bool {
        lock.lock()
        defer { lock.unlock() }
        return model != nil
    }

    /// Resolve a dot-path key to its identifier, falling back to the key itself.
    public func identifier(forKey key: String) -> String {
        lock.lock()
        defer { lock.unlock() }
        return model?.identifier(forKey: key) ?? key
    }

    /// Reset to the unconfigured state (primarily for tests).
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        model = nil
    }
}
