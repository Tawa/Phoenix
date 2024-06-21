import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct MacroComponentPackageProvider: MacroComponentPackageProviderProtocol {
    public init() {}
    
    public func package(for macroComponent: MacroComponent,
                        projectConfiguration: ProjectConfiguration) -> PackageWithPath {
        let name = macroComponent.name
        let macrosName = name + "Macros"
        let clientName = name + "Client"
        let testsName = name + "Tests"
        
        return PackageWithPath(
            package: SwiftPackage(
                name: name,
                defaultLocalization: nil,
                platforms: macroComponent.platforms,
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
                        name: macrosName,
                        dependencies: [
                            .external(
                                url: "",
                                name: .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                                description: .branch(name: "")
                            ),
                            .external(
                                url: "",
                                name: .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                                description: .branch(name: "")
                            )
                        ],
                        resources: [],
                        type: .macro
                    ),
                    Target(
                        name: name,
                        dependencies: [.module(path: "", name: macrosName)],
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
                            .module(path: "", name: macrosName),
                            .external(
                                url: "",
                                name: .product(
                                    name: "SwiftSyntaxMacrosTestSupport",
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
            path: projectConfiguration.macrosFolderName + "/" + macroComponent.name
        )
    }
}
