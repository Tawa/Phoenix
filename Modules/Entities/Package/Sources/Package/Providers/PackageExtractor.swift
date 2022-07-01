import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

protocol PackageExtracting {
    func package(for component: Component,
                 of family: Family,
                 allFamilies: [Family],
                 packageConfiguration: PackageConfiguration,
                 projectConfiguration: ProjectConfiguration) -> PackageWithPath
}

struct PackageExtractor: PackageExtracting {
    private let packageNameProvider: PackageNameProviding
    private let packageFolderNameProvider: PackageFolderNameProviding
    private let packagePathProvider: PackagePathProviding
    private let swiftVersion: String

    init(packageNameProvider: PackageNameProviding,
         packageFolderNameProvider: PackageFolderNameProviding,
         packagePathProvider: PackagePathProviding,
         swiftVersion: String) {
        self.packageNameProvider = packageNameProvider
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packagePathProvider = packagePathProvider
        self.swiftVersion = swiftVersion
    }


    func package(for component: Component,
                 of family: Family,
                 allFamilies: [Family],
                 packageConfiguration: PackageConfiguration,
                 projectConfiguration: ProjectConfiguration) -> PackageWithPath {
        let packageName = packageNameProvider.packageName(forComponentName: component.name,
                                                          of: family,
                                                          packageConfiguration: packageConfiguration)

        let packageTargetType = PackageTargetType(name: packageConfiguration.name, isTests: false)
        var dependencies: [Dependency] = []
        var implementationDependencies: [Dependency] = component.dependencies.sorted().compactMap { dependencyType -> Dependency? in
            switch dependencyType {
            case let .local(componentDependency):
                guard
                    let targetTypeString = componentDependency.targetTypes[packageTargetType],
                    let dependencyFamily = allFamilies.first(where: { $0.name == componentDependency.name.family }),
                    let dependencyConfiguration = projectConfiguration.packageConfigurations.first(where: { $0.name == targetTypeString })
                else { return nil }
                return .module(path: packagePathProvider.path(for: componentDependency.name,
                                                              of: dependencyFamily,
                                                              packageConfiguration: dependencyConfiguration,
                                                              relativeToConfiguration: packageConfiguration),
                               name: packageNameProvider.packageName(forComponentName: componentDependency.name,
                                                                     of: dependencyFamily,
                                                                     packageConfiguration: dependencyConfiguration))
            case let .remote(remoteDependency):
                guard remoteDependency.targetTypes.contains(packageTargetType) else { return nil }
                return .external(url: remoteDependency.url,
                                 name: remoteDependency.name,
                                 description: remoteDependency.version)
            }
        }
        if let internalDependencyString = packageConfiguration.internalDependency,
           component.modules[internalDependencyString] != nil,
           let internalDependencyConfiguration = projectConfiguration.packageConfigurations.first(where: { $0.name == internalDependencyString }) {
            implementationDependencies.insert(
                .module(path: packagePathProvider.path(for: component.name,
                                                       of: family,
                                                       packageConfiguration: internalDependencyConfiguration,
                                                       relativeToConfiguration: packageConfiguration),
                        name: packageNameProvider.packageName(forComponentName: component.name,
                                                              of: family,
                                                              packageConfiguration: internalDependencyConfiguration)),
                at: 0)
        }

        var targets: [Target] = [
            Target(name: packageName,
                   dependencies: implementationDependencies,
                   isTest: false,
                   resources: component.resources.filter { $0.targets.contains(packageTargetType) }
                .map { TargetResources(folderName: $0.folderName,
                                       resourcesType: $0.type) })
        ]

        dependencies = implementationDependencies
        if packageConfiguration.hasTests {
            let packageTestsTargetType = PackageTargetType(name: packageConfiguration.name, isTests: true)
            let testsDependencies: [Dependency] = component.dependencies.sorted().compactMap { dependencyType -> Dependency? in
                switch dependencyType {
                case let .local(componentDependency):
                    guard
                        let targetTypeString = componentDependency.targetTypes[packageTestsTargetType],
                        let dependencyFamily = allFamilies.first(where: { $0.name == componentDependency.name.family }),
                        let dependencyConfiguration = projectConfiguration.packageConfigurations.first(where: { $0.name == targetTypeString })
                    else { return nil }
                    return .module(path: packagePathProvider.path(for: componentDependency.name,
                                                                  of: dependencyFamily,
                                                                  packageConfiguration: dependencyConfiguration,
                                                                  relativeToConfiguration: packageConfiguration),
                                   name: packageNameProvider.packageName(forComponentName: componentDependency.name,
                                                                         of: dependencyFamily,
                                                                         packageConfiguration: dependencyConfiguration))
                case let .remote(remoteDependency):
                    guard remoteDependency.targetTypes.contains(packageTestsTargetType) else { return nil }
                    return .external(url: remoteDependency.url,
                                     name: remoteDependency.name,
                                     description: remoteDependency.version)
                }
            }
            targets.append(
                Target(name: packageName + "Tests",
                       dependencies: [Dependency.module(path: "", name: packageName)] + testsDependencies,
                       isTest: true,
                       resources: component.resources.filter { $0.targets.contains(PackageTargetType(name: packageConfiguration.name,
                                                                                                     isTests: true)) }
                    .map { TargetResources(folderName: $0.folderName,
                                           resourcesType: $0.type) })
            )
            dependencies += testsDependencies
        }

        return .init(package: .init(name: packageName,
                                    iOSVersion: component.iOSVersion,
                                    macOSVersion: component.macOSVersion,
                                    products: [Product.library(Library(name: packageName,
                                                                       type: component.modules[packageConfiguration.name] ?? .undefined,
                                                                       targets: [packageName]))],
                                    dependencies: dependencies.uniqued(),
                                    targets: targets,
                                    swiftVersion: swiftVersion),
                     path: packagePathProvider.path(for: component.name,
                                                    of: family,
                                                    packageConfiguration: packageConfiguration))
    }
}
