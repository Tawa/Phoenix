import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct MetaComponentPackageProvider: MetaComponentPackageProviderProtocol {
    public init() {
        
    }
    
    public func package(for metaComponent: MetaComponent,
                        projectConfiguration: ProjectConfiguration) -> PackageWithPath {
        let name = metaComponent.name
        
        return PackageWithPath(
            package: SwiftPackage(
                name: name,
                defaultLocalization: nil,
                platforms: metaComponent.platforms,
                products: [
                    .library(Library(name: name, type: .undefined, targets: [name]))
                ],
                dependencies: [                    
//                    loop here
                    .module(path: "/Users/kateryna.nerush/Developer/lab/_Phoenix-sample/Phoenix/Modules/Features/OneFeature", name: "OneFeature"),
                    .module(path: "/Users/kateryna.nerush/Developer/lab/_Phoenix-sample/Phoenix/Modules/Features/TwoFeature", name: "TwoFeature"),
                ],
                targets: [
                    Target(
                        name: name,
                        dependencies: [
                            .module(path: "Users/kateryna.nerush/Developer/lab/_Phoenix-sample/Phoenix/Modules/Features/OneFeature", name: "OneFeature"),
                            .module(path: "Users/kateryna.nerush/Developer/lab/_Phoenix-sample/Phoenix/Modules/Features/TwoFeature", name: "TwoFeature")
                        ],
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
