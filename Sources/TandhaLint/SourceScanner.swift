import Foundation

/// Reads source files under one or more directories into a single corpus string
/// for the unused-key heuristic.
public struct SourceScanner {
    /// File extensions to include (lowercased, no dot).
    public var extensions: Set<String>

    public init(extensions: Set<String> = ["swift"]) {
        self.extensions = extensions
    }

    /// Concatenate the text of every matching file under `paths`.
    public func scan(paths: [String]) -> String {
        let fm = FileManager.default
        var corpus = ""
        for path in paths {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: path, isDirectory: &isDir) else { continue }
            if isDir.boolValue {
                let url = URL(fileURLWithPath: path)
                let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: nil)
                while let file = enumerator?.nextObject() as? URL {
                    append(file, into: &corpus)
                }
            } else {
                append(URL(fileURLWithPath: path), into: &corpus)
            }
        }
        return corpus
    }

    private func append(_ url: URL, into corpus: inout String) {
        guard extensions.contains(url.pathExtension.lowercased()) else { return }
        if let text = try? String(contentsOf: url, encoding: .utf8) {
            corpus += text
            corpus += "\n"
        }
    }
}
