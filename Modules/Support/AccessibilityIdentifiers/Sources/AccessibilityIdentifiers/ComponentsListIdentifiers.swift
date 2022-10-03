import Foundation

public enum ComponentsListIdentifiers: AccessibilityIdentifiable {
    case component(named: String)
    case familySettingsButton(named: String)
    
    public var identifier: String {
        switch self {
        case let .component(named):
            return "ComponentsList-\(named)"
        case let .familySettingsButton(named):
            return "ComponentsListFamilySettings-\(named)"
        }
    }
}
