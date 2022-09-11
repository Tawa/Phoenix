import Foundation

public struct ProjectConfiguration: Codable, Hashable {
    public var packageConfigurations: [PackageConfiguration]
    public var swiftVersion: String
    public var defaultOrganizationIdentifier: String?
    
    enum CodingKeys: String, CodingKey {
        case packageConfigurations
        case swiftVersion
        case defaultOrganizationIdentifier
    }
    
    internal init(packageConfigurations: [PackageConfiguration], swiftVersion: String, defaultOrganizationIdentifier: String?) {
        self.packageConfigurations = packageConfigurations
        self.swiftVersion = swiftVersion
        self.defaultOrganizationIdentifier = defaultOrganizationIdentifier
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        packageConfigurations = try container.decode([PackageConfiguration].self, forKey: .packageConfigurations)
        swiftVersion = (try? container.decode(String.self, forKey: .swiftVersion)) ?? "5.6"
        defaultOrganizationIdentifier = try? container.decodeIfPresent(String.self, forKey: .defaultOrganizationIdentifier)
    }
}

extension ProjectConfiguration {
    public static let `default`: ProjectConfiguration = .init(packageConfigurations: [.init(name: "Implementation",
                                                                                            containerFolderName: nil,
                                                                                            appendPackageName: false,
                                                                                            internalDependency: nil,
                                                                                            hasTests: true)],
                                                              swiftVersion: "5.6",
                                                              defaultOrganizationIdentifier: nil)
}
