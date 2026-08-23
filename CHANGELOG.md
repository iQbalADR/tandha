# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/iQbalADR/tandha/commits/main
