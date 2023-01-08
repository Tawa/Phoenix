import Foundation
import PhoenixDocument

public struct DemoAppFeatureInput: Identifiable {
    public let id: String = UUID().uuidString
    let component: Component
    let document: PhoenixDocument
    let ashFileURL: URL
    let onDismiss: () -> Void
    let onError: (Error) -> Void
    
    public init(
        component: Component,
        document: PhoenixDocument,
        ashFileURL: URL,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.component = component
        self.document = document
        self.ashFileURL = ashFileURL
        self.onDismiss = onDismiss
        self.onError = onError
    }
}

