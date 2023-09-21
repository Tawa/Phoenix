import PhoenixDocument
import ProjectGeneratorContract

public struct DocumentPackagesProvider: DocumentPackagesProviderProtocol {
    let componentPackagesProvider: ComponentPackagesProviderProtocol
    let macroComponentPackageProvider: MacroComponentPackageProviderProtocol
    
    public init(
        componentPackagesProvider: ComponentPackagesProviderProtocol,
        macroComponentPackageProvider: MacroComponentPackageProviderProtocol
    ) {
        self.componentPackagesProvider = componentPackagesProvider
        self.macroComponentPackageProvider = macroComponentPackageProvider
    }

    public func packages(for document: PhoenixDocument) -> [PackageWithPath] {
        let allFamilies: [Family] = document.families.map { $0.family }
        
        let componentPackages = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                componentPackagesProvider.packages(for: component,
                                                   of: family,
                                                   allFamilies: allFamilies,
                                                   projectConfiguration: document.projectConfiguration,
                                                   remoteComponents: document.remoteComponents)
            }
        }

        let macroComponentPackages = document.macroComponents.map { macroComponent in
            macroComponentPackageProvider.package(for: macroComponent,
                                                  projectConfiguration: document.projectConfiguration)
        }
        
        var packagesWithPath: [PackageWithPath] = []
        packagesWithPath.append(contentsOf: componentPackages)
        packagesWithPath.append(contentsOf: macroComponentPackages)
        return packagesWithPath
    }
}
