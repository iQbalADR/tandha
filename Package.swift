// swift-tools-version:5.9
//
// tandha — Centralized UI automation-identifier toolkit for iOS.
// https://github.com/iQbalADR/tandha
import PackageDescription

let package = Package(
    name: "tandha",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
    ],
    products: [
        // App-side: define + assign automation identifiers. The `Tandha`
        // umbrella re-exports Core + UIKit + SwiftUI (so `import Tandha` works,
        // matching the CocoaPods module); the sub-modules stay importable too.
        .library(name: "Tandha", targets: ["Tandha", "TandhaCore", "TandhaUIKit", "TandhaSwiftUI"]),
        // Test-side: typed XCUITest accessors.
        .library(name: "TandhaXCUITest", targets: ["TandhaXCUITest"]),
        // Tooling libraries, usable programmatically outside the CLI.
        .library(name: "TandhaTooling", targets: ["TandhaCodegen", "TandhaExport", "TandhaLint"]),
        // The command-line tool. Product/command is `tandha`; the target is
        // `TandhaCLI` so its module name doesn't collide (case-insensitively)
        // with the `Tandha` umbrella library on case-insensitive filesystems.
        .executable(name: "tandha", targets: ["TandhaCLI"]),
        // Build-time codegen plugin.
        .plugin(name: "TandhaCodegenPlugin", targets: ["TandhaCodegenPlugin"]),
    ],
    targets: [
        // MARK: core
        .target(name: "TandhaCore"),

        // MARK: umbrella (re-exports the app-side modules as `import Tandha`)
        .target(name: "Tandha", dependencies: ["TandhaCore", "TandhaUIKit", "TandhaSwiftUI"]),

        // MARK: bindings
        .target(name: "TandhaUIKit", dependencies: ["TandhaCore"]),
        .target(name: "TandhaSwiftUI", dependencies: ["TandhaCore"]),

        // MARK: xcuitest
        .target(name: "TandhaXCUITest", dependencies: ["TandhaCore"]),

        // MARK: tooling
        .target(name: "TandhaCodegen", dependencies: ["TandhaCore"]),
        .target(name: "TandhaExport", dependencies: ["TandhaCore"]),
        .target(name: "TandhaLint", dependencies: ["TandhaCore"]),

        // MARK: cli
        .executableTarget(
            name: "TandhaCLI",
            dependencies: ["TandhaCore", "TandhaCodegen", "TandhaExport", "TandhaLint"]
        ),

        // MARK: build-tool plugin
        .plugin(
            name: "TandhaCodegenPlugin",
            capability: .buildTool(),
            dependencies: ["TandhaCLI"]
        ),

        // MARK: tests
        .testTarget(name: "TandhaCoreTests", dependencies: ["TandhaCore"]),
        .testTarget(name: "TandhaCodegenTests", dependencies: ["TandhaCodegen", "TandhaCore"]),
        .testTarget(name: "TandhaExportTests", dependencies: ["TandhaExport", "TandhaCore"]),
        .testTarget(name: "TandhaLintTests", dependencies: ["TandhaLint", "TandhaCore"]),
    ]
)
