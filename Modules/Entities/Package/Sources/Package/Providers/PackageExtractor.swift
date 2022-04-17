public protocol PackageExtracting {
    func package(for component: Component, of family: Family) -> Package
}

struct ContractPackageExtractor: PackageExtracting {
    private let packageNameProvider: PackageNameProviding
    private let packageFolderNameProvider: PackageFolderNameProviding

    init(packageNameProvider: PackageNameProviding,
                packageFolderNameProvider: PackageFolderNameProviding) {
        self.packageNameProvider = packageNameProvider
        self.packageFolderNameProvider = packageFolderNameProvider
    }

    func package(for component: Component, of family: Family) -> Package {
        let packageName = packageNameProvider.packageName(forType: .contract,
                                                          name: component.name,
                                                          of: family)

        return Package(
            name: packageName,
            iOSVersion: component.iOSVersion,
            macOSVersion: component.macOSVersion,
            products: [
                .library(Library(name: packageName,
                                 type: .dynamic,
                                 targets: [packageName]))],
            dependencies: [],
            targets: [
                Target(name: packageName,
                       dependencies: [],
                       isTest: false)
            ]
        )
    }
}

struct ImplementationPackageExtractor: PackageExtracting {
    private let packageNameProvider: PackageNameProviding
    private let packageFolderNameProvider: PackageFolderNameProviding

    init(packageNameProvider: PackageNameProviding,
                packageFolderNameProvider: PackageFolderNameProviding) {
        self.packageNameProvider = packageNameProvider
        self.packageFolderNameProvider = packageFolderNameProvider
    }

    func package(for component: Component, of family: Family) -> Package {
        let packageName = packageNameProvider.packageName(forType: .implementation,
                                                          name: component.name,
                                                          of: family)

        var dependencies: [Dependency] = []
        if component.modules.contains(.contract) {
            let contractName = packageNameProvider.packageName(forType: .contract,
                                                               name: component.name,
                                                               of: family)
            dependencies.append(.module(path: "", name: contractName))
        }

        return Package(
            name: packageName,
            iOSVersion: component.iOSVersion,
            macOSVersion: component.macOSVersion,
            products: [
                .library(Library(name: packageName,
                                 type: .static,
                                 targets: [packageName]))],
            dependencies: [],
            targets: [
                Target(name: packageName,
                       dependencies: [],
                       isTest: false)
            ]
        )
    }
}
