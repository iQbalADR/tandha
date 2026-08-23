import Foundation
import TandhaCore

/// Flags keys defined in the contract but never referenced in scanned source.
///
/// Requires `context.sourceCorpus` (populated by scanning source dirs). The
/// check is a heuristic: a key counts as referenced if its identifier string,
/// its dot-path, or its camelCased leaf name appears anywhere in the corpus —
/// which covers both direct string use and the generated `AutomationID.*`
/// constants. Reported as warnings, not errors.
public struct UnusedKeyRule: LintRule {
    public let name = "unused-key"

    public init() {}

    public func check(model: AutomationModel, context: LintContext) -> [LintFinding] {
        guard let corpus = context.sourceCorpus else { return [] }
        return model.entries.compactMap { entry -> LintFinding? in
            if isReferenced(entry, in: corpus) { return nil }
            return LintFinding(
                severity: .warning,
                rule: name,
                message: "key \"\(entry.dotPath)\" (identifier \"\(entry.identifier)\") is never referenced in scanned sources"
            )
        }
    }

    private func isReferenced(_ entry: AutomationIDEntry, in corpus: String) -> Bool {
        if corpus.contains(entry.identifier) { return true }
        if corpus.contains(entry.dotPath) { return true }
        let leaf = camelLeaf(entry.path.last ?? "")
        // Guard against very short names producing false "referenced" hits.
        if leaf.count >= 3, corpus.contains(leaf) { return true }
        return false
    }

    private func camelLeaf(_ raw: String) -> String {
        let parts = raw.split(whereSeparator: { $0 == "_" || $0 == "-" || $0 == " " }).map(String.init)
        guard let first = parts.first else { return raw }
        var result = first
        for part in parts.dropFirst() { result += part.prefix(1).uppercased() + part.dropFirst() }
        return result
    }
}
