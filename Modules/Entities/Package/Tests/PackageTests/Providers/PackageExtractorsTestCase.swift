@testable import Package
import XCTest

class PackageExtractorsTestCase: XCTestCase {
    
    let packageNameProviderMock = PackageNameProviderMock(value: "PackageName")
    let packageFolderNameProviderMock = PackageFolderNameProviderMock(value: "PackageFolder")
    let packagePathProviderMock = PackagePathProviderMock(value: PackagePath(parent: "Package", path: "Path"))
    let family = Family(name: "DataStore", ignoreSuffix: false, folder: "DataStores")
    
    func testContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.contract],
                                  moduleTypes: [.contract: .dynamic],
                                  dependencies: [],
                                  resources: [])
        let sut = ContractPackageExtractor(packageNameProvider: packageNameProviderMock,
                                           packageFolderNameProvider: packageFolderNameProviderMock,
                                           packagePathProvider: packagePathProviderMock)
        // When
        let package = sut.package(for: component, of: family, allFamilies: [])
        
        // Then
        XCTAssertEqual(package.package, Package(name: "PackageName",
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
    
    func testImplementationWithContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.contract, .implementation],
                                  moduleTypes: [.implementation: .static],
                                  dependencies: [],
                                  resources: [])
        let sut = ImplementationPackageExtractor(packageNameProvider: packageNameProviderMock,
                                                 packageFolderNameProvider: packageFolderNameProviderMock,
                                                 packagePathProvider: packagePathProviderMock)
        let contractDependency = Dependency.module(path: "PackagePath",
                                                   name: "PackageName")

        // When
        let package = sut.package(for: component, of: family, allFamilies: [])
        
        // Then
        XCTAssertEqual(package.package, Package(name: "PackageName",
                                                iOSVersion: .v13,
                                                macOSVersion: nil,
                                                products: [
                                                    .library(Library(name: "PackageName",
                                                                     type: .static,
                                                                     targets: ["PackageName"]))
                                                ],
                                                dependencies: [contractDependency],
                                                targets: [
                                                    Target(name: "PackageName",
                                                           dependencies: [contractDependency],
                                                           isTest: false,
                                                           resources: []),
                                                    Target(name: "PackageNameTests",
                                                           dependencies: [.module(path: "", name: "PackageName")],
                                                           isTest: true,
                                                           resources: []),
                                                ]))
    }
    
    func testImplementationWithoutContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.implementation],
                                  moduleTypes: [.implementation: .static],
                                  dependencies: [],
                                  resources: [])
        let sut = ImplementationPackageExtractor(packageNameProvider: packageNameProviderMock,
                                                 packageFolderNameProvider: packageFolderNameProviderMock,
                                                 packagePathProvider: packagePathProviderMock)

        // When
        let package = sut.package(for: component, of: family, allFamilies: [])

        // Then
        XCTAssertEqual(package.package, Package(name: "PackageName",
                                                iOSVersion: .v13,
                                                macOSVersion: nil,
                                                products: [
                                                    .library(Library(name: "PackageName",
                                                                     type: .static,
                                                                     targets: ["PackageName"]))
                                                ],
                                                dependencies: [],
                                                targets: [
                                                    Target(name: "PackageName",
                                                           dependencies: [],
                                                           isTest: false),
                                                    Target(name: "PackageNameTests",
                                                           dependencies: [.module(path: "", name: "PackageName")],
                                                           isTest: true),
                                                ]))
    }

    func testMockWithContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.contract, .implementation, .mock],
                                  moduleTypes: [:],
                                  dependencies: [],
                                  resources: [])
        let sut = MockPackageExtractor(packageNameProvider: packageNameProviderMock,
                                       packageFolderNameProvider: packageFolderNameProviderMock,
                                       packagePathProvider: packagePathProviderMock)
        let contractDependency = Dependency.module(path: "PackagePath",
                                                   name: "PackageName")

        // When
        let package = sut.package(for: component, of: family, allFamilies: [])

        // Then
        XCTAssertEqual(package.package, Package(name: "PackageName",
                                                iOSVersion: .v13,
                                                macOSVersion: nil,
                                                products: [
                                                    .library(Library(name: "PackageName",
                                                                     type: nil,
                                                                     targets: ["PackageName"]))
                                                ],
                                                dependencies: [contractDependency],
                                                targets: [
                                                    Target(name: "PackageName",
                                                           dependencies: [contractDependency],
                                                           isTest: false)
                                                ]))
    }

    func testMockWithoutContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.implementation, .mock],
                                  moduleTypes: [:],
                                  dependencies: [],
                                  resources: [])
        let sut = MockPackageExtractor(packageNameProvider: packageNameProviderMock,
                                       packageFolderNameProvider: packageFolderNameProviderMock,
                                       packagePathProvider: packagePathProviderMock)
        let implementationDependency = Dependency.module(path: "PackagePath",
                                                         name: "PackageName")

        // When
        let package = sut.package(for: component, of: family, allFamilies: [])

        // Then
        XCTAssertEqual(package.package, Package(name: "PackageName",
                                                iOSVersion: .v13,
                                                macOSVersion: nil,
                                                products: [
                                                    .library(Library(name: "PackageName",
                                                                     type: nil,
                                                                     targets: ["PackageName"]))
                                                ],
                                                dependencies: [implementationDependency],
                                                targets: [
                                                    Target(name: "PackageName",
                                                           dependencies: [implementationDependency],
                                                           isTest: false)
                                                ]))
    }
}
