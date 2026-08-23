import Foundation
import TandhaCore

/// Flags keys that are expected to exist (from `context.expectedKeys`, e.g. a
/// QA-owned list or a previous export) but are absent from the contract. Catches
/// the classic drift where a developer renames a key and QA's scripts break.
public struct MissingKeyRule: LintRule {
    public let name = "missing-key"

    public init() {}

    public func check(model: AutomationModel, context: LintContext) -> [LintFinding] {
        guard let expected = context.expectedKeys else { return [] }
        return expected
            .subtracting(model.map.keys)
            .sorted()
            .map {
                LintFinding(
                    severity: .error,
                    rule: name,
                    message: "expected key \"\($0)\" is not defined in the contract"
                )
            }
    }
}
