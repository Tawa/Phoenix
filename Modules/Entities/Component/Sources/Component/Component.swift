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
    public var id: Name { name }

    public let name: Name
    public var defaultLocalization: DefaultLocalization
    public var iOSVersion: IOSVersion?
    public var macOSVersion: MacOSVersion?
    public var modules: [String: LibraryType]
    public var dependencies: [ComponentDependencyType]
    public var resources: [ComponentResources]
    public var defaultDependencies: [PackageTargetType: String]

    public var localDependencies: [ComponentDependency] {
        dependencies.compactMap { componentDependencyType in
            guard case let .local(dependency) = componentDependencyType
            else { return nil }
            return dependency
        }
    }

    public init(name: Name,
                defaultLocalization: DefaultLocalization,
                iOSVersion: IOSVersion?,
                macOSVersion: MacOSVersion?,
                modules: [String: LibraryType],
                dependencies: [ComponentDependencyType],
                resources: [ComponentResources],
                defaultDependencies: [PackageTargetType: String]) {
        self.name = name
        self.defaultLocalization = defaultLocalization
        self.iOSVersion = iOSVersion
        self.macOSVersion = macOSVersion
        self.modules = modules
        self.dependencies = dependencies
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
        dependencies = try container.decode([ComponentDependencyType].self, forKey: .dependencies)
        resources = try container.decode([ComponentResources].self, forKey: .resources)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType : String].self, forKey: .defaultDependencies) ?? [:]
    }
    
    enum CodingKeys: CodingKey {
        case name
        case defaultLocalization
        case iOSVersion
        case macOSVersion
        case modules
        case dependencies
        case resources
        case defaultDependencies
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
        try container.encode(dependencies, forKey: .dependencies)
        try container.encode(resources, forKey: .resources)
        if !defaultDependencies.isEmpty {
            try container.encodeSorted(dictionary: defaultDependencies, forKey: .defaultDependencies)
        }
    }
}
