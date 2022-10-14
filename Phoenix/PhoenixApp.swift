import Factory
import PhoenixDocument
import SwiftPackage
import SwiftUI

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            ContentView(
                fileURL: file.fileURL,
                document: file.$document,
                viewModel: ViewModel(
                    appVersionUpdateProvider: Container.appVersionUpdateProvider(),
                    pbxProjSyncer: Container.pbxProjSyncer(),
                    familyFolderNameProvider: Container.familyFolderNameProvider(),
                    filesURLDataStore: Container.filesURLDataStore(),
                    projectGenerator: Container.projectGenerator()
                )
            )
        }.windowToolbarStyle(.expanded)
    }
}
