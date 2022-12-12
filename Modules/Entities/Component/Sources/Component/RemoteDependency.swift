import Foundation
import SwiftPackage

public struct RemoteDependency: Codable, Hashable, Identifiable, Comparable {
    public let id: String = UUID().uuidString
    
    public var url: String
    public var name: ExternalDependencyName
    public var version: ExternalDependencyVersion
    public var targetTypes: [PackageTargetType] = []
    
    enum CodingKeys: CodingKey {
        case url
        case name
        case version
        case targetTypes
    }

    public var nameText: String {
        get { name.name }
        set {
            switch name {
            case .name:
                name = .name(newValue)
            case .product(_, let package):
                self.name = .product(name: newValue, package: package)
            }
        }
    }

    public var packageText: String? {
        get { name.package }
        set {
            switch name {
            case .name:
                break
            case .product(let name, _):
                self.name = .product(name: name, package: newValue ?? "")
            }
        }
    }
    
    public var versionText: String {
        get { version.stringValue }
        set {
            switch version {
            case .branch:
                version = .branch(name: newValue)
            case .exact:
                version = .exact(version: newValue)
            case .from:
                version = .from(version: newValue)
            }
        }
    }
    
    public init(url: String,
                name: ExternalDependencyName,
                value: ExternalDependencyVersion) {
        self.url = url
        self.name = name
        self.version = value
    }
    
    public static func < (lhs: RemoteDependency, rhs: RemoteDependency) -> Bool {
        lhs.id < rhs.id
    }
}
