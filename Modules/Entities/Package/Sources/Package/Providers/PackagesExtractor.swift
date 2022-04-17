public protocol PackagesExtracting {
    func packages(for component: Component, of family: Family) -> [Package]
}

public struct PackagesExtractor: PackagesExtracting {
    let packageExtractors: [ModuleType: PackageExtracting]

    public init(packageExtractors: [ModuleType: PackageExtracting]) {
        self.packageExtractors = packageExtractors
    }

    public func packages(for component: Component, of family: Family) -> [Package] {
        component.modules.compactMap { packageExtractors[$0]?.package(for: component, of: family) }
    }

    func contract(for component: Component, of family: Family) -> Package {
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
                ])
    }

    func implementation(for component: Component, of family: Family) -> Package {
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
                            .module(path: "../../Contracts/DataStores/WordpressDataStoreContract",
                                    name: "WordpressDataStoreContract"),
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
                            .module(path: "../../Mocks/DataStores/WordpressDataStoreMock",
                                    name: "WordpressDataStore"),
                            .module(path: "../../Mocks/Entities/WordpressEntity",
                                    name: "WordpressEntityMock")
                           ],
                           isTest: true)
                ])
    }

    func mock(for component: Component, of family: Family) -> Package {
        Package(name: "WordpressRepositoryMock",
                iOSVersion: .v13,
                macOSVersion: nil,
                products: [
                    Product.library(
                        Library(name: "WordpressRepositoryMock",
                                type: nil,
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
    }
}
