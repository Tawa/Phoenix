import Package
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ViewModel = .init()
    @EnvironmentObject private var store: PhoenixDocumentStore
    private let familyFolderNameProvider: FamilyFolderNameProviding = FamilyFolderNameProvider()
    
    var body: some View {
        ZStack {
            HSplitView {
                componentsList()

                if let selectedComponentName = viewModel.selectedComponentName,
                   let selectedComponent = store.getComponent(withName: selectedComponentName) {
                    componentView(for: selectedComponent)
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
            
        }.sheet(item: $viewModel.showingDependencyPopover) { component in
            depedencyPopover(component: component)
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
                    viewModel.selectedComponentName = name
                }
                return nil
            }
            
        }.sheet(item: .constant(store.getSelectedFamily(withName: viewModel.selectedFamilyName ?? ""))) { family in
            FamilyPopover(name: family.name,
                          ignoreSuffix: family.ignoreSuffix,
                          onUpdateSelectedFamily: { store.updateSelectedFamily(withName: viewModel.selectedFamilyName, ignoresSuffix: !$0) },
                          folderName: family.folder ?? "",
                          onUpdateFolderName: { store.updateSelectedFamily(withName: viewModel.selectedFamilyName, folder: $0) },
                          defaultFolderName: familyFolderNameProvider.folderName(forFamily: family.name),
                          componentNameExample: "Component\(family.ignoreSuffix ? "" : family.name)",
                          onDismiss: { viewModel.selectedFamilyName = nil })
        }.toolbar {
            //            Button(action: viewModel.onAddAll, label: { Text("Add everything in the universe") })
            Button(action: viewModel.onAddButton, label: { Text("Add New Component") })
                .keyboardShortcut("A", modifiers: [.command, .shift])
            Button(action: { /*viewModel.onGenerate*/ }, label: { Text("Generate Packages") })
                .keyboardShortcut(.init("R"), modifiers: .command)
        }
    }

    // MARK: - Views
    func componentsList() -> some View {
        ComponentsList(sections: store
            .componentsFamilies
            .map { componentsFamily in
                    .init(name: sectionTitle(forFamily: componentsFamily.family),
                          rows: componentsFamily.components.map { component in
                            .init(name: componentName(component, for: componentsFamily.family),
                                  isSelected: viewModel.selectedComponentName == component.name,
                                  onSelect: { viewModel.selectedComponentName = component.name })
                    },
                          onSelect: { viewModel.selectedFamilyName = componentsFamily.family.name })
            })
        .frame(minWidth: 250)
    }

    func componentView(for selectedComponent: Component) -> some View {
        ComponentView(
            title: store.title(for: selectedComponent.name),
            platformsContent: {
                Group {
                    CustomMenu(title: iOSPlatformMenuTitle(forComponent: selectedComponent),
                               data: IOSVersion.allCases,
                               onSelection: { store.setIOSVersionForSelectedComponent(withName: selectedComponent.name, iOSVersion: $0) },
                               hasRemove: selectedComponent.iOSVersion != nil,
                               onRemove: { store.removeIOSVersionForSelectedComponent(withName: selectedComponent.name) })
                    .frame(width: 150)
                    CustomMenu(title: macOSPlatformMenuTitle(forComponent: selectedComponent),
                               data: MacOSVersion.allCases,
                               onSelection: { store.setMacOSVersionForSelectedComponent(withName: selectedComponent.name, macOSVersion: $0) },
                               hasRemove: selectedComponent.macOSVersion != nil,
                               onRemove: { store.removeMacOSVersionForSelectedComponent(withName: selectedComponent.name) })
                    .frame(width: 150)
                }
            },
            dependencies: selectedComponent.dependencies.sorted(),
            dependencyView: { dependencyType in
                VStack(spacing: 0) {
                    Divider()
                    switch dependencyType {
                    case let .local(dependency):
                        DependencyView<TargetType, ModuleType>(
                            title: store.title(for: dependency.name),
                            onSelection: { viewModel.selectedComponentName = dependency.name },
                            onRemove: { store.removeDependencyForSelectedComponent(withComponentName: selectedComponent.name, componentDependency: dependency) },
                            allTypes: componentTypes(for: dependency, component: selectedComponent),
                            allSelectionValues: Array(ModuleType.allCases),
                            onUpdateTargetTypeValue: { store.updateModuleTypeForDependency(withComponentName: selectedComponent.name, dependency: dependency, type: $0, value: $1) })
                    case let .remote(dependency):
                        RemoteDependencyView(
                            name: dependency.name.name,
                            urlString: dependency.url,
                            allVersionsTypes: [
                                .init(title: "branch", value: ExternalDependencyVersion.branch(name: "main")),
                                .init(title: "from", value: ExternalDependencyVersion.from(version: "1.0.0"))
                            ],
                            onSubmitVersionType: { updateVersion(for: dependency, version: $0) },
                            versionPlaceholder: versionPlaceholder(for: dependency),
                            versionTitle: dependency.version.title,
                            versionText: dependency.version.stringValue,
                            onSubmitVersionText: { store.updateVersionStringValueForRemoteDependency(withComponentName: selectedComponent.name, dependency: dependency, stringValue: $0) },
                            allDependencyTypes: [
                                .init(title: "Contract", subtitle: nil, value: TargetType.contract, subValue: nil),
                                .init(title: "Implementation", subtitle: "Tests", value: TargetType.implementation, subValue: .tests),
                                .init(title: "Mock", subtitle: nil, value: TargetType.mock, subValue: nil),
                            ].filter { allType in
                                dependencyTypes(for: dependency, component: selectedComponent).contains(where: { allType.value.id == $0.id })
                            },
                            enabledTypes: enabledDependencyTypes(for: dependency),
                            onUpdateDependencyType: { store.updateModuleTypeForRemoteDependency(withComponentName: selectedComponent.name, dependency: dependency, type: $0, value: $1) },
                            onRemove: { store.removeRemoteDependencyForSelectedComponent(withComponentName: selectedComponent.name, dependency: dependency) }
                        )
                    }
                }
            },
            allLibraryTypes: LibraryType.allCases,
            allModuleTypes: ModuleType.allCases,
            isModuleTypeOn: { selectedComponent.modules[$0] != nil },
            onModuleTypeSwitchedOn: { store.addModuleTypeForSelectedComponent(withName: selectedComponent.name, moduleType: $0) },
            onModuleTypeSwitchedOff: { store.removeModuleTypeForSelectedComponent(withName: selectedComponent.name, moduleType:$0) },
            moduleTypeTitle: { moduleTypeTitle(for: $0, component: selectedComponent) },
            onSelectionOfLibraryTypeForModuleType: { store.set(forComponentWithName: selectedComponent.name, libraryType: $0, forModuleType: $1) },
            onRemove: {
                guard let name = viewModel.selectedComponentName else { return }
                store.removeComponent(withName: name)
                viewModel.selectedComponentName = nil
            },
            allTargetTypes: allTargetTypes(forComponent: selectedComponent),
            onRemoveResourceWithId: { store.removeResource(withId: $0, forComponentWithName: selectedComponent.name) },
            onAddResourceWithName: { store.addResource($0, forComponentWithName: selectedComponent.name) },
            resourcesValueBinding: componentResourcesValueBinding(component: selectedComponent),
            showingDependencyPopover: Binding(get: { viewModel.showingDependencyPopover != nil }, set: { guard !$0 else { return }; viewModel.showingDependencyPopover = nil })
        )
        .frame(minWidth: 750)
    }

    func depedencyPopover(component: Component) -> some View {
        let filteredNames = Dictionary(grouping: store.allNames.filter { name in
            viewModel.selectedComponentName != name && !store.selectedComponent(withName: viewModel.selectedComponentName, containsDependencyWithName: name)
        }, by: { $0.family })
        let sections = filteredNames.reduce(into: [ComponentDependenciesListSection]()) { partialResult, keyValue in
            partialResult.append(ComponentDependenciesListSection(name: keyValue.key,
                                                                  rows: keyValue.value.map { name in
                ComponentDependenciesListRow(name: store.title(for: name),
                                             onSelect: { store.addDependencyToSelectedComponent(withName: viewModel.selectedComponentName, dependencyName: name) })
            }))
        }.sorted { lhs, rhs in
            lhs.name < rhs.name
        }
        return ComponentDependenciesPopover(
            sections: sections,
            onExternalSubmit: { remoteDependency in
                guard let selectedName = viewModel.selectedComponentName else { return }
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
                store.addRemoteDependencyToSelectedComponent(withName: selectedName, dependency: RemoteDependency(url: urlString,
                                                                                                                  name: name,
                                                                                                                  value: version))
            },
            onDismiss: { viewModel.showingDependencyPopover = nil }).frame(minWidth: 900, minHeight: 400)
    }

    // MARK: - Private
    
    private func componentName(_ component: Component, for family: Family) -> String {
        family.ignoreSuffix == true ? component.name.given : component.name.given + component.name.family
    }
    
    private func sectionTitle(forFamily family: Family) -> String {
        if let folder = family.folder {
            return folder
        }
        return familyFolderNameProvider.folderName(forFamily: family.name)
    }

    private func iOSPlatformMenuTitle(forComponent component: Component) -> String {
        if let iOSVersion = component.iOSVersion {
            return ".iOS(.\(iOSVersion))"
        } else {
            return "Add iOS"
        }
    }

    private func macOSPlatformMenuTitle(forComponent component: Component) -> String {
        if let macOSVersion = component.macOSVersion {
            return ".macOS(.\(macOSVersion))"
        } else {
            return "Add macOS"
        }
    }

    private func moduleTypeTitle(for moduleType: ModuleType, component: Component) -> String {
        if let libraryType = component.modules[moduleType] {
            return "\(libraryType)"
        } else {
            return "Add Type"
        }
    }

    private func componentTypes(for dependency: ComponentDependency, component: Component) -> [IdentifiableWithSubtypeAndSelection<TargetType, ModuleType>] {
        [
            .init(title: "Contract", subtitle: nil, value: .contract, subValue: nil, selectedValue: dependency.contract, selectedSubValue: nil),
            .init(title: "Implementation", subtitle: "Tests",
                  value: .implementation, subValue: .tests,
                  selectedValue: dependency.implementation, selectedSubValue: dependency.tests),
            .init(title: "Mock", subtitle: nil, value: .mock, subValue: nil, selectedValue: dependency.mock, selectedSubValue: nil),
        ].filter { value in
            component.modules.keys.contains { moduleType in
                switch (moduleType, value.value) {
                case (.contract, .contract),
                    (.implementation, .implementation),
                    (.mock, .mock):
                    return true
                default:
                    return false
                }
            }
        }
    }

    private func updateVersion(for dependency: RemoteDependency, version: ExternalDependencyVersion) {
        guard let name = viewModel.selectedComponentName else { return }
        store.updateVersionForRemoteDependency(withComponentName: name, dependency: dependency, version: version)
    }

    private func versionPlaceholder(for dependency: RemoteDependency) -> String {
        switch dependency.version {
        case .from:
            return "1.0.0"
        case .branch:
            return "main"
        }
    }

    private func dependencyTypes(for dependency: RemoteDependency, component: Component) -> [TargetType] {
        component.modules.keys.sorted().reduce(into: [TargetType](), { partialResult, moduleType in
            switch moduleType {
            case .contract:
                partialResult.append(TargetType.contract)
            case .implementation:
                partialResult.append(TargetType.implementation)
                partialResult.append(TargetType.tests)
            case .mock:
                partialResult.append(TargetType.mock)
            }
        })
    }

    private func enabledDependencyTypes(for dependency: RemoteDependency) -> [TargetType] {
        var types = [TargetType]()
        if dependency.contract {
            types.append(.contract)
        }
        if dependency.implementation {
            types.append(.implementation)
        }
        if dependency.tests {
            types.append(.tests)
        }
        if dependency.mock {
            types.append(.mock)
        }

        return types
    }

    private func componentResourcesValueBinding(component: Component) -> Binding<[DynamicTextFieldList<TargetResources.ResourcesType,
                                                                                  TargetType>.ValueContainer]> {
        Binding(get: {
            component.resources.map { resource -> DynamicTextFieldList<TargetResources.ResourcesType,
                                                                       TargetType>.ValueContainer in
                return .init(id: resource.id,
                             value: resource.folderName,
                             menuOption: resource.type,
                             targetTypes: resource.targets)
            }
        }, set: { store.updateResource($0.map {
            ComponentResources(id: $0.id, folderName: $0.value, type: $0.menuOption, targets: $0.targetTypes) }, forComponentWithName: component.name)
        })
    }

    private func allTargetTypes(forComponent component: Component) -> [IdentifiableWithSubtype<TargetType>] {
        [
            .init(title: "Contract", subtitle: nil, value: .contract, subValue: nil),
            .init(title: "Implementation", subtitle: "Tests",
                  value: .implementation, subValue: .tests),
            .init(title: "Mock", subtitle: nil, value: .mock, subValue: nil)
        ].filter { target in
            component.modules.keys.contains(where: { $0.rawValue == target.value.rawValue })
        }
    }
}
