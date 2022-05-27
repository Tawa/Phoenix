import Foundation
public struct ComponentDependency: Codable, Hashable, Identifiable {
    public var id: String { name.given + name.family }

    public let name: Name
    public var targetTypes: [PackageTargetType: String] = [:]

    public init(
        name: Name,
        targetTypes: [PackageTargetType: String]
    ) {
        self.name = name
        self.targetTypes = targetTypes
    }
}

public enum ComponentResourcesType: String, Codable, Hashable {
    case process
    case copy
}

public struct ComponentResources: Codable, Hashable, Identifiable, Comparable {
    public let id: String
    public var folderName: String
    public var type: TargetResources.ResourcesType
    public var targets: [TargetType]

    enum CodingKeys: String, CodingKey {
        case folderName
        case type
        case targets
    }

    public init(id: String = UUID().uuidString,
                folderName: String,
                type: TargetResources.ResourcesType,
                targets: [TargetType]) {
        self.id = id
        self.folderName = folderName
        self.type = type
        self.targets = targets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID().uuidString
        self.folderName = try container.decode(String.self, forKey: .folderName)
        self.type = try container.decode(TargetResources.ResourcesType.self, forKey: .type)
        self.targets = try container.decode([TargetType].self, forKey: .targets)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(folderName, forKey: .folderName)
        try container.encode(type, forKey: .type)
        try container.encode(targets, forKey: .targets)
    }

    public static func <(lhs: ComponentResources, rhs: ComponentResources) -> Bool {
        lhs.folderName < rhs.folderName
    }
}
