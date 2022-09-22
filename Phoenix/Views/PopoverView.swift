import SwiftUI

struct PopoverViewModel: Identifiable {
    let id: String = UUID().uuidString
    let text: String
}

struct PopoverView: View {
    let viewModel: PopoverViewModel
    let onOkayButton: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Text(viewModel.text)
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
