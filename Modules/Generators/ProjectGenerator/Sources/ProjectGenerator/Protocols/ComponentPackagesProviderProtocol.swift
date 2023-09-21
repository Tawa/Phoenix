import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public protocol ComponentPackagesProviderProtocol {
    func packages(for component: Component,
                  of family: Family,
                  allFamilies: [Family],
                  projectConfiguration: ProjectConfiguration,
                  remoteComponents: [RemoteComponent]) -> [PackageWithPath]
}

