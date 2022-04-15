import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false
    @Published var selectedName: Name? = nil
    
    var selectedComponent: Binding<Component?> {
        Binding {
            guard let selectedName = self.selectedName else { return nil }
            return self.document.components[selectedName.family]?.first(where: { $0.name.given == selectedName.given })
        } set: { newValue in
            guard let component = newValue,
                  let selectedName = self.selectedName,
                  let index = self.document.components[selectedName.family]?.firstIndex(where: { $0.name.given == selectedName.given })
            else { return }
            self.document.components[selectedName.family]?[index] = component
        }
    }
    
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
            HSplitView{
                ComponentsList(components: Binding(get: { viewModel.document.components },
                                                   set: { viewModel.document.components = $0 }),
                               selectedName: Binding(get: { viewModel.selectedName },
                                                     set: { viewModel.selectedName = $0 }),
                               folderNameForFamily: viewModel.folderNameForFamily(_:),
                               onAddButton: viewModel.onAddButton)
                
                ComponentView(component: viewModel.selectedComponent)
                
                FamiliesView(families: Binding(get: { viewModel.document.familyNames },
                                               set: { viewModel.document.familyNames = $0 }))
            }
            
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
