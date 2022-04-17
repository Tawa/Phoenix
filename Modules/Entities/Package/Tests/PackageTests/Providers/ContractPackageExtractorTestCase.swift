@testable import Package
import XCTest

class ContractPackageExtractorTestCase: XCTestCase {

    func testContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.contract],
                                  dependencies: [])
        let family = Family(name: "DataStore", ignoreSuffix: nil, folder: "DataStores")
        let packageNameProviderMock = PackageNameProviderMock(value: "PackageName")
        let packageFolderNameProviderMock = PackageFolderNameProviderMock(value: "PackageFolder")

        let sut = ContractPackageExtractor(packageNameProvider: packageNameProviderMock,
                                           packageFolderNameProvider: packageFolderNameProviderMock)

        // When
        let package = sut.package(for: component, of: family)

        // Then
        XCTAssertEqual(package, Package(name: "PackageName",
                                        iOSVersion: .v13,
                                        macOSVersion: nil,
                                        products: [
                                            .library(Library(name: "PackageName",
                                                             type: .dynamic,
                                                             targets: ["PackageName"]))
                                        ],
                                        dependencies: [],
                                        targets: [
                                            Target(name: "PackageName", dependencies: [], isTest: false)
                                        ]))
    }

}
