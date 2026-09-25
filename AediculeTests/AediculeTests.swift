import XCTest
@testable import Aedicule

final class AediculeTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: AediculeApp.self), "AediculeApp")
        XCTAssertEqual(NicheTint.face, "SF Pro")
        XCTAssertEqual(NicheTint.Hex.background, "#201E13")
        XCTAssertEqual(NicheTint.Hex.surface, "#2C291B")
        XCTAssertEqual(NicheTint.Hex.ink, "#F2F1ED")
        XCTAssertEqual(NicheTint.Hex.accent, "#EED34F")
        XCTAssertEqual(NicheTint.Hex.muted, "#AEA88F")
        XCTAssertEqual(NicheVault.snapshot, "aed.niche.v1")
        XCTAssertEqual(NicheVault.demo, "aed.demo.v1")
    }
}
