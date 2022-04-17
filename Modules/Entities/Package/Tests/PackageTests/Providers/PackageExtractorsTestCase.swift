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
                                            Target(name: "PackageName", dependencies: [.module(path: "PackagePath",
                                                                                               name: "PackageName")], isTest: false),
                                            Target(name: "PackageNameTests", dependencies: [.module(path: "", name: "PackageName")], isTest: true),
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
                                                             type: .dynamic,
                                                             targets: ["PackageName"]))
                                        ],
                                        dependencies: [],
                                        targets: [
                                            Target(name: "PackageName", dependencies: [], isTest: false)
                                        ]))
    }
}
