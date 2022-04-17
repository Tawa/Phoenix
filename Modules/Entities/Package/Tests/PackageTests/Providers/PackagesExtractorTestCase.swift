@testable import Package
import XCTest

class PackagesExtractorTestCase: XCTestCase {

    func testPackages() {
        // Given
        let component = Component(
            name: Name(given: "Networking", family: "Shared"),
            iOSVersion: .v13,
            macOSVersion: nil,
            modules: [.contract, .implementation, .mock],
            dependencies: [])
        let family = Family(name: "Shared", ignoreSuffix: true, folder: "Shared")
//        let sut = PackagesExtractor()
//
//        // When
//        let packages = sut.packages(for: component, of: family)
//
//        // Then
//        XCTAssertEqual(packages, [
//            Package(name: "NetworkingContract",
//                    iOSVersion: .v13,
//                    macOSVersion: nil,
//                    products: [
//                        Product.library(
//                            Library(name: "NetworkingContract",
//                                    type: .dynamic,
//                                    targets: ["NetworkingContract"])
//                        )
//                    ],
//                    dependencies: [ ],
//                    targets: [
//                        Target(name: "NetworkingContract",
//                               dependencies: [],
//                               isTest: false)
//                    ]),
//            Package(name: "Networking",
//                    iOSVersion: .v13,
//                    macOSVersion: nil,
//                    products: [
//                        Product.library(
//                            Library(name: "Networking",
//                                    type: nil,
//                                    targets: ["Networking"])
//                        )
//                    ],
//                    dependencies: [
//                        .module(path: "../../Contracts/Shared/NetworkingContract",
//                                name: "NetworkingContract"),
//                    ],
//                    targets: [
//                        Target(name: "Networking",
//                               dependencies: [
//                                .module(path: "", name: "NetworkingContract")
//                               ],
//                               isTest: false),
//                        Target(name: "NetworkingTests",
//                               dependencies: [.module(path: "", name: "Networking")],
//                               isTest: true)
//                    ]),
//            Package(name: "NetworkingMock",
//                    iOSVersion: .v13,
//                    macOSVersion: nil,
//                    products: [
//                        Product.library(
//                            Library(name: "NetworkingMock",
//                                    type: nil,
//                                    targets: ["NetworkingMock"])
//                        )
//                    ],
//                    dependencies: [
//                        .module(path: "../../Contracts/Shared/NetworkingContract",
//                                name: "NetworkingContract"),
//                    ],
//                    targets: [
//                        Target(name: "NetworkingMock",
//                               dependencies: [
//                                .module(path: "", name: "NetworkingContract")
//                               ],
//                               isTest: false)
//                    ])
//        ])
    }

}
