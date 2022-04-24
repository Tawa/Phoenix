import Package
import SwiftUI

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            ContentView()
                .environmentObject(ViewModel(document: file.$document,
                                             fileURL: file.fileURL))
                .environmentObject(PhoenixDocumentStore(document: file.$document))
        }
    }
}
