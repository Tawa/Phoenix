import PBXProjectSyncerContract
import Foundation
import PhoenixDocument

import SwiftPackage

import XcodeProj
import PathKit
import PackagePathProviderContract

public struct PBXProjectSyncer: PBXProjectSyncerProtocol {
    let packageFolderNameProvider: PackageFolderNameProviderProtocol
    let packageNameProvider: PackageNameProviderProtocol
    let packagePathProvider: PackagePathProviderProtocol
    let projectWriter: PBXProjectWriterProtocol
    
    public init(
        packageFolderNameProvider: PackageFolderNameProviderProtocol,
        packageNameProvider: PackageNameProviderProtocol,
        packagePathProvider: PackagePathProviderProtocol,
        projectWriter: PBXProjectWriterProtocol)
    {
        self.packageFolderNameProvider = packageFolderNameProvider
        self.packageNameProvider = packageNameProvider
        self.packagePathProvider = packagePathProvider
        self.projectWriter = projectWriter
    }
    
    public func sync(document: PhoenixDocument,
                     at documentURL: URL,
                     withProjectAt xcodeProjectURL: URL) throws {
        let allPackages = document.families.map { componentsFamily in
            componentsFamily.components.map { component in
                component.modules.keys.compactMap { moduleType -> PackageDescription? in
                    guard let packageConfiguration = document.projectConfiguration.packageConfigurations.first(where: { $0.name == moduleType }) else { return nil }
                    let name = component.name
                    let family = componentsFamily.family
                    return PackageDescription(name: packageNameProvider.packageName(forComponentName: name,
                                                                                    of: family,
                                                                                    packageConfiguration: packageConfiguration),
                                              path: packagePathProvider.path(for: name,
                                                                             of: family,
                                                                             packageConfiguration: packageConfiguration))
                }
            }
        }
            .flatMap { $0 }
            .flatMap { $0 }
            .sorted(by: { $0.path < $1.path })
        
        let modulesGroup = group(for: allPackages, rootPath: documentURL.deletingLastPathComponent().lastPathComponent)
        try projectWriter.write(group: modulesGroup, xcodeProjectURL: xcodeProjectURL)
    }
    
    func group(for packages: [PackageDescription], rootPath: String) -> Group {
        let group = Group(name: rootPath, children: [], packages: [])
        packages.forEach { add(package: $0, toGroup: group, rootPath: rootPath) }
        return group
    }
    
    func add(package: PackageDescription, toGroup group: Group, rootPath: String) {
        let newGroup = getGroup(at: package.path, in: group)
        newGroup.packages.append(
            PackageDescription(
                name: package.name,
                path: [rootPath, package.path].joined(separator: "/")
            )
        )
    }
    
    func getGroup(at path: String, in group: Group) -> Group {
        var pathComponents = path.components(separatedBy: "/").dropLast()
        var groupReference = group
        while let firstPathComponent = pathComponents.first {
            if let child = groupReference.children.first(where: { $0.name == firstPathComponent }) {
                groupReference = child
            } else {
                let newGroup = Group(name: firstPathComponent, children: [], packages: [])
                groupReference.children.append(newGroup)
                groupReference = newGroup
            }
            pathComponents.removeFirst()
        }
        return groupReference
    }
    
    func group(forComponentsFamily: ComponentsFamily, projectConfigmration: ProjectConfiguration) -> Group {
        Group(name: packageFolderNameProvider.folderName(for: forComponentsFamily.family),
              children: [],
              packages: packages(forComponentsFamily: forComponentsFamily, projectConfigmration: projectConfigmration))
    }
    
    func packages(forComponentsFamily: ComponentsFamily, projectConfigmration: ProjectConfiguration) -> [PackageDescription] {
        guard let packageConfiguration = projectConfigmration.packageConfigurations.first(where: { $0.containerFolderName == nil }) else { return [] }
        return forComponentsFamily.components.map { component in
            PackageDescription(name: packageNameProvider.packageName(forComponentName: component.name,
                                                                     of: forComponentsFamily.family,
                                                                     packageConfiguration: packageConfiguration),
                               path: packagePathProvider.path(for: component.name,
                                                              of: forComponentsFamily.family,
                                                              packageConfiguration: packageConfiguration))
        }
    }
}
