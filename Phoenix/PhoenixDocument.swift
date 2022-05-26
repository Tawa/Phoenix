import Package
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var ash: UTType {
        UTType(exportedAs: "com.tawanicolas.ash")
    }
}

struct PhoenixDocument: FileDocument, Codable {
    var families: [ComponentsFamily]

    init(families: [ComponentsFamily] = []) {
        self.families = families
    }

    static var readableContentTypes: [UTType] { [.ash] }

    init(configuration: ReadConfiguration) throws {
        let jsonDecoder = JSONDecoder()

        if configuration.file.isDirectory, let fileWrapper = configuration.file.fileWrappers {
            let familyFolderWrappers = fileWrapper.values
            var componentsFamilies = [ComponentsFamily]()
            for familyFolderWrapper in familyFolderWrappers {
                guard
                    let familyFileWrapper = familyFolderWrapper.fileWrappers?["family.ashf"],
                    let familyData = familyFileWrapper.regularFileContents,
                    let componentsWrappers = familyFolderWrapper.fileWrappers?.filter({ $0.key.hasSuffix(".ashc") }).map(\.value)
                else { continue }
                let family = try jsonDecoder.decode(Family.self, from: familyData)
                let components = try componentsWrappers.compactMap(\.regularFileContents)
                    .map { try jsonDecoder.decode(Component.self, from: $0) }

                guard !components.isEmpty else { continue }
                componentsFamilies.append(.init(family: family, components: components))
            }

            self = .init(families: componentsFamilies)
        } else {
            guard let data = configuration.file.regularFileContents
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            self = try jsonDecoder.decode(PhoenixDocument.self, from: data)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        let mainFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        for family in families {
            let familyFolderWrapper = FileWrapper(directoryWithFileWrappers: [:])
            familyFolderWrapper.preferredFilename = family.family.name

            let familyFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(family.family))
            familyFileWrapper.preferredFilename = "family.ashf"
            familyFolderWrapper.addFileWrapper(familyFileWrapper)

            for component in family.components {
                let componentFileWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(component))
                componentFileWrapper.preferredFilename = component.name.full + ".ashc"
                familyFolderWrapper.addFileWrapper(componentFileWrapper)
            }
            mainFolderWrapper.addFileWrapper(familyFolderWrapper)
        }

        return mainFolderWrapper
    }
}
