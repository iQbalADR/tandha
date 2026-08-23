import Foundation
import TandhaCore

/// Enforces a configurable naming convention on identifier strings.
///
/// Set `context.namingPattern` to a regex the *whole* identifier must match.
/// A couple of ready-made patterns live in `NamingConventionRule.Patterns`.
public struct NamingConventionRule: LintRule {
    public let name = "naming-convention"

    /// Common ready-made patterns.
    public enum Patterns {
        /// Dotted snake_case, e.g. `login.submit_button`.
        public static let dottedSnakeCase = "^[a-z0-9]+(_[a-z0-9]+)*(\\.[a-z0-9]+(_[a-z0-9]+)*)*$"
        /// Lower snake_case with no dots.
        public static let snakeCase = "^[a-z0-9]+(_[a-z0-9]+)*$"
    }

    public init() {}

    public func check(model: AutomationModel, context: LintContext) -> [LintFinding] {
        guard let pattern = context.namingPattern else { return [] }
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [LintFinding(
                severity: .error,
                rule: name,
                message: "invalid naming-convention regex: \(pattern)"
            )]
        }
        return model.entries.compactMap { entry in
            let range = NSRange(entry.identifier.startIndex..., in: entry.identifier)
            let matched = regex.firstMatch(in: entry.identifier, range: range).map {
                $0.range == range
            } ?? false
            guard !matched else { return nil }
            return LintFinding(
                severity: .error,
                rule: name,
                message: "identifier \"\(entry.identifier)\" (key \"\(entry.dotPath)\") does not match \(pattern)"
            )
        }
    }
}
