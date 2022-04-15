import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false
    @Published var showingFamilyPopup: Bool = false
    @Published var selectedFamilyForPopup: Family? = nil

    init(document: Binding<PhoenixDocument>) {
        self._document = document
    }

    var selectedComponent: Binding<Component?> {
        Binding {
            guard
                let selectedName = self.document.selectedName,
                let componentFamilyIndex = self.document.families.firstIndex(where: { $0.family.name == selectedName.family })
            else { return nil }
            return self.document.families[componentFamilyIndex].components.first(where: { $0.name.given == selectedName.given })
        } set: { newValue in
            guard let component = newValue,
                  let selectedName = self.document.selectedName,
                  let componentFamilyIndex = self.document.families.firstIndex(where: { $0.family.name == selectedName.family }),
                  let componentIndex = self.document.families[componentFamilyIndex].components.firstIndex(where: { $0.name.given == selectedName.given })
            else { return }
            self.document.families[componentFamilyIndex].components[componentIndex] = component
        }
    }

    var selectedFamily: Binding<Family?> {
        Binding {
            self.selectedFamilyForPopup
        } set: { newValue in
            guard
                let newValue = newValue,
                let index = self.document.families.firstIndex(where: { $0.family == self.selectedFamilyForPopup })
            else { return }
            self.document.families[index].family = newValue
        }
    }

    func onAddButton() {
        withAnimation { showingNewComponentPopup = true }
    }

    func onFamilySelection(_ family: Family) {
        selectedFamilyForPopup = family
        withAnimation { showingFamilyPopup = true }
    }

    func onNewComponent(_ name: Name) {
        var componentsFamily: ComponentsFamily = document
            .families
            .first(where: {
                $0.family.name == name.family
            }) ?? ComponentsFamily(family: Family(name: name.family, suffix: nil, folder: nil), components: [])
        guard componentsFamily.components.contains(where: { $0.name == name }) == false else { return }

        var array = componentsFamily.components

        let newComponent = Component(name: name,
                                     iOSVersion: nil,
                                     macOSVersion: nil,
                                     types: [:])
        array.append(newComponent)
        array.sort(by: { $0.name.full < $1.name.full })

        componentsFamily.components = array

        if let familyIndex = document.families.firstIndex(where: { $0.family.name == name.family }) {
            document.families[familyIndex].components = array
        } else {
            var familiesArray = document.families
            familiesArray.append(componentsFamily)
            familiesArray.sort(by: { $0.family.name < $1.family.name })
            document.families = familiesArray
        }

        showingNewComponentPopup = false
    }

    func isNameAlreadyInUse(_ name: Name) -> Bool {
        document.families.flatMap { $0.components }.contains(where: { (component: Component) -> Bool in component.name == name })
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
            HSplitView {
                ComponentsList(componentsFamilies: Binding(get: { viewModel.document.families },
                                                           set: { viewModel.document.families = $0 }),
                               selectedName: Binding(get: { viewModel.document.selectedName },
                                                     set: { viewModel.document.selectedName = $0 }),
                               onFamilySelection: viewModel.onFamilySelection(_:),
                               onAddButton: viewModel.onAddButton)
                .frame(minWidth: 250)

                ComponentView(component: viewModel.selectedComponent)
                    .frame(minWidth: 500)
            }

            if viewModel.showingNewComponentPopup {
                NewComponentPopover(isPresenting: $viewModel.showingNewComponentPopup,
                                    onSubmit: viewModel.onNewComponent(_:),
                                    isNameAlreadyInUse: viewModel.isNameAlreadyInUse(_:))
            }

            if viewModel.showingFamilyPopup {
                FamilyPopover(family: viewModel.selectedFamily,
                              isPresenting: $viewModel.showingFamilyPopup)
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
