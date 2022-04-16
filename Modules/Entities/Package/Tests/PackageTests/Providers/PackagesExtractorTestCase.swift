@testable import Package
import XCTest

class PackagesExtractorTestCase: XCTestCase {

    func testPackages() {
        // Given
        let component = Component(
            name: Name(given: "Wordpress", family: "Repository"),
            iOSVersion: .v13,
            macOSVersion: nil,
            modules: [.contract, .implementation, .mock],
            dependencies: [
                ComponentDependency(name: Name(given: "Wordpress", family: "DataStore"),
                                    contract: nil,
                                    implementation: .contract,
                                    tests: .mock,
                                    mock: nil),
                ComponentDependency(name: Name(given: "Wordpress", family: "Entity"),
                                    contract: .implementation,
                                    implementation: .implementation,
                                    tests: .mock,
                                    mock: nil)
            ])
        let sut = PackagesExtractor()

        // When
        let packages = sut.packages(for: component)

        // Then
        XCTAssertEqual(packages, [
            Package(name: "WordpressRepositoryContract",
                    iOSVersion: .v13,
                    macOSVersion: nil,
                    products: [
                        Product.library(
                            Library(name: "WordpressRepositoryContract",
                                    type: .dynamic,
                                    targets: ["WordpressRepositoryContract"])
                        )
                    ],
                    dependencies: [
                        .module(path: "../../Entities/WordpressEntity",
                                name: "WordpressEntity")
                    ],
                    targets: [
                        Target(name: "WordpressRepositoryContract",
                               dependencies: [
                                .module(
                                    path: "",
                                    name: "WordpressEntity"),
                                .module(path: "../../Entities/WordpressEntity",
                                        name: "WordpressEntity")],
                               isTest: false)
                    ]),
            Package(name: "WordpressRepository",
                    iOSVersion: .v13,
                    macOSVersion: nil,
                    products: [
                        Product.library(
                            Library(name: "WordpressRepository",
                                    type: nil,
                                    targets: ["WordpressRepository"])
                        )
                    ],
                    dependencies: [
                        .module(path: "../../Contracts/DataStores/WordpressDataStore",
                                name: "WordpressDataStore"),
                        .module(path: "../../Contracts/Repositories/WordpressRepositoryContract",
                                name: "WordpressRepositoryContract"),
                        .module(path: "../../Entities/WordpressEntity",
                                name: "WordpressEntity")
                    ],
                    targets: [
                        Target(name: "WordpressRepository",
                               dependencies: [
                                .module(path: "../../Contracts/DataStores/WordpressDataStore",
                                        name: "WordpressDataStore"),
                                .module(path: "../../Contracts/Repositories/WordpressRepositoryContract",
                                        name: "WordpressRepositoryContract"),
                                .module(path: "../../Entities/WordpressEntity",
                                        name: "WordpressEntity")
                               ],
                               isTest: false),
                        Target(name: "WordpressRepositoryTests",
                               dependencies: [
                                .module(path: "",
                                        name: "WordpressRepository"),
                                .module(path: "../../Contracts/DataStores/WordpressDataStore",
                                        name: "WordpressDataStore"),
                                .module(path: "../../Contracts/Repositories/WordpressRepositoryContract",
                                        name: "WordpressRepositoryContract"),
                                .module(path: "../../Entities/WordpressEntity",
                                        name: "WordpressEntity")
                               ],
                               isTest: false)
                    ]),
            Package(name: "WordpressRepositoryMock",
                    iOSVersion: .v13,
                    macOSVersion: nil,
                    products: [
                        Product.library(
                            Library(name: "WordpressRepositoryMock",
                                    type: .dynamic,
                                    targets: ["WordpressRepositoryMock"])
                        )
                    ],
                    dependencies: [
                        .module(path: "../../../Contracts/Repositories/WordpressRepository",
                                name: "Wordpress"),
                        .module(path: "../../../Entities/WordpressEntity",
                                name: "WordpressEntity")
                    ],
                    targets: [
                        Target(name: "WordpressRepositoryMock",
                               dependencies: [
                                .module(path: "",
                                        name: "WordpressRepositoryMock"),
                                .module(path: "../../../Contracts/Repositories/WordpressRepository",
                                        name: "Wordpress"),
                                .module(path: "../../../Entities/WordpressEntity",
                                        name: "WordpressEntity")
                               ],
                               isTest: false)
                    ])
        ])
    }

}
