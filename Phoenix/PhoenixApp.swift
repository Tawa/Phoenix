import Package
import SwiftUI
import PhoenixDocument

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            ContentView()
                .environmentObject(PhoenixDocumentStore(
                    fileURL: file.fileURL,
                    document: file.$document
                ))
        }.windowToolbarStyle(.expanded)
    }
}
