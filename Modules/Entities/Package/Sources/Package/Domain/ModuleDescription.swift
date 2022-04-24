public enum ExternalDependencyDescription: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    case from(value: String)
    case branch(name: String)
}

public enum Dependency: Codable, Hashable, Identifiable, Comparable {
    public var id: Int { hashValue }

    case module(path: String, name: String)
    case external(url: String, name: String, description: ExternalDependencyDescription)

    public static func <(lhs: Dependency, rhs: Dependency) -> Bool {
        switch (lhs, rhs) {
        case (.module(let lhsPath, _) , .module(let rhsPath, _)):
            return lhsPath < rhsPath
        case (.external(let lhsUrl, _, _), .external(let rhsUrl, _, _)):
            return lhsUrl < rhsUrl
        case (.module, .external):
            return true
        case (.external, .module):
            return false
        }
    }
}
