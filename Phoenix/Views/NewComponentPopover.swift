import SwiftUI

struct NewComponentPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    enum FocusFields: Hashable {
        case given
        case family
    }

    @Binding var isPresenting: Bool
    let onSubmit: (String, String) -> String?
    @State private var name: String = ""
    @State private var familyName: String = ""
    @State private var popoverViewModel: PopoverViewModel? = nil
    @FocusState private var focusField: FocusFields?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TextField("Given Name", text: $name)
                    .focused($focusField, equals: .given)
                    .font(.largeTitle)
                    .onSubmit {
                        focusField = .family
                    }

                TextField("Family Name", text: $familyName)
                    .focused($focusField, equals: .family)
                    .font(.largeTitle)
                    .onSubmit(onSubmitAction)

                Spacer().frame(height: 30)
                HStack {
                    Button(action: onDismiss) {
                        Text("Cancel")
                    }
                    Button(action: onSubmitAction) {
                        Text("Create")
                    }
                }
            }
            .frame(width: 300)
            .padding()
            .frame(maxWidth:  .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .onAppear { focusField = .given }
        }
        .onExitCommand(perform: onDismiss)
        .sheet(item: $popoverViewModel) { viewModel in
            PopoverView(viewModel: viewModel) {
                popoverViewModel = nil
            }
        }
    }

    private func onSubmitAction() {
        focusField = nil
        onSubmit(name, familyName).map { popoverViewModel = .init(text: $0) }
    }

    private func onDismiss() {
        isPresenting = false
    }

    private func onPopoverOkayButton() {
        focusField = nil
        popoverViewModel = nil
    }
}

struct NewComponentPopover_Previews: PreviewProvider {
    static var previews: some View {
        NewComponentPopover(isPresenting: .constant(true),
                            onSubmit: { _, _ in nil })
    }
}
