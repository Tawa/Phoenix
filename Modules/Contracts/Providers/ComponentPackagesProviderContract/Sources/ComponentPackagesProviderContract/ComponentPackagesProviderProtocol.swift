import Package

public struct PackageWithPath: Equatable {
    public let package: Package
    public let path: String

    public init(package: Package, path: String) {
        self.package = package
        self.path = path
    }
}

public protocol ComponentPackagesProviderProtocol {
    func packages(for component: Component,
                  of family: Family,
                  allFamilies: [Family],
                  projectConfiguration: ProjectConfiguration) -> [PackageWithPath]
}
