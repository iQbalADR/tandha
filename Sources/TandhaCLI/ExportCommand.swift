import Foundation
import TandhaCore
import TandhaExport

/// `tandha export` — emit the contract for external QA tooling.
enum ExportCommand {
    static var usage: String {
        """
        Usage: tandha export <contract.json>... --format <name> [options]

        Export the identifier contract for Appium / Katalon / Selenium-family tools.

        Options:
          --format <name>  One of: \(Exporters.formatNames.joined(separator: ", "))
          --output <file>  Write to file (default: stdout)
          --help           Show this help
        """
    }

    static func run(_ raw: [String]) -> Int32 {
        let args = Arguments(raw, flagNames: ["help"])
        if args.flag("help") { IO.out(usage); return 0 }
        guard !args.positionals.isEmpty else { IO.err(usage); return 2 }

        guard let format = args.option("format") else {
            IO.err("error: --format is required\n")
            IO.err(usage)
            return 2
        }
        guard let exporter = Exporters.exporter(named: format) else {
            IO.err("error: unknown format \"\(format)\". Available: \(Exporters.formatNames.joined(separator: ", "))")
            return 2
        }

        do {
            let model = try IO.loadModel(inputs: args.positionals)
            try IO.write(exporter.export(model), to: args.option("output"))
            return 0
        } catch {
            IO.err("error: \(error)")
            return 1
        }
    }
}
