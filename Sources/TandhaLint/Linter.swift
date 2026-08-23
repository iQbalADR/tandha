import Foundation
import TandhaCore

/// Runs a set of lint rules over a model and aggregates their findings.
public struct Linter {
    public let rules: [LintRule]

    public init(rules: [LintRule]) {
        self.rules = rules
    }

    /// The full built-in rule set. Rules that need extra context
    /// (`unused-key`, `missing-key`, `naming-convention`) no-op unless that
    /// context is supplied.
    public static var all: Linter {
        Linter(rules: [
            DuplicateIdentifierRule(),
            MissingKeyRule(),
            UnusedKeyRule(),
            NamingConventionRule(),
        ])
    }

    /// The always-safe subset that needs only the model (v1 "basic lint").
    public static var basic: Linter {
        Linter(rules: [DuplicateIdentifierRule()])
    }

    public func run(model: AutomationModel, context: LintContext = LintContext()) -> [LintFinding] {
        rules.flatMap { $0.check(model: model, context: context) }
    }
}
