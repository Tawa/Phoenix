import Factory
import PhoenixDocument
import SwiftPackage
import SwiftUI

class PhoenixAppCompositionRoot: ObservableObject {
    var compositions: [URL: Composition] = [:]
    
    func composition(for document: Binding<PhoenixDocument>, url: URL?) -> Composition {
        guard let url = url else { return Composition(document: document) }
        if let composition = compositions[url] {
            composition.phoenixDocumentRepository().bind(document: document)
            return composition
        }
        let composition = Composition(document: document)
        self.compositions[url] = composition
        return composition
    }
}

@main
struct PhoenixApp: App {
    @StateObject var compositionRoot: PhoenixAppCompositionRoot = .init()
    
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
                    projectGenerator: Container.projectGenerator(),
                    composition: compositionRoot.composition(for: file.$document, url: file.fileURL)
                )
            )
            .environmentObject(compositionRoot.composition(for: file.$document, url: file.fileURL))
        }.windowToolbarStyle(.expanded)
    }
}
