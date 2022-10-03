import AccessibilityIdentifiers
import SwiftUI

struct NewComponentPopover: View {
    enum FocusFields: Hashable {
        case given
        case family
    }

    let onSubmit: (String, String) throws -> Void
    let onDismiss: () -> Void
    let familyNameSuggestion: (String) -> String?
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
                    .textFieldStyle(.plain)
                    .with(accessibilityIdentifier: NewComponentSheet.givenNameTextField)

                ZStack {
                    HStack {
                        Text(familyNameSuggestion(familyName) ?? "")
                            .opacity(0.5)
                        Spacer()
                    }
                    TextField("Family Name", text: $familyName)
                        .focused($focusField, equals: .family)
                        .textFieldStyle(.plain)
                        .onSubmit(onSubmitAction)
                        .onChange(of: focusField) { newValue in
                            guard newValue != .family else { return }
                            familyNameSuggestion(familyName).map { familyName = $0 }
                        }
                        .with(accessibilityIdentifier: NewComponentSheet.familyNameTextField)
                }.font(.largeTitle)

                Spacer().frame(height: 30)
                HStack {
                    Button(action: onDismiss) {
                        Text("Cancel")
                    }
                    .keyboardShortcut(.cancelAction)
                    .with(accessibilityIdentifier: NewComponentSheet.cancelButton)
                    Button(action: onSubmitAction) {
                        Text("Create")
                    }
                    .keyboardShortcut(.defaultAction)
                    .with(accessibilityIdentifier: NewComponentSheet.createButton)
                }
            }
            .frame(minWidth: 300)
            .padding()
            .frame(maxWidth:  .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .onAppear { focusField = .given }
        }
        .sheet(item: $popoverViewModel) { viewModel in
            PopoverView(viewModel: viewModel) {
                popoverViewModel = nil
            }
        }
    }

    private func onSubmitAction() {
        familyNameSuggestion(familyName).map { familyName = $0 }
        focusField = nil
        do {
            try onSubmit(name, familyName)
        } catch {
            popoverViewModel = .init(text: error.localizedDescription)
        }
    }

    private func onPopoverOkayButton() {
        focusField = nil
        popoverViewModel = nil
    }
}

struct NewComponentPopover_Previews: PreviewProvider {
    static var previews: some View {
        NewComponentPopover(onSubmit: { _, _ in },
                            onDismiss: {},
                            familyNameSuggestion: { $0 })
    }
}
