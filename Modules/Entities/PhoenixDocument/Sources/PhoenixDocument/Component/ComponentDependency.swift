import Foundation
import SwiftPackage

enum EitherOrValue <FirstType, SecondType> {
    case either(FirstType)
    case or(SecondType)
}

public struct ComponentDependency: Codable, Hashable, Identifiable, Comparable {
    public var id: String { name.given + name.family }
    
    public let name: Name
    public var targetTypes: [PackageTargetType: String] = [:]
    
    enum CodingKeys: String, CodingKey {
        case name
        case targetTypes
    }
    
    public init(
        name: Name,
        targetTypes: [PackageTargetType: String]
    ) {
        self.name = name
        self.targetTypes = targetTypes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encodeSorted(dictionary: targetTypes, forKey: .targetTypes)
    }
    
    public static func < (lhs: ComponentDependency, rhs: ComponentDependency) -> Bool {
        lhs.id < rhs.id
    }
}

