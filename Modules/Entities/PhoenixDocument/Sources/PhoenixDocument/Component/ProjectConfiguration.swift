import Foundation

public struct ProjectConfiguration: Codable, Hashable {
    public var packageConfigurations: [PackageConfiguration]
    public var defaultDependencies: [PackageTargetType: String]
    public var swiftVersion: String
    public var defaultOrganizationIdentifier: String?
    
    enum CodingKeys: String, CodingKey {
        case packageConfigurations
        case defaultDependencies
        case swiftVersion
        case defaultOrganizationIdentifier
    }
    
    internal init(packageConfigurations: [PackageConfiguration],
                  defaultDependencies: [PackageTargetType: String],
                  swiftVersion: String,
                  defaultOrganizationIdentifier: String?) {
        self.packageConfigurations = packageConfigurations
        self.defaultDependencies = defaultDependencies
        self.swiftVersion = swiftVersion
        self.defaultOrganizationIdentifier = defaultOrganizationIdentifier
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        packageConfigurations = try container.decode([PackageConfiguration].self, forKey: .packageConfigurations)
        defaultDependencies = try container.decodeIfPresent([PackageTargetType: String].self, forKey: .defaultDependencies) ?? [:]
        swiftVersion = (try? container.decode(String.self, forKey: .swiftVersion)) ?? "5.6"
        defaultOrganizationIdentifier = try? container.decodeIfPresent(String.self, forKey: .defaultOrganizationIdentifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(packageConfigurations, forKey: .packageConfigurations)
        if !defaultDependencies.isEmpty {
            try container.encodeSorted(dictionary: defaultDependencies, forKey: .defaultDependencies)
        }
        try container.encode(swiftVersion, forKey: .swiftVersion)
        try container.encodeIfPresent(defaultOrganizationIdentifier, forKey: .defaultOrganizationIdentifier)
    }
}

extension ProjectConfiguration {
    public static let `default`: ProjectConfiguration = .init(packageConfigurations: [.init(name: "Implementation",
                                                                                            containerFolderName: nil,
                                                                                            appendPackageName: false,
                                                                                            internalDependency: nil,
                                                                                            hasTests: true)],
                                                              defaultDependencies: [:],
                                                              swiftVersion: "5.6",
                                                              defaultOrganizationIdentifier: nil)
}
