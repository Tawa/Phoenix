import Component
import DemoAppGeneratorContract
import PackageGeneratorContract
import ComponentDetailsProviderContract
import Foundation
import RelativeURLProviderContract
import SwiftPackage

public struct DemoAppGenerator: DemoAppGeneratorProtocol {
    private let packageGenerator: PackageGeneratorProtocol
    private let packageNameProvider: PackageNameProviderProtocol
    private let packagePathProvider: PackagePathProviderProtocol
    private let relativeURLProvider: RelativeURLProviderProtocol
    private let fileManager: FileManager
    
    public init(packageGenerator: PackageGeneratorProtocol,
                packageNameProvider: PackageNameProviderProtocol,
                packagePathProvider: PackagePathProviderProtocol,
                relativeURLProvider: RelativeURLProviderProtocol,
                fileManager: FileManager = .default) {
        self.packageGenerator = packageGenerator
        self.packageNameProvider = packageNameProvider
        self.packagePathProvider = packagePathProvider
        self.relativeURLProvider = relativeURLProvider
        self.fileManager = fileManager
    }
    
    public func generateDemoApp(forComponent component: Component,
                                of family: Family,
                                families: [ComponentsFamily],
                                projectConfiguration: ProjectConfiguration,
                                at url: URL,
                                relativeURL: URL) throws {
        var resultURL = url
        let name = packageNameProvider.packageName(
            forComponentName: component.name,
            of: family,
            packageConfiguration: .init(name: "", appendPackageName: false, hasTests: false)
        )
        if fileManager.fileExists(atPath: resultURL.appendingPathComponent("\(name)DemoApp.xcodeproj").path) {
            resultURL = resultURL.deletingLastPathComponent()
        }
        
        try copyProjectFilesIfNecessary(named: name, url: resultURL)
        try generateXcodeProj(named: name, url: resultURL)
        try generateDependenciesPackage(named: name,
                                        forComponent: component,
                                        of: family,
                                        families: families,
                                        projectConfiguration: projectConfiguration,
                                        at: resultURL,
                                        relativeURL: relativeURL)
        try generatePBXProjectFile(forComponent: component,
                                   named: name,
                                   families: families,
                                   projectConfiguration: projectConfiguration,
                                   url: resultURL,
                                   relativeURL: relativeURL)
    }
    
    func generateXcodeProj(
        named name: String,
        url: URL) throws
    {
        let finalURL = url
            .appendingPathComponent("\(name)DemoApp")
            .appendingPathComponent("\(name)DemoApp.xcodeproj")
        
        try fileManager.createDirectory(at: finalURL,
                                        withIntermediateDirectories: true)
    }
    
    func generatePBXProjectFile(
        forComponent component: Component,
        named name: String,
        families: [ComponentsFamily],
        projectConfiguration: ProjectConfiguration,
        url: URL,
        relativeURL: URL) throws
    {
        let finalURL = url
            .appendingPathComponent("\(name)DemoApp")
            .appendingPathComponent("\(name)DemoApp.xcodeproj")
            .appendingPathComponent("project.pbxproj")

        let modulesRelativePath = relativeURLProvider.path(for: finalURL.deletingLastPathComponent(), relativeURL: relativeURL)
        let dependencies: [Dependency] = getAllDependencies(forComponent: component,
                                                            families: families,
                                                            projectConfiguration: projectConfiguration,
                                                            modulesRelativePath: modulesRelativePath)

        guard let pbxString = pbxProjectContent(forComponent: component,
                                                named: name,
                                                dependencies: dependencies)
        else { return }
        
        try pbxString.data(using: .utf8)?.write(to: finalURL)
    }
    
    func generateDependenciesPackage(named name: String,
                                     forComponent component: Component,
                                     of family: Family,
                                     families: [ComponentsFamily],
                                     projectConfiguration: ProjectConfiguration,
                                     at url: URL,
                                     relativeURL: URL) throws {
        let dependenciesPackageName: String = "Dependencies"
        let resultURL = url
            .appendingPathComponent("\(name)DemoApp")
            .appendingPathComponent(dependenciesPackageName)
        
        let modulesRelativePath = relativeURLProvider.path(for: resultURL, relativeURL: relativeURL)
        let dependencies: [Dependency] = getAllDependencies(forComponent: component,
                                                            families: families,
                                                            projectConfiguration: projectConfiguration,
                                                            modulesRelativePath: modulesRelativePath)

        let package = SwiftPackage(name: dependenciesPackageName,
                              iOSVersion: .v15,
                              macOSVersion: .v12,
                              products: [
                                .library(.init(name: dependenciesPackageName,
                                               type: .undefined,
                                               targets: [dependenciesPackageName]))
                              ],
                              dependencies: dependencies,
                              targets: [
                                .init(name: dependenciesPackageName,
                                      dependencies: dependencies,
                                      isTest: false,
                                      resources: [])
                              ],
                              swiftVersion: "5.6")
        try packageGenerator.generate(package: package, at: resultURL)
    }
    
    func getAllDependencies(forComponent component: Component,
                            families: [ComponentsFamily],
                            projectConfiguration: ProjectConfiguration,
                            modulesRelativePath: String) -> [Dependency] {
        var dependenciesDictionary: [String: Dependency] = [:]
        addDependencies(forComponent: component,
                        families: families,
                        projectConfiguration: projectConfiguration,
                        dependenciesDictionary: &dependenciesDictionary,
                        modulesRelativePath: modulesRelativePath)
        return Array(dependenciesDictionary.values).sorted()
    }
    
    func addDependencies(forComponent component: Component,
                         families: [ComponentsFamily],
                         projectConfiguration: ProjectConfiguration,
                         dependenciesDictionary: inout [String: Dependency],
                         modulesRelativePath: String) {
        guard let family = families.first(where: { $0.family.name == component.name.family })?.family
        else { return }
        component.modules.forEach { (key: String, value: LibraryType) in
            guard let packageConfiguration = projectConfiguration.packageConfigurations.first(where: { $0.name == key })
            else { return }
            let name = self.packageNameProvider.packageName(forComponentName: component.name,
                                                            of: family,
                                                            packageConfiguration: packageConfiguration)
            guard dependenciesDictionary[name] == nil
            else { return }
            
            let path = self.packagePathProvider.path(for: component.name,
                                                     of: family,
                                                     packageConfiguration: packageConfiguration)
            let resultPath = [modulesRelativePath, path].joined(separator: "/")
            
            dependenciesDictionary[name] = .module(path: resultPath, name: name)
            
            for dependency in component.dependencies {
                switch dependency {
                case .local(let componentDependency):
                    if let newComponent = families.first(where: {
                        $0.family.name == componentDependency.name.family
                    })?.components.first(where: { $0.name == componentDependency.name }) {
                        addDependencies(forComponent: newComponent,
                                        families: families,
                                        projectConfiguration: projectConfiguration,
                                        dependenciesDictionary: &dependenciesDictionary,
                                        modulesRelativePath: modulesRelativePath)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func pbxProjectContent(forComponent component: Component,
                           named name: String,
                           dependencies: [Dependency]) -> String? {
        guard
            let resourcesPath = Bundle.module.resourcePath,
            let data = fileManager.contents(atPath: resourcesPath + "/Templates/pbxprojecttemplate"),
            let pbxString = String(data: data, encoding: .utf8)
        else { return nil }
        
        let packageNameKey: String = "[[PACKAGE_NAME]]"
        let packageNameValue: String = name
        
        var current: Int = 0
        let dependenciesMap: [(id: String, name: String, path: String)] = dependencies.compactMap { dependency -> (id: String, name: String, path: String)? in
            switch dependency {
            case let .module(path, name):
                current += 1
                return (id: "PHOENIXPACKAGE" + String(format: "%010d", current), name: name, path: path)
            default:
                return nil
            }
        }
        
        let packagesReferencesContentKey: String = "[[PACKAGES_REFERENCES_CONTENT]]"
        let packagesReferencesContentValue: String = dependenciesMap.map { (id, name, path) in
            return "        \(id) /* \(name) */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = \(name); path = \(path); sourceTree = \"<group>\"; };"
        }.joined(separator: "\n")
        
        let packagesGroupContentKey: String = "[[PACKAGES_GROUP_CONTENT]]"
        let packagesGroupContentValue: String = dependenciesMap.map { (id, name, path) in
            return "                \(id) /* \(name) */,"
        }.joined(separator: "\n")
        
        let frameworksContentKey: String = "[[FRAMEWORKS_CONTENT]]"
        let frameworksContentValue: String = packagesGroupContentValue
        
        let result = pbxString
            .replacingOccurrences(of: packageNameKey, with: packageNameValue)
            .replacingOccurrences(of: packagesGroupContentKey, with: packagesGroupContentValue)
            .replacingOccurrences(of: packagesReferencesContentKey, with: packagesReferencesContentValue)
            .replacingOccurrences(of: frameworksContentKey, with: frameworksContentValue)
        
        return result
    }
    
    func copyProjectFilesIfNecessary(named name: String, url: URL) throws {
        guard
            let resourcesPath = Bundle.module.resourcePath
        else { return }
        let sourcesFolderPath: String = resourcesPath + "/Templates/DemoApp"
        let sourcesFolderURL: URL = .init(fileURLWithPath: sourcesFolderPath)
        
        let destinationURL = url
            .appendingPathComponent("\(name)DemoApp/")
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            return
        }
        
        try fileManager.copyItem(at: sourcesFolderURL, to: destinationURL)
        
        let projectFilesFolderURL = destinationURL.appendingPathComponent("DemoApp")
        let projectFilesFolderRenamedURL = destinationURL.appendingPathComponent("\(name)DemoApp")
        
        try fileManager.moveItem(at: projectFilesFolderURL, to: projectFilesFolderRenamedURL)
    }
}
