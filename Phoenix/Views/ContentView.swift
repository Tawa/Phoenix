import AccessibilityIdentifiers
import AppVersionProviderContract
import DemoAppFeature
import Factory
import PhoenixDocument
import GenerateFeature
import SwiftUI
import SwiftPackage
import ValidationFeature

enum ListSelection: String, Hashable, CaseIterable, Identifiable {
    static var allCases: [ListSelection] { [.components, .remote] }
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .components:
            return "1"
        case .remote:
            return "2"
        case .plugins:
            return "3"
        }
    }
    
    case components
    case remote
    case plugins
}

enum InspectorSelection: String, Hashable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case none
    case mentions
    
    mutating func toggle() {
        switch self {
        case .none:
            self = .mentions
        case .mentions:
            self = .none
        }
    }
}

struct ContentView: View {
    var fileURL: URL?
    @Binding var document: PhoenixDocument
    @StateObject var viewModel: ViewModel = .init()
    
    @State private var listSelection: ListSelection = .components
    @State private var inspectorSelection: InspectorSelection = .none
    
    init(fileURL: URL?,
         document: Binding<PhoenixDocument>) {
        self.fileURL = fileURL
        self._document = document
    }
    
    var body: some View {
        splitView(sidebar: sideView, content: contentView)
            .sheet(item: .constant(viewModel.showingNewComponentPopup)) { state in
                newComponentSheet(state: state)
            }.sheet(item: .constant(viewModel.selectedFamily(document: $document))) { family in
                FamilySheet(family: family,
                            relationViewData: document.familyRelationViewData(familyName: family.wrappedValue.name),
                            rules: viewModel.allRules(for: family.wrappedValue, document: document),
                            onDismiss: { viewModel.select(familyName: nil) }
                )
            }.sheet(isPresented: .constant(viewModel.showingConfigurationPopup)) {
                ConfigurationView(
                    configuration: $document.projectConfiguration,
                    relationViewData: document.projectConfigurationRelationViewData()
                ) {
                    viewModel.showingConfigurationPopup = false
                }.frame(minHeight: 800)
            }
            .sheet(item: $viewModel.demoAppFeatureData, content: { data in
                Container.demoAppFeatureView(data)
            })
            .sheet(isPresented: $viewModel.showingQuickSelectionSheet, content: {
                QuickSelectionSheet(rows: viewModel.quickSelectionRows(document: document))
            })
            .popover(item: $viewModel.showingUpdatePopup) { showingUpdatePopup in
                updateView(appVersionInfo: showingUpdatePopup)
            }
            .alertSheet(model: $viewModel.alertSheetState)
            .onAppear(perform: viewModel.checkForUpdate)
            .toolbar(content: toolbarViews)
            .frame(minWidth: 900)
    }
    
    // MARK: - Views
    @ViewBuilder private func splitView<Sidebar: View, Content: View>(
        sidebar: @escaping () -> Sidebar,
        content: @escaping () -> Content
    ) -> some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView(sidebar: sidebar, detail: content)
        } else {
            HSplitView {
                sidebar()
                content()
            }
        }
    }
    
    @ViewBuilder private func sideView() -> some View {
        ZStack {
            Button(action: onUpArrow, label: {})
                .opacity(0)
                .keyboardShortcut(.upArrow, modifiers: [])
            Button(action: onDownArrow, label: {})
                .opacity(0)
                .keyboardShortcut(.downArrow, modifiers: [])
            Button(action: { viewModel.showingQuickSelectionSheet = true }, label: {})
                .opacity(0)
                .keyboardShortcut("O", modifiers: [.command, .shift])
            if ListSelection.allCases.count > 1 {
                ForEach(ListSelection.allCases) { selection in
                    Button(action: { listSelection = selection }, label: {})
                        .opacity(0)
                        .keyboardShortcut(selection.keyboardShortcut, modifiers: .command)
                }
            }
            
            VStack {
                if ListSelection.allCases.count > 1 {
                    Picker("", selection: $listSelection) {
                        ForEach(ListSelection.allCases) { selection in
                            Text(selection.title)
                                .tag(selection)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.leading, 8)
                    .padding(.trailing, 16)
                    .foregroundColor(.accentColor)
                }
                
                switch listSelection {
                case .components:
                    componentsList()
                case .remote:
                    remoteComponentsList()
                case .plugins:
                    pluginsList()
                }
                FilterView(text: $viewModel.componentsListFilter.nonOptionalBinding)
            }
        }
        .frame(minWidth: 250)
    }
    
    @ViewBuilder private func componentsList() -> some View {
        VStack(alignment: .leading) {
            Button(action: viewModel.onAddButton) {
                Label("New Component", systemImage: "plus.circle.fill")
            }
            .keyboardShortcut("A", modifiers: [.command, .shift])
            .with(accessibilityIdentifier: ToolbarIdentifiers.newComponentButton)
            .padding(.horizontal)
            ComponentsList(
                sections: viewModel.componentsListSections(document: document),
                footerText: viewModel.numberOfComponentsAndPackagesText(document: document),
                onSelect: viewModel.select(componentName:),
                onSelectSection: viewModel.select(familyName:)
            )
        }
    }
    
    @ViewBuilder private func remoteComponentsList() -> some View {
        VStack(alignment: .leading) {
            Button(action: viewModel.onAddRemoteButton) {
                Label("New Remote Dependency", systemImage: "plus.circle.fill")
            }
            .keyboardShortcut("A", modifiers: [.command, .shift])
            .with(accessibilityIdentifier: ToolbarIdentifiers.newRemoteComponentButton)
            .padding(.horizontal)
            RemoteComponentsList(
                rows: viewModel.remoteComponentsListRows(document: document),
                onSelect: viewModel.select(remoteComponentURL:)
            )
        }
    }
    
    @ViewBuilder private func pluginsList() -> some View {
        VStack(alignment: .leading) {
            Button(action: viewModel.onAddButton) {
                Label("New Plugin", systemImage: "plus.circle.fill")
            }
            .keyboardShortcut("A", modifiers: [.command, .shift])
            .with(accessibilityIdentifier: ToolbarIdentifiers.newComponentButton)
            .padding(.horizontal)
            ScrollView {
                
            }
            Spacer()
        }
    }
    
    @ViewBuilder private func contentView() -> some View {
        HSplitView {
            Group {
                if let selectedComponentBinding = viewModel.selectedComponent(document: $document) {
                    componentView(for: selectedComponentBinding)
                        .sheet(isPresented: .constant(viewModel.showingDependencySheet)) {
                            dependencySheet(component: selectedComponentBinding.wrappedValue)
                        }
                        .sheet(isPresented: .constant(viewModel.showingRemoteDependencySheet)) {
                            remoteDependencySheet(component: selectedComponentBinding.wrappedValue)
                        }
                } else if let selectedRemoteComponentBinding = viewModel.selectedRemoteComponent(document: $document) {
                    remoteComponentView(for: selectedRemoteComponentBinding)
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
            .frame(minWidth: 700)
            detailView()
                .frame(minWidth: 200)
        }
    }
    
    @ViewBuilder private func componentView(for component: Binding<Component>) -> some View {
        ComponentView(
            component: component,
            remoteDependencies: document.remoteComponents.reduce(into: [String: RemoteComponent](), { partialResult, remoteComponent in
                partialResult[remoteComponent.url] = remoteComponent
            }),
            relationViewData: document.componentRelationViewData(componentName: component.wrappedValue.name),
            relationViewDataToComponentNamed: { dependencyName, selectedValues in
                document.relationViewData(fromComponentName: component.wrappedValue.name,
                                          toComponentName: dependencyName,
                                          selectedValues: selectedValues)
            },
            titleForComponentNamed: document.title(forComponentNamed:),
            onGenerateDemoAppProject: {
                viewModel.onGenerateDemoProject(for: component.wrappedValue, from: document, fileURL: fileURL)
            },
            onRemove: { document.removeComponent(withName: component.wrappedValue.name) },
            allTargetTypes: allTargetTypes(forComponent: component.wrappedValue),
            onShowDependencySheet: { viewModel.showingDependencySheet = true },
            onShowRemoteDependencySheet: { viewModel.showingRemoteDependencySheet = true },
            onSelectComponentName: viewModel.select(componentName:),
            onSelectRemoteURL: viewModel.select(remoteComponentURL:),
            allModuleTypes: document.projectConfiguration.packageConfigurations.map(\.name)
        )
    }
    
    @ViewBuilder private func remoteComponentView(for remoteComponent: Binding<RemoteComponent>) -> some View {
        RemoteComponentView(
            remoteComponent: remoteComponent,
            onRemove: { document.removeRemoteComponent(withURL: remoteComponent.wrappedValue.url) }
        )
    }
    
    @ViewBuilder private func detailView() -> some View {
        if inspectorSelection == .none || viewModel.selection == nil {
            EmptyView()
        } else {
            MentionsView(
                mentions: mentionsViewMentions(),
                title: mentionsViewTitle(),
                titleForComponentNamed: document.title(forComponentNamed:),
                onSelectComponentName: viewModel.select(componentName:)
            )
        }
    }
    
    private func mentionsViewTitle() -> String {
        switch viewModel.selection {
        case let .component(name):
            return document.title(forComponentNamed: name)
        case let .remoteComponent(url):
            return url
        case .none:
            return ""
        }
    }
    
    private func mentionsViewMentions() -> [Name] {
        switch viewModel.selection {
        case let .component(name):
            return document.mentions(forName: name)
        case let .remoteComponent(url):
            return document.mentions(forURL: url)
        case .none:
            return []
        }
    }
    
    @ViewBuilder private func newComponentSheet(state: ComponentPopupState) -> some View {
        switch state {
        case .new:
            NewComponentSheet(onSubmit: { name, familyName in
                let name = Name(given: name, family: familyName)
                try document.addNewComponent(withName: name)
                viewModel.select(componentName: name)
                viewModel.showingNewComponentPopup = nil
            }, onDismiss: {
                viewModel.showingNewComponentPopup = nil
            }, familyNameSuggestion: { familyName in
                guard !familyName.isEmpty else { return nil }
                return document.families.first { componentFamily in
                    componentFamily.family.name.hasPrefix(familyName)
                }?.family.name
            })
            
        case .remote:
            NewRemoteComponentSheet { url, version in
                try document.addNewRemoteComponent(withURL: url, version: version)
                viewModel.showingNewComponentPopup = nil
            } onDismiss: {
                viewModel.showingNewComponentPopup = nil
            }
        }
    }
    
    @ViewBuilder private func dependencySheet(component: Component) -> some View {
        let familyName = document.family(named: component.name.family)?.name ?? ""
        let allFamilies = document.families.filter { !$0.family.excludedFamilies.contains(familyName) }
        let allNames = allFamilies.flatMap(\.components).map(\.name)
        let filteredNames = Dictionary(grouping: allNames.filter { name in
            component.name != name && !component.localDependencies.contains { localDependency in
                localDependency.name == name
            }
        }, by: { $0.family })
        let sections = filteredNames.reduce(into: [ComponentDependenciesListSection]()) { partialResult, keyValue in
            partialResult.append(ComponentDependenciesListSection(name: keyValue.key,
                                                                  rows: keyValue.value.map { name in
                ComponentDependenciesListRow(name: document.title(forComponentNamed: name),
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
        RemoteComponentDependenciesSheet(
            rows: document.remoteComponents.filter { remoteComponent in
                !component.remoteComponentDependencies.contains { remoteComponentDependency in
                    remoteComponent.url == remoteComponentDependency.url
                }
            },
            onSelect: { remoteComponent in
                document.addRemoteDependencyToComponent(withName: component.name, dependencyURL: remoteComponent.url)
                viewModel.showingRemoteDependencySheet = false
            },
            onDismiss: { viewModel.showingRemoteDependencySheet = false }
        )
    }
    
    @ViewBuilder private func toolbarViews() -> some View {
        toolbarLeadingItems()
        Spacer()
        toolbarTrailingItems()
    }
    
    @ViewBuilder private func toolbarLeadingItems() -> some View {
        Button(action: viewModel.undoSelection) {
            Image(systemName: "chevron.left")
        }
        .keyboardShortcut("[", modifiers: [.command])
        .disabled(viewModel.undoSelectionDisabled)
        Button(action: viewModel.redoSelection) {
            Image(systemName: "chevron.right")
        }
        .keyboardShortcut("]", modifiers: [.command])
        .disabled(viewModel.redoSelectionDisabled)
        
        Button(action: viewModel.onConfigurationButton) {
            Image(systemName: "wrench.and.screwdriver")
            Text("Configuration")
        }
        .keyboardShortcut(",", modifiers: [.command])
        .with(accessibilityIdentifier: ToolbarIdentifiers.configurationButton)
    }
    
    @ViewBuilder private func toolbarTrailingItems() -> some View {
        ValidationFeatureView(
            document: document,
            fileURL: fileURL,
            dependencies: ValidationFeatureDependencies(
                dataStore: Container.generateFeatureDataStore(),
                projectValidator: Container.projectValidator()
            )
        )
        GenerateFeatureView(
            fileURL: fileURL,
            getDocument: document,
            onGenerate: viewModel.onGenerateCompletion,
            onAlert: viewModel.onAlert,
            dependencies: GenerateFeatureDependencies(
                dataStore: Container.generateFeatureDataStore(),
                projectGenerator: Container.projectGenerator(),
                pbxProjectSyncer: Container.pbxProjSyncer()
            )
        )
        if
            let appUpdateVerdsionInfo = viewModel.appUpdateVersionInfo,
            !appUpdateVerdsionInfo.versions.isEmpty
        {
            Button(action: viewModel.onUpdateButton) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.red)
                Text("Update \(appUpdateVerdsionInfo.versions.first.map(\.version) ?? "") Available")
                    .foregroundColor(.red)
            }
        }
        if viewModel.selectedComponent(document: $document) != nil {
            Button(action: { inspectorSelection.toggle() }) {
                Image(systemName: "sidebar.trailing")
            }
            .keyboardShortcut(.init("0"), modifiers: [.command, .option])
        }
    }
    
    @ViewBuilder private func updateView(appVersionInfo: AppVersionInfoPopoverDetails) -> some View {
        VStack(alignment: .leading) {
            ForEach(appVersionInfo.versions) { appVersionInfo in
                Text("Update v\(appVersionInfo.version) is available.")
                    .font(.title)
                Text("Release Notes: \(appVersionInfo.releaseNotes)")
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Container.updateButton()
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
        switch listSelection {
        case .components:
            viewModel.selectNextComponent(names: document.families.flatMap(\.components).map(\.name))
        case .remote:
            viewModel.selectNextRemoteComponent(remoteComponents: document.remoteComponents)
        case .plugins:
            break
        }
    }
    
    private func onUpArrow() {
        switch listSelection {
        case .components:
            viewModel.selectPreviousComponent(names: document.families.flatMap(\.components).map(\.name))
        case .remote:
            viewModel.selectPreviousRemoteComponent(remoteComponents: document.remoteComponents)
        case .plugins:
            break
        }
    }
}
