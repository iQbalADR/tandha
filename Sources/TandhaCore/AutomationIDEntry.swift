import Foundation

/// A single resolved automation identifier: one leaf of the JSON contract.
///
/// The `identifier` is the exact string written to `accessibilityIdentifier`
/// and queried by XCUITest / Appium. `path` is the namespaced dot-path used to
/// address the entry (e.g. `["login", "submit_button"]`).
public struct AutomationIDEntry: Equatable, Hashable {
    /// Namespaced path components, e.g. `["login", "submit_button"]`.
    public let path: [String]
    /// The resolved identifier string set on the element.
    public let identifier: String
    /// Optional human description (QA docs / generated page objects).
    public let description: String?
    /// Optional screen name (grouping in docs).
    public let screen: String?
    /// Optional owning team.
    public let owner: String?

    public init(
        path: [String],
        identifier: String,
        description: String? = nil,
        screen: String? = nil,
        owner: String? = nil
    ) {
        self.path = path
        self.identifier = identifier
        self.description = description
        self.screen = screen
        self.owner = owner
    }

    /// The dot-path key used to address this entry, e.g. `"login.submit_button"`.
    public var dotPath: String { path.joined(separator: ".") }
}

/// The parsed contract as an ordered tree: either a leaf entry or a named group
/// of child nodes. Used by codegen to emit a matching nested Swift enum tree.
public indirect enum AutomationNode: Equatable {
    case leaf(AutomationIDEntry)
    case group(name: String, path: [String], children: [AutomationNode])

    /// The path component naming this node.
    public var name: String {
        switch self {
        case .leaf(let entry): return entry.path.last ?? ""
        case .group(let name, _, _): return name
        }
    }
}
