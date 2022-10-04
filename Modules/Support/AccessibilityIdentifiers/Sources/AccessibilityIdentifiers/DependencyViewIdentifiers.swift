import Foundation

public enum DependencyViewIdentifiers: AccessibilityIdentifiable {
    case menu(dependencyName: String, packageName: String)
    case option(dependencyName: String, packageName: String, option: String)
    case removeOption(dependencyName: String, packageName: String)
    
    public var identifier: String {
        switch self {
        case let .menu(dependencyName, packageName):
            return "DependencySheet-Menu-\(dependencyName)-\(packageName)"
        case let .option(dependencyName, packageName, option):
            return "DependencySheet-Option-\(dependencyName)-\(packageName)-\(option)"
        case let .removeOption(dependencyName, packageName):
            return "DependencySheet-RemoveOption-\(dependencyName)-\(packageName)"
        }
    }
}

