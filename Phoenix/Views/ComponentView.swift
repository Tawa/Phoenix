import AccessibilityIdentifiers
import Combine
import Component
import Factory
import SwiftUI
import SwiftPackage

struct ComponentView: View {
    @Binding var component: Component
    let relationViewData: RelationViewData
    let relationViewDataToComponentNamed: (Name, [PackageTargetType: String]) -> RelationViewData
    let titleForComponentNamed: (Name) -> String
    
    let onGenerateDemoAppProject: () -> Void
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>]
    let onShowDependencySheet: () -> Void
    let onShowRemoteDependencySheet: () -> Void
    let onSelectRemoteURL: (String) -> Void
    
    // MARK: - Private
    private var title: String { titleForComponentNamed(component.name) }
    private let allModuleTypes: [String]
    
    @State private var showingLocalDependencies: Bool = false
    @State private var showingRemoteDependencies: Bool = false
    
    init(
        component: Binding<Component>,
        relationViewData: RelationViewData,
        relationViewDataToComponentNamed: @escaping (Name, [PackageTargetType: String]) -> RelationViewData,
        titleForComponentNamed: @escaping (Name) -> String,
        onGenerateDemoAppProject: @escaping () -> Void,
        onRemove: @escaping () -> Void,
        allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>],
        allModuleTypes: [String],
        onShowDependencySheet: @escaping () -> Void,
        onShowRemoteDependencySheet: @escaping () -> Void,
        onSelectRemoteURL: @escaping (String) -> Void
    ) {
        self._component = component
        self.relationViewData = relationViewData
        self.relationViewDataToComponentNamed = relationViewDataToComponentNamed
        self.titleForComponentNamed = titleForComponentNamed
        
        self.onGenerateDemoAppProject = onGenerateDemoAppProject
        self.onRemove = onRemove
        self.allTargetTypes = allTargetTypes
        self.onShowDependencySheet = onShowDependencySheet
        self.onShowRemoteDependencySheet = onShowRemoteDependencySheet
        self.onSelectRemoteURL = onSelectRemoteURL
        
        self.allModuleTypes = allModuleTypes
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                headerView()
                moduleTypesView()
                defaultLocalizationView()
                platformsContent()
                
                defaultDependenciesView()
                localDependenciesView()
                remoteComponentDependenciesView()
                resourcesView()
            }
            .padding()
        }
    }
    // MARK: - Subviews
    @ViewBuilder private func headerView() -> some View {
        section {
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.leading)
            Spacer()
            Button(action: onGenerateDemoAppProject) {
                Text("Generate Demo App")
            }.help("Generate Demo App Xcode Project")
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    @ViewBuilder private func moduleTypesView() -> some View {
        section {
            Text("Module Types:")
            ComponentModuleTypesView(dictionary: $component.modules,
                                     allModuleTypes: allModuleTypes)
            Spacer()
        }
    }
    
    @ViewBuilder private func defaultLocalizationView() -> some View {
        section {
            Text("Default Localization: ")
            TextField("ex: en", text: $component.defaultLocalization.value.nonOptionalBinding)
                .frame(width: 100)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            VStack(alignment: .leading) {
                ForEach(allModuleTypes.filter(isModuleTypeOn), id: \.self) { moduleType in
                    HStack {
                        Toggle(isOn: Binding(get: {
                            $component.wrappedValue.defaultLocalization.modules.contains(moduleType)
                        }, set: {
                            var defaultLocalization = component.defaultLocalization
                            if $0 {
                                defaultLocalization.modules.removeAll(where: { $0 == moduleType })
                                defaultLocalization.modules.append(moduleType)
                                defaultLocalization.modules.sort()
                            } else {
                                defaultLocalization.modules.removeAll(where: { $0 == moduleType })
                            }
                            component.defaultLocalization = defaultLocalization
                        })) {
                            Text(moduleType)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func platformsContent() -> some View {
        section {
            Text("Platforms:")
            CustomMenu(title: iOSPlatformMenuTitle(forComponent: component),
                       data: IOSVersion.allCases,
                       onSelection: { component.iOSVersion = $0 },
                       hasRemove: component.iOSVersion != nil,
                       onRemove: { component.iOSVersion = nil })
            .frame(width: 150)
            CustomMenu(title: macOSPlatformMenuTitle(forComponent: component),
                       data: MacOSVersion.allCases,
                       onSelection: { component.macOSVersion = $0 },
                       hasRemove: component.macOSVersion != nil,
                       onRemove: { component.macOSVersion = nil })
            .frame(width: 150)
        }
    }
    
    @ViewBuilder private func defaultDependenciesView() -> some View {
        section {
            RelationView(
                defaultDependencies: $component.defaultDependencies,
                title: "Default Dependencies",
                viewData: relationViewData
            )
        }
    }
    
    @ViewBuilder private func localDependenciesView() -> some View {
        Section {
            if showingLocalDependencies {
                LazyVStack {
                    ForEach($component.localDependencies) { localDependency in
                        HStack {
                            Divider()
                            componentDependencyView(for: localDependency)
                        }
                    }
                }
                if component.localDependencies.isEmpty {
                    Text("No local dependencies")
                }
            } else {
                EmptyView()
            }
        } header: {
            HStack {
                Button {
                    showingLocalDependencies.toggle()
                } label: {
                    HStack {
                        Image(systemName: showingLocalDependencies ? "chevron.down" : "chevron.forward")
                        Text("Local Dependencies")
                    }
                    .font(.largeTitle.bold())
                }
                .buttonStyle(PlainButtonStyle())
                .with(accessibilityIdentifier: ComponentIdentifiers.localDependenciesButton)
                Button(action: onShowDependencySheet) { Image(systemName: "plus") }
                    .with(accessibilityIdentifier: ComponentIdentifiers.dependenciesPlusButton)
            }
        }
        Divider()
    }
    
    @ViewBuilder private func remoteComponentDependenciesView() -> some View {
        Section {
            if showingRemoteDependencies {
                LazyVStack {
                    ForEach($component.remoteComponentDependencies) { remoteComponentDependency in
                        RemoteComponentDependencyView(
                            dependency: remoteComponentDependency,
                            allDependencyTypes: allTargetTypes,
                            onSelect: { onSelectRemoteURL(remoteComponentDependency.wrappedValue.url) },
                            onRemove: {
                                component.remoteComponentDependencies.removeAll(where: {
                                    $0.url == remoteComponentDependency.wrappedValue.url
                                })
                            }
                        )
                    }
                }
                if component.remoteComponentDependencies.isEmpty {
                    Text("No remote dependencies")
                }
            } else {
                EmptyView()
            }
        } header: {
            HStack {
                Button {
                    showingRemoteDependencies.toggle()
                } label: {
                    HStack {
                        Image(systemName: showingRemoteDependencies ? "chevron.down" : "chevron.forward")
                        Text("Remote Dependencies")
                    }
                    .font(.largeTitle.bold())
                }
                .buttonStyle(PlainButtonStyle())
                .with(accessibilityIdentifier: ComponentIdentifiers.remoteDependenciesButton)
                Button(action: onShowRemoteDependencySheet) { Image(systemName: "plus") }
            }
        }
        Divider()
    }
    
    @ViewBuilder private func componentDependencyView(for dependency: Binding<ComponentDependency>) -> some View {
        RelationView(
            defaultDependencies: dependency.targetTypes,
            title: titleForComponentNamed(dependency.wrappedValue.name),
            viewData: relationViewDataToComponentNamed(dependency.wrappedValue.name, dependency.wrappedValue.targetTypes),
            onRemove: { component.localDependencies.removeAll(where: { $0.name == dependency.wrappedValue.name }) }
        )
    }
    
    @ViewBuilder func resourcesView() -> some View {
        Section {
            ResourcesView(resources: $component.resources, allTargetTypes: allTargetTypes)
        } header: {
            Text("Resources")
                .font(.largeTitle.bold())
        }
        Divider()
    }
    
    // MARK: - Helper Functions
    @ViewBuilder private func section<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        Section {
            HStack(alignment: .center) {
                content()
            }
            Divider()
        }
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
    
    private func isModuleTypeOn(_ name: String) -> Bool {
        component.modules[name] != nil
    }
}
