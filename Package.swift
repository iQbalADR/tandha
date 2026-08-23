// swift-tools-version:5.9
//
// tandha — Centralized UI automation-identifier toolkit for iOS.
// https://github.com/iQbalADR/tandha
import PackageDescription

let package = Package(
    name: "tandha",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        // App-side: define + assign automation identifiers.
        .library(name: "Tandha", targets: ["TandhaCore", "TandhaUIKit", "TandhaSwiftUI"]),
        // Test-side: typed XCUITest accessors.
        .library(name: "TandhaXCUITest", targets: ["TandhaXCUITest"]),
        // Tooling libraries, usable programmatically outside the CLI.
        .library(name: "TandhaTooling", targets: ["TandhaCodegen", "TandhaExport", "TandhaLint"]),
        // The command-line tool.
        .executable(name: "tandha", targets: ["tandha"]),
        // Build-time codegen plugin.
        .plugin(name: "TandhaCodegenPlugin", targets: ["TandhaCodegenPlugin"]),
    ],
    targets: [
        // MARK: core
        .target(name: "TandhaCore"),

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
            name: "tandha",
            dependencies: ["TandhaCore", "TandhaCodegen", "TandhaExport", "TandhaLint"]
        ),

        // MARK: build-tool plugin
        .plugin(
            name: "TandhaCodegenPlugin",
            capability: .buildTool(),
            dependencies: ["tandha"]
        ),

        // MARK: tests
        .testTarget(name: "TandhaCoreTests", dependencies: ["TandhaCore"]),
        .testTarget(name: "TandhaCodegenTests", dependencies: ["TandhaCodegen", "TandhaCore"]),
        .testTarget(name: "TandhaExportTests", dependencies: ["TandhaExport", "TandhaCore"]),
        .testTarget(name: "TandhaLintTests", dependencies: ["TandhaLint", "TandhaCore"]),
    ]
)
