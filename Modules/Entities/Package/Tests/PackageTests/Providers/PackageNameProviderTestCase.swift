@testable import Package
import XCTest

class PackageNameProviderTestCase: XCTestCase {

    let sut = PackageNameProvider()

    func test_Contract_WithSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: nil,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forType: .contract, name: name, of: family)

        // Then
        XCTAssertEqual(packageName, "WordpressDataStoreContract")
    }

    func test_Contract_WithoutSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: true,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forType: .contract, name: name, of: family)

        // Then
        XCTAssertEqual(packageName, "WordpressContract")
    }

    func test_Implementation_WithSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: nil,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forType: .implementation, name: name, of: family)

        // Then
        XCTAssertEqual(packageName, "WordpressDataStore")
    }

    func test_Implementation_WithoutSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: true,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forType: .implementation, name: name, of: family)

        // Then
        XCTAssertEqual(packageName, "Wordpress")
    }

    func test_Mock_WithSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: nil,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forType: .mock, name: name, of: family)

        // Then
        XCTAssertEqual(packageName, "WordpressDataStoreMock")
    }

    func test_Mock_WithoutSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: true,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forType: .mock, name: name, of: family)

        // Then
        XCTAssertEqual(packageName, "WordpressMock")
    }

}
