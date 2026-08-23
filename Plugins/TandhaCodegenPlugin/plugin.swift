import Foundation
import PackagePlugin

/// Build-tool plugin: regenerates the Swift enum tree from every
/// `*.automationids.json` file in a target, at build time.
///
/// Add it to a target:
/// ```swift
/// .target(
///     name: "App",
///     plugins: [.plugin(name: "TandhaCodegenPlugin", package: "tandha")]
/// )
/// ```
/// Drop `something.automationids.json` in the target's sources; the generated
/// `AutomationID` enum is compiled in automatically. No output to check in.
@main
struct TandhaCodegenPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else { return [] }
        return try commands(
            tool: context.tool(named: "TandhaCLI"),
            workDir: context.pluginWorkDirectory,
            inputs: sourceTarget.sourceFiles.map(\.path)
        )
    }

    private func commands(tool: PluginContext.Tool, workDir: Path, inputs: [Path]) throws -> [Command] {
        inputs
            .filter { $0.lastComponent.hasSuffix(".automationids.json") }
            .map { input in
                let output = workDir.appending("\(input.stem).generated.swift")
                return .buildCommand(
                    displayName: "tandha generate \(input.lastComponent)",
                    executable: tool.path,
                    arguments: ["generate", input.string, "--output", output.string],
                    inputFiles: [input],
                    outputFiles: [output]
                )
            }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension TandhaCodegenPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        try commands(
            tool: context.tool(named: "TandhaCLI"),
            workDir: context.pluginWorkDirectory,
            inputs: target.inputFiles.map(\.path)
        )
    }
}
#endif
