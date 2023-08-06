public enum ComponentDependencyType: Codable, Hashable, Identifiable, Comparable {
    public var id: String {
        switch self {
        case let .local(value):
            return value.id
        case let .macro(value):
            return value.id
        case let .remote(value):
            return value.id
        }
    }
    
    case local(ComponentDependency)
    case macro(MacroComponentDependency)
    case remote(RemoteDependency)
    
    public static func <(lhs: ComponentDependencyType, rhs: ComponentDependencyType) -> Bool {
        switch (lhs, rhs) {
        case (.local(let lhsValue), .local(let rhsValue)):
            return lhsValue.id < rhsValue.id
        case (.macro(let lhsValue), .macro(let rhsValue)):
            return lhsValue.id < rhsValue.id
        case (.remote(let lhsValue), .remote(let rhsValue)):
            return lhsValue.url < rhsValue.url
        case (.remote, .local):
            return false
        case (.local, .remote):
            return true
        case (.macro, .local):
            return false
        case (.local, .macro):
            return true
        case (.remote, .macro):
            return false
        case (.macro, .remote):
            return true
        }
    }
}
