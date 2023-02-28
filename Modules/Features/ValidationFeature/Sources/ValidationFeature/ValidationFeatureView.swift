import SwiftUI

public struct ValidationFeatureView: View {
    let fileURL: URL?
    
    public init(fileURL: URL?) {
        self.fileURL = fileURL
    }
    
    public var body: some View {
        if let fileURL {
            Text("Saved File \(fileURL)")
        } else {
            Text("Unsaved File")
        }
    }
}
