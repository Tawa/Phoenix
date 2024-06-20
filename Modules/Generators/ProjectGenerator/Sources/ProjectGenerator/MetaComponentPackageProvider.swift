import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct MetaComponentPackageProvider: MetaComponentPackageProviderProtocol {
    public init() {
        
    }
    
    public func package(for metaComponent: MetaComponent,
                        projectConfiguration: ProjectConfiguration) -> PackageWithPath {
        let name = metaComponent.name
        let localDependencies = metaComponent.localDependencies
        print("dependencies: \(localDependencies)")
        localDependencies.forEach { dependency in
            let name = dependency.name.given
            let type = dependency.targetTypes.keys.first!.name
            print("name: \(name)")
            print("type: \(type)")
        }
        // we want to calculate a dependencies array [.module(path: , name: )] // path should be relative!!!
        // here is just a local sample
        let dependencies: [Dependency] = [.module(path: "/Users/nuno.pereira/Desktop/cp/HelloFresh/Modules/Contracts/Repositories/ApplyOneOffRepositoryContract", name: "ApplyOneOffRepositoryContract"),
                                          .module(path: "/Users/nuno.pereira/Desktop/cp/HelloFresh/Modules/Contracts/Features/AutoSaveFeatureContract", name: "AutoSaveFeatureContract"),
                                          .module(path: "/Users/nuno.pereira/Desktop/cp/HelloFresh/Modules/Contracts/Repositories/BalanceRepositoryContract", name: "BalanceRepositoryContract")]

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
