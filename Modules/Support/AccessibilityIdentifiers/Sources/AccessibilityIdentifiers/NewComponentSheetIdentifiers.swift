import Foundation

public enum NewComponentSheetIdentifiers: String, AccessibilityIdentifiable {
    public var identifier: String { rawValue }
    
    case givenNameTextField
    case familyNameTextField
    case cancelButton
    case createButton
}
