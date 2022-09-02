import Package
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ViewModel = .init()
    @EnvironmentObject private var store: PhoenixDocumentStore
    private let familyFolderNameProvider: FamilyFolderNameProviderProtocol = FamilyFolderNameProvider()

    var body: some View {
        HSplitView {
            componentsList()

            if let selectedComponentName = viewModel.selectedComponentName,
               let selectedComponent = store.getComponent(withName: selectedComponentName) {
                componentView(for: selectedComponent)
                    .sheet(isPresented: .constant(viewModel.showingDependencyPopover)) {
                        dependencyPopover(component: selectedComponent)
                    }
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
        }.sheet(item: .constant(viewModel.showingNewComponentPopup)) { state in
            newComponentPopover(state: state)
        }.sheet(item: .constant(store.getFamily(withName: viewModel.selectedFamilyName ?? ""))) { family in
            familyPopover(family: family)
        }.sheet(isPresented: .constant(viewModel.showingConfigurationPopup)) {
            ConfigurationView(configuration: store.document.projectConfiguration) {
                viewModel.showingConfigurationPopup = false
            }.frame(minHeight: 300)
        }
        .alert(item: $viewModel.alertState, content: { alertState in
            Alert(title: Text("Error"),
                  message: Text(alertState.title),
                  dismissButton: .default(Text("Ok")))
        })
        .toolbar {
            toolbarViews()
        }
    }

    // MARK: - Views
    func componentsList() -> some View {
        ComponentsList(
            filter: $viewModel.componentsListFilter,
            sections: filteredComponentsFamilies
                .map { componentsFamily in
                        .init(name: sectionTitle(forFamily: componentsFamily.family),
                              rows: componentsFamily.components.map { component in
                                .init(name: componentName(component, for: componentsFamily.family),
                                      isSelected: viewModel.selectedComponentName == component.name,
                                      onSelect: { viewModel.selectedComponentName = component.name },
                                      onDuplicate: { viewModel.onDuplicate(component: component) })
                        },
                              onSelect: { viewModel.selectedFamilyName = componentsFamily.family.name })
                }
        )
        .frame(minWidth: 250)
    }

    func componentView(for component: Component) -> some View {
        ComponentView(
            title: store.title(for: component.name),
            platformsContent: { platformsContent(forComponent: component) },
            dependencies: component.dependencies.sorted(),
            dependencyView: { dependencyType in
                VStack(spacing: 0) {
                    Divider()
                    switch dependencyType {
                    case let .local(dependency):
                        componentDependencyView(forComponent: component, dependency: dependency)
                    case let .remote(dependency):
                        remoteDependencyView(forComponent: component, dependency: dependency)
                    }
                }
            },
            allLibraryTypes: LibraryType.allCases,
            allModuleTypes: configurationTargetTypes().map { $0.title },
            isModuleTypeOn: { component.modules[$0] != nil },
            onModuleTypeSwitchedOn: { store.addModuleTypeForComponent(withName: component.name, moduleType: $0) },
            onModuleTypeSwitchedOff: { store.removeModuleTypeForComponent(withName: component.name, moduleType:$0) },
            moduleTypeTitle: { component.modules[$0]?.rawValue ?? "undefined" },
            onSelectionOfLibraryTypeForModuleType: { store.set(forComponentWithName: component.name, libraryType: $0, forModuleType: $1) },
            onGenerateDemoAppProject: { viewModel.onGenerateDemoProject(for: component, from: store.document.wrappedValue, ashFileURL: store.fileURL) },
            onRemove: {
                guard let name = viewModel.selectedComponentName else { return }
                store.removeComponent(withName: name)
                viewModel.selectedComponentName = nil
            },
            allTargetTypes: allTargetTypes(forComponent: component),
            onRemoveResourceWithId: { store.removeResource(withId: $0, forComponentWithName: component.name) },
            onAddResourceWithName: { store.addResource($0, forComponentWithName: component.name) },
            onShowDependencyPopover: { viewModel.showingDependencyPopover = true },
            resourcesValueBinding: componentResourcesValueBinding(component: component)
        )
        .frame(minWidth: 750)
    }

    func newComponentPopover(state: ComponentPopupState) -> some View {
        return NewComponentPopover(onSubmit: { name, familyName in
            let name = Name(given: name, family: familyName)
            switch state {
            case .new:
                try store.addNewComponent(withName: name)
            case let .template(component):
                try store.addNewComponent(withName: name, template: component)
            }
            viewModel.selectedComponentName = name
            viewModel.showingNewComponentPopup = nil
        }, onDismiss: {
            viewModel.showingNewComponentPopup = nil
        }, familyNameSuggestion: { familyName in
            guard !familyName.isEmpty else { return nil }
            return store.componentsFamilies.first { componentFamily in
                componentFamily.family.name.lowercased().hasPrefix(familyName.lowercased())
            }?.family.name
        })
    }

    func dependencyPopover(component: Component) -> some View {
        let filteredNames = Dictionary(grouping: store.allNames.filter { name in
            component.name != name && !component.dependencies.contains { componentDependencyType in
                guard case let .local(componentDependency) = componentDependencyType else { return false }
                return componentDependency.name == name
            }
        }, by: { $0.family })
        let sections = filteredNames.reduce(into: [ComponentDependenciesListSection]()) { partialResult, keyValue in
            partialResult.append(ComponentDependenciesListSection(name: keyValue.key,
                                                                  rows: keyValue.value.map { name in
                ComponentDependenciesListRow(name: store.title(for: name),
                                             onSelect: {
                    store.addDependencyToComponent(withName: component.name, dependencyName: name)
                    viewModel.showingDependencyPopover = false
                })
            }))
        }.sorted { lhs, rhs in
            lhs.name < rhs.name
        }
        return ComponentDependenciesPopover(
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
                case .exact:
                    version = .exact(version: remoteDependency.versionValue)
                }
                store.addRemoteDependencyToComponent(withName: component.name, dependency: RemoteDependency(url: urlString,
                                                                                                            name: name,
                                                                                                            value: version))
                viewModel.showingDependencyPopover = false
            },
            onDismiss: {
                viewModel.showingDependencyPopover = false
            }).frame(minWidth: 900, minHeight: 400)
    }

    func familyPopover(family: Family) -> some View {
        return FamilyPopover(name: family.name,
                             ignoreSuffix: family.ignoreSuffix,
                             onUpdateSelectedFamily: { store.updateFamily(withName: family.name, ignoresSuffix: !$0) },
                             folderName: family.folder ?? "",
                             onUpdateFolderName: { store.updateFamily(withName: family.name, folder: $0) },
                             defaultFolderName: familyFolderNameProvider.folderName(forFamily: family.name),
                             componentNameExample: "Component\(family.ignoreSuffix ? "" : family.name)",
                             onDismiss: { viewModel.selectedFamilyName = nil })
    }

    func componentDependencyView(forComponent component: Component, dependency: ComponentDependency) -> some View {
        DependencyView<PackageTargetType, String>(
            title: store.title(for: dependency.name),
            onSelection: { viewModel.selectedComponentName = dependency.name },
            onRemove: { store.removeDependencyForComponent(withComponentName: component.name, componentDependency: dependency) },
            allTypes: componentTypes(for: dependency, component: component),
            allSelectionValues: allTargetTypes(forDependency: dependency).map { $0.title },
            onUpdateTargetTypeValue: { store.updateModuleTypeForDependency(withComponentName: component.name, dependency: dependency, type: $0, value: $1) })
    }

    func remoteDependencyView(forComponent component: Component, dependency: RemoteDependency) -> some View {
        RemoteDependencyView(
            name: dependency.name.name,
            urlString: dependency.url,
            allVersionsTypes: [
                .init(title: "branch", value: ExternalDependencyVersion.branch(name: "main")),
                .init(title: "exact", value: ExternalDependencyVersion.exact(version: "1.0.0")),
                .init(title: "from", value: ExternalDependencyVersion.from(version: "1.0.0"))
            ],
            onSubmitVersionType: { updateVersion(for: dependency, version: $0) },
            versionPlaceholder: versionPlaceholder(for: dependency),
            versionTitle: dependency.version.title,
            versionText: dependency.version.stringValue,
            onSubmitVersionText: { store.updateVersionStringValueForRemoteDependency(withComponentName: component.name, dependency: dependency, stringValue: $0) },
            allDependencyTypes: allDependencyTypes(dependency: dependency, component: component),
            enabledTypes: enabledDependencyTypes(for: dependency, component: component),
            onUpdateDependencyType: { store.updateModuleTypeForRemoteDependency(withComponentName: component.name, dependency: dependency, type: $0, value: $1) },
            onRemove: { store.removeRemoteDependencyForComponent(withComponentName: component.name, dependency: dependency) }
        )
    }

    func platformsContent(forComponent component: Component) -> some View {
        Group {
            CustomMenu(title: iOSPlatformMenuTitle(forComponent: component),
                       data: IOSVersion.allCases,
                       onSelection: { store.setIOSVersionForComponent(withName: component.name, iOSVersion: $0) },
                       hasRemove: component.iOSVersion != nil,
                       onRemove: { store.removeIOSVersionForComponent(withName: component.name) })
            .frame(width: 150)
            CustomMenu(title: macOSPlatformMenuTitle(forComponent: component),
                       data: MacOSVersion.allCases,
                       onSelection: { store.setMacOSVersionForComponent(withName: component.name, macOSVersion: $0) },
                       hasRemove: component.macOSVersion != nil,
                       onRemove: { store.removeMacOSVersionForComponent(withName: component.name) })
            .frame(width: 150)
        }
    }

    @ViewBuilder
    private func toolbarViews() -> some View {
        //            Button(action: viewModel.onAddAll, label: { Text("Add everything in the universe") })
        ZStack {
            Button(action: onUpArrow, label: {})
                .opacity(0)
                .keyboardShortcut(.upArrow, modifiers: [])
            Button(action: onDownArrow, label: {})
                .opacity(0)
                .keyboardShortcut(.downArrow, modifiers: [])

            HStack {
                Button(action: viewModel.onConfigurationButton) {
                    Image(systemName: "wrench.and.screwdriver")
                    Text("Configuration")
                }.keyboardShortcut(",", modifiers: [.command])
                Spacer()
                Button(action: viewModel.onAddButton) {
                    Image(systemName: "plus.circle.fill")
                    Text("New Component")
                }.keyboardShortcut("A", modifiers: [.command, .shift])
                Button(action: { viewModel.onGenerate(document: store.document.wrappedValue, withFileURL: store.fileURL) }) {
                    Image(systemName: "shippingbox.fill")
                    Text("Generate")
                }.keyboardShortcut(.init("R"), modifiers: .command)
                Button(action: { viewModel.onSyncPBXProj(for: store.document.wrappedValue, ashFileURL: store.fileURL) }) {
                    Image(systemName: "arrow.clockwise")
                    Text("Sync Xcode Project")
                }.keyboardShortcut(.init("R"), modifiers: [.command, .shift])
            }
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Private

    private var filteredComponentsFamilies: [ComponentsFamily] {
        guard !viewModel.componentsListFilter.isEmpty else { return store.componentsFamilies }
        return store.componentsFamilies
            .map { componentsFamily in
                ComponentsFamily(family: componentsFamily.family,
                                 components: componentsFamily.components.filter {
                    componentName($0, for: componentsFamily.family)
                        .lowercased().contains(viewModel.componentsListFilter.lowercased())
                })
            }.filter { !$0.components.isEmpty }

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

    private func componentTypes(for dependency: ComponentDependency, component: Component) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] {
        allTargetTypes(forComponent: component).compactMap { targetType -> IdentifiableWithSubtypeAndSelection<PackageTargetType, String>? in
            let selectedValue = dependency.targetTypes[targetType.value]
            let selectedSubValue: String? = targetType.subValue.flatMap { dependency.targetTypes[$0] }

            return IdentifiableWithSubtypeAndSelection<PackageTargetType, String>(
                title: targetType.title,
                subtitle: targetType.subtitle,
                value: targetType.value,
                subValue: targetType.subValue,
                selectedValue: selectedValue,
                selectedSubValue: selectedSubValue)
        }
    }

    private func updateVersion(for dependency: RemoteDependency, version: ExternalDependencyVersion) {
        guard let name = viewModel.selectedComponentName else { return }
        store.updateVersionForRemoteDependency(withComponentName: name, dependency: dependency, version: version)
    }

    private func versionPlaceholder(for dependency: RemoteDependency) -> String {
        switch dependency.version {
        case .from, .exact:
            return "1.0.0"
        case .branch:
            return "main"
        }
    }

    private func enabledDependencyTypes(for dependency: RemoteDependency, component: Component) -> [PackageTargetType] {
        allTargetTypes(forComponent: component).filter { dependency.targetTypes.contains($0.value) }.map { $0.value }
    }

    private func componentResourcesValueBinding(component: Component) -> Binding<[DynamicTextFieldList<TargetResources.ResourcesType,
                                                                                  PackageTargetType>.ValueContainer]> {
        Binding(get: {
            component.resources.map { resource -> DynamicTextFieldList<TargetResources.ResourcesType,
                                                                       PackageTargetType>.ValueContainer in
                return .init(id: resource.id,
                             value: resource.folderName,
                             menuOption: resource.type,
                             targetTypes: resource.targets)
            }
        }, set: { store.updateResource($0.map {
            return ComponentResources(id: $0.id, folderName: $0.value, type: $0.menuOption, targets: $0.targetTypes) }, forComponentWithName: component.name)
        })
    }


    private func allDependencyTypes(dependency: RemoteDependency, component: Component) -> [IdentifiableWithSubtype<PackageTargetType>] {
        allTargetTypes(forComponent: component)
    }

    private func allTargetTypes(forComponent component: Component) -> [IdentifiableWithSubtype<PackageTargetType>] {
        configurationTargetTypes().filter { target in
            component.modules.keys.contains(where: { $0.lowercased() == target.value.name.lowercased() })
        }
    }

    private func allTargetTypes(forDependency dependency: ComponentDependency) -> [IdentifiableWithSubtype<PackageTargetType>] {
        guard let component = store.getComponent(withName: dependency.name) else { return [] }
        return allTargetTypes(forComponent: component)
    }

    private func configurationTargetTypes() -> [IdentifiableWithSubtype<PackageTargetType>] {
        store.document.wrappedValue.projectConfiguration.packageConfigurations.map { packageConfiguration in
            IdentifiableWithSubtype(title: packageConfiguration.name,
                                    subtitle: packageConfiguration.hasTests ? "Tests" : nil,
                                    value: PackageTargetType(name: packageConfiguration.name, isTests: false),
                                    subValue: packageConfiguration.hasTests ? PackageTargetType(name: packageConfiguration.name, isTests: true) : nil)
        }
    }

    private func onDownArrow() {
        let allNames = filteredComponentsFamilies.flatMap(\.components).map(\.name)
        if let selectedComponentName = viewModel.selectedComponentName,
           let index = allNames.firstIndex(of: selectedComponentName),
           index < allNames.count - 1 {
            viewModel.selectedComponentName = allNames[index+1]
        } else {
            viewModel.selectedComponentName = allNames.first
        }
    }

    private func onUpArrow() {
        let allNames = filteredComponentsFamilies.flatMap(\.components).map(\.name)
        if let selectedComponentName = viewModel.selectedComponentName,
           let index = allNames.firstIndex(of: selectedComponentName),
           index > 0 {
            viewModel.selectedComponentName = allNames[index-1]
        } else {
            viewModel.selectedComponentName = allNames.last
        }
    }
}
