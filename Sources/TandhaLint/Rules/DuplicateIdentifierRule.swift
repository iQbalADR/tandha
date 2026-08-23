import Foundation
import TandhaCore

/// Flags identifier strings shared by more than one key. Duplicates make QA
/// queries ambiguous — two elements answer to the same `accessibility id`.
public struct DuplicateIdentifierRule: LintRule {
    public let name = "duplicate-identifier"

    public init() {}

    public func check(model: AutomationModel, context: LintContext) -> [LintFinding] {
        var keysByIdentifier: [String: [String]] = [:]
        for entry in model.entries {
            keysByIdentifier[entry.identifier, default: []].append(entry.dotPath)
        }
        return keysByIdentifier
            .filter { $0.value.count > 1 }
            .sorted { $0.key < $1.key }
            .map { identifier, keys in
                LintFinding(
                    severity: .error,
                    rule: name,
                    message: "identifier \"\(identifier)\" is used by \(keys.count) keys: \(keys.sorted().joined(separator: ", "))"
                )
            }
    }
}
