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
        case macOSVersion
        case modules
        case dependencies
        case localDependencies
        case remoteDependencies
        case remoteComponentDependencies
        case resources
        case defaultDependencies
    }
    
    public let name: Name
    public var defaultLocalization: DefaultLocalization
    public var iOSVersion: IOSVersion?
    public var macOSVersion: MacOSVersion?
    public var modules: [String: LibraryType]
    public var resources: [ComponentResources]
    public var defaultDependencies: [PackageTargetType: String]

    public var localDependencies: [ComponentDependency]
    public var remoteDependencies: [RemoteDependency]
    public var remoteComponentDependencies: [RemoteComponentDependency]

    public init(name: Name,
                defaultLocalization: DefaultLocalization,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                modules: [String: LibraryType],
                localDependencies: [ComponentDependency],
                remoteDependencies: [RemoteDependency],
                remoteComponentDependencies: [RemoteComponentDependency],
                resources: [ComponentResources],
                defaultDependencies: [PackageTargetType: String]) {
        self.name = name
        self.defaultLocalization = defaultLocalization
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
        self.localDependencies = localDependencies
        self.remoteDependencies = remoteDependencies
        self.remoteComponentDependencies = remoteComponentDependencies
        self.resources = resources
        self.defaultDependencies = defaultDependencies
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(Name.self, forKey: .name)
        defaultLocalization = try container.decodeIfPresent(DefaultLocalization.self, forKey: .defaultLocalization) ?? .init()
        iOSVersion = try container.decodeIfPresent(IOSVersion.self, forKey: .iOSVersion)
        macOSVersion = try container.decodeIfPresent(MacOSVersion.self, forKey: .macOSVersion)
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
        resources = try container.decode([ComponentResources].self, forKey: .resources)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType : String].self, forKey: .defaultDependencies) ?? [:]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if let value = defaultLocalization.value, !value.isEmpty {
            try container.encode(defaultLocalization, forKey: .defaultLocalization)
        }
        try container.encodeIfPresent(iOSVersion, forKey: .iOSVersion)
        try container.encodeIfPresent(macOSVersion, forKey: .macOSVersion)
        try container.encode(modules, forKey: .modules)
        try container.encode(localDependencies, forKey: .localDependencies)
        try container.encode(remoteDependencies, forKey: .remoteDependencies)
        try container.encode(remoteComponentDependencies, forKey: .remoteComponentDependencies)
        try container.encode(resources, forKey: .resources)
        if !defaultDependencies.isEmpty {
            try container.encodeSorted(dictionary: defaultDependencies, forKey: .defaultDependencies)
        }
    }
    
    public mutating func clearRemoteDependencies() {
        remoteDependencies.removeAll(keepingCapacity: false)
    }
}
