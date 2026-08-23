import Foundation
import TandhaCore

/// Emits a flat `{ "dot.path": "identifier" }` JSON map, sorted by key.
///
/// This is the lowest-common-denominator contract any Appium / Selenium-family
/// suite can load to look up `accessibility id` locators.
public struct JSONExporter: Exporter {
    public static let formatName = "json"
    public static let fileExtension = "json"

    public init() {}

    public func export(_ model: AutomationModel) -> String {
        // Build deterministic, human-diffable JSON by hand (sorted keys, 2-space).
        let pairs = model.entries
            .sorted { $0.dotPath < $1.dotPath }
            .map { "  \(encode($0.dotPath)): \(encode($0.identifier))" }
        if pairs.isEmpty { return "{}\n" }
        return "{\n" + pairs.joined(separator: ",\n") + "\n}\n"
    }

    private func encode(_ s: String) -> String {
        let escaped = s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }
}
