import SwiftPackage

public struct RemoteDependency: Codable, Hashable, Identifiable, Comparable {
    public var id: String { url }
    
    public let url: String
    public var name: ExternalDependencyName
    public var version: ExternalDependencyVersion
    public var targetTypes: [PackageTargetType] = []
    
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
