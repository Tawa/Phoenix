import Foundation

public enum AlertMessageIdentifiers: String, AccessibilityIdentifiable {
    public var identifier: String { "alert-message-\(rawValue)" }
    
    case alertMessage
    case okButton
}
