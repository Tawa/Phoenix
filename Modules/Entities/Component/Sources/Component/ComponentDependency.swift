import Foundation
import SwiftPackage

enum EitherOrValue <FirstType, SecondType> {
    case either(FirstType)
    case or(SecondType)
}

struct AnyEncodable<FirstType: Encodable, SecondType: Encodable>: Encodable {
    let value: Any

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let encodableValue = value as? FirstType {
            try container.encode(encodableValue)
        } else if let encodableValue = value as? SecondType {
            try container.encode(encodableValue)
        }
    }
}

public struct ComponentDependency: Codable, Hashable, Identifiable {
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

        let array = targetTypes.keys.sorted().reduce(into: [AnyEncodable<PackageTargetType, String>]()) { partialResult, packageTargetType in
            guard let value = targetTypes[packageTargetType] else { return }
            partialResult.append(AnyEncodable(value: packageTargetType))
            partialResult.append(AnyEncodable(value: value))
        }

        try container.encode(array, forKey: .targetTypes)
    }
}

