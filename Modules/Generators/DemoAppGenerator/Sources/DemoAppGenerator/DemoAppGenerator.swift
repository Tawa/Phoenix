import DemoAppGeneratorContract
import Package
import PackageGeneratorContract
import Foundation
import RelativeURLProviderContract

public struct DemoAppGenerator: DemoAppGeneratorProtocol {
    private let packageNameProvider: PackageNameProviding
    private let relativeURLProvider: RelativeURLProviding
    private let fileManager: FileManager
    
    public init(packageNameProvider: PackageNameProviding,
                relativeURLProvider: RelativeURLProviding,
                fileManager: FileManager = .default) {
        self.packageNameProvider = packageNameProvider
        self.relativeURLProvider = relativeURLProvider
        self.fileManager = fileManager
    }
    
    public func generateDemoApp(forComponent component: Component,
                                of family: Family,
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
    
    
    func pbxProjectContent(forComponent component: Component, named name: String) -> String? {
        guard
            let resourcesPath = Bundle.module.resourcePath,
            let data = fileManager.contents(atPath: resourcesPath + "/Templates/pbxprojecttemplate"),
            let pbxString = String(data: data, encoding: .utf8)
        else { return nil }
        
        let packageNameKey: String = "[[PACKAGE_NAME]]"
        let packageNameValue: String = name
        
        let packagesReferencesContentKey: String = "[[PACKAGES_REFERENCES_CONTENT]]"
        let packagesReferencesContentValue: String = """
                B214226F28B7E0BA00FD7132 /* ActionSheetFeature */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = ActionSheetFeature; path = ../../../../HelloFresh/Modules/Features/ActionSheetFeature; sourceTree = "<group>"; };
                B214227028B7E0C200FD7132 /* ActionSheetFeatureContract */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = ActionSheetFeatureContract; path = ../../../../HelloFresh/Modules/Contracts/Features/ActionSheetFeatureContract; sourceTree = "<group>"; };
                B214227128B7E0C700FD7132 /* HFNavigator */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HFNavigator; path = ../../../../HelloFresh/Modules/Support/HFNavigator; sourceTree = "<group>"; };
                B214227228B7E0CC00FD7132 /* HFNavigatorContract */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HFNavigatorContract; path = ../../../../HelloFresh/Modules/Contracts/Support/HFNavigatorContract; sourceTree = "<group>"; };
                B214227328B7E0D100FD7132 /* HFNavigatorMock */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HFNavigatorMock; path = ../../../../HelloFresh/Modules/Mocks/Support/HFNavigatorMock; sourceTree = "<group>"; };
                B214227428B7E0DA00FD7132 /* HxD */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HxD; path = ../../../../HelloFresh/Modules/Support/HxD; sourceTree = "<group>"; };
"""
        
        let packagesGroupContentKey: String = "[[PACKAGES_GROUP_CONTENT]]"
        let packagesGroupContentValue: String = """
                B214227428B7E0DA00FD7132 /* HxD */,
                B214227328B7E0D100FD7132 /* HFNavigatorMock */,
                B214227228B7E0CC00FD7132 /* HFNavigatorContract */,
                B214227128B7E0C700FD7132 /* HFNavigator */,
                B214226F28B7E0BA00FD7132 /* ActionSheetFeature */,
                B214227028B7E0C200FD7132 /* ActionSheetFeatureContract */,
"""
        
        let frameworksContentKey: String = "[[FRAMEWORKS_CONTENT]]"
        let frameworksContentValue: String = """
                B214227428B7E0DA00FD7132 /* HxD */,
                B214227328B7E0D100FD7132 /* HFNavigatorMock */,
                B214227228B7E0CC00FD7132 /* HFNavigatorContract */,
                B214227128B7E0C700FD7132 /* HFNavigator */,
                B214226F28B7E0BA00FD7132 /* ActionSheetFeature */,
                B214227028B7E0C200FD7132 /* ActionSheetFeatureContract */,
"""
        
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
