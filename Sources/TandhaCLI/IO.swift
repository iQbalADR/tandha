import Foundation
import TandhaCore

/// Shared input/output helpers for the CLI commands.
enum IO {
    /// Load a model from one file, or merge several by namespace.
    static func loadModel(inputs: [String]) throws -> AutomationModel {
        let urls = inputs.map { URL(fileURLWithPath: $0) }
        if urls.count == 1 {
            return try AutomationModel(contentsOf: urls[0])
        }
        return try AutomationModel(mergingContentsOf: urls)
    }

    /// Write text to `path`, or to stdout when `path` is nil.
    static func write(_ text: String, to path: String?) throws {
        if let path {
            try text.write(toFile: path, atomically: true, encoding: .utf8)
        } else {
            FileHandle.standardOutput.write(Data(text.utf8))
        }
    }

    static func out(_ text: String) {
        FileHandle.standardOutput.write(Data((text + "\n").utf8))
    }

    static func err(_ text: String) {
        FileHandle.standardError.write(Data((text + "\n").utf8))
    }
}
