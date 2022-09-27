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

    public var rawValue: String{
        switch self{
        case .local(let componentDependency):
            return componentDependency.name.given + componentDependency.name.family
        case .remote(let remoteDependency):
            return remoteDependency.name.name
        }
    }
    
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
