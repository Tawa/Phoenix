import XCTest
@testable import PackagePathProvider

final class PackagePathProviderTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PackagePathProvider().text, "Hello, World!")
    }
}
