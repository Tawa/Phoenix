import XCTest
import SwiftPackage
@testable import PackageStringProvider

final class PackageStringProviderTests: XCTestCase {
    
    func testPackage() {
        // Given
        let package = SwiftPackage(
            name: "HomeService",
            defaultLocalization: nil,
            platforms: .empty,
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
                       resources: [],
                       type: .target),
                Target(name: "HomeServiceTests",
                       dependencies: [ .module(path: "", name: "HomeService") ],
                       resources: [],
                       type: .testTarget)
            ],
            swiftVersion: "5.7"
        )
        
        let sut = PackageStringProvider()
        
        // When
        let packageString = sut.string(for: package)
        
        // Then
        XCTAssertEqual(packageString, """
// swift-tools-version: 5.7

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
