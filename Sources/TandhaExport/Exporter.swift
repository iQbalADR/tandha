import Foundation
import TandhaCore

/// A format that renders an `AutomationModel` into text for external QA tooling.
///
/// Each format is a single self-contained type, registered in `Exporters.all`.
public protocol Exporter {
    /// CLI-facing format name, e.g. `json`, `csv`, `java`.
    static var formatName: String { get }
    /// Conventional file extension for the output (no dot).
    static var fileExtension: String { get }
    /// Render the whole contract as a string.
    func export(_ model: AutomationModel) -> String
}

/// Registry of the built-in exporters, keyed by `formatName`.
public enum Exporters {
    public static let all: [any Exporter] = [
        JSONExporter(),
        CSVExporter(),
        JavaPageObjectExporter(),
    ]

    public static let formatNames: [String] = all.map { type(of: $0).formatName }

    /// Look up an exporter by its `formatName` (case-insensitive).
    public static func exporter(named name: String) -> (any Exporter)? {
        let lowered = name.lowercased()
        return all.first { type(of: $0).formatName == lowered }
    }
}
