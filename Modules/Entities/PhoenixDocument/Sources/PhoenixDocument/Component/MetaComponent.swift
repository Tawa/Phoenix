import Foundation
import SwiftPackage

public struct MetaComponent: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString
    public var name: String
    
    public var localDependencies: [ComponentDependency]
    public var platforms: Platforms
    
    enum CodingKeys: CodingKey {
        case name
        case localDependencies
        case iOSVersion
        case macCatalystVersion
        case macOSVersion
        case tvOSVersion
        case watchOSVersion
    }
    
    public init(
        name: String,
        localDependencies: [ComponentDependency] = [],
        platforms: Platforms = .metaDefault
    ) {
        self.name = name
        self.localDependencies = localDependencies
        self.platforms = platforms
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        localDependencies = try container.decodeIfPresent([ComponentDependency].self, forKey: .localDependencies) ?? []

        platforms = .empty
        platforms.iOSVersion = try container.decode(IOSVersion.self, forKey: .iOSVersion)
        platforms.macCatalystVersion = try container.decode(MacCatalystVersion.self, forKey: .macCatalystVersion)
        platforms.macOSVersion = try container.decode(MacOSVersion.self, forKey: .macOSVersion)
        platforms.tvOSVersion = try container.decode(TVOSVersion.self, forKey: .tvOSVersion)
        platforms.watchOSVersion = try container.decode(WatchOSVersion.self, forKey: .watchOSVersion)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(localDependencies.sorted(), forKey: .localDependencies)
        try container.encodeIfPresent(platforms.iOSVersion, forKey: .iOSVersion)
        try container.encodeIfPresent(platforms.macCatalystVersion, forKey: .macCatalystVersion)
        try container.encodeIfPresent(platforms.macOSVersion, forKey: .macOSVersion)
        try container.encodeIfPresent(platforms.tvOSVersion, forKey: .tvOSVersion)
        try container.encodeIfPresent(platforms.watchOSVersion, forKey: .watchOSVersion)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(localDependencies)
        hasher.combine(platforms)
    }
}
