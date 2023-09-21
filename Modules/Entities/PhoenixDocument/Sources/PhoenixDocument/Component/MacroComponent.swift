import Foundation
import SwiftPackage

public struct MacroComponent: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString
    public var name: String
    
    public var defaultDependencies: Set<PackageTargetType>
    
    public var iOSVersion: IOSVersion?
    public var macCatalystVersion: MacCatalystVersion?
    public var macOSVersion: MacOSVersion?
    public var tvOSVersion: TVOSVersion?
    public var watchOSVersion: WatchOSVersion?
    
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
        iOSVersion: IOSVersion? = .v13,
        macCatalystVersion: MacCatalystVersion? = .v13,
        macOSVersion: MacOSVersion? = .v10_15,
        tvOSVersion: TVOSVersion? = .v13,
        watchOSVersion: WatchOSVersion? = .v6
    ) {
        self.name = name
        self.defaultDependencies = defaultDependencies
        self.iOSVersion = iOSVersion
        self.macCatalystVersion = macCatalystVersion
        self.macOSVersion = macOSVersion
        self.tvOSVersion = tvOSVersion
        self.watchOSVersion = watchOSVersion
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.defaultDependencies.sorted(), forKey: .defaultDependencies)
        try container.encodeIfPresent(self.iOSVersion, forKey: .iOSVersion)
        try container.encodeIfPresent(self.macCatalystVersion, forKey: .macCatalystVersion)
        try container.encodeIfPresent(self.macOSVersion, forKey: .macOSVersion)
        try container.encodeIfPresent(self.tvOSVersion, forKey: .tvOSVersion)
        try container.encodeIfPresent(self.watchOSVersion, forKey: .watchOSVersion)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(defaultDependencies)
        hasher.combine(iOSVersion)
        hasher.combine(macCatalystVersion)
        hasher.combine(macOSVersion)
        hasher.combine(tvOSVersion)
        hasher.combine(watchOSVersion)
    }
}
