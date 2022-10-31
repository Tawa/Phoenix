public struct Family: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    enum CodingKeys: CodingKey {
        case name
        case ignoreSuffix
        case folder
        case defaultDependencies
        case excludedFamilies
    }

    public let name: String
    public var ignoreSuffix: Bool
    public var folder: String?
    public var defaultDependencies: [PackageTargetType: String]
    public var excludedFamilies: [String]

    public init(name: String,
                ignoreSuffix: Bool = false,
                folder: String? = nil,
                defaultDependencies: [PackageTargetType: String] = [:],
                excludedFamilies: [String] = []) {
        self.name = name
        self.ignoreSuffix = ignoreSuffix
        self.folder = folder
        self.defaultDependencies = defaultDependencies
        self.excludedFamilies = excludedFamilies
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        ignoreSuffix = try container.decode(Bool.self, forKey: .ignoreSuffix)
        folder = try container.decodeIfPresent(String.self, forKey: .folder)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType : String].self, forKey: .defaultDependencies) ?? [:]
        excludedFamilies = try container.decodeIfPresent([String].self, forKey: .excludedFamilies) ?? []
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(ignoreSuffix, forKey: .ignoreSuffix)
        try container.encodeIfPresent(folder, forKey: .folder)
        if !defaultDependencies.isEmpty {
            try container.encodeSorted(dictionary: defaultDependencies, forKey: .defaultDependencies)
        }
        if !excludedFamilies.isEmpty {
            try container.encode(excludedFamilies, forKey: .excludedFamilies)
        }
    }
}
