public protocol PackagesExtracting {
    func packages(for component: Component) -> [Package]
}

public struct PackagesExtractor: PackagesExtracting {
    public func packages(for component: Component) -> [Package] {
        component.modules.map { moduleType in
            switch moduleType {
            case .contract:
                return contract(for: component)
            case .implementation:
                return implementation(for: component)
            case .mock:
                return mock(for: component)
            }
        }
    }
    
    func contract(for component: Component) -> Package {
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
    
    
    func implementation(for component: Component) -> Package {
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
                ])
    }
    
    func mock(for component: Component) -> Package {
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
    }
}