import Foundation

public enum FamilySheetIdentifiers: String, AccessibilityIdentifiable {
    public var identifier: String { rawValue }
    
    case appendNameToggle
    case folderNameTextField
    case doneButton
}
