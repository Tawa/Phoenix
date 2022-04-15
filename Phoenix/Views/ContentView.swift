import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false
    @Published var selectedName: Name? = nil

    public init(document: Binding<PhoenixDocument>) {
        self._document = document
    }

    func onAddButton() {
        withAnimation { showingNewComponentPopup = true }
    }

    func onNewComponent(_ name: Name) {
        guard document.components[name.family]?.contains(where: { $0.name.given == name.given }) != true else { return }

        var array = document.components[name.family] ?? []

        let newComponent = Component(name: name,
                                     platforms: [],
                                     types: [:])
        array.append(newComponent)
        array.sort(by: { $0.name.full < $1.name.full })

        document.components[name.family] = array

        showingNewComponentPopup = false
    }

    func isNameAlreadyInUse(_ name: Name) -> Bool {
        document.components[name.family]?.contains(where: { $0.name.full.lowercased() == name.full.lowercased() }) == true
    }

    func folderNameForFamily(_ familyName: String) -> String {
        guard let family = document.familyNames.first(where: { $0.name == familyName })
        else { return familyName }
        return family.folderName
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
                           selectedName: Binding(get: { viewModel.selectedName },
                                                 set: { viewModel.selectedName = $0 }),
                           folderNameForFamily: viewModel.folderNameForFamily(_:),
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
