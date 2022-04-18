@testable import Package
import XCTest

class PackageExtractorsTestCase: XCTestCase {
    
    let packageNameProviderMock = PackageNameProviderMock(value: "PackageName")
    let packageFolderNameProviderMock = PackageFolderNameProviderMock(value: "PackageFolder")
    let packagePathProviderMock = PackagePathProviderMock(value: "PackagePath")
    let family = Family(name: "DataStore", ignoreSuffix: nil, folder: "DataStores")
    
    func testContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.contract],
                                  dependencies: [])
        let sut = ContractPackageExtractor(packageNameProvider: packageNameProviderMock,
                                           packageFolderNameProvider: packageFolderNameProviderMock,
                                           packagePathProvider: packagePathProviderMock)
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
    
    func testImplementationWithContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.contract, .implementation],
                                  dependencies: [])
        let sut = ImplementationPackageExtractor(packageNameProvider: packageNameProviderMock,
                                                 packageFolderNameProvider: packageFolderNameProviderMock,
                                                 packagePathProvider: packagePathProviderMock)
        let contractDependency = Dependency.module(path: "PackagePath",
                                                   name: "PackageName")

        // When
        let package = sut.package(for: component, of: family)
        
        // Then
        XCTAssertEqual(package, Package(name: "PackageName",
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
                                                   isTest: false),
                                            Target(name: "PackageNameTests",
                                                   dependencies: [.module(path: "", name: "PackageName")],
                                                   isTest: true),
                                        ]))
    }
    
    func testImplementationWithoutContract() {
        // Given
        let component = Component(name: Name(given: "Wordpress", family: "DataStore"),
                                  iOSVersion: .v13,
                                  macOSVersion: nil,
                                  modules: [.implementation],
                                  dependencies: [])
        let sut = ImplementationPackageExtractor(packageNameProvider: packageNameProviderMock,
                                                 packageFolderNameProvider: packageFolderNameProviderMock,
                                                 packagePathProvider: packagePathProviderMock)

        // When
        let package = sut.package(for: component, of: family)

        // Then
        XCTAssertEqual(package, Package(name: "PackageName",
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
                                  dependencies: [])
        let sut = MockPackageExtractor(packageNameProvider: packageNameProviderMock,
                                       packageFolderNameProvider: packageFolderNameProviderMock,
                                       packagePathProvider: packagePathProviderMock)
        let contractDependency = Dependency.module(path: "PackagePath",
                                                   name: "PackageName")

        // When
        let package = sut.package(for: component, of: family)

        // Then
        XCTAssertEqual(package, Package(name: "PackageName",
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
                                  dependencies: [])
        let sut = MockPackageExtractor(packageNameProvider: packageNameProviderMock,
                                       packageFolderNameProvider: packageFolderNameProviderMock,
                                       packagePathProvider: packagePathProviderMock)
        let implementationDependency = Dependency.module(path: "PackagePath",
                                                   name: "PackageName")

        // When
        let package = sut.package(for: component, of: family)

        // Then
        XCTAssertEqual(package, Package(name: "PackageName",
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
