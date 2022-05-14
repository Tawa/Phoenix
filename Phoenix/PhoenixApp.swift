import Package
import SwiftUI

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            let store = PhoenixDocumentStore(document: file.$document)
            ContentView()
                .environmentObject(ViewModel(document: file.$document,
                                             store: store,
                                             fileURL: file.fileURL))
                .environmentObject(store)
        }
    }
}
