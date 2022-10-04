import Foundation

public enum ToolbarIdentifiers: String, AccessibilityIdentifiable {
    public var identifier: String { rawValue }
    
    case configurationButton
    case newComponentButton
}
