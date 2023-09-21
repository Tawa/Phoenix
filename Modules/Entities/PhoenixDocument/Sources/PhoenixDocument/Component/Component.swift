import Foundation
import SwiftPackage

public struct DefaultLocalization: Codable, Hashable {
    public var value: String?
    public var modules: [String]
    
    public init(value: String? = nil,
                modules: [String] = []) {
        self.value = value
        self.modules = modules
    }
}

public struct Component: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString

    enum CodingKeys: CodingKey {
        case name
        case defaultLocalization
        case iOSVersion
        case macCatalystVersion
        case macOSVersion
        case tvOSVersion
        case watchOSVersion
        case modules
        case dependencies
        case localDependencies
        case remoteDependencies
        case remoteComponentDependencies
        case macroComponentDependencies
        case resources
        case defaultDependencies
    }
    
    public let name: Name
    public var defaultLocalization: DefaultLocalization
    public var platforms: Platforms
    public var modules: [String: LibraryType]
    public var resources: [ComponentResources]
    public var defaultDependencies: [PackageTargetType: String]

    public var localDependencies: [ComponentDependency]
    private(set) public var remoteDependencies: [RemoteDependency]
    public var remoteComponentDependencies: [RemoteComponentDependency]
    public var macroComponentDependencies: [MacroComponentDependency]

    public init(name: Name,
                defaultLocalization: DefaultLocalization,
                platforms: Platforms,
                modules: [String: LibraryType],
                localDependencies: [ComponentDependency],
                remoteDependencies: [RemoteDependency],
                remoteComponentDependencies: [RemoteComponentDependency],
                macroComponentDependencies: [MacroComponentDependency],
                resources: [ComponentResources],
                defaultDependencies: [PackageTargetType: String]) {
        self.name = name
        self.defaultLocalization = defaultLocalization
        self.platforms = platforms
        self.modules = modules
        self.localDependencies = localDependencies
        self.remoteDependencies = remoteDependencies
        self.remoteComponentDependencies = remoteComponentDependencies
        self.macroComponentDependencies = macroComponentDependencies
        self.resources = resources
        self.defaultDependencies = defaultDependencies
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(Name.self, forKey: .name)
        defaultLocalization = try container.decodeIfPresent(DefaultLocalization.self, forKey: .defaultLocalization) ?? .init()

        // Platforms decoding
        platforms = .empty
        platforms.iOSVersion = try container.decodeIfPresent(IOSVersion.self, forKey: .iOSVersion)
        platforms.macCatalystVersion = try container.decodeIfPresent(MacCatalystVersion.self, forKey: .macCatalystVersion)
        platforms.macOSVersion = try container.decodeIfPresent(MacOSVersion.self, forKey: .macOSVersion)
        platforms.tvOSVersion = try container.decodeIfPresent(TVOSVersion.self, forKey: .tvOSVersion)
        platforms.watchOSVersion = try container.decodeIfPresent(WatchOSVersion.self, forKey: .watchOSVersion)

        modules = try container.decode([String : LibraryType].self, forKey: .modules)
        if let dependencies = try? container.decode([ComponentDependencyType].self, forKey: .dependencies) {
            localDependencies = dependencies.compactMap { componentDependencyType in
                guard case let .local(dependency) = componentDependencyType
                else { return nil }
                return dependency
            }
            remoteDependencies = dependencies.compactMap { componentDependencyType in
                guard case let .remote(dependency) = componentDependencyType
                else { return nil }
                return dependency
            }
        } else {
            localDependencies = try container.decodeIfPresent([ComponentDependency].self, forKey: .localDependencies) ?? []
            remoteDependencies = try container.decodeIfPresent([RemoteDependency].self, forKey: .remoteDependencies) ?? []
        }
        remoteComponentDependencies = try container.decodeIfPresent([RemoteComponentDependency].self, forKey: .remoteComponentDependencies) ?? []
        macroComponentDependencies = try container.decodeIfPresent([MacroComponentDependency].self, forKey: .macroComponentDependencies) ?? []
        resources = try container.decode([ComponentResources].self, forKey: .resources)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType : String].self, forKey: .defaultDependencies) ?? [:]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if let value = defaultLocalization.value, !value.isEmpty {
            try container.encode(defaultLocalization, forKey: .defaultLocalization)
        }
        try container.encodeIfPresent(platforms.iOSVersion, forKey: .iOSVersion)
        try container.encodeIfPresent(platforms.macCatalystVersion, forKey: .macCatalystVersion)
        try container.encodeIfPresent(platforms.macOSVersion, forKey: .macOSVersion)
        try container.encodeIfPresent(platforms.tvOSVersion, forKey: .tvOSVersion)
        try container.encodeIfPresent(platforms.watchOSVersion, forKey: .watchOSVersion)
        try container.encode(modules, forKey: .modules)
        if !localDependencies.isEmpty {
            try container.encode(localDependencies, forKey: .localDependencies)
        }
        if !remoteDependencies.isEmpty {
            try container.encode(remoteDependencies, forKey: .remoteDependencies)
        }
        if !remoteComponentDependencies.isEmpty {
            try container.encode(remoteComponentDependencies, forKey: .remoteComponentDependencies)
        }
        if !macroComponentDependencies.isEmpty {
            try container.encode(macroComponentDependencies, forKey: .macroComponentDependencies)
        }
        try container.encode(resources, forKey: .resources)
        if !defaultDependencies.isEmpty {
            try container.encodeSorted(dictionary: defaultDependencies, forKey: .defaultDependencies)
        }
    }
    
    public mutating func clearRemoteDependencies() {
        remoteDependencies.removeAll(keepingCapacity: false)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(defaultLocalization)
        hasher.combine(platforms)
        hasher.combine(modules)
        hasher.combine(localDependencies)
        hasher.combine(remoteDependencies)
        hasher.combine(remoteComponentDependencies)
        hasher.combine(macroComponentDependencies)
        hasher.combine(resources)
        hasher.combine(defaultDependencies)
    }
}

// MARK: - Platforms
public extension Component {
    struct Platforms: Codable, Hashable {
        public var iOSVersion: IOSVersion?
        public var macCatalystVersion: MacCatalystVersion?
        public var macOSVersion: MacOSVersion?
        public var tvOSVersion: TVOSVersion?
        public var watchOSVersion: WatchOSVersion?
    }
}

public extension Component.Platforms {
    static var empty: Self { .init() }
}
