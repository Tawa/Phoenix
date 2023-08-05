import ComponentDetailsProviderContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

extension Component {
    func allDependencies(remoteComponents: [RemoteComponent]) -> [ComponentDependencyType] {
        var allDependencies: [ComponentDependencyType] = localDependencies.map(ComponentDependencyType.local)
        
        let remoteDependencies: [RemoteDependency] = remoteComponentDependencies
            .compactMap { remoteComponentDependency -> (RemoteComponent, [ExternalDependencyName : [PackageTargetType]])? in
                let targetTypes = remoteComponentDependency.targetTypes.filter { element in
                    !element.value.isEmpty
                }
                guard let remoteComponent = remoteComponents.first(where: {
                    $0.url == remoteComponentDependency.url
                })
                else { return nil }
                return (remoteComponent, targetTypes)
            }
            .flatMap { remoteComponent, targetTypes in
                targetTypes.keys.map { name in
                    RemoteDependency(
                        url: remoteComponent.url,
                        name: name,
                        value: remoteComponent.version,
                        targetTypes: targetTypes[name] ?? []
                    )
                }
            }
        
        allDependencies.append(contentsOf: remoteDependencies.map(ComponentDependencyType.remote))
        
        return allDependencies
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

public struct ComponentPackageProvider: ComponentPackageProviderProtocol {
    private let packageFolderNameProvider: PackageFolderNameProviderProtocol
    private let packageNameProvider: PackageNameProviderProtocol
    private let packagePathProvider: PackagePathProviderProtocol
    
    public init(packageFolderNameProvider: PackageFolderNameProviderProtocol,
                packageNameProvider: PackageNameProviderProtocol,
                packagePathProvider: PackagePathProviderProtocol) {
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packageNameProvider = packageNameProvider
        self.packagePathProvider = packagePathProvider
    }
    
    public func package(for component: Component,
                        of family: Family,
                        allFamilies: [Family],
                        packageConfiguration: PackageConfiguration,
                        projectConfiguration: ProjectConfiguration,
                        remoteComponents: [RemoteComponent]) -> PackageWithPath {
        let packageName = packageNameProvider.packageName(forComponentName: component.name,
                                                          of: family,
                                                          packageConfiguration: packageConfiguration)
        
        let defaultLocalization: String? = component.defaultLocalization.modules.contains(packageConfiguration.name) ? component.defaultLocalization.value : nil
        
        let packageTargetType = PackageTargetType(name: packageConfiguration.name, isTests: false)
        var dependencies: [Dependency] = []
        var implementationDependencies: [Dependency] = component.allDependencies(remoteComponents: remoteComponents)
            .sorted()
            .compactMap { dependencyType -> Dependency? in
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
            let testsDependencies: [Dependency] = component.allDependencies(remoteComponents: remoteComponents)
                .sorted()
                .compactMap { dependencyType -> Dependency? in
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
                                    defaultLocalization: defaultLocalization,
                                    iOSVersion: component.iOSVersion,
                                    macCatalystVersion: component.macCatalystVersion,
                                    macOSVersion: component.macOSVersion,
                                    tvOSVersion: component.tvOSVersion,
                                    watchOSVersion: component.watchOSVersion,
                                    products: [Product.library(Library(name: packageName,
                                                                       type: component.modules[packageConfiguration.name] ?? .undefined,
                                                                       targets: [packageName]))],
                                    dependencies: dependencies.uniqued(),
                                    targets: targets,
                                    swiftVersion: projectConfiguration.swiftVersion),
                     path: packagePathProvider.path(for: component.name,
                                                    of: family,
                                                    packageConfiguration: packageConfiguration))
    }
}
