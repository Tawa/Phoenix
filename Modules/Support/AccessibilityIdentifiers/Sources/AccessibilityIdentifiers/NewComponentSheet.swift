import Foundation

public enum NewComponentSheet: String, AccessibilityIdentifiable {
    public var identifier: String { rawValue }
    
    case givenNameTextField
    case familyNameTextField
    case cancelButton
    case createButton
}
