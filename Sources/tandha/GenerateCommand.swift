import Foundation
import TandhaCore
import TandhaCodegen

/// `tandha generate` — JSON contract -> Swift enum tree.
enum GenerateCommand {
    static let usage = """
    Usage: tandha generate <contract.json>... [options]

    Generate a compile-time-safe Swift enum tree from the contract.

    Options:
      --output <file>     Write to file (default: stdout)
      --root-name <name>  Root enum name (default: AutomationID)
      --access <level>    Access level: public | internal (default: public)
      --no-doc-comments   Omit doc comments derived from metadata
      --help              Show this help
    """

    static func run(_ raw: [String]) -> Int32 {
        let args = Arguments(raw, flagNames: ["no-doc-comments", "help"])
        if args.flag("help") { IO.out(usage); return 0 }
        guard !args.positionals.isEmpty else { IO.err(usage); return 2 }

        do {
            let model = try IO.loadModel(inputs: args.positionals)
            var generator = SwiftEnumGenerator()
            if let root = args.option("root-name") { generator.rootName = root }
            if let access = args.option("access") { generator.accessLevel = access }
            if args.flag("no-doc-comments") { generator.emitDocComments = false }
            try IO.write(generator.generate(model), to: args.option("output"))
            return 0
        } catch {
            IO.err("error: \(error)")
            return 1
        }
    }
}
