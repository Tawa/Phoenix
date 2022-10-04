import Foundation

public enum DependencyViewIdentifiers: AccessibilityIdentifiable {
    case selector(dependencyName: String, packageName: String)
    case option(dependencyName: String, packageName: String, option: String)
    
    public var identifier: String {
        switch self {
        case let .selector(dependencyName, packageName):
            return "DependencySheet-Selector-\(dependencyName)-\(packageName)"
        case let .option(dependencyName, packageName, option):
            return "DependencySheet-Option-\(dependencyName)-\(packageName)-\(option)"
        }
    }
}

