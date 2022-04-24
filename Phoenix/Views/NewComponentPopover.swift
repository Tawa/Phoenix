import Package
import SwiftUI

struct NewComponentPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    enum FocusFields: Hashable {
        case given
        case family
    }

    @Binding var isPresenting: Bool
    @State private var name: String = ""
    @State private var familyName: String = ""
    @State private var popoverText: String? = nil
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

            if let popoverText = popoverText {
                ZStack {
                    VStack(alignment: .center) {
                        Text(popoverText)
                            .font(.largeTitle)
                        Button(action: onPopoverOkayButton) {
                            Text("Ok")
                        }
                    }
                }
                .frame(maxWidth:  .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .onSubmit(onPopoverOkayButton)
                .onExitCommand(perform: onPopoverOkayButton)
            }
        }
        .onExitCommand(perform: onDismiss)
    }

    private func onSubmitAction() {
        focusField = nil
        let name = Name(given: name, family: familyName)
        if name.given.isEmpty {
            popoverText = "Given name cannot be empty"
        } else if name.family.isEmpty {
            popoverText = "Component must be part of a family"
        } else if store.nameExists(name: name) {
            popoverText = "Name already in use"
        } else {
            store.addNewComponent(withName: name)
            store.selectComponent(withName: name)
        }
    }

    private func onDismiss() {
        isPresenting = false
    }

    private func onPopoverOkayButton() {
        focusField = nil
        popoverText = nil
    }
}

struct NewComponentPopover_Previews: PreviewProvider {
    static var previews: some View {
        NewComponentPopover(isPresenting: .constant(true))
    }
}
