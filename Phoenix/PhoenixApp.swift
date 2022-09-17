import Factory
import PhoenixDocument
import SwiftPackage
import SwiftUI

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            ContentView(
                viewModel: ViewModel(
                    appVersionUpdateProvider: Container.appVersionUpdateProvider(),
                    pbxProjSyncer: Container.pbxProjSyncer(),
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
