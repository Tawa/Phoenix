import Foundation

struct PhoenixDocumentFileWrapperEncoder {
    func fileWrapper(for document: PhoenixDocument) throws -> FileWrapper {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        let mainFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])

        let configurationFolderWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(document.projectConfiguration))
        configurationFolderWrapper.preferredFilename = "config.json"
        mainFolderWrapper.addFileWrapper(configurationFolderWrapper)

        for family in document.families {
            let familyFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
            familyFolderWrapper.preferredFilename = family.family.name

            let familyFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(family.family))
            familyFileWrapper.preferredFilename = "family.json"
            familyFolderWrapper.addFileWrapper(familyFileWrapper)

            for component in family.components {
                let componentFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(component))
                componentFileWrapper.preferredFilename = component.name.full + ".json"
                familyFolderWrapper.addFileWrapper(componentFileWrapper)
            }
            mainFolderWrapper.addFileWrapper(familyFolderWrapper)
        }

        return mainFolderWrapper
    }
}
