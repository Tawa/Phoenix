@testable import Package
import XCTest

class PackageParserTests: XCTestCase {

    func testParsePackage() {
//        // Given
//        let packageString: String = """
//// swift-tools-version:5.6
//
//import PackageDescription
//
//let package = Package(
//    name: "Package",
//    platforms: [
//        .macOS(.v12),
//    ],
//    products: [
//        .library(
//            name: "Package",
//            targets: ["Package"])
//    ],
//    targets: [
//        .target(
//            name: "Package"
//        ),
//        .testTarget(
//            name: "PackageTests",
//            dependencies: [
//                "Package"
//            ]
//        )
//    ]
//)
//"""
//        let sut = PackageParser()
//
//        // When
//        let package = sut.package(from: packageString)
//
//        // Then
//        XCTAssertEqual(package.name, "Package")
//        XCTAssertEqual(package.iOSVersion, nil)
//        XCTAssertEqual(package.macOSVersion, .v12)
//        XCTAssertEqual(package.products, [
//            .library(.init(name: "Package",
//                           type: .undefined,
//                           targets: ["Package"]))
//        ])
//        XCTAssertEqual(package.dependencies, [])
//        XCTAssertEqual(package.targets, [
//            .init(name: "Package",
//                  dependencies: [],
//                  isTest: false,
//                  resources: []),
//            .init(name: "PackageTests",
//                  dependencies: [.module(path: "", name: "Package")],
//                  isTest: true,
//                  resources: [])
//        ])
//        XCTAssertEqual(package.swiftVersion, "5.6")

    }

}
