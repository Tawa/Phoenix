import Factory
import PhoenixDocument
import SwiftPackage
import SwiftUI

class PhoenixAppCompositionRoot: ObservableObject {
    var compositions: [String: Composition] = [:]
    
    func composition(for document: Binding<PhoenixDocument>) -> Composition {
        let id = document.wrappedValue.id
        if let composition = compositions[id] {
            composition.phoenixDocumentRepository().bind(document: document)
            return composition
        }
        let composition = Composition(document: document)
        self.compositions[id] = composition
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
                    filesURLDataStore: Container.filesURLDataStore(),
                    projectGenerator: Container.projectGenerator(),
                    composition: compositionRoot.composition(for: file.$document)
                )
            )
            .environmentObject(compositionRoot.composition(for: file.$document))
        }.windowToolbarStyle(.expanded)
    }
}
