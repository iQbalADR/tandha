import Foundation
import TandhaCore

/// Inputs a rule may consult beyond the model itself.
public struct LintContext {
    /// Concatenated text of scanned source files, if a scan was requested.
    /// Enables the unused-key heuristic.
    public var sourceCorpus: String?
    /// Regex every identifier must fully match, if naming enforcement is on.
    public var namingPattern: String?
    /// Keys that are expected to exist (e.g. from a QA-owned list or a prior
    /// export). Any missing from the model is reported by `MissingKeyRule`.
    public var expectedKeys: Set<String>?

    public init(
        sourceCorpus: String? = nil,
        namingPattern: String? = nil,
        expectedKeys: Set<String>? = nil
    ) {
        self.sourceCorpus = sourceCorpus
        self.namingPattern = namingPattern
        self.expectedKeys = expectedKeys
    }
}

/// A self-contained lint check. Each rule lives in one file — an ideal
/// "good first issue".
public protocol LintRule {
    /// Stable rule id used in findings, e.g. `duplicate-identifier`.
    var name: String { get }
    /// Inspect the model and return any findings.
    func check(model: AutomationModel, context: LintContext) -> [LintFinding]
}
