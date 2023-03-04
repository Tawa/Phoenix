import PhoenixDocument
import ProjectGeneratorContract

public struct DocumentPackagesProvider: DocumentPackagesProviderProtocol {
    let componentPackagesProvider: ComponentPackagesProviderProtocol
    
    public init(componentPackagesProvider: ComponentPackagesProviderProtocol) {
        self.componentPackagesProvider = componentPackagesProvider
    }

    public func packages(for document: PhoenixDocument) -> [PackageWithPath] {
        let allFamilies: [Family] = document.families.map { $0.family }
        let packagesWithPath: [PackageWithPath] = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                componentPackagesProvider.packages(for: component,
                                                   of: family,
                                                   allFamilies: allFamilies,
                                                   projectConfiguration: document.projectConfiguration,
                                                   remoteComponents: document.remoteComponents)
            }
        }

        return packagesWithPath
    }
}
