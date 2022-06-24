@testable import Package
import XCTest

class PackageStringProviderTestCase: XCTestCase {

    func testPackage() {
        // Given
        let package = Package(name: "HomeService",
                              iOSVersion: nil,
                              macOSVersion: nil,
                              products: [
                                .library(Library(name: "HomeService", type: .undefined, targets: ["HomeService"]))
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
                                       isTest: false,
                                      resources: []),
                                Target(name: "HomeServiceTests",
                                       dependencies: [ .module(path: "", name: "HomeService") ],
                                       isTest: true,
                                      resources: [])
                              ])

        let sut = PackageStringProvider()

        // When
        let packageString = sut.string(for: package)

        // Then
        XCTAssertEqual(packageString, """
// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "HomeService",
    products: [
        .library(
            name: "HomeService",
            targets: ["HomeService"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Repositories/HomeRepositoryContract"),
        .package(path: "../../Contracts/Services/HomeServiceContract"),
        .package(path: "../../Support/DI")
    ],
    targets: [
        .target(
            name: "HomeService",
            dependencies: [
                "HomeRepositoryContract",
                "HomeServiceContract",
                "DI"
            ]
        ),
        .testTarget(
            name: "HomeServiceTests",
            dependencies: [
                "HomeService"
            ]
        )
    ]
)

""")
    }
}
