import SwiftUI

public protocol AccessibilityIdentifiable {
    var identifier: String { get }
}

public extension View {
    func with(accessibilityIdentifier value: AccessibilityIdentifiable) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        self.accessibilityIdentifier(value.identifier)
    }
}
