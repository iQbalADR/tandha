import XCTest
import TandhaCore
@testable import TandhaLint

final class LintTests: XCTestCase {
    private func model(_ json: String) throws -> AutomationModel {
        try AutomationModel(data: Data(json.utf8))
    }

    func testDuplicateIdentifierIsError() throws {
        let m = try model("""
        { "a": { "one": "dup", "two": "dup" }, "b": "unique" }
        """)
        let findings = DuplicateIdentifierRule().check(model: m, context: LintContext())
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .error)
        XCTAssertTrue(findings.first!.message.contains("a.one"))
        XCTAssertTrue(findings.first!.message.contains("a.two"))
    }

    func testNoDuplicatesIsClean() throws {
        let m = try model(#"{ "a": "1", "b": "2" }"#)
        XCTAssertTrue(DuplicateIdentifierRule().check(model: m, context: LintContext()).isEmpty)
    }

    func testMissingKeyIsError() throws {
        let m = try model(#"{ "login": { "a": "login.a" } }"#)
        let ctx = LintContext(expectedKeys: ["login.a", "login.missing"])
        let findings = MissingKeyRule().check(model: m, context: ctx)
        XCTAssertEqual(findings.count, 1)
        XCTAssertTrue(findings.first!.message.contains("login.missing"))
    }

    func testUnusedKeyWarnsWhenNotInCorpus() throws {
        let m = try model("""
        { "login": { "used_field": "login.used_field", "orphan_field": "login.orphan_field" } }
        """)
        let corpus = "someView.setAutomationID(AutomationID.login.usedField)"
        let ctx = LintContext(sourceCorpus: corpus)
        let findings = UnusedKeyRule().check(model: m, context: ctx)
        XCTAssertEqual(findings.count, 1)
        XCTAssertEqual(findings.first?.severity, .warning)
        XCTAssertTrue(findings.first!.message.contains("login.orphan_field"))
    }

    func testUnusedKeyMatchesByIdentifierString() throws {
        let m = try model(#"{ "login": { "field": "login.field" } }"#)
        let ctx = LintContext(sourceCorpus: #"query["login.field"]"#)
        XCTAssertTrue(UnusedKeyRule().check(model: m, context: ctx).isEmpty)
    }

    func testNamingConventionRejectsCamelCase() throws {
        let m = try model(#"{ "login": { "submitButton": "login.submitButton" } }"#)
        let ctx = LintContext(namingPattern: NamingConventionRule.Patterns.dottedSnakeCase)
        let findings = NamingConventionRule().check(model: m, context: ctx)
        XCTAssertEqual(findings.count, 1)
    }

    func testNamingConventionAcceptsDottedSnake() throws {
        let m = try model(#"{ "login": { "submit_button": "login.submit_button" } }"#)
        let ctx = LintContext(namingPattern: NamingConventionRule.Patterns.dottedSnakeCase)
        XCTAssertTrue(NamingConventionRule().check(model: m, context: ctx).isEmpty)
    }

    func testLinterAllAggregates() throws {
        let m = try model(#"{ "a": { "x": "dup", "y": "dup" } }"#)
        let findings = Linter.all.run(model: m, context: LintContext())
        XCTAssertTrue(findings.hasErrors)
    }

    func testLinterBasicOnlyDuplicates() throws {
        let m = try model(#"{ "login": { "submitButton": "login.submitButton" } }"#)
        // Naming would fail under `.all`, but `.basic` skips it.
        let ctx = LintContext(namingPattern: NamingConventionRule.Patterns.dottedSnakeCase)
        XCTAssertTrue(Linter.basic.run(model: m, context: ctx).isEmpty)
    }
}
