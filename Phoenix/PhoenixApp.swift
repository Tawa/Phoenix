import Package
import SwiftUI
import PhoenixDocument
import Factory

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            ContentView(
                viewModel: ViewModel(
                    projectGenerator: Container.projectGenerator(),
                    familyFolderNameProvider: Container.familyFolderNameProvider()
                )
            )
                .environmentObject(PhoenixDocumentStore(
                    fileURL: file.fileURL,
                    document: file.$document
                ))
        }.windowToolbarStyle(.expanded)
    }
}
