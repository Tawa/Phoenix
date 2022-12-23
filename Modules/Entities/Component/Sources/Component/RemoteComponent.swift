import Foundation
import SwiftPackage

public struct RemoteComponent: Codable, Hashable, Identifiable {
    public let id: String
    public var url: String
    public var version: ExternalDependencyVersion
    public var names: [ExternalDependencyName]
    
    enum CodingKeys: CodingKey {
        case id
        case url
        case version
        case names
    }
    
    public init(
        id: String = UUID().uuidString,
        url: String,
        version: ExternalDependencyVersion,
        names: [ExternalDependencyName]) {
            self.id = id
            self.url = url
            self.version = version
            self.names = names
        }
}
