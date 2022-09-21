import Component
import SwiftPackage

public struct PackageWithPath: Equatable {
    public let package: SwiftPackage
    public let path: String

    public init(package: SwiftPackage, path: String) {
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
