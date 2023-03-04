import ComponentDetailsProviderContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct ComponentPackagesProvider: ComponentPackagesProviderProtocol {
    let componentPackageProvider: ComponentPackageProviderProtocol
    
    public init(componentPackageProvider: ComponentPackageProviderProtocol) {
        self.componentPackageProvider = componentPackageProvider
    }
    
    public func packages(for component: Component,
                         of family: Family,
                         allFamilies: [Family],
                         projectConfiguration: ProjectConfiguration,
                         remoteComponents: [RemoteComponent]) -> [PackageWithPath] {
        projectConfiguration
            .packageConfigurations
            .filter { component.modules[$0.name] != nil }
            .map { packageConfiguration in
                componentPackageProvider.package(for: component,
                                                 of: family,
                                                 allFamilies: allFamilies,
                                                 packageConfiguration: packageConfiguration,
                                                 projectConfiguration: projectConfiguration,
                                                 remoteComponents: remoteComponents)
            }
    }
}
