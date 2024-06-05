import Foundation
import SwiftPackage

public struct MetaComponent: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString
    public var name: String
    
    public var defaultDependencies: Set<PackageTargetType>
    public var platforms: Platforms
    
    enum CodingKeys: CodingKey {
        case name
        case defaultDependencies
        case iOSVersion
        case macCatalystVersion
        case macOSVersion
        case tvOSVersion
        case watchOSVersion
    }
    
    public init(
        name: String,
        defaultDependencies: Set<PackageTargetType> = [],
        platforms: Platforms = .metaDefault
    ) {
        self.name = name
        self.defaultDependencies = defaultDependencies
        self.platforms = platforms
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        defaultDependencies = try container.decode(Set<PackageTargetType>.self, forKey: .defaultDependencies)

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
        try container.encode(defaultDependencies.sorted(), forKey: .defaultDependencies)
        try container.encodeIfPresent(platforms.iOSVersion, forKey: .iOSVersion)
        try container.encodeIfPresent(platforms.macCatalystVersion, forKey: .macCatalystVersion)
        try container.encodeIfPresent(platforms.macOSVersion, forKey: .macOSVersion)
        try container.encodeIfPresent(platforms.tvOSVersion, forKey: .tvOSVersion)
        try container.encodeIfPresent(platforms.watchOSVersion, forKey: .watchOSVersion)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(defaultDependencies)
        hasher.combine(platforms)
    }
}
