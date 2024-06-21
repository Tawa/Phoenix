import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage
import ComponentDetailsProviderContract

public struct MetaComponentPackageProvider: MetaComponentPackageProviderProtocol {
    private let packageNameProvider: PackageNameProviderProtocol
    private let packagePathProvider: PackagePathProviderProtocol
    
    public init(
        packageNameProvider: PackageNameProviderProtocol,
        packagePathProvider: PackagePathProviderProtocol) {
            self.packageNameProvider = packageNameProvider
            self.packagePathProvider = packagePathProvider
        }
    
    public func package(for metaComponent: MetaComponent,
                        projectConfiguration: ProjectConfiguration) -> PackageWithPath {
        let name = metaComponent.name
        let localDependencies = metaComponent.localDependencies
        print("dependencies: \(localDependencies)")
        var dependencies: [Dependency] = []
        
        localDependencies.forEach { dependency in
            let type = dependency.targetTypes.keys.first!.name
            let dependencyConfiguration = projectConfiguration.packageConfigurations.first(where: { $0.name == type })!
            dependencies.insert(
                .module(path: packagePathProvider.path(for: dependency.name,
                                                       of: Family(name: dependency.name.family),
                                                       packageConfiguration: dependencyConfiguration,
                                                       relativeToConfiguration: dependencyConfiguration),
                        name: packageNameProvider.packageName(forComponentName: dependency.name,
                                                              of: Family(name: dependency.name.family),
                                                              packageConfiguration: dependencyConfiguration)),
                at: 0)
        }
        
        return PackageWithPath(
            package: SwiftPackage(
                name: name,
                defaultLocalization: nil,
                platforms: metaComponent.platforms,
                products: [
                    .library(Library(name: name, type: .undefined, targets: [name]))
                ],
                dependencies: dependencies,
                targets: [
                    Target(
                        name: name,
                        dependencies: dependencies,
                        resources: [],
                        type: .meta
                    )
                ],
                swiftVersion: projectConfiguration.swiftVersion
            ),
            path: projectConfiguration.metasFolderName + "/" + metaComponent.name
        )
    }
}
