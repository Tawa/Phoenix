import SwiftUI

struct InfoSheetModel: Identifiable {
    let id: String = UUID().uuidString
    let text: String
}

struct InfoSheet: View {
    let model: InfoSheetModel
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
    func infoSheet(model infoSheetModel: Binding<InfoSheetModel?>) -> some View {
        sheet(item: infoSheetModel) { model in
            InfoSheet(model: model) {
                infoSheetModel.wrappedValue = nil
            }
        }
    }
}
