import Foundation

public enum ComponentIdentifiers: String, AccessibilityIdentifiable {
    public var identifier: String { rawValue }
    
    case dependenciesPlusButton
    case localDependenciesButton
    case remoteDependenciesButton
    case macroDependenciesButton
    case resourcesButton
}
