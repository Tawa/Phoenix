import Component
import DocumentCoderContract
import Foundation
import PhoenixDocument

enum PhoenixDocumentConstants {
    static let appVersionFileName: String = "appversion"
    static let jsonFileExtension: String = ".json"
    static let configurationFileName: String = "config" + jsonFileExtension
    static let familyFileName: String = "family" + jsonFileExtension
}

enum PhoenixDocumentError: LocalizedError {
    case versionNotFound
    case versionUnsupported
    
    var errorDescription: String? {
        switch self {
        case .versionNotFound:
            return "File Version Not Found"
        case .versionUnsupported:
            return "File Version Unsupposed, please update Phoenix to read this file."
        }
    }
}

public struct PhoenixDocumentFileWrappersDecoder: PhoenixDocumentFileWrappersDecoderProtocol {
    
    public init() {
        
    }
    
    public func phoenixDocument(from fileWrapper: [String: FileWrapper]) throws -> PhoenixDocument {
        let jsonDecoder = JSONDecoder()
        let familyFolderWrappers = fileWrapper.values.filter(\.isDirectory)
        var componentsFamilies = [ComponentsFamily]()
        for familyFolderWrapper in familyFolderWrappers {
            guard
                let familyFileWrapper = familyFolderWrapper.fileWrappers?[PhoenixDocumentConstants.familyFileName],
                let familyData = familyFileWrapper.regularFileContents,
                let componentsWrappers = familyFolderWrapper.fileWrappers?.filter({ $0.value != familyFileWrapper })
                    .filter({ $0.key.hasSuffix(PhoenixDocumentConstants.jsonFileExtension) }).map(\.value)
            else { continue }
            let family = try jsonDecoder.decode(Family.self, from: familyData)
            let components = try componentsWrappers.compactMap(\.regularFileContents)
                .map { try jsonDecoder.decode(Component.self, from: $0) }
                .sorted(by: { $0.name < $1.name })

            guard !components.isEmpty else { continue }
            componentsFamilies.append(.init(family: family, components: components))
        }

        let configurationFileWrapper = fileWrapper.values.filter { $0.preferredFilename == PhoenixDocumentConstants.configurationFileName }.first
        let projectConfiguration: ProjectConfiguration = try configurationFileWrapper?.regularFileContents
            .map({ try jsonDecoder.decode(ProjectConfiguration.self, from: $0) }) ?? .default

        componentsFamilies.sort(by: { $0.family.name < $1.family.name })

        return .init(
            families: componentsFamilies,
            remoteComponents: [],
            projectConfiguration: projectConfiguration
        )
    }

}
