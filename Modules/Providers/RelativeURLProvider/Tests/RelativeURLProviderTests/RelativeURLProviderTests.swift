import XCTest
@testable import RelativeURLProvider

final class RelativeURLProviderTests: XCTestCase {

    func testExample() throws {
        // Given
        let folderURL: URL = .init(string: "/Users/tn/Work/ios/Demos/Features")!
        let relativeURL: URL = .init(string: "Users/tn/Work/ios/HelloFresh/Modules/Modules.ash/")!
        
        let sut = RelativeURLProvider()

        // When
        let path = sut.path(for: folderURL, relativeURL: relativeURL)
        print(path)
        // Then
        XCTAssertEqual(path, "../../HelloFresh/Modules")
     }
}
