import Foundation

public struct PackageWithPath {
    public let package: Package
    public let path: String
}

public protocol PackagesExtracting {
    func packages(for component: Component, of family: Family, allFamilies: [Family], fileURL: URL) -> [PackageWithPath]
}

public struct PackagesExtractor: PackagesExtracting {
    let packageExtractors: [ModuleType: PackageExtracting]

    public init() {
        let defaultFolderNameProvider = FamilyFolderNameProvider()
        let packageNameProvider = PackageNameProvider()
        let packageFolderNameProvider = PackageFolderNameProvider(defaultFolderNameProvider: defaultFolderNameProvider)
        let packagePathProvider = PackagePathProvider(packageFolderNameProvider: packageFolderNameProvider,
                                                      packageNameProvider: packageNameProvider)

        self.packageExtractors = [
            .contract: ContractPackageExtractor(packageNameProvider: packageNameProvider,
                                                packageFolderNameProvider: packageFolderNameProvider,
                                                packagePathProvider: packagePathProvider),
            .implementation: ImplementationPackageExtractor(packageNameProvider: packageNameProvider,
                                                            packageFolderNameProvider: packageFolderNameProvider,
                                                            packagePathProvider: packagePathProvider),
            .mock: MockPackageExtractor(packageNameProvider: packageNameProvider,
                                        packageFolderNameProvider: packageFolderNameProvider,
                                        packagePathProvider: packagePathProvider)
        ]
    }

    init(packageExtractors: [ModuleType: PackageExtracting]) {
        self.packageExtractors = packageExtractors
    }

    public func packages(for component: Component, of family: Family, allFamilies: [Family], fileURL: URL) -> [PackageWithPath] {
        component.modules.compactMap { packageExtractors[$0]?.package(for: component, of: family, allFamilies: allFamilies, fileURL: fileURL) }
    }
}
