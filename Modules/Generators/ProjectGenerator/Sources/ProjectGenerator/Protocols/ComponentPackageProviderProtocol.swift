import PhoenixDocument
import ProjectGeneratorContract

public protocol ComponentPackageProviderProtocol {
    func package(for component: Component,
                 of family: Family,
                 allFamilies: [Family],
                 packageConfiguration: PackageConfiguration,
                 projectConfiguration: ProjectConfiguration,
                 remoteComponents: [RemoteComponent]) -> PackageWithPath
}
