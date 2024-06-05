import Foundation

public enum MetasListIdentifiers: AccessibilityIdentifiable {
    case component(named: String)
    case familySettingsButton(named: String)
    
    public var identifier: String {
        switch self {
        case let .component(named):
            return "MetasList-\(named)"
        case let .familySettingsButton(named):
            return "MetasList-FamilySettings-\(named)"
        }
    }
}
