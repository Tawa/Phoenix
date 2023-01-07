import Foundation

public struct GenerateFeatureInput: Identifiable {
    public let id: String = UUID().uuidString
    public let fileURL: URL
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
}
