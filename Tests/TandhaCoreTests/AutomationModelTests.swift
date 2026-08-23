import XCTest
@testable import TandhaCore

final class AutomationModelTests: XCTestCase {
    private func model(_ json: String) throws -> AutomationModel {
        try AutomationModel(data: Data(json.utf8))
    }

    func testParsesNamespacedExample() throws {
        let m = try model("""
        {
          "login": {
            "username_field": "login.username_field",
            "password_field": "login.password_field",
            "submit_button":  "login.submit_button"
          },
          "dashboard": {
            "balance_label": "dashboard.balance_label"
          }
        }
        """)
        XCTAssertEqual(m.entries.count, 4)
        XCTAssertEqual(m.resolve("login.submit_button"), "login.submit_button")
        XCTAssertEqual(m.resolve("dashboard.balance_label"), "dashboard.balance_label")
        XCTAssertNil(m.resolve("login.nope"))
    }

    func testExplicitIdentifierWins() throws {
        let m = try model("""
        { "login": { "submit_button": "legacy_submit_id" } }
        """)
        XCTAssertEqual(m.resolve("login.submit_button"), "legacy_submit_id")
    }

    func testAutoDeriveFromNullAndEmptyString() throws {
        let m = try model("""
        { "login": { "a": null, "b": "" } }
        """)
        XCTAssertEqual(m.resolve("login.a"), "login.a")
        XCTAssertEqual(m.resolve("login.b"), "login.b")
    }

    func testLeafWithMetadata() throws {
        let m = try model("""
        {
          "login": {
            "username_field": {
              "$id": "login.username_field",
              "description": "The username input",
              "screen": "Login",
              "owner": "auth-team"
            }
          }
        }
        """)
        let entry = try XCTUnwrap(m.map["login.username_field"])
        XCTAssertEqual(entry.identifier, "login.username_field")
        XCTAssertEqual(entry.description, "The username input")
        XCTAssertEqual(entry.screen, "Login")
        XCTAssertEqual(entry.owner, "auth-team")
    }

    func testMetadataLeafAutoDerivesWhenIdOmitted() throws {
        let m = try model("""
        { "login": { "field": { "$id": null, "description": "x" } } }
        """)
        XCTAssertEqual(m.resolve("login.field"), "login.field")
        XCTAssertEqual(m.map["login.field"]?.description, "x")
    }

    func testIdentifierForKeyFallsBackToKey() throws {
        let m = try model("{}")
        XCTAssertEqual(m.identifier(forKey: "unknown.key"), "unknown.key")
    }

    func testStableOrdering() throws {
        let m = try model("""
        { "z": "z", "a": { "y": "ay", "b": "ab" } }
        """)
        XCTAssertEqual(m.entries.map(\.dotPath), ["a.b", "a.y", "z"])
    }

    func testRootMustBeObject() {
        XCTAssertThrowsError(try model("[1, 2, 3]")) { error in
            XCTAssertEqual(error as? AutomationIDError, .rootNotObject)
        }
    }

    func testUnsupportedValueThrows() {
        XCTAssertThrowsError(try model("""
        { "login": { "count": 3 } }
        """)) { error in
            XCTAssertEqual(error as? AutomationIDError, .unsupportedValue(path: "login.count"))
        }
    }

    func testMergeByNamespace() throws {
        let base = try model("""
        { "login": { "a": "login.a" } }
        """)
        let incoming = try model("""
        { "login": { "b": "login.b" }, "home": { "c": "home.c" } }
        """)
        let merged = AutomationModel(root: mergeRoots(base.root, incoming.root))
        XCTAssertEqual(Set(merged.map.keys), ["login.a", "login.b", "home.c"])
    }

    // Exercise merge via the public multi-file initializer through temp files.
    func testMergeContentsOfFiles() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let a = dir.appendingPathComponent("a.json")
        let b = dir.appendingPathComponent("b.json")
        try #"{ "login": { "a": "login.a" } }"#.write(to: a, atomically: true, encoding: .utf8)
        try #"{ "login": { "b": "login.b" } }"#.write(to: b, atomically: true, encoding: .utf8)

        let merged = try AutomationModel(mergingContentsOf: [a, b])
        XCTAssertEqual(Set(merged.map.keys), ["login.a", "login.b"])
    }

    /// Re-derive a merged tree the way the internal merge does, for the unit test
    /// above (merge is private; validate its observable result via files elsewhere).
    private func mergeRoots(_ a: [AutomationNode], _ b: [AutomationNode]) -> [AutomationNode] {
        // Build a combined model by writing to data and reparsing is overkill;
        // instead rely on the file-based merge test for the real path. Here we
        // just concatenate top-level groups that differ, which suffices for the
        // key-set assertion above.
        var byName: [String: AutomationNode] = [:]
        for node in a { byName[node.name] = node }
        for node in b {
            if case .group(let name, let path, let bc) = node,
               case .group(_, _, let ac)? = byName[name] {
                byName[name] = .group(name: name, path: path, children: ac + bc)
            } else {
                byName[node.name] = node
            }
        }
        return byName.keys.sorted().compactMap { byName[$0] }
    }
}
