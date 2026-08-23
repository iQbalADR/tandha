import Foundation

let tandhaVersion = "0.1.0"

let topLevelUsage = """
tandha \(tandhaVersion) — centralized UI automation-identifier toolkit for iOS.

Usage: tandha <command> [options]

Commands:
  generate   Generate a Swift enum tree from the JSON contract
  export     Export the contract for Appium / Katalon / Selenium-family tools
  lint       Validate the contract (CI-friendly exit codes)

Run `tandha <command> --help` for command-specific options.

Other:
  --version  Print version
  --help     Show this help
"""

let arguments = Array(CommandLine.arguments.dropFirst())

func dispatch(_ arguments: [String]) -> Int32 {
    guard let command = arguments.first else {
        IO.out(topLevelUsage)
        return 0
    }
    let rest = Array(arguments.dropFirst())

    switch command {
    case "generate": return GenerateCommand.run(rest)
    case "export": return ExportCommand.run(rest)
    case "lint": return LintCommand.run(rest)
    case "--version", "-v", "version":
        IO.out(tandhaVersion)
        return 0
    case "--help", "-h", "help":
        IO.out(topLevelUsage)
        return 0
    default:
        IO.err("error: unknown command \"\(command)\"\n")
        IO.err(topLevelUsage)
        return 2
    }
}

exit(dispatch(arguments))
