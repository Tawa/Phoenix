import Package
import SwiftUI

struct NewComponentPopover: View {
    enum FocusFields: Hashable {
        case given
        case family
    }

    @Binding var isPresenting: Bool
    @State private var name: String = ""
    @State private var familyName: String = ""
    @State private var popoverText: String? = nil
    @FocusState private var focusField: FocusFields?

    let onSubmit: (Name) -> Void
    let isNameAlreadyInUse: (Name) -> Bool

    var body: some View {
        ZStack {
            VStack {
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

                }.padding()
                Button(action: onSubmitAction) {
                    Text("Create")
                }

            }
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
            }
        }
        .onExitCommand(perform: { withAnimation { isPresenting = false } })
    }

    private func onSubmitAction() {
        focusField = nil
        let name = Name(given: name, family: familyName)
        if name.given.isEmpty {
            withAnimation { popoverText = "Given name cannot be empty" }
        } else if name.family.isEmpty {
            withAnimation { popoverText = "Component must be part of a family" }
        } else if isNameAlreadyInUse(name) {
            withAnimation { popoverText = "Name already in use" }
        } else {
            onSubmit(name)
        }
    }

    private func onPopoverOkayButton() {
        focusField = nil
        withAnimation { popoverText = nil }
    }
}

struct NewComponentPopover_Previews: PreviewProvider {
    static var previews: some View {
        NewComponentPopover(
            isPresenting: .constant(true),
            onSubmit: { _ in },
            isNameAlreadyInUse: { _ in false })
    }
}
