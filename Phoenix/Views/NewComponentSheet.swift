import AccessibilityIdentifiers
import SwiftUI

struct NewComponentSheet: View {
    enum FocusFields: Hashable {
        case given
        case family
    }

    let onSubmit: (String, String) throws -> Void
    let onDismiss: () -> Void
    let familyNameSuggestion: (String) -> String?
    @State private var name: String = ""
    @State private var familyName: String = ""
    @State private var infoSheetModel: InfoSheetModel? = nil
    @FocusState private var focusField: FocusFields?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TextField("Given Name", text: $name)
                    .focused($focusField, equals: .given)
                    .textFieldStyle(.plain)
                    .with(accessibilityIdentifier: NewComponentSheetIdentifiers.givenNameTextField)

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
                        .with(accessibilityIdentifier: NewComponentSheetIdentifiers.familyNameTextField)
                }

                Spacer().frame(height: 30)
                HStack {
                    Button(action: onDismiss) {
                        Text("Cancel")
                    }
                    .keyboardShortcut(.cancelAction)
                    .with(accessibilityIdentifier: NewComponentSheetIdentifiers.cancelButton)
                    Button(action: onSubmitAction) {
                        Text("Create")
                    }
                    .keyboardShortcut(.defaultAction)
                    .with(accessibilityIdentifier: NewComponentSheetIdentifiers.createButton)
                }
            }
            .frame(minWidth: 300)
            .padding()
            .frame(maxWidth:  .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .onAppear { focusField = .given }
        }
        .sheet(item: $infoSheetModel) { model in
            InfoSheet(model: model) {
                infoSheetModel = nil
            }
        }
    }

    private func onSubmitAction() {
        familyNameSuggestion(familyName).map { familyName = $0 }
        focusField = nil
        do {
            try onSubmit(name, familyName)
        } catch {
            infoSheetModel = .init(text: error.localizedDescription)
        }
    }
}

struct NewComponentSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewComponentSheet(onSubmit: { _, _ in },
                            onDismiss: {},
                            familyNameSuggestion: { $0 })
    }
}
