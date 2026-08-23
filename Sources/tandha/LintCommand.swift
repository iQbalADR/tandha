import Foundation
import TandhaCore
import TandhaLint

/// `tandha lint` — validate the contract; non-zero exit on errors (CI-friendly).
enum LintCommand {
    static let usage = """
    Usage: tandha lint <contract.json>... [options]

    Validate the contract. Exits non-zero if any error-level finding is present.

    Checks: duplicate identifiers, missing keys, unused keys, naming convention.

    Options:
      --sources <dir>       Scan dir for references (enables unused-key). Repeatable.
      --naming <pattern>    Enforce a naming regex, or a preset: snake | dotted-snake
      --expect-keys <file>  Newline-delimited keys that must exist (missing-key)
      --basic               Run only always-safe checks (duplicate identifiers)
      --help                Show this help
    """

    static func run(_ raw: [String]) -> Int32 {
        let args = Arguments(raw, flagNames: ["basic", "help"])
        if args.flag("help") { IO.out(usage); return 0 }
        guard !args.positionals.isEmpty else { IO.err(usage); return 2 }

        do {
            let model = try IO.loadModel(inputs: args.positionals)
            let context = try buildContext(args)
            let linter = args.flag("basic") ? Linter.basic : Linter.all
            let findings = linter.run(model: model, context: context)

            if findings.isEmpty {
                IO.out("OK — \(model.entries.count) identifiers, no issues.")
                return 0
            }
            for finding in findings.sorted(by: { $0.description < $1.description }) {
                IO.out(finding.description)
            }
            let errors = findings.filter { $0.severity == .error }.count
            let warnings = findings.count - errors
            IO.out("\n\(errors) error(s), \(warnings) warning(s).")
            return findings.hasErrors ? 1 : 0
        } catch {
            IO.err("error: \(error)")
            return 1
        }
    }

    private static func buildContext(_ args: Arguments) throws -> LintContext {
        var context = LintContext()

        let sources = args.optionValues("sources")
        if !sources.isEmpty {
            context.sourceCorpus = SourceScanner().scan(paths: sources)
        }

        if let naming = args.option("naming") {
            switch naming {
            case "snake": context.namingPattern = NamingConventionRule.Patterns.snakeCase
            case "dotted-snake": context.namingPattern = NamingConventionRule.Patterns.dottedSnakeCase
            default: context.namingPattern = naming
            }
        }

        if let path = args.option("expect-keys") {
            let text = try String(contentsOfFile: path, encoding: .utf8)
            let keys = text
                .split(whereSeparator: \.isNewline)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            context.expectedKeys = Set(keys)
        }

        return context
    }
}
