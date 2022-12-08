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
                composition: Composition()
            )
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.expanded)
    }
}
