import SwiftUI

struct NewRemoteComponentSheet: View {
    let onSubmit: (String) throws -> Void
    let onDismiss: () -> Void
    
    @State private var url: String = ""
    @State private var infoSheetModel: InfoSheetModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            TextField("URL", text: $url)
                .textFieldStyle(.plain)
            
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
        .infoSheet(model: $infoSheetModel)
    }
    
    private func onSubmitAction() {
        do {
            try onSubmit(url)
        } catch {
            infoSheetModel = .init(text: error.localizedDescription)
        }
    }
}
