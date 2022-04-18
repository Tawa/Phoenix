@testable import Package
import XCTest

class PackageStringProviderTestCase: XCTestCase {

    func testPackage() {
        // Given
        let package = Package(name: "HomeService",
                              iOSVersion: nil,
                              macOSVersion: nil,
                              products: [
                                .library(Library(name: "HomeService", type: nil, targets: ["HomeService"]))
                              ],
                              dependencies: [
                                .module(path: "../../Contracts/Services/HomeServiceContract", name: "HomeServiceContract"),
                                .module(path: "../../Contracts/Repositories/HomeRepositoryContract", name: "HomeRepositoryContract"),
                                .module(path: "../../Support/DI", name: "DI")
                              ],
                              targets: [
                                Target(name: "HomeService",
                                       dependencies: [
                                        .module(path: "../../Contracts/Services/HomeServiceContract", name: "HomeServiceContract"),
                                        .module(path: "../../Contracts/Repositories/HomeRepositoryContract", name: "HomeRepositoryContract"),
                                        .module(path: "../../Support/DI", name: "DI")
                                       ],
                                       isTest: false),
                                Target(name: "HomeServiceTests",
                                       dependencies: [ .module(path: "", name: "HomeService") ],
                                       isTest: true)
                              ])

        let sut = PackageStringProvider()

        // When
        let packageString = sut.string(for: package)

        // Then
        XCTAssertEqual(packageString, "")
    }
}
