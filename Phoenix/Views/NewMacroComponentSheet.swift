import SwiftUI

struct NewMacroComponentSheet: View {
    let onSubmit: (String) throws -> Void
    let onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var infoSheetModel: InfoSheetModel? = nil
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
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

struct NewMacroComponentSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewMacroComponentSheet(
            onSubmit: { _ in },
            onDismiss: { }
        )
    }
}
