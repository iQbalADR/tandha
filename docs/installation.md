# Installation

tandha is a Swift Package. It supports **iOS 13+**, **tvOS 13+**, and **macOS 10.15+**
(the CLI and codegen plugin run on macOS).

## Add the package

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/iQbalADR/tandha.git", from: "0.1.0")
]
```

## Choose products per target

tandha ships focused products so each target pulls in only what it needs.

| Product | Use it in | Provides |
|---------|-----------|----------|
| `Tandha` | App target | Core resolver + SwiftUI / UIKit / XIB bindings |
| `TandhaXCUITest` | UI test target | Typed XCUITest query accessors |
| `TandhaTooling` | Tools / scripts | Codegen, export, and lint as libraries |
| `TandhaCodegenPlugin` | Any target | Build-time codegen (see below) |

```swift
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Tandha", package: "tandha"),
    ]),
    .testTarget(name: "AppUITests", dependencies: [
        .product(name: "TandhaXCUITest", package: "tandha"),
    ]),
]
```

## Optional: build-time codegen plugin

Skip the manual `generate` step — regenerate the `AutomationID` enum on every build.

```swift
.target(
    name: "App",
    plugins: [.plugin(name: "TandhaCodegenPlugin", package: "tandha")]
)
```

Drop a `*.automationids.json` file into the target's sources and the enum is compiled
in automatically. See [Codegen & plugin](codegen.md).

## The CLI

The `tandha` command-line tool is built by the package:

```bash
git clone https://github.com/iQbalADR/tandha.git
cd tandha
swift build -c release
.build/release/tandha --help

# optional: install onto your PATH
cp .build/release/tandha /usr/local/bin/tandha
```

!!! note "Dependency-free"
    tandha has **no external dependencies**, so it builds and tests offline. A
    Homebrew formula for the CLI will follow.

Next: the [60-second quickstart](quickstart.md).
