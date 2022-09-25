import DemoAppGeneratorContract
import Foundation

enum DemoAppGeneratorError: Error {
    case couldNotFindResourcesURL
    case couldNotGenerateData
}

public struct DemoAppGenerator: DemoAppGeneratorProtocol {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func generateDemoApp(named name: String,
                                at url: URL) throws {
        var resultURL = url
        if !fileManager.fileExists(atPath: resultURL.appendingPathComponent("\(name)Demo.xcodeproj").path) {
            resultURL = resultURL.appendingPathComponent("\(name)Demo")
        }
        
        try createEmptyXcodeProjectIfNecessary(named: name, url: resultURL)
        try createSourceFolderIfNecessary(named: name, url: resultURL)
        try createUnitTestsFolderIfNecessary(named: name, url: resultURL)
        try createUITestsFolderIfNecessary(named: name, url: resultURL)
    }

    // MARK: Copying Functions
    func createEmptyXcodeProjectIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let resourcesTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
        
        let sourceXcodeProjURL = resourcesTemplateFolderURL.appendingPathComponent("MyFeatureDemoXcodeProj")
        let destinationXcodeProjURL = url.appendingPathComponent("\(name)Demo.xcodeproj")
        
        guard !fileManager.fileExists(atPath: destinationXcodeProjURL.path) else { return }
        try fileManager.createDirectory(at: destinationXcodeProjURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fileManager.copyItem(at: sourceXcodeProjURL, to: destinationXcodeProjURL)
        let destinationPBXProjFileURL = destinationXcodeProjURL.appendingPathComponent("project.pbxproj")

        try replace(string: "MyFeatureDemo", with: "\(name)Demo", inFileAt: destinationPBXProjFileURL)
        try replace(string: "com.myorganisationidentifier.demo", with: "com.hellofresh.iosdemo", inFileAt: destinationPBXProjFileURL)
    }
    
    func createSourceFolderIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let sourceTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
            .appendingPathComponent("MyFeatureDemo")
        
        let destinationFolderURL = url.appendingPathComponent("\(name)Demo")
        
        guard !fileManager.fileExists(atPath: destinationFolderURL.path) else { return }
        try fileManager.copyItem(at: sourceTemplateFolderURL, to: destinationFolderURL)
        
        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemo.entitlements"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)Demo.entitlements"))
        
        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemoApp.swift"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)DemoApp.swift"))
        try replace(string: "MyFeatureDemo", with: "\(name)Demo", inFileAt: destinationFolderURL.appendingPathComponent("\(name)DemoApp.swift"))
    }
    
    func createUnitTestsFolderIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let sourceTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
            .appendingPathComponent("MyFeatureDemoTests")
        
        let destinationFolderURL = url.appendingPathComponent("\(name)DemoTests")
        
        guard !fileManager.fileExists(atPath: destinationFolderURL.path) else { return }
        try fileManager.copyItem(at: sourceTemplateFolderURL, to: destinationFolderURL)

        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemoTests.swift"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)DemoTests.swift"))
        try replace(string: "MyFeatureDemo", with: "\(name)Demo", inFileAt: destinationFolderURL.appendingPathComponent("\(name)DemoTests.swift"))
    }
    
    func createUITestsFolderIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let sourceTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
            .appendingPathComponent("MyFeatureDemoUITests")
        
        let destinationFolderURL = url.appendingPathComponent("\(name)DemoUITests")
        
        guard !fileManager.fileExists(atPath: destinationFolderURL.path) else { return }
        try fileManager.copyItem(at: sourceTemplateFolderURL, to: destinationFolderURL)

        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemoUITests.swift"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)DemoUITests.swift"))
        try replace(string: "MyFeatureDemo", with: "\(name)Demo", inFileAt: destinationFolderURL.appendingPathComponent("\(name)DemoUITests.swift"))
    }
    
    // MARK: - Private
    func replace(string: String, with newString: String, inFileAt url: URL) throws {
        let initialString = try String(contentsOf: url)
        let result = initialString.replacingOccurrences(of: string, with: newString)
        guard let data = result.data(using: .utf8) else {
            throw DemoAppGeneratorError.couldNotGenerateData
        }
        try data.write(to: url)
    }
}
