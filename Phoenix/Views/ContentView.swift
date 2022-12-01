import AppVersionProviderContract
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
    private var composition: Composition { viewModel.composition }
    
    var fileURL: URL?
    @Binding var document: PhoenixDocument
    @StateObject var viewModel: ViewModel
    let interactor: ContentViewInteractor = .init()
    
    init(fileURL: URL?,
         document: Binding<PhoenixDocument>,
         composition: Composition) {
        self.fileURL = fileURL
        self._document = document
        self._viewModel = .init(wrappedValue: .init(composition: composition))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            splitView(componentsList, detail: detailView)
                .alert(item: $viewModel.alertState, content: { alertState in
                    Alert(title: Text("Error"),
                          message: Text(alertState.title),
                          dismissButton: .default(Text("Ok")))
                }).sheet(item: .constant(viewModel.showingNewComponentPopup)) { state in
                    newComponentSheet(state: state)
                }.sheet(isPresented: .constant(viewModel.selectedFamilyName != nil)) {
                    FamilySheet(
                        getSelectedFamilyUseCase: composition.getSelectedFamilyUseCase(),
                        getFamilySheetDataUseCase: composition.getFamilySheetDataUseCase(),
                        selectFamilyUseCase: composition.selectFamilyUseCase()
                    )
                }.sheet(isPresented: .constant(viewModel.showingConfigurationPopup)) {
                    ConfigurationView(getProjectConfigurationUseCase: composition.getProjectConfigurationUseCase()) {
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
                .popover(item: $viewModel.showingUpdatePopup) { showingUpdatePopup in
                    updateView(appVersionInfo: showingUpdatePopup)
                }
        }
        .onAppear(perform: viewModel.checkForUpdate)
        .toolbar(content: toolbarViews)
        .frame(minWidth: 900)
        .environmentObject(viewModel.composition)
    }
    
    // MARK: - Views
    @ViewBuilder private func splitView<Sidebar: View, Detail: View>(_ sidebar: () -> Sidebar, detail: () -> Detail) -> some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView(sidebar: sidebar, detail: detailView)
                .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: nil)
        } else {
            HSplitView {
                sidebar()
                detail()
            }
        }
    }
    
    @ViewBuilder private func componentsList() -> some View {
        ZStack {
            Button(action: onUpArrow, label: {})
                .opacity(0)
                .keyboardShortcut(.upArrow, modifiers: [])
            Button(action: onDownArrow, label: {})
                .opacity(0)
                .keyboardShortcut(.downArrow, modifiers: [])
            VStack {
                FilterView(text: composition.getComponentsFilterUseCase().binding)
                ComponentsList(sections: viewModel.componentsListSections)
            }
        }
        .frame(minWidth: 250)
            
    }
    
    @ViewBuilder private func detailView() -> some View {
        if let selectedComponentName = viewModel.selectedComponentName,
           composition.getSelectedComponentUseCase().value.name != .empty,
           let selectedComponent = document.getComponent(withName: selectedComponentName),
           selectedComponent.name != .empty {
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
            }
        }
    }
    
    @ViewBuilder private func componentView(for component: Component) -> some View {
        ComponentView(
            getComponentTitleUseCase: composition.getComponentTitleUseCase(),
            getSelectedComponentUseCase: composition.getSelectedComponentUseCase(),
            onGenerateDemoAppProject: {
                viewModel.onGenerateDemoProject(for: component, from: document, fileURL: fileURL)
            },
            onRemove: { interactor.onRemoveComponent(with: component.id, composition: composition) },
            allTargetTypes: allTargetTypes(forComponent: component),
            allModuleTypes: composition.getProjectConfigurationUseCase().value.packageConfigurations.map(\.name),
            onShowDependencySheet: { viewModel.showingDependencySheet = true },
            onShowRemoteDependencySheet: { viewModel.showingRemoteDependencySheet = true }
        )
    }
    
    @ViewBuilder private func newComponentSheet(state: ComponentPopupState) -> some View {
        NewComponentSheet(onSubmit: { name, familyName in
            let name = Name(given: name, family: familyName)
            switch state {
            case .new:
                try document.addNewComponent(withName: name)
            case let .template(component):
                try document.addNewComponent(withName: name, template: component)
            }
            viewModel.selectedComponentName = name
            viewModel.reloadComponentsList()
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
    
    @ViewBuilder private func dependencySheet(component: Component) -> some View {
        let familyName = document.getFamily(withName: component.name.family)?.name ?? ""
        let allFamilies = document.componentsFamilies.filter { !$0.family.excludedFamilies.contains(familyName) }
        let allNames = allFamilies.flatMap(\.components).map(\.name)
        let filteredNames = Dictionary(grouping: allNames.filter { name in
            component.name != name && !component.localDependencies.contains { localDependency in
                localDependency.name == name
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
        ComponentDependenciesSheet(
            sections: sections,
            onDismiss: {
                viewModel.showingDependencySheet = false
            }).frame(minHeight: 600)
    }
    
    @ViewBuilder private func remoteDependencySheet(component: Component) -> some View {
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
    
    @ViewBuilder private func toolbarViews() -> some View {
        toolbarLeadingItems()
        Spacer()
        toolbarTrailingItems()
    }
    
    @ViewBuilder private func toolbarLeadingItems() -> some View {
        if let appUpdateVerdsionInfo = viewModel.appUpdateVersionInfo {
            Button(action: viewModel.onUpdateButton) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.red)
                Text("Update \(appUpdateVerdsionInfo.version) Available")
            }
        }
        
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
    }

    @ViewBuilder private func toolbarTrailingItems() -> some View {
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
    
    @ViewBuilder private func updateView(appVersionInfo: AppVersionInfo) -> some View {
        VStack(alignment: .leading) {
            Text("Update v\(appVersionInfo.version) is available.")
                .font(.title)
            Text("Release Notes: \(appVersionInfo.releaseNotes)")
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
                        viewModel.showingUpdatePopup = nil
                    }
                }.buttonStyle(.plain)
            }
        }.padding()
    }
    
    // MARK: - Private
    private func allTargetTypes(forComponent component: Component) -> [IdentifiableWithSubtype<PackageTargetType>] {
        configurationTargetTypes().filter { target in
            component.modules.keys.contains(where: { $0.lowercased() == target.value.name.lowercased() })
        }
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
}
