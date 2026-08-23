import Foundation

/// Helpers to turn contract keys into valid, idiomatic Swift identifiers.
enum SwiftIdentifier {
    /// Reserved words that must be back-tick escaped when used as identifiers.
    static let keywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
        "func", "import", "init", "inout", "internal", "let", "open", "operator",
        "private", "protocol", "public", "rethrows", "static", "struct",
        "subscript", "typealias", "var", "break", "case", "continue", "default",
        "defer", "do", "else", "fallthrough", "for", "guard", "if", "in",
        "repeat", "return", "switch", "where", "while", "as", "Any", "catch",
        "false", "is", "nil", "super", "self", "Self", "throw", "throws", "true",
        "try", "_", "async", "await", "actor", "some", "any",
    ]

    /// Lower-camelCase a key for a leaf constant name: `username_field` -> `usernameField`.
    static func camelCased(_ raw: String) -> String {
        let parts = split(raw)
        guard let first = parts.first else { return sanitizeFallback(raw) }
        var result = lowercaseFirst(first)
        for part in parts.dropFirst() { result += uppercaseFirst(part) }
        return escape(sanitizeLeading(result))
    }

    /// Sanitize a key for a group enum name, preserving its shape:
    /// `bottom_sheet` -> `bottom_sheet`, `2fa` -> `_2fa`.
    static func groupName(_ raw: String) -> String {
        var cleaned = String(raw.unicodeScalars.map { isIdentifierScalar($0) ? Character($0) : "_" })
        if cleaned.isEmpty { cleaned = "_" }
        return escape(sanitizeLeading(cleaned))
    }

    // MARK: internals

    private static func split(_ raw: String) -> [String] {
        raw.split(whereSeparator: { $0 == "_" || $0 == "-" || $0 == " " || $0 == "." })
            .map(String.init)
    }

    private static func lowercaseFirst(_ s: String) -> String {
        guard let first = s.first else { return s }
        return first.lowercased() + s.dropFirst()
    }

    private static func uppercaseFirst(_ s: String) -> String {
        guard let first = s.first else { return s }
        return first.uppercased() + s.dropFirst()
    }

    private static func isIdentifierScalar(_ scalar: Unicode.Scalar) -> Bool {
        let c = Character(scalar)
        return c.isLetter || c.isNumber || c == "_"
    }

    /// Prefix with `_` when the identifier would start with a digit.
    private static func sanitizeLeading(_ s: String) -> String {
        guard let first = s.first else { return "_" }
        return first.isNumber ? "_" + s : s
    }

    private static func sanitizeFallback(_ raw: String) -> String {
        let cleaned = String(raw.unicodeScalars.map { isIdentifierScalar($0) ? Character($0) : "_" })
        return escape(sanitizeLeading(cleaned.isEmpty ? "_" : cleaned))
    }

    private static func escape(_ s: String) -> String {
        keywords.contains(s) ? "`\(s)`" : s
    }
}
