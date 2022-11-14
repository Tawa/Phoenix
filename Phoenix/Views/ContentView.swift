import Component
import DemoAppFeature
import Factory
import PhoenixDocument
import PhoenixViews
import SwiftUI
import SwiftPackage
import AccessibilityIdentifiers

class ContentViewInteractor {
    func onRemoveComponent(with id: String, composition: Composition) {
        composition.deleteComponentUseCase().deleteComponent(with: id)
    }
}

struct ContentView: View {
    @EnvironmentObject var composition: Composition
    
    var fileURL: URL?
    @Binding var document: PhoenixDocument
    @StateObject var viewModel: ViewModel
    let interactor: ContentViewInteractor = .init()
    
    init(fileURL: URL?,
         document: Binding<PhoenixDocument>,
         viewModel: ViewModel) {
        self.fileURL = fileURL
        self._document = document
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            toolbarViews()
            Divider()
            HSplitView {
                componentsList()
                
                if let selectedComponentName = viewModel.selectedComponentName,
                   let selectedComponent = document.getComponent(withName: selectedComponentName) {
                    componentView(for: selectedComponent)
                        .sheet(isPresented: .constant(viewModel.showingDependencySheet)) {
                            dependencySheet(component: selectedComponent)
                        }
                        .sheet(isPresented: .constant(viewModel.showingRemoteDependencySheet)) {
                            remoteDependencySheet(component: selectedComponent)
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
            }.alert(item: $viewModel.alertState, content: { alertState in
                Alert(title: Text("Error"),
                      message: Text(alertState.title),
                      dismissButton: .default(Text("Ok")))
            }).sheet(item: .constant(viewModel.showingNewComponentPopup)) { state in
                newComponentSheet(state: state)
            }.sheet(isPresented: .constant(viewModel.selectedFamilyName != nil)) {
                FamilySheet(interactor: FamilySheetInteractor(selectFamilyUseCase: composition.selectFamilyUseCase()))
            }.sheet(isPresented: .constant(viewModel.showingConfigurationPopup)) {
                ConfigurationView(
                    interactor: composition.configurationViewInteractor(),
                    allDependenciesConfiguration: allDependenciesConfiguration(
                        defaultDependencies: document.projectConfiguration.defaultDependencies)
                ) {
                    viewModel.showingConfigurationPopup = false
                }.frame(minHeight: 800)
            }
            .sheet(item: $viewModel.demoAppFeatureData, content: { data in
                Container.demoAppFeatureView(data)
            })
            .sheet(isPresented: $viewModel.showingGenerateSheet,
                   onDismiss: viewModel.onDismissGenerateSheet,
                   content: {
                GenerateSheetView(
                    viewModel: GenerateSheetViewModel(
                        modulesPath: viewModel.modulesFolderURL?.path ?? "path/to/modules",
                        xcodeProjectPath: viewModel.xcodeProjectURL?.path ?? "path/to/Project.xcodeproj",
                        hasModulesPath: viewModel.modulesFolderURL != nil,
                        hasXcodeProjectPath: viewModel.xcodeProjectURL != nil,
                        isSkipXcodeProjectOn: viewModel.skipXcodeProject,
                        onOpenModulesFolder: { viewModel.onOpenModulesFolder(fileURL: fileURL) },
                        onOpenXcodeProject: { viewModel.onOpenXcodeProject(fileURL: fileURL) },
                        onSkipXcodeProject: viewModel.onSkipXcodeProject,
                        onGenerate: { viewModel.onGenerate(document: document, fileURL: fileURL) },
                        onDismiss: viewModel.onDismissGenerateSheet)
                )
            })
        }
        .onAppear {
            viewModel.checkForUpdate()
        }
    }
    
    // MARK: - Views
    func componentsList() -> some View {
        VStack {
            FilterView(interactor: composition.componentsFilterInteractor())
            ComponentsList(interactor: composition.componentsListInteractor())
        }
        .frame(minWidth: 250)
    }
    
    func componentView(for component: Component) -> some View {
        ComponentView(
            interactor: composition.componentViewInteractor(),
            defaultLocalization: component.defaultLocalization,
            onUpdateDefaultLocalization: { document.update(defaultLocalization: $0,
                                                           forComponentName: component.name) },
            platformsContent: { platformsContent(forComponent: component) },
            dependencies: component.dependencies,
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
            onModuleTypeSwitchedOn: { document.addModuleTypeForComponent(withName: component.name, moduleType: $0) },
            onModuleTypeSwitchedOff: { document.removeModuleTypeForComponent(withName: component.name, moduleType:$0) },
            moduleTypeTitle: { component.modules[$0]?.rawValue ?? "undefined" },
            onSelectionOfLibraryTypeForModuleType: { document.set(forComponentWithName: component.name, libraryType: $0, forModuleType: $1) },
            allDependenciesConfiguration: allDependenciesConfiguration(defaultDependencies: component.defaultDependencies),
            allDependenciesSelectionValues: allDependenciesSelectionValues(forComponent: component),
            onUpdateTargetTypeValue: {
                document.updateDefaultdependencyForComponent(
                    withName: component.name,
                    packageType: $0,
                    value: $1)
            },
            onGenerateDemoAppProject: {
                viewModel.onGenerateDemoProject(for: component, from: document, fileURL: fileURL)
            },
            onRemove: { interactor.onRemoveComponent(with: component.id, composition: composition) },
            allTargetTypes: allTargetTypes(forComponent: component),
            onRemoveResourceWithId: { document.removeResource(withId: $0, forComponentWithName: component.name) },
            onAddResourceWithName: { document.addResource($0, forComponentWithName: component.name) },
            onShowDependencySheet: { viewModel.showingDependencySheet = true },
            onShowRemoteDependencySheet: { viewModel.showingRemoteDependencySheet = true },
            resourcesValueBinding: componentResourcesValueBinding(component: component)
        )
        .frame(minWidth: 750)
    }
    
    func newComponentSheet(state: ComponentPopupState) -> some View {
        return NewComponentSheet(onSubmit: { name, familyName in
            let name = Name(given: name, family: familyName)
            switch state {
            case .new:
                try document.addNewComponent(withName: name)
            case let .template(component):
                try document.addNewComponent(withName: name, template: component)
            }
            viewModel.selectedComponentName = name
            viewModel.showingNewComponentPopup = nil
        }, onDismiss: {
            viewModel.showingNewComponentPopup = nil
        }, familyNameSuggestion: { familyName in
            guard !familyName.isEmpty else { return nil }
            return document.componentsFamilies.first { componentFamily in
                componentFamily.family.name.hasPrefix(familyName)
            }?.family.name
        })
    }
    
    func dependencySheet(component: Component) -> some View {
        let familyName = document.getFamily(withName: component.name.family)?.name ?? ""
        let allFamilies = document.componentsFamilies.filter { !$0.family.excludedFamilies.contains(familyName) }
        let allNames = allFamilies.flatMap(\.components).map(\.name)
        let filteredNames = Dictionary(grouping: allNames.filter { name in
            component.name != name && !component.dependencies.contains { componentDependencyType in
                guard case let .local(componentDependency) = componentDependencyType else { return false }
                return componentDependency.name == name
            }
        }, by: { $0.family })
        let sections = filteredNames.reduce(into: [ComponentDependenciesListSection]()) { partialResult, keyValue in
            partialResult.append(ComponentDependenciesListSection(name: keyValue.key,
                                                                  rows: keyValue.value.map { name in
                ComponentDependenciesListRow(name: document.title(for: name),
                                             onSelect: {
                    document.addDependencyToComponent(withName: component.name, dependencyName: name)
                    viewModel.showingDependencySheet = false
                })
            }))
        }.sorted { lhs, rhs in
            lhs.name < rhs.name
        }
        return ComponentDependenciesSheet(
            sections: sections,
            onDismiss: {
                viewModel.showingDependencySheet = false
            }).frame(minHeight: 600)
    }
    
    func remoteDependencySheet(component: Component) -> some View {
        RemoteDependencySheet(onExternalSubmit: { remoteDependency in
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
            document.addRemoteDependencyToComponent(withName: component.name, dependency: RemoteDependency(url: urlString,
                                                                                                           name: name,
                                                                                                           value: version))
            viewModel.showingRemoteDependencySheet = false
        }, onDismiss: { viewModel.showingRemoteDependencySheet = false })
    }
    
    func componentDependencyView(forComponent component: Component, dependency: ComponentDependency) -> some View {
        DependencyView<PackageTargetType, String>(
            title: document.title(for: dependency.name),
            onSelection: { viewModel.selectedComponentName = dependency.name },
            onRemove: { document.removeDependencyForComponent(withComponentName: component.name, componentDependency: dependency) },
            allTypes: componentTypes(for: dependency, component: component),
            allSelectionValues: allTargetTypes(forDependency: dependency).map { $0.title },
            onUpdateTargetTypeValue: { document.updateModuleTypeForDependency(withComponentName: component.name, dependency: dependency, type: $0, value: $1) })
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
            onSubmitVersionText: { document.updateVersionStringValueForRemoteDependency(withComponentName: component.name, dependency: dependency, stringValue: $0) },
            allDependencyTypes: allDependencyTypes(dependency: dependency, component: component),
            enabledTypes: enabledDependencyTypes(for: dependency, component: component),
            onUpdateDependencyType: { document.updateModuleTypeForRemoteDependency(withComponentName: component.name, dependency: dependency, type: $0, value: $1) },
            onRemove: { document.removeRemoteDependencyForComponent(withComponentName: component.name, dependency: dependency) }
        )
    }
    
    func platformsContent(forComponent component: Component) -> some View {
        Group {
            CustomMenu(title: iOSPlatformMenuTitle(forComponent: component),
                       data: IOSVersion.allCases,
                       onSelection: { document.setIOSVersionForComponent(withName: component.name, iOSVersion: $0) },
                       hasRemove: component.iOSVersion != nil,
                       onRemove: { document.removeIOSVersionForComponent(withName: component.name) })
            .frame(width: 150)
            CustomMenu(title: macOSPlatformMenuTitle(forComponent: component),
                       data: MacOSVersion.allCases,
                       onSelection: { document.setMacOSVersionForComponent(withName: component.name, macOSVersion: $0) },
                       hasRemove: component.macOSVersion != nil,
                       onRemove: { document.removeMacOSVersionForComponent(withName: component.name) })
            .frame(width: 150)
        }
    }
    
    @ViewBuilder
    private func toolbarViews() -> some View {
        VStack(alignment: .leading) {
            if let appUpdateVersion = viewModel.appUpdateVersionInfo {
                VStack(alignment: .leading) {
                    Text("Update v\(appUpdateVersion.version) is available.")
                        .font(.title)
                    Text("Release Notes: \(appUpdateVersion.releaseNotes)")
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Link(destination: URL(
                            string: "https://apps.apple.com/us/app/phoenix-app/id1626793172")!
                        ) {
                            Text("Update")
                        }
                        Button("Dismiss") {
                            withAnimation {
                                viewModel.appUpdateVersionInfo = nil
                            }
                        }.buttonStyle(.plain)
                    }
                }
                .padding([.leading, .top, .trailing])
            }
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
                    }
                    .keyboardShortcut(",", modifiers: [.command])
                    .with(accessibilityIdentifier: ToolbarIdentifiers.configurationButton)
                    Button(action: viewModel.onAddButton) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Component")
                    }
                    .keyboardShortcut("A", modifiers: [.command, .shift])
                    .with(accessibilityIdentifier: ToolbarIdentifiers.newComponentButton)
                    Spacer()
                    
                    Button(action: { viewModel.onGenerateSheetButton(fileURL: fileURL) }) {
                        Image(systemName: "shippingbox.fill")
                        Text("Generate")
                    }.keyboardShortcut(.init("R"), modifiers: .command)
                    Button(action: { viewModel.onGenerate(document: document, fileURL: fileURL) }) {
                        Image(systemName: "play")
                    }
                    .disabled(viewModel.modulesFolderURL == nil || viewModel.xcodeProjectURL == nil)
                    .keyboardShortcut(.init("R"), modifiers: [.command, .shift])
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
        }
    }
    
    // MARK: - Private
    
    private var filteredComponentsFamilies: [ComponentsFamily] {
        guard !viewModel.componentsListFilter.isEmpty else { return document.componentsFamilies }
        return document.componentsFamilies
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
        family.name == family.folder ? family.name : viewModel.folderName(forFamily: family.name)
    }
    
    private func sectionFolderName(forFamily family: Family) -> String? {
        let result = family.folder ?? viewModel.folderName(forFamily: family.name)
        guard result != family.name
        else { return nil }
        return result
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
        document.updateVersionForRemoteDependency(withComponentName: name, dependency: dependency, version: version)
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
        }, set: { document.updateResource($0.map {
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
        guard let component = document.getComponent(withName: dependency.name) else { return [] }
        return allTargetTypes(forComponent: component)
    }
    
    private func configurationTargetTypes() -> [IdentifiableWithSubtype<PackageTargetType>] {
        document.projectConfiguration.packageConfigurations.map { packageConfiguration in
            IdentifiableWithSubtype(title: packageConfiguration.name,
                                    subtitle: packageConfiguration.hasTests ? "Tests" : nil,
                                    value: PackageTargetType(name: packageConfiguration.name, isTests: false),
                                    subValue: packageConfiguration.hasTests ? PackageTargetType(name: packageConfiguration.name, isTests: true) : nil)
        }
    }
    
    private func onDownArrow() {
        composition.selectNextComponentUseCase().perform()
    }
    
    private func onUpArrow() {
        composition.selectPreviousComponentUseCase().perform()
    }
    
    func allDependenciesConfiguration(
        defaultDependencies: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] {
        let configuration = document.projectConfiguration
        return configuration.packageConfigurations.map { packageConfiguration in
            IdentifiableWithSubtypeAndSelection(
                title: packageConfiguration.name,
                subtitle: packageConfiguration.hasTests ? "Tests" : nil,
                value: PackageTargetType(name: packageConfiguration.name, isTests: false),
                subValue: packageConfiguration.hasTests ? PackageTargetType(name: packageConfiguration.name, isTests: true) : nil,
                selectedValue: defaultDependencies[PackageTargetType(name: packageConfiguration.name, isTests: false)],
                selectedSubValue: defaultDependencies[PackageTargetType(name: packageConfiguration.name, isTests: true)])
        }
    }
    
    func allDependenciesSelectionValues() -> [String] {
        document.projectConfiguration.packageConfigurations.map(\.name)
    }
    
    func allDependenciesSelectionValues(forComponent component: Component) -> [String] {
        component.modules.map(\.key).sorted()
    }
}
