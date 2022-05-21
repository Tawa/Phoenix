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
                            .init(name: sectionTitle(forFamily: componentsFamily.family),
                                  rows: componentsFamily.components.map { component in
                                    .init(name: componentName(component, for: componentsFamily.family),
                                          isSelected: store.selectedName == component.name,
                                          onSelect: { store.selectComponent(withName: component.name) })
                            },
                                  onSelect: { store.selectFamily(withName: componentsFamily.family.name) })
                    })
                .frame(minWidth: 250)
                
                if let selectedComponent = store.selectedComponent {
                    ComponentView(
                        title: store.title(for: selectedComponent.name),
                        onRemove: { store.removeSelectedComponent() },
                        component: selectedComponent,
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
            let filteredNames = Dictionary(grouping: store.allNames.filter { name in
                store.selectedName != name && !store.selectedComponentDependenciesContains(dependencyName: name)
            }, by: { $0.family })
            let sections = filteredNames.reduce(into: [ComponentDependenciesListSection]()) { partialResult, keyValue in
                partialResult.append(ComponentDependenciesListSection(name: keyValue.key,
                                                                      rows: keyValue.value.map { name in
                    ComponentDependenciesListRow(name: store.title(for: name),
                                                 onSelect: { store.addDependencyToSelectedComponent(dependencyName: name) })
                }))
            }.sorted { lhs, rhs in
                lhs.name < rhs.name
            }
            ComponentDependenciesPopover(
                sections: sections,
                onExternalSubmit: { remoteDependency in
                    let urlString = remoteDependency.urlString

                    let name: ExternalDependencyName
                    switch remoteDependency.productType {
                    case .name:
                        name = .name(remoteDependency.productName)
                    case .product:
                        name = .product(name: remoteDependency.productName, package: remoteDependency.productPackage)
                    }

                    let version: ExternalDependencyVersion
                    switch remoteDependency.versionType {
                    case .from:
                        version = .from(version: remoteDependency.versionValue)
                    case .branch:
                        version = .branch(name: remoteDependency.versionValue)
                    }
                    store.addRemoteDependencyToSelectedComponent(dependency: RemoteDependency(url: urlString,
                                                                                              name: name,
                                                                                              value: version))
                },
                onDismiss: { viewModel.showingDependencyPopover = false })
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
            
        }.sheet(item: .constant(store.selectedFamily)) { family in
            FamilyPopover(name: family.name,
                          ignoreSuffix: family.ignoreSuffix,
                          onUpdateSelectedFamily: { store.updateSelectedFamily(ignoresSuffix: !$0) },
                          folderName: family.folder ?? "",
                          onUpdateFolderName: { store.updateSelectedFamily(folder: $0) },
                          defaultFolderName: familyFolderNameProvider.folderName(forFamily: family.name),
                          componentNameExample: "Component\(family.ignoreSuffix ? "" : family.name)",
                          onDismiss: store.deselectFamily)
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
    
    private func sectionTitle(forFamily family: Family) -> String {
        if let folder = family.folder {
            return folder
        }
        return familyFolderNameProvider.folderName(forFamily: family.name)
    }
}
