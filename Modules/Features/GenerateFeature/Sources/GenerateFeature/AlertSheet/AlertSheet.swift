import SwiftUI

struct AlertSheetModel: Identifiable {
    let id: String = UUID().uuidString
    let text: String
}

struct AlertSheet: View {
    let model: AlertSheetModel
    let onOkayButton: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text(model.text)
                .font(.largeTitle)
            Button(action: onOkayButton) {
                Text("Ok")
            }.keyboardShortcut(.defaultAction)
        }
        .frame(maxWidth:  .infinity, maxHeight: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .onSubmit(onOkayButton)
    }
}

extension View {
    func alertSheet(model alertSheetModel: Binding<AlertSheetModel?>) -> some View {
        sheet(item: alertSheetModel) { model in
            AlertSheet(model: model) {
                alertSheetModel.wrappedValue = nil
            }
        }
    }
}
