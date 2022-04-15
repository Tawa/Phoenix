import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false
    @Published var selectedIndex: Int = 0

    public init(document: Binding<PhoenixDocument>) {
        self._document = document
    }

    func onAddButton() {
        withAnimation { showingNewComponentPopup = true }
    }

    func onNewComponent(_ name: Name) {
        guard document.components.contains(where: { $0.name == name }) == false else { return }
        let newComponent = Component(name: name,
                                     platforms: [],
                                     types: [:])
        document.components.append(newComponent)
        document.components.sort(by: { $0.name.full < $1.name.full })

        showingNewComponentPopup = false
    }

    func isNameAlreadyInUse(_ name: Name) -> Bool {
        document.components.contains(where: { $0.name.full.lowercased() == name.full.lowercased() })
    }
}

extension Collection {
    func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
        Array(enumerated())
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            ComponentsList(components: Binding(get: { viewModel.document.components },
                                               set: { viewModel.document.components = $0 }),
                           selectedIndex: Binding(get: { viewModel.selectedIndex },
                                                  set: { viewModel.selectedIndex = $0 }),
                           onAddButton: viewModel.onAddButton)

            if viewModel.showingNewComponentPopup {
                NewComponentPopover(isPresenting: $viewModel.showingNewComponentPopup,
                                    onSubmit: viewModel.onNewComponent(_:),
                                    isNameAlreadyInUse: viewModel.isNameAlreadyInUse(_:))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel(document: .constant(PhoenixDocument())))
    }
}
