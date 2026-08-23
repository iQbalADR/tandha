import Foundation

/// Errors surfaced while loading or parsing an automation-identifier contract.
public enum AutomationIDError: Error, Equatable, CustomStringConvertible {
    /// The file could not be read.
    case fileNotReadable(path: String)
    /// The top-level JSON value was not an object.
    case rootNotObject
    /// A value at `path` was of an unsupported JSON type (array/number/bool).
    case unsupportedValue(path: String)
    /// The `$id` marker was present but not a string or null.
    case invalidIdentifier(path: String)

    public var description: String {
        switch self {
        case .fileNotReadable(let path):
            return "Cannot read contract file at \(path)"
        case .rootNotObject:
            return "The contract JSON must have an object at its root"
        case .unsupportedValue(let path):
            return "Unsupported value at \(path): expected a string, null, or object"
        case .invalidIdentifier(let path):
            return "The \"$id\" at \(path) must be a string or null"
        }
    }
}
