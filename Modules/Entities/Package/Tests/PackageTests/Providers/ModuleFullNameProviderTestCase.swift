@testable import PackageDescription
import XCTest

class ModuleFullNameProviderTestCase: XCTestCase {

    let sut = ModuleFullNameProvider()

    func testContractName() {
        // Given
        let module = ModuleDescription(name: Name(given: "Wordpress", family: "DataStore"),
                                       type: .contract)
        // When
        let name = sut.name(for: module)

        // Then
        XCTAssertEqual(name, "WordpressDataStoreContract")
    }

    func testImplementationName() {
        // Given
        let module = ModuleDescription(name: Name(given: "Wordpress", family: "DataStore"),
                                       type: .implementation)
        // When
        let name = sut.name(for: module)

        // Then
        XCTAssertEqual(name, "WordpressDataStore")
    }

    func testMockName() {
        // Given
        let module = ModuleDescription(name: Name(given: "Wordpress", family: "DataStore"),
                                       type: .mock)
        // When
        let name = sut.name(for: module)

        // Then
        XCTAssertEqual(name, "WordpressDataStoreMock")
    }
}
