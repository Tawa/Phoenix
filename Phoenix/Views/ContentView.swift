import Package
import SwiftUI

class ViewModel: ObservableObject {
    @Binding private var document: PhoenixDocument
    @Published var showingNewComponentPopup: Bool = false
    @Published var fileErrorString: String? = nil
    @Published var showingDependencyPopover: Bool = false
    let fileURL: URL?

    init(document: Binding<PhoenixDocument>,
         fileURL: URL?) {
        self._document = document
        self.fileURL = fileURL
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
            guard
                let index = self.document.families.firstIndex(where: { $0.family.name == self.document.selectedFamilyName })
            else { return nil }
            return self.document.families[index].family
        } set: { newValue in
            guard
                let newValue = newValue,
                let index = self.document.families.firstIndex(where: { $0.family.name == self.document.selectedFamilyName })
            else {
                self.document.selectedFamilyName = nil
                return
            }
            self.document.families[index].family = newValue
        }
    }

    var componentsFamilies: Binding<[ComponentsFamily]> { Binding(get: { self.document.families },
                                                                  set: { self.document.families = $0 }) }

    var selectedName: Binding<Name?> { Binding(get: { self.document.selectedName },
                                               set: { self.document.selectedName = $0 }) }

    func onAddButton() {
        showingNewComponentPopup = true
    }

    func onFamilySelection(_ family: Family) {
        document.selectedFamilyName = family.name
    }

    func onRemoveSelectedComponent() {
        guard let componentId = selectedComponent.wrappedValue?.id else { return }
        for familyIndex in 0..<document.families.count {
            document.families[familyIndex].components.removeAll(where: { $0.id == componentId })
        }
        document.families.removeAll(where: { $0.components.isEmpty })
    }

    func select(name: Name) {
        self.document.selectedName = name
    }

    func onGenerate() {
        guard let fileURL = fileURL else {
            fileErrorString = "File must be saved before packages can be generated."
            return
        }

        let packagesExtractor = PackagesExtractor()
        let allFamilies: [Family] = document.families.map { $0.family }
        let packagesWithPath: [PackageWithPath] = document.families.flatMap { componentFamily -> [PackageWithPath] in
            let family = componentFamily.family
            return componentFamily.components.flatMap { (component: Component) -> [PackageWithPath] in
                packagesExtractor.packages(for: component, of: family, allFamilies: allFamilies)
            }
        }

        let packagesGenerator = PackageGenerator()
        for packageWithPath in packagesWithPath {
            let url = fileURL.deletingLastPathComponent().appendingPathComponent(packageWithPath.path, isDirectory: true)
            try? packagesGenerator.generate(package: packageWithPath.package, at: url)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var store: PhoenixDocumentStore

    var body: some View {
        ZStack {
            HSplitView {
                ComponentsList(onAddButton: viewModel.onAddButton)
                    .frame(minWidth: 250)

                ZStack {
                    if let selectedComponent = store.selectedComponent {
                        ComponentView(component: selectedComponent,
                                      showingDependencyPopover: $viewModel.showingDependencyPopover)
                    } else {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("No Component Selected")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .padding()
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .frame(minWidth: 700)
            }

            if let family = store.selectedFamily {
                FamilyPopover(family: family)
            }

            if viewModel.showingDependencyPopover {
                ComponentDependenciesPopover(showingPopup: $viewModel.showingDependencyPopover)
            }

            if viewModel.showingNewComponentPopup {
                NewComponentPopover(isPresenting: $viewModel.showingNewComponentPopup)
            }

        }.toolbar {
            Button(action: viewModel.onGenerate, label: { Text("Generate") })
                .keyboardShortcut(.init("R"), modifiers: .command)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel(document: .constant(PhoenixDocument()), fileURL: nil))
    }
}
