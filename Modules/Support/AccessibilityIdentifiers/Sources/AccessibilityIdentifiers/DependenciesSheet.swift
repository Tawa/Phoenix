import Foundation

public enum DependenciesSheet: AccessibilityIdentifiable {
    case filter
    case component(named: String)
    
    public var identifier: String {
        switch self {
        case .filter:
            return "DependenciesSheet-Filter"
        case let .component(named):
            return "DependenciesSheet-Component-\(named)"
        }
    }
}
