import DocumentCoderContract
import Foundation
import PhoenixDocument

enum PhoenixDocumentConstants {
    static let appVersionFileName: String = "appversion"
    static let jsonFileExtension: String = ".json"
    static let configurationFileName: String = "config" + jsonFileExtension
    static let familyFileName: String = "family" + jsonFileExtension
    static let remoteComponentsFolderName: String = "_remote"
    static let macroComponentsFolderName: String = "_macros"
    static let metaComponentsFolderName: String = "_metas"
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
    let jsonDecoder: JSONDecoder
    
    public init() {
        jsonDecoder = JSONDecoder()
    }
    
    public func phoenixDocument(from fileWrapper: [String: FileWrapper]) throws -> PhoenixDocument {
        var componentsFamilies = try decodeFamilies(fileWrapper: fileWrapper)
        let remoteComponents = try decodeRemoteComponents(fileWrapper: fileWrapper, componentsFamilies: &componentsFamilies)
        let projectConfiguration = try decodeConfiguration(fileWrapper: fileWrapper)
        let macros = try decodeMacros(fileWrapper: fileWrapper)
        let metas = try decodeMetas(fileWrapper: fileWrapper)

        return .init(
            families: componentsFamilies,
            remoteComponents: remoteComponents,
            macros: macros,
            metas: metas,
            projectConfiguration: projectConfiguration
        )
    }
    
    // MARK: - Private
    private func decodeFamilies(fileWrapper: [String: FileWrapper]) throws -> [ComponentsFamily] {
        var componentsFamilies = [ComponentsFamily]()
        let familyFolderWrappers = fileWrapper.values
            .filter(\.isDirectory)
            .filter { $0.filename?.hasPrefix("_") == false }
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
        componentsFamilies.sort(by: { $0.family.name < $1.family.name })
        
        return componentsFamilies
    }
    
    private func decodeRemoteComponents(fileWrapper: [String: FileWrapper], componentsFamilies: inout [ComponentsFamily]) throws -> [RemoteComponent] {
        var remoteComponents: [RemoteComponent] = []
        
        if let remoteComponentsFolderWrappers = fileWrapper.values
            .first(where: { $0.filename == PhoenixDocumentConstants.remoteComponentsFolderName }),
           let remoteComponentsWrappers = remoteComponentsFolderWrappers.fileWrappers?.values.compactMap(\.regularFileContents) {
            remoteComponents = try remoteComponentsWrappers.map { try jsonDecoder.decode(RemoteComponent.self, from: $0) }
                .sorted(by: { $0.url < $1.url })
        } else {
            remoteComponents = componentsFamilies
                .flatMap(\.components)
                .flatMap(\.remoteDependencies)
                .reduce(into: [String: RemoteComponent](), { partialResult, remoteDependency in
                    let key = remoteDependency.url
                    var value = partialResult[key] ?? RemoteComponent(url: remoteDependency.url,
                                                                      version: remoteDependency.version,
                                                                      names: [remoteDependency.name])
                    if !value.names.contains(remoteDependency.name) {
                        value.names.append(remoteDependency.name)
                        value.names.sort(by: { $0.name < $1.name })
                    }
                    partialResult[remoteDependency.url] = value
                })
                .map(\.value)
                .sorted(by: { $0.url < $1.url })
            
            for i in 0..<componentsFamilies.count {
                for j in 0..<componentsFamilies[i].components.count {
                    componentsFamilies[i].components[j].remoteComponentDependencies = componentsFamilies[i].components[j].remoteDependencies
                        .map { remoteDependency in
                            RemoteComponentDependency(
                                url: remoteDependency.url,
                                targetTypes: [
                                    remoteDependency.name: remoteDependency.targetTypes
                                ]
                            )
                        }
                    componentsFamilies[i].components[j].clearRemoteDependencies()
                }
            }
        }
        
        return remoteComponents
    }
    
    private func decodeMacros(fileWrapper: [String: FileWrapper]) throws -> [MacroComponent] {
        var macroComponents: [MacroComponent] = []
        
        if let macroComponentsFolderWrappers = fileWrapper.values
            .first(where: { $0.filename == PhoenixDocumentConstants.macroComponentsFolderName }),
           let macroComponentsWrappers = macroComponentsFolderWrappers.fileWrappers?.values.compactMap(\.regularFileContents) {
            macroComponents = try macroComponentsWrappers.map { try jsonDecoder.decode(MacroComponent.self, from: $0) }
                .sorted(by: { $0.name < $1.name })
        }
        
        return macroComponents
    }

    private func decodeMetas(fileWrapper: [String: FileWrapper]) throws -> [MetaComponent] {
        var metaComponents: [MetaComponent] = []

        if let metaComponentsFolderWrappers = fileWrapper.values
            .first(where: { $0.filename == PhoenixDocumentConstants.metaComponentsFolderName }),
           let metaComponentsWrappers = metaComponentsFolderWrappers.fileWrappers?.values.compactMap(\.regularFileContents) {
            metaComponents = try metaComponentsWrappers.map { try jsonDecoder.decode(MetaComponent.self, from: $0) }
                .sorted(by: { $0.name < $1.name })
        }

        return metaComponents
    }

    private func decodeConfiguration(fileWrapper: [String: FileWrapper]) throws -> ProjectConfiguration {
        let configurationFileWrapper = fileWrapper.values.first {
            $0.preferredFilename == PhoenixDocumentConstants.configurationFileName
        }
        return try configurationFileWrapper?.regularFileContents
            .map({ try jsonDecoder.decode(ProjectConfiguration.self, from: $0) }) ?? .default
    }
}
