import Foundation

public struct PackageWithPath {
    public let package: Package
    public let path: String
}

public protocol ComponentExtracting {
    func packages(for component: Component,
                  of family: Family,
                  allFamilies: [Family],
                  projectConfiguration: ProjectConfiguration) -> [PackageWithPath]
}

public struct ComponentExtractor: ComponentExtracting {
    let packageExtractor: PackageExtracting

    public init(swiftVersion: String) {
        let defaultFolderNameProvider = FamilyFolderNameProvider()
        let packageNameProvider = PackageNameProvider()
        let packageFolderNameProvider = PackageFolderNameProvider(defaultFolderNameProvider: defaultFolderNameProvider)
        let packagePathProvider = PackagePathProvider(packageFolderNameProvider: packageFolderNameProvider,
                                                      packageNameProvider: packageNameProvider)
        self.packageExtractor = PackageExtractor(packageNameProvider: packageNameProvider,
                                                 packageFolderNameProvider: packageFolderNameProvider,
                                                 packagePathProvider: packagePathProvider,
                                                 swiftVersion: swiftVersion)
    }

    init(packageExtractor: PackageExtracting) {
        self.packageExtractor = packageExtractor
    }

    public func packages(for component: Component,
                         of family: Family,
                         allFamilies: [Family],
                         projectConfiguration: ProjectConfiguration) -> [PackageWithPath] {
        projectConfiguration
            .packageConfigurations
            .filter { component.modules[$0.name] != nil }
            .map { packageConfiguration in
                packageExtractor.package(for: component,
                                         of: family,
                                         allFamilies: allFamilies,
                                         packageConfiguration: packageConfiguration,
                                         projectConfiguration: projectConfiguration)
            }
    }
}
