import Foundation
import SwiftPackage

public enum ComponentResourcesType: String, Codable, Hashable {
    case process
    case copy
}

public struct ComponentResources: Codable, Hashable, Identifiable, Comparable {
    public let id: String = UUID().uuidString
    public var folderName: String
    public var type: TargetResources.ResourcesType
    public var targets: [PackageTargetType]

    enum CodingKeys: String, CodingKey {
        case folderName
        case type
        case targets
    }

    public init(folderName: String,
                type: TargetResources.ResourcesType,
                targets: [PackageTargetType]) {
        self.folderName = folderName
        self.type = type
        self.targets = targets
    }

    public static func <(lhs: ComponentResources, rhs: ComponentResources) -> Bool {
        lhs.folderName < rhs.folderName
    }
}
