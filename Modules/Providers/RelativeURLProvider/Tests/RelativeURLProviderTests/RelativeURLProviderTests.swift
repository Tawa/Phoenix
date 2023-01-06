import XCTest
@testable import RelativeURLProvider

final class RelativeURLProviderTests: XCTestCase {

    func testExample() throws {
        // Given
        let folderURL: URL = .init(string: "/Users/tn/Projects/Phoenix/Demos/Features")!
        let relativeURL: URL = .init(string: "Users/tn/Projects/Phoenix/Phoenix/Modules/Modules.ash/")!
        
        let sut = RelativeURLProvider()

        // When
        let path = sut.path(for: folderURL, relativeURL: relativeURL)
        // Then
        XCTAssertEqual(path, "../../Phoenix/Modules")
     }
}
