// Umbrella module: `import Tandha` gives the whole app-side API (core resolver +
// registry, UIKit helpers, SwiftUI modifier) in one import — matching the
// single-module `import Tandha` a CocoaPods install provides.
//
// Prefer this over importing the sub-modules individually. The sub-modules
// (TandhaCore / TandhaUIKit / TandhaSwiftUI) remain importable for fine-grained use.
@_exported import TandhaCore
@_exported import TandhaUIKit
@_exported import TandhaSwiftUI
