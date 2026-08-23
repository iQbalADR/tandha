# Installation

tandha supports **iOS 15+**, **tvOS 15+**, and **macOS 12+** (the CLI and codegen
plugin run on macOS). Install with **Swift Package Manager** or **CocoaPods**.

## Swift Package Manager

### Add the package

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/iQbalADR/tandha.git", from: "0.1.0")
]
```

### Choose products per target

tandha ships focused products so each target pulls in only what it needs.

| Product | Use it in | Provides |
|---------|-----------|----------|
| `Tandha` | App target | Core resolver + SwiftUI / UIKit / XIB bindings (`import Tandha`) |
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

`import Tandha` gives the whole app-side API. The sub-modules (`TandhaCore`,
`TandhaUIKit`, `TandhaSwiftUI`) stay importable if you want finer granularity.

## CocoaPods

Add tandha via subspecs. The default (`pod 'Tandha'`) gives the core resolver plus the
UIKit and SwiftUI bindings; the XCUITest accessors are an opt-in subspec for UI test
targets.

```ruby
# Podfile
target 'App' do
  use_frameworks!
  pod 'Tandha'                 # Core + UIKit + SwiftUI

  target 'AppUITests' do
    inherit! :search_paths
    pod 'Tandha/XCUITest'      # typed XCUITest accessors
  end
end
```

With CocoaPods everything is one module — `import Tandha` in both the app and the UI
test target. Run `pod install`, then open the generated `.xcworkspace`.

!!! note "Pick individual pieces"
    You can depend on just what you need: `pod 'Tandha/Core'`, `pod 'Tandha/UIKit'`,
    or `pod 'Tandha/SwiftUI'`.

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

!!! note "CocoaPods"
    Build-tool plugins are a Swift Package Manager feature. On CocoaPods, run the
    `tandha generate` CLI (e.g. as an Xcode build phase) instead.

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
