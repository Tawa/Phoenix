import Foundation

protocol PackageExtracting {
    func package(for component: Component, of family: Family, allFamilies: [Family]) -> PackageWithPath
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

    func package(for component: Component, of family: Family, allFamilies: [Family]) -> PackageWithPath {
        let packageName = packageNameProvider.packageName(forType: .contract,
                                                          name: component.name,
                                                          of: family)
        
        var dependencies: [Dependency] = component.dependencies.compactMap { componentDependencyType -> (Dependency)? in
            switch componentDependencyType {
            case let .local(componentDependency):
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
            case let .remote(remoteDependency):
                guard remoteDependency.contract else { return nil }
                return Dependency.external(url: remoteDependency.url,
                                           name: remoteDependency.name,
                                           description: remoteDependency.version)
            }
        }
        dependencies.sort()

        return PackageWithPath(
            package: Package(
                name: packageName,
                iOSVersion: component.iOSVersion,
                macOSVersion: component.macOSVersion,
                products: [
                    .library(Library(name: packageName,
                                     type: component.modules[.contract] ?? .undefined,
                                     targets: [packageName]))],
                dependencies: dependencies,
                targets: [
                    Target(name: packageName,
                           dependencies: dependencies,
                           isTest: false,
                           resources: component.resources.filter { $0.targets.contains(.contract) }
                        .map { TargetResources(folderName: $0.folderName,
                                               resourcesType: $0.type) })
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
    
    func package(for component: Component, of family: Family, allFamilies: [Family]) -> PackageWithPath {
        let packageName = packageNameProvider.packageName(forType: .implementation,
                                                          name: component.name,
                                                          of: family)
        
        var dependencies: [Dependency] = []
        if component.modules[.contract] != nil {
            let contractPath = packagePathProvider.path(for: component.name,
                                                        of: family,
                                                        type: .contract,
                                                        relativeToType: .implementation)
            let contractName = packageNameProvider.packageName(forType: .contract,
                                                               name: component.name,
                                                               of: family)
            dependencies.append(.module(path: contractPath.full, name: contractName))
        }
        let implementationDependencies = component.dependencies.compactMap { componentDependencyType -> (Dependency)? in
            switch componentDependencyType {
            case let .local(componentDependency):
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
            case let .remote(remoteDependency):
                guard remoteDependency.implementation else { return nil }
                return Dependency.external(url: remoteDependency.url,
                                           name: remoteDependency.name,
                                           description: remoteDependency.version)
            }
        }
        let testsDependencies = component.dependencies.compactMap { componentDependencyType -> (Dependency)? in
            switch componentDependencyType {
            case let .local(componentDependency):
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
            case let .remote(remoteDependency):
                guard remoteDependency.tests else { return nil }
                return Dependency.external(url: remoteDependency.url,
                                           name: remoteDependency.name,
                                           description: remoteDependency.version)
            }
        }
        
        return PackageWithPath(
            package: Package(
                name: packageName,
                iOSVersion: component.iOSVersion,
                macOSVersion: component.macOSVersion,
                products: [
                    .library(Library(name: packageName,
                                     type: component.modules[.implementation] ?? .undefined,
                                     targets: [packageName]))],
                dependencies: Array(Set((dependencies + implementationDependencies + testsDependencies))).sorted(),
                targets: [
                    Target(name: packageName,
                           dependencies: (implementationDependencies + dependencies).sorted(),
                           isTest: false,
                           resources: component.resources.filter { $0.targets.contains(.implementation) }
                        .map { TargetResources(folderName: $0.folderName,
                                               resourcesType: $0.type) }),
                    Target(name: packageName + "Tests",
                           dependencies: (testsDependencies + [
                            Dependency.module(path: "",
                                              name: packageName)
                           ]).sorted(),
                           isTest: true,
                           resources: component.resources.filter { $0.targets.contains(.tests) }
                        .map { TargetResources(folderName: $0.folderName,
                                               resourcesType: $0.type) })
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
    
    func package(for component: Component, of family: Family, allFamilies: [Family]) -> PackageWithPath {
        let packageName = packageNameProvider.packageName(forType: .mock,
                                                          name: component.name,
                                                          of: family)
        
        var dependencies: [Dependency] = []
        if component.modules[.contract] != nil {
            let contractPath = packagePathProvider.path(for: component.name,
                                                        of: family,
                                                        type: .contract,
                                                        relativeToType: .mock)
            let contractName = packageNameProvider.packageName(forType: .contract,
                                                               name: component.name,
                                                               of: family)
            dependencies.append(.module(path: contractPath.full, name: contractName))
        } else if component.modules[.implementation] != nil {
            let implementationPath = packagePathProvider.path(for: component.name,
                                                              of: family,
                                                              type: .implementation,
                                                              relativeToType: .mock)
            let implementationName = packageNameProvider.packageName(forType: .contract,
                                                                     name: component.name,
                                                                     of: family)
            dependencies.append(.module(path: implementationPath.full, name: implementationName))
        }
        let otherDependencies: [Dependency] = component.dependencies.compactMap { componentDependencyType -> (Dependency)? in
            switch componentDependencyType {
            case let .local(componentDependency):
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
            case let .remote(remoteDependency):
                guard remoteDependency.mock else { return nil }
                return Dependency.external(url: remoteDependency.url,
                                           name: remoteDependency.name,
                                           description: remoteDependency.version)
            }
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
                                     type: component.modules[.mock] ?? .undefined,
                                     targets: [packageName]))],
                dependencies: dependencies,
                targets: [
                    Target(name: packageName,
                           dependencies: dependencies,
                           isTest: false,
                           resources: component.resources.filter { $0.targets.contains(.mock) }
                        .map { TargetResources(folderName: $0.folderName,
                                               resourcesType: $0.type) })
                ]
            ),
            path: packagePathProvider.path(for: component.name,
                                           of: family,
                                           type: .mock,
                                           relativeToType: .mock).path)
    }
}
