import Foundation

public enum GenerateSheetIdentifiers: String, AccessibilityIdentifiable {
    public var identifier: String { "generate-sheet-\(rawValue)" }
    
    case modulesFolderButton
    case skipXcodeToggle
    case xcodeButton
    case generateButton
    case cancelButton
}
