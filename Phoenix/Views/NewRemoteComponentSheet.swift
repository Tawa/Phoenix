import SwiftPackage
import SwiftUI

struct NewRemoteComponentSheet: View {
    let onSubmit: (String, ExternalDependencyVersion) throws -> Void
    let onDismiss: () -> Void
    
    @State private var url: String = ""
    @State private var version: ExternalDependencyVersion = .branch(name: "main")
    @State private var infoSheetModel: InfoSheetModel? = nil

    var body: some View {
        VStack {
            TextField("URL", text: $url)
                .textFieldStyle(.plain)
            ExternalDependencyVersionView(version: $version)
            Spacer().frame(height: 30)
            HStack {
                Button(action: onDismiss) {
                    Text("Cancel")
                }
                .keyboardShortcut(.cancelAction)
                Button(action: onSubmitAction) {
                    Text("Create")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(minWidth: 300)
        .padding()
        .background(.ultraThinMaterial)
        .infoSheet(model: $infoSheetModel)
    }
    
    private func onSubmitAction() {
        do {
            try onSubmit(url, version)
        } catch {
            infoSheetModel = .init(text: error.localizedDescription)
        }
    }
}
