import XCTest
import TandhaCore
@testable import TandhaCodegen

final class SwiftEnumGeneratorTests: XCTestCase {
    private func model(_ json: String) throws -> AutomationModel {
        try AutomationModel(data: Data(json.utf8))
    }

    func testGeneratesNestedEnumTree() throws {
        let m = try model("""
        {
          "login": {
            "username_field": "login.username_field",
            "submit_button":  "login.submit_button"
          }
        }
        """)
        let source = SwiftEnumGenerator(emitDocComments: false).generate(m)
        XCTAssertTrue(source.contains("public enum AutomationID {"))
        XCTAssertTrue(source.contains("public enum login {"))
        XCTAssertTrue(source.contains("public static let usernameField = \"login.username_field\""))
        XCTAssertTrue(source.contains("public static let submitButton = \"login.submit_button\""))
    }

    func testCustomRootNameAndAccessLevel() throws {
        let m = try model(#"{ "a": "a" }"#)
        let source = SwiftEnumGenerator(rootName: "IDs", accessLevel: "internal").generate(m)
        XCTAssertTrue(source.contains("internal enum IDs {"))
        XCTAssertTrue(source.contains("internal static let a = \"a\""))
    }

    func testEscapesSwiftKeywords() throws {
        let m = try model("""
        { "class": { "return": "class.return" } }
        """)
        let source = SwiftEnumGenerator(emitDocComments: false).generate(m)
        XCTAssertTrue(source.contains("enum `class` {"))
        XCTAssertTrue(source.contains("static let `return` = \"class.return\""))
    }

    func testEmitsDocCommentsFromMetadata() throws {
        let m = try model("""
        { "login": { "user": { "$id": "login.user", "description": "Username", "screen": "Login" } } }
        """)
        let source = SwiftEnumGenerator().generate(m)
        XCTAssertTrue(source.contains("/// Username"))
        XCTAssertTrue(source.contains("/// Screen: Login"))
    }

    func testLeadingDigitIsSanitized() throws {
        let m = try model(#"{ "2fa": { "code_field": "2fa.code_field" } }"#)
        let source = SwiftEnumGenerator(emitDocComments: false).generate(m)
        XCTAssertTrue(source.contains("enum _2fa {"))
    }

    func testGeneratedSourceQuotesAreEscaped() throws {
        let m = try model(#"{ "weird": "he said \"hi\"" }"#)
        let source = SwiftEnumGenerator(emitDocComments: false).generate(m)
        XCTAssertTrue(source.contains(#"= "he said \"hi\"""#))
    }
}
