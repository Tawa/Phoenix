import Package
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var store: PhoenixDocumentStore
    private let familyFolderNameProvider: FamilyFolderNameProviding = FamilyFolderNameProvider()

    var body: some View {
        ZStack {
            HSplitView {
                ComponentsList(sections: store
                    .componentsFamilies
                    .map { componentsFamily in
                        .init(name: familyFolderNameProvider.folderName(forFamily: componentsFamily.family.name),
                              rows: componentsFamily.components.map { component in
                                .init(name: componentName(component, for: componentsFamily.family),
                                      isSelected: store.selectedName == component.name,
                                      onSelect: { store.selectComponent(withName: component.name) })
                        },
                              onSelect: { store.selectFamily(withName: componentsFamily.family.name) })
                    })
                    .frame(minWidth: 250)

                if let selectedComponent = store.selectedComponent {
                    ComponentView(component: selectedComponent,
                                  showingDependencyPopover: $viewModel.showingDependencyPopover)
                    .frame(minWidth: 750)
                } else {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("No Component Selected")
                                .font(.title)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }.frame(minWidth: 750)
                }
            }

        }.sheet(isPresented: $viewModel.showingDependencyPopover) {
            ComponentDependenciesPopover(showingPopup: $viewModel.showingDependencyPopover)
                .frame(minWidth: 900, minHeight: 400)
        }.sheet(isPresented: $viewModel.showingNewComponentPopup) {
            NewComponentPopover(isPresenting: $viewModel.showingNewComponentPopup) { name, familyName in
                let name = Name(given: name, family: familyName)
                if name.given.isEmpty {
                    return "Given name cannot be empty"
                } else if name.family.isEmpty {
                    return "Component must be part of a family"
                } else if store.nameExists(name: name) {
                    return "Name already in use"
                } else {
                    store.addNewComponent(withName: name)
                    store.selectComponent(withName: name)
                }
                return nil
            }

        }.sheet(item: .constant(store.selectedFamily.map { FamilyPopoverViewModel(family: $0) })) { viewModel in
            FamilyPopover(viewModel: viewModel)
        }.toolbar {
//            Button(action: viewModel.onAddAll, label: { Text("Add everything in the universe") })
            Button(action: viewModel.onAddButton, label: { Text("Add New Component") })
                .keyboardShortcut("A", modifiers: [.command, .shift])
            Button(action: viewModel.onGenerate, label: { Text("Generate Packages") })
                .keyboardShortcut(.init("R"), modifiers: .command)
        }
    }

    private func componentName(_ component: Component, for family: Family) -> String {
        family.ignoreSuffix == true ? component.name.given : component.name.given + component.name.family
    }
}
