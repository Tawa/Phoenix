import Foundation
import SwiftPackage

public struct MacroComponent: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString
    public var name: String
    
    public var iOSVersion: IOSVersion?
    public var macCatalystVersion: MacCatalystVersion?
    public var macOSVersion: MacOSVersion?
    public var tvOSVersion: TVOSVersion?
    public var watchOSVersion: WatchOSVersion?
    
    enum CodingKeys: CodingKey {
        case name
        case iOSVersion
        case macCatalystVersion
        case macOSVersion
        case tvOSVersion
        case watchOSVersion
    }
    
    public init(
        name: String,
        iOSVersion: IOSVersion? = .v13,
        macCatalystVersion: MacCatalystVersion? = .v13,
        macOSVersion: MacOSVersion? = .v10_15,
        tvOSVersion: TVOSVersion? = .v13,
        watchOSVersion: WatchOSVersion? = .v6
    ) {
        self.name = name
        self.iOSVersion = iOSVersion
        self.macCatalystVersion = macCatalystVersion
        self.macOSVersion = macOSVersion
        self.tvOSVersion = tvOSVersion
        self.watchOSVersion = watchOSVersion
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(iOSVersion)
        hasher.combine(macCatalystVersion)
        hasher.combine(macOSVersion)
        hasher.combine(tvOSVersion)
        hasher.combine(watchOSVersion)
    }
}
