import DemoAppGeneratorContract
import Foundation

enum DemoAppGeneratorError: Error {
    case couldNotFindResourcesURL
    case couldNotGenerateData
}

struct DemoAppOutput: DemoAppOutputProtocol {
    var folderURL: URL
    var xcodeProjURL: URL
}

public struct DemoAppGenerator: DemoAppGeneratorProtocol {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func generateDemoApp(named name: String,
                                at url: URL) throws -> DemoAppOutputProtocol {
        var resultURL = url
        if !fileManager.fileExists(atPath: resultURL.appendingPathComponent("\(name).xcodeproj").path) {
            resultURL = resultURL.appendingPathComponent(name)
        }
        
        try createEmptyXcodeProjectIfNecessary(named: name, url: resultURL)
        try createSourceFolderIfNecessary(named: name, url: resultURL)
        try createUnitTestsFolderIfNecessary(named: name, url: resultURL)
        try createUITestsFolderIfNecessary(named: name, url: resultURL)
        
        return DemoAppOutput(folderURL: resultURL,
                             xcodeProjURL: resultURL.appendingPathComponent("\(name).xcodeproj"))
    }

    // MARK: Copying Functions
    func createEmptyXcodeProjectIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let resourcesTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
        
        let sourceXcodeProjURL = resourcesTemplateFolderURL.appendingPathComponent("MyFeatureDemoXcodeProj")
        let destinationXcodeProjURL = url.appendingPathComponent("\(name).xcodeproj")
        
        guard !fileManager.fileExists(atPath: destinationXcodeProjURL.path) else { return }
        try fileManager.createDirectory(at: destinationXcodeProjURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fileManager.copyItem(at: sourceXcodeProjURL, to: destinationXcodeProjURL)
        
        let destinationPBXProjFileURL = destinationXcodeProjURL.appendingPathComponent("project.pbxproj")
        try fileManager.moveItem(at: destinationXcodeProjURL.appendingPathComponent("project"), to: destinationPBXProjFileURL)

        try replace(string: "MyFeatureDemo", with: name, inFileAt: destinationPBXProjFileURL)
        try replace(string: "com.myorganisationidentifier.demo", with: "com.hellofresh.iosdemo", inFileAt: destinationPBXProjFileURL)
    }
    
    func createSourceFolderIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let sourceTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
            .appendingPathComponent("MyFeatureDemo")
        
        let destinationFolderURL = url.appendingPathComponent(name)
        
        guard !fileManager.fileExists(atPath: destinationFolderURL.path) else { return }
        try fileManager.copyItem(at: sourceTemplateFolderURL, to: destinationFolderURL)
        
        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemo.entitlements"),
                                 to: destinationFolderURL.appendingPathComponent("\(name).entitlements"))
        
        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemoApp.swift"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)App.swift"))
        try replace(string: "MyFeatureDemo", with: name, inFileAt: destinationFolderURL.appendingPathComponent("\(name)App.swift"))
    }
    
    func createUnitTestsFolderIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let sourceTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
            .appendingPathComponent("MyFeatureDemoTests")
        
        let destinationFolderURL = url.appendingPathComponent("\(name)Tests")
        
        guard !fileManager.fileExists(atPath: destinationFolderURL.path) else { return }
        try fileManager.copyItem(at: sourceTemplateFolderURL, to: destinationFolderURL)

        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemoTests.swift"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)Tests.swift"))
        try replace(string: "MyFeatureDemo", with: name, inFileAt: destinationFolderURL.appendingPathComponent("\(name)Tests.swift"))
    }
    
    func createUITestsFolderIfNecessary(named name: String, url: URL) throws {
        guard let resourcesURL = Bundle.module.resourceURL else {
            throw DemoAppGeneratorError.couldNotFindResourcesURL
        }
        
        let sourceTemplateFolderURL = resourcesURL.appendingPathComponent("Templates")
            .appendingPathComponent("MyFeatureDemoUITests")
        
        let destinationFolderURL = url.appendingPathComponent("\(name)UITests")
        
        guard !fileManager.fileExists(atPath: destinationFolderURL.path) else { return }
        try fileManager.copyItem(at: sourceTemplateFolderURL, to: destinationFolderURL)

        try fileManager.moveItem(at: destinationFolderURL.appendingPathComponent("MyFeatureDemoUITests.swift"),
                                 to: destinationFolderURL.appendingPathComponent("\(name)UITests.swift"))
        try replace(string: "MyFeatureDemo", with: name, inFileAt: destinationFolderURL.appendingPathComponent("\(name)UITests.swift"))
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
