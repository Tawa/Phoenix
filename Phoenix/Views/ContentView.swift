import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false

    var components: [Component] { document.components }

    public init(document: Binding<PhoenixDocument>) {
        self._document = document
    }

    func onAddButton() {
        showingNewComponentPopup = true
    }

    func onNewComponent(_ name: Name) {
        guard components.contains(where: { $0.name == name }) == false else { return }
        let newComponent = Component(name: name,
                                     types: [:],
                                     platforms: [])
        document.components.append(newComponent)

        showingNewComponentPopup = false
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            List {
                Text("Hello, World")

                ForEach(viewModel.components) { component in
                    Text(component.name.given + component.name.family)
                }

                Button(action: viewModel.onAddButton) {
                    Text("Add")
                }
            }
            if viewModel.showingNewComponentPopup {
                NewComponentPopover(onSubmit: viewModel.onNewComponent(_:))
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
