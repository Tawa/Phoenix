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
                        projectConfiguration: ProjectConfiguration,
                        componentPackages: [PackageWithPath]) -> PackageWithPath {
        let name = metaComponent.name
        let localDependencies: [ComponentDependency] = metaComponent.localDependencies
        var dependencies: [Dependency] = []

        localDependencies.forEach { dependency in
            let dependencyName = dependency.name.full 
            let filtered = dependency.targetTypes.filter({ $0.value == "Contract" })
            filtered.forEach {
                let dependencyFamily = $0.key.name
                let packageName = "\(dependencyName)\(dependencyFamily)"
                let componentPackage = componentPackages.first { $0.package.name == packageName}
                if let packageDependencies = componentPackage?.package.dependencies {
                    packageDependencies.forEach { packageDependency in
                        dependencies.append(packageDependency)
                    }
                }
            }
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
