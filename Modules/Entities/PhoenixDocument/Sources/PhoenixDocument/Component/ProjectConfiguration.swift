import Foundation
import SwiftPackage

private enum ProjectConfigurationConstants {
    static let defaultMacrosFolderName = "Macros"
    static let defaultMetasFolderName = "Metas"
}

public struct ProjectConfiguration: Codable, Hashable {
    public var packageConfigurations: [PackageConfiguration]
    public var defaultDependencies: [PackageTargetType: String]
    public var macrosFolderName: String
    public var metasFolderName: String
    public var swiftVersion: String
    public var platforms: Platforms
    public var defaultOrganizationIdentifier: String?
    
    enum CodingKeys: String, CodingKey {
        case packageConfigurations
        case defaultDependencies
        case macrosFolderName
        case metasFolderName
        case swiftVersion
        case defaultOrganizationIdentifier
        case platforms
    }
    
    internal init(packageConfigurations: [PackageConfiguration],
                  defaultDependencies: [PackageTargetType: String],
                  macrosFoldeName: String = ProjectConfigurationConstants.defaultMacrosFolderName,
                  metasFoldeName: String = ProjectConfigurationConstants.defaultMetasFolderName,
                  swiftVersion: String,
                  defaultOrganizationIdentifier: String?,
                  platforms: Platforms) {
        self.packageConfigurations = packageConfigurations
        self.defaultDependencies = defaultDependencies
        self.macrosFolderName = macrosFoldeName
        self.metasFolderName = metasFoldeName
        self.swiftVersion = swiftVersion
        self.defaultOrganizationIdentifier = defaultOrganizationIdentifier
        self.platforms = platforms
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        packageConfigurations = try container.decode([PackageConfiguration].self, forKey: .packageConfigurations)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType: String].self, forKey: .defaultDependencies) ?? [:]
        macrosFolderName = try container.decodeIfPresent(String.self, forKey: .macrosFolderName) ?? ProjectConfigurationConstants.defaultMacrosFolderName
        metasFolderName = try container.decodeIfPresent(String.self, forKey: .metasFolderName) ?? ProjectConfigurationConstants.defaultMetasFolderName
        swiftVersion = (try? container.decode(String.self, forKey: .swiftVersion)) ?? "5.10"
        defaultOrganizationIdentifier = try? container.decodeIfPresent(String.self, forKey: .defaultOrganizationIdentifier)
        platforms = (try? container.decode(Platforms.self, forKey: .platforms)) ?? .empty
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(packageConfigurations, forKey: .packageConfigurations)
        if !defaultDependencies.isEmpty {
            try container.encodeSorted(dictionary: defaultDependencies, forKey: .defaultDependencies)
        }
        try container.encode(macrosFolderName, forKey: .macrosFolderName)
        try container.encode(metasFolderName, forKey: .metasFolderName)
        try container.encode(swiftVersion, forKey: .swiftVersion)
        try container.encodeIfPresent(defaultOrganizationIdentifier, forKey: .defaultOrganizationIdentifier)
        try container.encode(platforms, forKey: .platforms)
    }
}

extension ProjectConfiguration {
    public static let `default`: ProjectConfiguration = .init(
        packageConfigurations: [.init(
            name: "Implementation",
            containerFolderName: nil,
            appendPackageName: false,
            internalDependency: nil,
            hasTests: true
        )],
        defaultDependencies: [:],
        swiftVersion: "5.10",
        defaultOrganizationIdentifier: nil,
        platforms: .empty
    )
}
