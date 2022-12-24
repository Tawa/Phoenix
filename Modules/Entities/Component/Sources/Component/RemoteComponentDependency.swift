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
}
