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
    let projectConfiguration: ProjectConfiguration

    init(families: [ComponentsFamily] = [],
         projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.projectConfiguration = projectConfiguration
    }

    static var readableContentTypes: [UTType] { [.ash] }

    init(configuration: ReadConfiguration) throws {
        let jsonDecoder = JSONDecoder()

        if configuration.file.isDirectory, let fileWrapper = configuration.file.fileWrappers {
            let familyFolderWrappers = fileWrapper.values.filter(\.isDirectory)
            var componentsFamilies = [ComponentsFamily]()
            for familyFolderWrapper in familyFolderWrappers {
                guard
                    let familyFileWrapper = familyFolderWrapper.fileWrappers?["family.json"],
                    let familyData = familyFileWrapper.regularFileContents,
                    let componentsWrappers = familyFolderWrapper.fileWrappers?.filter({ $0.value != familyFileWrapper })
                        .filter({ $0.key.hasSuffix(".json") }).map(\.value)
                else { continue }
                let family = try jsonDecoder.decode(Family.self, from: familyData)
                let components = try componentsWrappers.compactMap(\.regularFileContents)
                    .map { try jsonDecoder.decode(Component.self, from: $0) }
                    .sorted(by: { $0.name < $1.name })

                guard !components.isEmpty else { continue }
                componentsFamilies.append(.init(family: family, components: components))
            }

            let configurationFileWrapper = fileWrapper.values.filter{ !$0.isDirectory }.first
            let projectConfiguration: ProjectConfiguration = try configurationFileWrapper?.regularFileContents
                .map({ try jsonDecoder.decode(ProjectConfiguration.self, from: $0) }) ?? .default

            componentsFamilies.sort(by: { $0.family.name < $1.family.name })

            self = .init(families: componentsFamilies, projectConfiguration: projectConfiguration)
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

        let configurationFolderWrapper = FileWrapper(regularFileWithContents: try jsonEncoder.encode(projectConfiguration))
        configurationFolderWrapper.preferredFilename = "config.json"
        mainFolderWrapper.addFileWrapper(configurationFolderWrapper)

        for family in families {
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
