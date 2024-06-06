import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct MetaComponentPackageProvider: MetaComponentPackageProviderProtocol {
    public init() {
        
    }
    
    public func package(for metaComponent: MetaComponent,
                        projectConfiguration: ProjectConfiguration) -> PackageWithPath {
        let name = metaComponent.name
        let metasName = name + "Metas"
        let clientName = name + "Client"
        let testsName = name + "Tests"
        
        return PackageWithPath(
            package: SwiftPackage(
                name: name,
                defaultLocalization: nil,
                platforms: metaComponent.platforms,
                products: [
                    .executable(Executable(name: clientName, targets: [clientName])),
                    .library(Library(name: name, type: .undefined, targets: [name]))
                ],
                dependencies: [
                    .external(
                        url: "https://github.com/apple/swift-syntax.git",
                        name: .name(""),
                        description: .from(version: "509.0.0")
                    )
                ],
                targets: [
                    Target(
                        name: metasName,
                        dependencies: [
                            .external(
                                url: "",
                                name: .product(name: "SwiftSyntaxMetas", package: "swift-syntax"),
                                description: .branch(name: "")
                            ),
                            .external(
                                url: "",
                                name: .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                                description: .branch(name: "")
                            )
                        ],
                        resources: [],
                        type: .meta
                    ),
                    Target(
                        name: name,
                        dependencies: [.module(path: "", name: metasName)],
                        resources: [],
                        type: .target
                    ),
                    Target(
                        name: clientName,
                        dependencies: [.module(path: "", name: name)],
                        resources: [],
                        type: .executableTarget
                    ),
                    Target(
                        name: testsName,
                        dependencies: [
                            .module(path: "", name: metasName),
                            .external(
                                url: "",
                                name: .product(
                                    name: "SwiftSyntaxMetasTestSupport",
                                    package: "swift-syntax"
                                ),
                                description: .branch(name: "")
                            )
                        ],
                        resources: [],
                        type: .testTarget
                    ),
                ],
                swiftVersion: projectConfiguration.swiftVersion
            ),
            path: projectConfiguration.macrosFolderName + "/" + metaComponent.name
        )
    }
}
