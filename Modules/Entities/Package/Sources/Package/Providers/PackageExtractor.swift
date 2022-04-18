public protocol PackageExtracting {
    func package(for component: Component, of family: Family) -> Package
}

struct ContractPackageExtractor: PackageExtracting {
    private let packageNameProvider: PackageNameProviding
    private let packageFolderNameProvider: PackageFolderNameProviding
    private let packagePathProvider: PackagePathProviding

    init(packageNameProvider: PackageNameProviding,
         packageFolderNameProvider: PackageFolderNameProviding,
         packagePathProvider: PackagePathProviding) {
        self.packageNameProvider = packageNameProvider
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packagePathProvider = packagePathProvider
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
    private let packagePathProvider: PackagePathProviding

    init(packageNameProvider: PackageNameProviding,
         packageFolderNameProvider: PackageFolderNameProviding,
         packagePathProvider: PackagePathProviding) {
        self.packageNameProvider = packageNameProvider
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packagePathProvider = packagePathProvider
    }

    func package(for component: Component, of family: Family) -> Package {
        let packageName = packageNameProvider.packageName(forType: .implementation,
                                                          name: component.name,
                                                          of: family)

        var dependencies: [Dependency] = []
        if component.modules.contains(.contract) {
            let contractPath = packagePathProvider.path(for: component.name,
                                                        of: family,
                                                        type: .contract,
                                                        relativeToType: .implementation)
            let contractName = packageNameProvider.packageName(forType: .contract,
                                                               name: component.name,
                                                               of: family)
            dependencies.append(.module(path: contractPath, name: contractName))
        }

        dependencies.sort()

        return Package(
            name: packageName,
            iOSVersion: component.iOSVersion,
            macOSVersion: component.macOSVersion,
            products: [
                .library(Library(name: packageName,
                                 type: .static,
                                 targets: [packageName]))],
            dependencies: dependencies,
            targets: [
                Target(name: packageName,
                       dependencies: dependencies,
                       isTest: false),
                Target(name: packageName + "Tests",
                       dependencies: [
                        Dependency.module(path: "",
                                          name: packageName)
                       ], isTest: true)
            ]
        )
    }
}

struct MockPackageExtractor: PackageExtracting {
    private let packageNameProvider: PackageNameProviding
    private let packageFolderNameProvider: PackageFolderNameProviding
    private let packagePathProvider: PackagePathProviding

    init(packageNameProvider: PackageNameProviding,
         packageFolderNameProvider: PackageFolderNameProviding,
         packagePathProvider: PackagePathProviding) {
        self.packageNameProvider = packageNameProvider
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packagePathProvider = packagePathProvider
    }

    func package(for component: Component, of family: Family) -> Package {
        let packageName = packageNameProvider.packageName(forType: .mock,
                                                          name: component.name,
                                                          of: family)

        var dependencies: [Dependency] = []
        if component.modules.contains(.contract) {
            let contractPath = packagePathProvider.path(for: component.name,
                                                        of: family,
                                                        type: .contract,
                                                        relativeToType: .mock)
            let contractName = packageNameProvider.packageName(forType: .contract,
                                                               name: component.name,
                                                               of: family)
            dependencies.append(.module(path: contractPath, name: contractName))
        } else if component.modules.contains(.implementation) {
            let implementationPath = packagePathProvider.path(for: component.name,
                                                              of: family,
                                                              type: .implementation,
                                                              relativeToType: .mock)
            let implementationName = packageNameProvider.packageName(forType: .contract,
                                                                     name: component.name,
                                                                     of: family)
            dependencies.append(.module(path: implementationPath, name: implementationName))
        }

        dependencies.sort()

        return Package(
            name: packageName,
            iOSVersion: component.iOSVersion,
            macOSVersion: component.macOSVersion,
            products: [
                .library(Library(name: packageName,
                                 type: nil,
                                 targets: [packageName]))],
            dependencies: dependencies,
            targets: [
                Target(name: packageName,
                       dependencies: dependencies,
                       isTest: false)
            ]
        )
    }}
