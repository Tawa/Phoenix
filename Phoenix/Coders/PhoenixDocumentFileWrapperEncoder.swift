import Foundation
import Resolver
import AppVersionProviderContract

struct PhoenixDocumentFileWrapperEncoder {
    @Injected private var currentApp: CurrentAppVersionStringProviderProtocol

    func fileWrapper(for document: PhoenixDocument) throws -> FileWrapper {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        let mainFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])

        if let appVersionString = currentApp.currentAppVersionString(),
           let data = appVersionString.data(using: .utf8) {
            let appVersionFileWrapper = FileWrapper(regularFileWithContents: data)
            appVersionFileWrapper.preferredFilename = PhoenixDocumentConstants.appVersionFileName
            mainFolderWrapper.addFileWrapper(appVersionFileWrapper)
        }

        let configurationFolderWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(document.projectConfiguration))
        configurationFolderWrapper.preferredFilename = PhoenixDocumentConstants.configurationFileName
        mainFolderWrapper.addFileWrapper(configurationFolderWrapper)

        for family in document.families {
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

        return mainFolderWrapper
    }
}
