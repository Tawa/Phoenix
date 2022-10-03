import Foundation

public enum Toolbar: String, AccessibilityIdentifiable {
    public var identifier: String { rawValue }
    
    case configurationButton
    case newComponentButton
}
