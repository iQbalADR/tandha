import Foundation
import TandhaCore

/// Emits `key,identifier,description,screen,owner` CSV (RFC 4180 quoting),
/// sorted by key. Handy for spreadsheets and QA documentation.
public struct CSVExporter: Exporter {
    public static let formatName = "csv"
    public static let fileExtension = "csv"

    public init() {}

    public func export(_ model: AutomationModel) -> String {
        var rows = ["key,identifier,description,screen,owner"]
        for entry in model.entries.sorted(by: { $0.dotPath < $1.dotPath }) {
            let fields = [
                entry.dotPath,
                entry.identifier,
                entry.description ?? "",
                entry.screen ?? "",
                entry.owner ?? "",
            ]
            rows.append(fields.map(escape).joined(separator: ","))
        }
        return rows.joined(separator: "\n") + "\n"
    }

    private func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else {
            return field
        }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
