public enum ExternalDependencyName: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }
    public var name: String {
        switch self {
        case .name(let string):
            return string
        case .product(let name, _):
            return name
        }
    }
    public var package: String? {
        switch self {
        case .name:
            return nil
        case .product(_, let package):
            return package
        }
    }

    case name(String)
    case product(name: String, package: String)
}

public enum ExternalDependencyVersion: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    case from(version: String)
    case branch(name: String)
    case exact(version: String)

    public var title: String {
        switch self {
        case .from:
            return "from"
        case .branch:
            return "branch"
        case .exact:
            return "exact"
        }
    }

    public var stringValue: String {
        switch self {
        case let .from(version), let .exact(version):
            return version
        case let .branch(name):
            return name
        }
    }
}

public enum Dependency: Codable, Hashable, Identifiable, Comparable {
    public var id: Int { hashValue }
    public var name: String {
        switch self {
        case .module(_, let name):
            return name
        case .external(_, let name, _):
            return name.name
        }
    }

    case module(path: String,
                name: String)

    case external(url: String,
                  name: ExternalDependencyName,
                  description: ExternalDependencyVersion)

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
