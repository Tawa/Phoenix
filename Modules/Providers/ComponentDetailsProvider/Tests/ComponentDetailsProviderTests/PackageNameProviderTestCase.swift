import Component
@testable import ComponentDetailsProvider
import XCTest

class PackageNameProviderTestCase: XCTestCase {

    let sut = PackageNameProvider()

    func test_Contract_WithSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: false,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forComponentName: name,
                                          of: family,
                                          packageConfiguration: .contract)

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
        let packageName = sut.packageName(forComponentName: name,
                                          of: family,
                                          packageConfiguration: .contract)

        // Then
        XCTAssertEqual(packageName, "WordpressContract")
    }

    func test_Implementation_WithSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: false,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forComponentName: name,
                                          of: family,
                                          packageConfiguration: .implementation)

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
        let packageName = sut.packageName(forComponentName: name,
                                          of: family,
                                          packageConfiguration: .implementation)

        // Then
        XCTAssertEqual(packageName, "Wordpress")
    }

    func test_Mock_WithSuffix() {
        // Given
        let name = Name(given: "Wordpress", family: "DataStore")
        let family = Family(name: "DataStore",
                            ignoreSuffix: false,
                            folder: "DataStores")

        // When
        let packageName = sut.packageName(forComponentName: name,
                                          of: family,
                                          packageConfiguration: .mock)

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
        let packageName = sut.packageName(forComponentName: name,
                                          of: family,
                                          packageConfiguration: .mock)

        // Then
        XCTAssertEqual(packageName, "WordpressMock")
    }

}
