import Foundation
import SwiftPackage

public struct RemoteComponent: Codable, Hashable, Identifiable {
    public let id: String = UUID().uuidString
    public var url: String
    public var version: ExternalDependencyVersion
    public var names: [ExternalDependencyName]
    
    enum CodingKeys: CodingKey {
        case url
        case version
        case names
    }
    
    public init(
        url: String,
        version: ExternalDependencyVersion,
        names: [ExternalDependencyName]) {
            self.url = url
            self.version = version
            self.names = names
        }
}
