import Foundation
import SwiftPackage

public struct RemoteComponentDependency: Codable, Hashable, Identifiable {
    public var id: String { url }
    public let url: String
    public var targetTypes: [ExternalDependencyName: [PackageTargetType]]
    
    public init(url: String, targetTypes: [ExternalDependencyName : [PackageTargetType]]) {
        self.url = url
        self.targetTypes = targetTypes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeSorted(dictionary: targetTypes, forKey: .targetTypes)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(targetTypes)
    }
}
