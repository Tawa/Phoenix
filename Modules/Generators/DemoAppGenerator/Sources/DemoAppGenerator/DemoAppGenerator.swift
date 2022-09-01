import DemoAppGeneratorContract
import Package
import PackageGeneratorContract
import Foundation
import RelativeURLProviderContract

public struct DemoAppGenerator: DemoAppGeneratorProtocol {
    private let packageNameProvider: PackageNameProviding
    private let packageGenerator: PackageGeneratorProtocol
    private let relativeURLProvider: RelativeURLProviding
    private let fileManager: FileManager
    
    public init(packageNameProvider: PackageNameProviding,
                packageGenerator: PackageGeneratorProtocol,
                relativeURLProvider: RelativeURLProviding,
                fileManager: FileManager = .default) {
        self.packageNameProvider = packageNameProvider
        self.packageGenerator = packageGenerator
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
                                        at: resultURL)
        try generatePBXProjectFile(forComponent: component, named: name, url: resultURL)
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
        url: URL) throws
    {
        guard let pbxString = pbxProjectContent(forComponent: component, named: name)
        else { return }
        
        let finalURL = url
            .appendingPathComponent("\(name)DemoApp")
            .appendingPathComponent("\(name)DemoApp.xcodeproj")
            .appendingPathComponent("project.pbxproj")
        
        try pbxString.data(using: .utf8)?.write(to: finalURL)
    }
    
    func generateDependenciesPackage(named name: String,
                                     forComponent component: Component,
                                     of family: Family,
                                     families: [ComponentsFamily],
                                     projectConfiguration: ProjectConfiguration,
                                     at url: URL) throws {
        let dependenciesPackageName: String = "Dependencies"
        let resultURL = url
            .appendingPathComponent("\(name)DemoApp")
            .appendingPathComponent(dependenciesPackageName)
        
        let componentDependencies: [Dependency] = getAllDependencies(forComponent: component,
                                                                     families: families,
                                                                     projectConfiguration: projectConfiguration)
        
        let dependencies: [Dependency] = [
            .module(path: "../../../../HelloFresh/Modules/Features/ActionSheetFeature",
                    name: "ActionSheetFeature"),
            .module(path: "../../../../HelloFresh/Modules/Contracts/Features/ActionSheetFeatureContract",
                    name: "ActionSheetFeatureContract"),
            .module(path: "../../../../HelloFresh/Modules/Support/HFNavigator",
                    name: "HFNavigator"),
            .module(path: "../../../../HelloFresh/Modules/Contracts/Support/HFNavigatorContract",
                    name: "HFNavigatorContract"),
            .module(path: "../../../../HelloFresh/Modules/Mocks/Support/HFNavigatorMock",
                    name: "HFNavigatorMock"),
            .module(path: "../../../../HelloFresh/Modules/Support/HxD", name: "HxD")
        ]
        let package = Package(name: name,
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
                            projectConfiguration: ProjectConfiguration) -> [Dependency] {
        var dependenciesDictionary: [String: Dependency] = [:]
        addDependencies(forComponent: component,
                        families: families,
                        projectConfiguration: projectConfiguration,
                        dependenciesDictionary: &dependenciesDictionary)
        return Array(dependenciesDictionary.values)
        //        component.dependencies.map { dependencyType in
        //           switch dependencyType {
        //           case let .local(dependency):
        //               return .module(path: packagePathProvider,
        //                              name: packageNameProvider.packageName(forComponentName: dependency.name,
        //                                                                    of: <#T##Family#>,
        //                                                                    packageConfiguration: dependency.targetTypes))
        //           case let .remote(dependency):
        //               return .external(url: dependency.url,
        //                                name: dependency.name,
        //                                description: dependency.version)
        //           }
        //        }
    }
    
    func addDependencies(forComponent component: Component,
                         families: [ComponentsFamily],
                         projectConfiguration: ProjectConfiguration,
                         dependenciesDictionary: inout [String: Dependency]) {
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
        }
    }
    
    func pbxProjectContent(forComponent component: Component, named name: String) -> String? {
        guard
            let resourcesPath = Bundle.module.resourcePath,
            let data = fileManager.contents(atPath: resourcesPath + "/Templates/pbxprojecttemplate"),
            let pbxString = String(data: data, encoding: .utf8)
        else { return nil }
        
        let packageNameKey: String = "[[PACKAGE_NAME]]"
        let packageNameValue: String = name
        
        let dependencies: [Dependency] = [
            .module(path: "../../../../HelloFresh/Modules/Features/ActionSheetFeature",
                    name: "ActionSheetFeature"),
            .module(path: "../../../../HelloFresh/Modules/Contracts/Features/ActionSheetFeatureContract",
                    name: "ActionSheetFeatureContract"),
            .module(path: "../../../../HelloFresh/Modules/Support/HFNavigator",
                    name: "HFNavigator"),
            .module(path: "../../../../HelloFresh/Modules/Contracts/Support/HFNavigatorContract",
                    name: "HFNavigatorContract"),
            .module(path: "../../../../HelloFresh/Modules/Mocks/Support/HFNavigatorMock",
                    name: "HFNavigatorMock"),
            .module(path: "../../../../HelloFresh/Modules/Support/HxD", name: "HxD")
        ]
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
