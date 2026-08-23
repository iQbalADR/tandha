import Foundation

/// Minimal argument splitter: positionals, `--flag`, and `--key value` /
/// `--key=value` options (options may repeat).
struct Arguments {
    private(set) var positionals: [String] = []
    private(set) var options: [String: [String]] = [:]
    private(set) var flags: Set<String> = []

    init(_ args: [String], flagNames: Set<String>) {
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg.hasPrefix("--") {
                let body = String(arg.dropFirst(2))
                if let eq = body.firstIndex(of: "=") {
                    let name = String(body[..<eq])
                    let value = String(body[body.index(after: eq)...])
                    options[name, default: []].append(value)
                } else if flagNames.contains(body) {
                    flags.insert(body)
                } else {
                    index += 1
                    if index < args.count { options[body, default: []].append(args[index]) }
                }
            } else {
                positionals.append(arg)
            }
            index += 1
        }
    }

    func option(_ name: String) -> String? { options[name]?.last }
    func optionValues(_ name: String) -> [String] { options[name] ?? [] }
    func flag(_ name: String) -> Bool { flags.contains(name) }
}
