@testable import Package
import XCTest

class PackagesExtractorTestCase: XCTestCase {

    func testPackages() {
        // Given
        let defaultFamilyFolderNameProvider: FamilyFolderNameProviding = FamilyFolderNameProvider()
        let packageNameProvider: PackageNameProviding = PackageNameProvider()
        let packageFolderNameProvider: PackageFolderNameProviding = PackageFolderNameProvider(defaultFolderNameProvider: defaultFamilyFolderNameProvider)
        let packagePathProvider: PackagePathProviding = PackagePathProvider(packageFolderNameProvider: packageFolderNameProvider,
                                                                            packageNameProvider: packageNameProvider)

        let component = Component(
            name: Name(given: "Home", family: "Repository"),
            iOSVersion: .v13,
            macOSVersion: nil,
            modules: ["Contract": .dynamic, "Implementation": .static, "Mock": .undefined],
            dependencies: [
                .local(.init(name: Name(given: "Home", family: "DataStore"),
                             targetTypes: [
                                .init(name: "Implementation", isTests: false): "Contract",
                                .init(name: "Implementation", isTests: true): "Mock"
                             ])),
                .local(.init(name: Name(given: "Networking", family: "Support"),
                             targetTypes: [
                                .init(name: "Implementation", isTests: false): "Contract",
                                .init(name: "Implementation", isTests: true): "Mock"
                             ]))
            ],
            resources: [])

        let family = Family(name: "Repository", ignoreSuffix: false, folder: nil)
        let allFamilies: [Family] = [
            family,
            Family(name: "DataStore", ignoreSuffix: false, folder: nil),
            Family(name: "Support", ignoreSuffix: true, folder: "Support")
        ]
        let packageConfiguration = PackageConfiguration(name: "Implementation",
                                                        containerFolderName: nil,
                                                        appendPackageName: false,
                                                        internalDependency: "Contract",
                                                        hasTests: true)
        let projectConfiguration = ProjectConfiguration(packageConfigurations: [packageConfiguration,
                                                                                PackageConfiguration(name: "Contract",
                                                                                                     containerFolderName: "Contracts",
                                                                                                     appendPackageName: true,
                                                                                                     internalDependency: nil,
                                                                                                     hasTests: false),
                                                                                PackageConfiguration(name: "Mock",
                                                                                                     containerFolderName: "Mocks",
                                                                                                     appendPackageName: true,
                                                                                                     internalDependency: "Contract",
                                                                                                     hasTests: false)],
                                                        swiftVersion: "5.6")

        let sut = PackageExtractor(packageNameProvider: packageNameProvider,
                                   packageFolderNameProvider: packageFolderNameProvider,
                                   packagePathProvider: packagePathProvider,
                                   swiftVersion: "5.6")

        // When
        let packages = sut.package(for: component,
                                   of: family,
                                   allFamilies: allFamilies,
                                   packageConfiguration: packageConfiguration,
                                   projectConfiguration: projectConfiguration)

        // Then
        XCTAssertEqual(packages,
                       PackageWithPath(package: Package(name: "HomeRepository",
                                                        iOSVersion: .v13,
                                                        macOSVersion: nil,
                                                        products: [
                                                           .library(.init(name: "HomeRepository", type: .static, targets: ["HomeRepository"]))
                                                        ],
                                                        dependencies: [
                                                           .module(path: "../../Contracts/Repositories/HomeRepositoryContract", name: "HomeRepositoryContract"),
                                                           .module(path: "../../Contracts/DataStores/HomeDataStoreContract", name: "HomeDataStoreContract"),
                                                           .module(path: "../../Contracts/Support/NetworkingContract", name: "NetworkingContract"),
                                                           .module(path: "../../Mocks/DataStores/HomeDataStoreMock", name: "HomeDataStoreMock"),
                                                           .module(path: "../../Mocks/Support/NetworkingMock", name: "NetworkingMock"),
                                                        ],
                                                        targets: [
                                                           .init(name: "HomeRepository",
                                                                 dependencies: [
                                                                   .module(path: "../../Contracts/Repositories/HomeRepositoryContract", name: "HomeRepositoryContract"),
                                                                   .module(path: "../../Contracts/DataStores/HomeDataStoreContract", name: "HomeDataStoreContract"),
                                                                   .module(path: "../../Contracts/Support/NetworkingContract", name: "NetworkingContract"),
                                                                 ],
                                                                 isTest: false,
                                                                 resources: []),
                                                           .init(name: "HomeRepositoryTests",
                                                                 dependencies: [
                                                                   .module(path: "", name: "HomeRepository"),
                                                                   .module(path: "../../Mocks/DataStores/HomeDataStoreMock", name: "HomeDataStoreMock"),
                                                                   .module(path: "../../Mocks/Support/NetworkingMock", name: "NetworkingMock"),
                                                                 ],
                                                                 isTest: true,
                                                                 resources: []),
                                                        ],
                                                        swiftVersion: "5.6"),
                                       path: "Repositories/HomeRepository")
        )
    }

}
