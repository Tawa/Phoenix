import Foundation

public enum ConfigurationSheet: AccessibilityIdentifiable {
    case addNewButton
    case closeButton
    case textField(column: Int, row: Int)
    
    public var identifier: String {
        switch self {
        case .addNewButton:
            return "Configuration-AddNew"
        case .closeButton:
            return "Configuration-Close"
        case let .textField(column, row):
            return "Configuration-TextField-\(column)-\(row)"
        }
    }
}
