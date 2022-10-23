public struct Family: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    enum CodingKeys: CodingKey {
        case name
        case ignoreSuffix
        case folder
        case defaultDependencies
    }

    public let name: String
    public var ignoreSuffix: Bool
    public var folder: String?
    public var defaultDependencies: [PackageTargetType: String]

    public init(name: String, ignoreSuffix: Bool = false, folder: String? = nil) {
        self.name = name
        self.ignoreSuffix = ignoreSuffix
        self.folder = folder
        self.defaultDependencies = [:]
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        ignoreSuffix = try container.decode(Bool.self, forKey: .ignoreSuffix)
        folder = try container.decodeIfPresent(String.self, forKey: .folder)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType : String].self, forKey: .defaultDependencies) ?? [:]
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(ignoreSuffix, forKey: .ignoreSuffix)
        try container.encodeIfPresent(folder, forKey: .folder)
        if !defaultDependencies.isEmpty {
            try container.encode(defaultDependencies, forKey: .defaultDependencies)
        }
    }
}
