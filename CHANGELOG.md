# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-08-23

### Added

- **Core** — namespaced JSON contract parser, flattener, and resolver
  (`AutomationModel`), plus a process-wide `AutomationRegistry` for key-based
  resolution. Supports explicit and auto-derived identifiers, `$id` metadata
  leaves, and multi-file merge by namespace.
- **Bindings** — SwiftUI `.automationID(_:)` / `.automationKey(_:)`, UIKit
  `setAutomationID(_:)` / `setAutomationKey(_:)`, and the XIB `automationKey`
  `@IBInspectable`.
- **XCUITest** — typed query accessors (`query[automationID:]`,
  `app.element(_:type:)`).
- **Codegen** — `tandha generate` produces a compile-time-safe Swift enum tree;
  also available as a SwiftPM build-tool plugin (`TandhaCodegenPlugin`).
- **Export** — `tandha export` to flat JSON, CSV, and an Appium/Katalon-friendly
  Java page object.
- **Lint** — `tandha lint` with duplicate-identifier, missing-key, unused-key, and
  naming-convention rules, and CI-friendly exit codes.
- **Distribution** — CocoaPods support via `Tandha.podspec` (Core / UIKit / SwiftUI /
  XCUITest subspecs) alongside Swift Package Manager, plus a `Tandha` umbrella module
  so `import Tandha` works under both.

### Changed

- Minimum deployment targets raised to **iOS 15 / tvOS 15 / macOS 12**.

[Unreleased]: https://github.com/iQbalADR/tandha/compare/0.1.0...HEAD
[0.1.0]: https://github.com/iQbalADR/tandha/releases/tag/0.1.0
