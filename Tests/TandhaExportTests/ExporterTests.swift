import XCTest
import TandhaCore
@testable import TandhaExport

final class ExporterTests: XCTestCase {
    private func model(_ json: String) throws -> AutomationModel {
        try AutomationModel(data: Data(json.utf8))
    }

    private let sample = """
    {
      "login": {
        "username_field": "login.username_field",
        "submit_button":  "login.submit_button"
      },
      "dashboard": { "balance_label": "dashboard.balance_label" }
    }
    """

    func testJSONExportIsFlatAndSorted() throws {
        let out = JSONExporter().export(try model(sample))
        let expected = """
        {
          "dashboard.balance_label": "dashboard.balance_label",
          "login.submit_button": "login.submit_button",
          "login.username_field": "login.username_field"
        }

        """
        XCTAssertEqual(out, expected)
    }

    func testJSONExportEmptyModel() throws {
        XCTAssertEqual(JSONExporter().export(try model("{}")), "{}\n")
    }

    func testCSVExportHeaderAndRows() throws {
        let out = CSVExporter().export(try model("""
        { "login": { "user": { "$id": "login.user", "description": "has, comma" } } }
        """))
        XCTAssertTrue(out.hasPrefix("key,identifier,description,screen,owner\n"))
        XCTAssertTrue(out.contains("login.user,login.user,\"has, comma\",,"))
    }

    func testJavaPageObjectExport() throws {
        let out = JavaPageObjectExporter().export(try model(sample))
        XCTAssertTrue(out.contains("public final class AutomationIDs {"))
        XCTAssertTrue(out.contains("public static final class Login {"))
        XCTAssertTrue(out.contains("public static final By usernameField = AppiumBy.accessibilityId(\"login.username_field\");"))
    }

    func testExporterLookupByName() {
        XCTAssertNotNil(Exporters.exporter(named: "json"))
        XCTAssertNotNil(Exporters.exporter(named: "CSV"))
        XCTAssertNotNil(Exporters.exporter(named: "java"))
        XCTAssertNil(Exporters.exporter(named: "xml"))
    }
}
