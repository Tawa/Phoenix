import AppVersionProviderContract
import DocumentCoderContract
import Foundation
import PhoenixDocument

public struct PhoenixDocumentFileWrapperEncoder: PhoenixDocumentFileWrapperEncoderProtocol {
    private let currentAppVersionStringProvider: CurrentAppVersionStringProviderProtocol
    let jsonEncoder: JSONEncoder

    public init(currentAppVersionStringProvider: CurrentAppVersionStringProviderProtocol) {
        self.currentAppVersionStringProvider = currentAppVersionStringProvider

        jsonEncoder = JSONEncoder()
        if #available(macOS 10.13, *) {
            jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        } else {
            jsonEncoder.outputFormatting = [.prettyPrinted]
        }
    }

    public func fileWrapper(for document: PhoenixDocument) throws -> FileWrapper {
        let mainFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])

        if let appVersionString = currentAppVersionStringProvider.currentAppVersionString(),
           let data = appVersionString.data(using: .utf8) {
            let appVersionFileWrapper = FileWrapper(regularFileWithContents: data)
            appVersionFileWrapper.preferredFilename = PhoenixDocumentConstants.appVersionFileName
            mainFolderWrapper.addFileWrapper(appVersionFileWrapper)
        }

        try encode(projectConfiguration: document.projectConfiguration, mainFolderWrapper: mainFolderWrapper)
        try encode(families: document.families, mainFolderWrapper: mainFolderWrapper)
        try encode(remoteComponents: document.remoteComponents, mainFolderWrapper: mainFolderWrapper)
        try encode(macroComponents: document.macrosComponents, mainFolderWrapper: mainFolderWrapper)
        
        return mainFolderWrapper
    }

    private func encode(projectConfiguration: ProjectConfiguration, mainFolderWrapper: FileWrapper) throws {
        let configurationFolderWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(projectConfiguration))
        configurationFolderWrapper.preferredFilename = PhoenixDocumentConstants.configurationFileName
        mainFolderWrapper.addFileWrapper(configurationFolderWrapper)
    }
    
    private func encode(families: [ComponentsFamily], mainFolderWrapper: FileWrapper) throws {
        for family in families {
            let familyFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
            familyFolderWrapper.preferredFilename = family.family.name

            let familyFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(family.family))
            familyFileWrapper.preferredFilename = PhoenixDocumentConstants.familyFileName
            familyFolderWrapper.addFileWrapper(familyFileWrapper)

            for component in family.components {
                let componentFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(component))
                componentFileWrapper.preferredFilename = component.name.full + PhoenixDocumentConstants.jsonFileExtension
                familyFolderWrapper.addFileWrapper(componentFileWrapper)
            }
            mainFolderWrapper.addFileWrapper(familyFolderWrapper)
        }
    }
    
    private func encode(remoteComponents: [RemoteComponent], mainFolderWrapper: FileWrapper) throws {
        guard !remoteComponents.isEmpty else { return }
        let remoteComponentsFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        remoteComponentsFolderWrapper.preferredFilename = PhoenixDocumentConstants.remoteComponentsFolderName
        
        for remoteComponent in remoteComponents {
            let remoteComponentFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(remoteComponent))
            let fileName = remoteComponent.url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? remoteComponent.url
            remoteComponentFileWrapper.preferredFilename = fileName + PhoenixDocumentConstants.jsonFileExtension
            remoteComponentsFolderWrapper.addFileWrapper(remoteComponentFileWrapper)
        }
        mainFolderWrapper.addFileWrapper(remoteComponentsFolderWrapper)
    }
    
    private func encode(macroComponents: [MacroComponent], mainFolderWrapper: FileWrapper) throws {
        guard !macroComponents.isEmpty else { return }
        let macroComponentsFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        macroComponentsFolderWrapper.preferredFilename = PhoenixDocumentConstants.macrosComponentsFolderName
        
        for macroComponent in macroComponents {
            let macroComponentFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(macroComponent))
            macroComponentFileWrapper.preferredFilename = macroComponent.name + PhoenixDocumentConstants.jsonFileExtension
            macroComponentsFolderWrapper.addFileWrapper(macroComponentFileWrapper)
        }
        mainFolderWrapper.addFileWrapper(macroComponentsFolderWrapper)
    }
}
