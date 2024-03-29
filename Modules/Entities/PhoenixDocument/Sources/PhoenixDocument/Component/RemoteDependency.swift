import Foundation
import SwiftPackage

public struct RemoteDependency: Codable, Hashable, Identifiable, Comparable {
    public let id: String = UUID().uuidString
    
    public var url: String
    public var name: ExternalDependencyName
    public var version: ExternalDependencyVersion
    public var targetTypes: [PackageTargetType]
    
    enum CodingKeys: CodingKey {
        case url
        case name
        case version
        case targetTypes
    }
    
    public init(url: String,
                name: ExternalDependencyName,
                value: ExternalDependencyVersion,
                targetTypes: [PackageTargetType]) {
        self.url = url
        self.name = name
        self.version = value
        self.targetTypes = targetTypes
    }
    
    public static func < (lhs: RemoteDependency, rhs: RemoteDependency) -> Bool {
        lhs.id < rhs.id
    }
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(name)
        hasher.combine(version)
        hasher.combine(targetTypes)
    }
}
