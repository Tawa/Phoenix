public enum ComponentDependencyType: Codable, Hashable, Identifiable, Comparable {
    public var id: String {
        switch self {
        case let .local(value):
            return value.id
        case let .remote(value):
            return value.id
        }
    }

    case local(ComponentDependency)
    case remote(RemoteDependency)

    public static func <(lhs: ComponentDependencyType, rhs: ComponentDependencyType) -> Bool {
        switch (lhs, rhs) {
        case (.local(let lhsValue), .local(let rhsValue)):
            return lhsValue.id < rhsValue.id
        case (.remote(let lhsValue), .remote(let rhsValue)):
            return lhsValue.id < rhsValue.id
        case (.remote(_), .local(_)):
            return false
        case (.local(_), .remote(_)):
            return true
        }
    }
}
