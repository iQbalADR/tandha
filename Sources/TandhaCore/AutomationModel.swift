import Foundation

/// A parsed automation-identifier contract.
///
/// Loads the namespaced JSON described in `docs/format.md` and exposes it three
/// ways:
/// - `root`: the ordered node tree (used by codegen),
/// - `entries`: every leaf, flattened and ordered,
/// - `resolve(_:)` / `map`: dot-path -> resolved identifier lookups.
///
/// ## Leaf vs. group
/// - A **string** value is a leaf. Non-empty is an explicit identifier; empty
///   auto-derives the identifier from the dot path.
/// - A **null** value is a leaf that auto-derives its identifier.
/// - An **object containing `$id`** is a leaf with metadata. `$id` is the
///   identifier (auto-derived when empty/null); `description` / `screen` /
///   `owner` are optional metadata.
/// - Any other **object** is a group; its keys are recursed into.
public struct AutomationModel: Equatable {
    /// Ordered top-level nodes (groups sort before/after leaves by key).
    public let root: [AutomationNode]
    /// Every leaf entry, flattened in stable (sorted-by-path) order.
    public let entries: [AutomationIDEntry]
    /// Dot-path -> entry. On duplicate dot-paths, the last one loaded wins.
    public let map: [String: AutomationIDEntry]

    // MARK: Loading

    /// Parse a contract from raw JSON `Data`.
    public init(data: Data) throws {
        let object = try Self.topLevelObject(from: data)
        let root = try Self.buildNodes(from: object, path: [])
        self.init(root: root)
    }

    /// Parse a contract from a JSON file on disk.
    public init(contentsOf url: URL) throws {
        guard let data = try? Data(contentsOf: url) else {
            throw AutomationIDError.fileNotReadable(path: url.path)
        }
        try self.init(data: data)
    }

    /// Parse and merge multiple contract files by namespace. Later files add to
    /// (and, on identical dot-paths, override) earlier ones.
    public init(mergingContentsOf urls: [URL]) throws {
        var merged: [AutomationNode] = []
        for url in urls {
            let model = try AutomationModel(contentsOf: url)
            merged = Self.merge(merged, model.root)
        }
        self.init(root: merged)
    }

    /// Build directly from a node tree (used by merge and tests).
    public init(root: [AutomationNode]) {
        self.root = root
        let flat = Self.flatten(root)
        self.entries = flat
        // Last-writer-wins so merged overrides take effect; lint reports dupes.
        var map: [String: AutomationIDEntry] = [:]
        for entry in flat { map[entry.dotPath] = entry }
        self.map = map
    }

    // MARK: Resolution

    /// Resolve a dot-path key to its identifier, or `nil` if undefined.
    public func resolve(_ dotPath: String) -> String? {
        map[dotPath]?.identifier
    }

    /// Resolve a dot-path key to its identifier, falling back to the key itself
    /// (which matches the auto-derive default) when it is undefined.
    public func identifier(forKey dotPath: String) -> String {
        map[dotPath]?.identifier ?? dotPath
    }

    // MARK: JSON walking

    private static func topLevelObject(from data: Data) throws -> [String: Any] {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let object = json as? [String: Any] else {
            throw AutomationIDError.rootNotObject
        }
        return object
    }

    private static let idKey = "$id"
    private static let metadataKeys: Set<String> = ["$id", "description", "screen", "owner"]

    private static func buildNodes(from object: [String: Any], path: [String]) throws -> [AutomationNode] {
        var nodes: [AutomationNode] = []
        // Stable output regardless of JSON key order.
        for key in object.keys.sorted() {
            let childPath = path + [key]
            let value = object[key] as Any
            nodes.append(try buildNode(from: value, path: childPath))
        }
        return nodes
    }

    private static func buildNode(from value: Any, path: [String]) throws -> AutomationNode {
        let derived = path.joined(separator: ".")

        if value is NSNull {
            return .leaf(AutomationIDEntry(path: path, identifier: derived))
        }
        if let string = value as? String {
            let id = string.isEmpty ? derived : string
            return .leaf(AutomationIDEntry(path: path, identifier: id))
        }
        if let dict = value as? [String: Any] {
            if dict.keys.contains(idKey) {
                return try leafWithMetadata(from: dict, path: path, derived: derived)
            }
            let children = try buildNodes(from: dict, path: path)
            return .group(name: path.last ?? "", path: path, children: children)
        }
        // Numbers, bools, arrays are not valid contract values.
        throw AutomationIDError.unsupportedValue(path: derived)
    }

    private static func leafWithMetadata(
        from dict: [String: Any],
        path: [String],
        derived: String
    ) throws -> AutomationNode {
        let identifier: String
        switch dict[idKey] {
        case let string as String:
            identifier = string.isEmpty ? derived : string
        case is NSNull, .none:
            identifier = derived
        default:
            throw AutomationIDError.invalidIdentifier(path: derived)
        }
        let entry = AutomationIDEntry(
            path: path,
            identifier: identifier,
            description: dict["description"] as? String,
            screen: dict["screen"] as? String,
            owner: dict["owner"] as? String
        )
        return .leaf(entry)
    }

    // MARK: Flatten & merge

    private static func flatten(_ nodes: [AutomationNode]) -> [AutomationIDEntry] {
        var result: [AutomationIDEntry] = []
        for node in nodes {
            switch node {
            case .leaf(let entry):
                result.append(entry)
            case .group(_, _, let children):
                result.append(contentsOf: flatten(children))
            }
        }
        return result
    }

    /// Merge two node lists by name. Groups with the same name are merged
    /// recursively; leaves (and leaf-vs-group conflicts) are overridden by the
    /// incoming node. Output stays sorted by name.
    private static func merge(_ base: [AutomationNode], _ incoming: [AutomationNode]) -> [AutomationNode] {
        var byName: [String: AutomationNode] = [:]
        for node in base { byName[node.name] = node }
        for node in incoming {
            if case .group(let name, let path, let newChildren) = node,
               case .group(_, _, let oldChildren)? = byName[name] {
                byName[name] = .group(name: name, path: path, children: merge(oldChildren, newChildren))
            } else {
                byName[node.name] = node
            }
        }
        return byName.keys.sorted().compactMap { byName[$0] }
    }
}
