import SwiftPackage
import SwiftUI

struct NewRemoteComponentNameSheet: View {
    let onSubmit: (ExternalDependencyName) throws -> Void
    let onDismiss: () -> Void
    
    @State private var name: ExternalDependencyName = .name("")
    @State private var infoSheetModel: InfoSheetModel? = nil

    var body: some View {
        VStack {
            ExternalDependencyNameView(name: $name)
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
            try onSubmit(name)
        } catch {
            infoSheetModel = .init(text: error.localizedDescription)
        }
    }
}
