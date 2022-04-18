import Foundation

protocol PackageExtracting {
    func package(for component: Component, of family: Family, allFamilies: [Family], fileURL: URL) -> PackageWithPath
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

    func package(for component: Component, of family: Family, allFamilies: [Family], fileURL: URL) -> PackageWithPath {
        let packageName = packageNameProvider.packageName(forType: .contract,
                                                          name: component.name,
                                                          of: family)
        
        var dependencies: [Dependency] = component.dependencies.compactMap { componentDependency -> (Dependency)? in
            guard let dependencyType = componentDependency.contract,
                  let dependencyFamily = allFamilies.first(where: { $0.name == componentDependency.name.family })
            else { return nil }
            let path = packagePathProvider.path(for: componentDependency.name,
                                                of: dependencyFamily,
                                                type: dependencyType,
                                                relativeToType: .contract)
            let componentName = packageNameProvider.packageName(forType: dependencyType,
                                                                name: componentDependency.name,
                                                                of: dependencyFamily)
            return Dependency.module(path: path.full, name: componentName)
        }
        dependencies.sort()

        return PackageWithPath(
            package: Package(
                name: packageName,
                iOSVersion: component.iOSVersion,
                macOSVersion: component.macOSVersion,
                products: [
                    .library(Library(name: packageName,
                                     type: .dynamic,
                                     targets: [packageName]))],
                dependencies: dependencies,
                targets: [
                    Target(name: packageName,
                           dependencies: dependencies,
                           isTest: false)
                ]
            ),
            path: packagePathProvider.path(for: component.name,
                                           of: family,
                                           type: .contract,
                                           relativeToType: .contract).path
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
    
    func package(for component: Component, of family: Family, allFamilies: [Family], fileURL: URL) -> PackageWithPath {
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
            dependencies.append(.module(path: contractPath.full, name: contractName))
        }
        let implementationDependencies = component.dependencies.compactMap { componentDependency -> (Dependency)? in
            guard let dependencyType = componentDependency.implementation,
                  let dependencyFamily = allFamilies.first(where: { $0.name == componentDependency.name.family })
            else { return nil }
            let path = packagePathProvider.path(for: componentDependency.name,
                                                of: dependencyFamily,
                                                type: dependencyType,
                                                relativeToType: .implementation)
            let componentName = packageNameProvider.packageName(forType: dependencyType,
                                                                name: componentDependency.name,
                                                                of: dependencyFamily)
            return Dependency.module(path: path.full, name: componentName)
        }
        let testsDependencies = component.dependencies.compactMap { componentDependency -> (Dependency)? in
            guard let dependencyType = componentDependency.tests,
                  let dependencyFamily = allFamilies.first(where: { $0.name == componentDependency.name.family })
            else { return nil }
            let path = packagePathProvider.path(for: componentDependency.name,
                                                of: dependencyFamily,
                                                type: dependencyType,
                                                relativeToType: .implementation)
            let componentName = packageNameProvider.packageName(forType: dependencyType,
                                                                name: componentDependency.name,
                                                                of: dependencyFamily)
            return Dependency.module(path: path.full, name: componentName)
        }
        
        return PackageWithPath(
            package: Package(
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
                           dependencies: (implementationDependencies + dependencies).sorted(),
                           isTest: false),
                    Target(name: packageName + "Tests",
                           dependencies: (testsDependencies + [
                            Dependency.module(path: "",
                                              name: packageName)
                           ]).sorted(), isTest: true)
                ]
            ),
            path: packagePathProvider.path(for: component.name,
                                           of: family,
                                           type: .implementation,
                                           relativeToType: .implementation).path)
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
    
    func package(for component: Component, of family: Family, allFamilies: [Family], fileURL: URL) -> PackageWithPath {
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
            dependencies.append(.module(path: contractPath.full, name: contractName))
        } else if component.modules.contains(.implementation) {
            let implementationPath = packagePathProvider.path(for: component.name,
                                                              of: family,
                                                              type: .implementation,
                                                              relativeToType: .mock)
            let implementationName = packageNameProvider.packageName(forType: .contract,
                                                                     name: component.name,
                                                                     of: family)
            dependencies.append(.module(path: implementationPath.full, name: implementationName))
        }
        let otherDependencies: [Dependency] = component.dependencies.compactMap { componentDependency -> (Dependency)? in
            guard let dependencyType = componentDependency.mock,
                  let dependencyFamily = allFamilies.first(where: { $0.name == componentDependency.name.family })
            else { return nil }
            let path = packagePathProvider.path(for: componentDependency.name,
                                                of: dependencyFamily,
                                                type: dependencyType,
                                                relativeToType: .mock)
            let componentName = packageNameProvider.packageName(forType: dependencyType,
                                                                name: componentDependency.name,
                                                                of: dependencyFamily)
            return Dependency.module(path: path.full, name: componentName)
        }
        dependencies.append(contentsOf: otherDependencies)
        dependencies.sort()
        
        return PackageWithPath(
            package: Package(
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
            ),
            path: packagePathProvider.path(for: component.name,
                                           of: family,
                                           type: .mock,
                                           relativeToType: .mock).path)
    }
}
