import Foundation

/// A single problem reported by a lint rule.
public struct LintFinding: Equatable, CustomStringConvertible {
    public enum Severity: String, Equatable {
        case warning
        case error
    }

    public let severity: Severity
    /// The rule that produced this finding, e.g. `duplicate-identifier`.
    public let rule: String
    /// Human-readable explanation.
    public let message: String

    public init(severity: Severity, rule: String, message: String) {
        self.severity = severity
        self.rule = rule
        self.message = message
    }

    public var description: String {
        "\(severity.rawValue): [\(rule)] \(message)"
    }
}

public extension Array where Element == LintFinding {
    /// True when any finding is an error (CI should fail).
    var hasErrors: Bool { contains { $0.severity == .error } }
}
