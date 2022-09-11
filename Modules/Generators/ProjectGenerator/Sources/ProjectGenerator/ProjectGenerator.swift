import ComponentPackagesProviderContract
import Foundation
import Package
import PackageGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import ProjectGeneratorContract

public struct ProjectGenerator: ProjectGeneratorProtocol {
    let componentPackagesProvider: ComponentPackagesProviderProtocol
    let packageGenerator: PackageGeneratorProtocol
    let pbxProjectSyncer: PBXProjectSyncerProtocol
    
    public init(
        componentPackagesProvider: ComponentPackagesProviderProtocol,
        packageGenerator: PackageGeneratorProtocol,
        pbxProjectSyncer: PBXProjectSyncerProtocol
    ) {
        self.componentPackagesProvider = componentPackagesProvider
        self.packageGenerator = packageGenerator
        self.pbxProjectSyncer = pbxProjectSyncer
    }
    
    public func generate(document: PhoenixDocument, folderURL: URL) throws {
        let allFamilies: [Family] = document.families.map { $0.family }
        let packagesWithPath: [PackageWithPath] = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                componentPackagesProvider.packages(for: component,
                                                   of: family,
                                                   allFamilies: allFamilies,
                                                   projectConfiguration: document.projectConfiguration)
            }
        }
        
        for packageWithPath in packagesWithPath {
            let url = folderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            try packageGenerator.generate(package: packageWithPath.package, at: url)
        }
    }
}
