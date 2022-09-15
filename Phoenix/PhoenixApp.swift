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
                    familyFolderNameProvider: Container.familyFolderNameProvider(),
                    filesURLDataStore: Container.filesURLDataStore(),
                    projectGenerator: Container.projectGenerator()
                )
            )
                .environmentObject(PhoenixDocumentStore(
                    fileURL: file.fileURL,
                    document: file.$document
                ))
        }.windowToolbarStyle(.expanded)
    }
}
