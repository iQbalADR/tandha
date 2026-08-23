Pod::Spec.new do |s|
  # Confirm the name is free before publishing: `pod trunk info Tandha`.
  s.name             = 'Tandha'
  s.version          = '0.1.0'
  s.summary          = 'Centralized UI automation-identifier toolkit for iOS.'
  s.description      = <<-DESC
    tandha turns iOS UI automation identifiers into one shared JSON contract: set an
    identifier once via XIB, UIKit, or SwiftUI, and query the same value from XCUITest
    and Appium-based tools. Type-safe codegen, export, and lint ship with the package.
  DESC
  s.homepage         = 'https://github.com/iQbalADR/tandha'
  s.documentation_url = 'https://iqbaladr.github.io/tandha/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iQbalADR' => 'iqbal.adr@gmail.com' }
  s.source           = { :git => 'https://github.com/iQbalADR/tandha.git', :tag => s.version.to_s }

  s.swift_versions = ['5.9']
  s.ios.deployment_target  = '15.0'
  s.osx.deployment_target  = '12.0'
  s.tvos.deployment_target = '15.0'

  # App-side by default: core resolver + registry and the UIKit / SwiftUI bindings.
  # (The XCUITest subspec is opt-in — it links XCTest, for UI test targets only.)
  s.default_subspecs = 'Core', 'UIKit', 'SwiftUI'

  # Parser -> flattener -> resolver (key -> identifier) + AutomationRegistry.
  s.subspec 'Core' do |core|
    core.source_files = 'Sources/TandhaCore/**/*.swift'
    core.frameworks   = 'Foundation'
  end

  # UIKit helper + XIB @IBInspectable. UIKit only exists on iOS/tvOS; the sources
  # compile away on macOS via `#if canImport(UIKit)`.
  s.subspec 'UIKit' do |ui|
    ui.source_files   = 'Sources/TandhaUIKit/**/*.swift'
    ui.dependency 'Tandha/Core'
    ui.ios.frameworks  = 'UIKit'
    ui.tvos.frameworks = 'UIKit'
  end

  # SwiftUI `.automationID(_:)` view modifier.
  s.subspec 'SwiftUI' do |sw|
    sw.source_files = 'Sources/TandhaSwiftUI/**/*.swift'
    sw.dependency 'Tandha/Core'
    sw.frameworks   = 'SwiftUI'
  end

  # Typed XCUITest query accessors. Opt-in for UI test targets:
  #   pod 'Tandha/XCUITest'
  s.subspec 'XCUITest' do |xc|
    xc.source_files = 'Sources/TandhaXCUITest/**/*.swift'
    xc.dependency 'Tandha/Core'
    xc.frameworks   = 'XCTest'
  end
end
