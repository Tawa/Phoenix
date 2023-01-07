import AccessibilityIdentifiers
import Combine
import Factory
import PhoenixDocument
import SwiftUI
import SwiftPackage

struct ComponentView: View {
    @Binding var component: Component
    let remoteDependencies: [String: RemoteComponent]
    let relationViewData: RelationViewData
    let relationViewDataToComponentNamed: (Name, [PackageTargetType: String]) -> RelationViewData
    let titleForComponentNamed: (Name) -> String
    
    let onGenerateDemoAppProject: () -> Void
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>]
    let onShowDependencySheet: () -> Void
    let onShowRemoteDependencySheet: () -> Void
    let onSelectComponentName: (Name) -> Void
    let onSelectRemoteURL: (String) -> Void
    let allModuleTypes: [String]
    
    // MARK: - Private
    private var title: String { titleForComponentNamed(component.name) }
    
    @State private var showingLocalDependencies: Bool = false
    @State private var showingRemoteDependencies: Bool = false
    @State private var showingResources: Bool = false

    var body: some View {
        List {
            headerView()
            moduleTypesView()
            defaultLocalizationView()
            platformsContent()
            
            defaultDependenciesView()
            localDependenciesView()
            remoteComponentDependenciesView()
            resourcesView()
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
        expandableDependenciesSection(
            title: "Local Dependencies",
            isExpanded: $showingLocalDependencies,
            accessibilityIdentifier: ComponentIdentifiers.localDependenciesButton) {
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
            } accessoryContent: {
                Button(action: onShowDependencySheet) { Image(systemName: "plus") }
                    .with(accessibilityIdentifier: ComponentIdentifiers.dependenciesPlusButton)
            }
    }
    
    @ViewBuilder private func remoteComponentDependenciesView() -> some View {
        expandableDependenciesSection(
            title: "Remote Dependencies",
            isExpanded: $showingRemoteDependencies,
            accessibilityIdentifier: ComponentIdentifiers.remoteDependenciesButton) {
                LazyVStack {
                    ForEach($component.remoteComponentDependencies) { remoteComponentDependency in
                        RemoteComponentDependencyView(
                            dependency: remoteComponentDependency,
                            remoteDependency: remoteDependencies[remoteComponentDependency.wrappedValue.url],
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
            } accessoryContent: {
                Button(action: onShowRemoteDependencySheet) { Image(systemName: "plus") }
            }
    }
    
    @ViewBuilder private func componentDependencyView(for dependency: Binding<ComponentDependency>) -> some View {
        RelationView(
            defaultDependencies: dependency.targetTypes,
            title: titleForComponentNamed(dependency.wrappedValue.name),
            viewData: relationViewDataToComponentNamed(dependency.wrappedValue.name, dependency.wrappedValue.targetTypes),
            onSelect: { onSelectComponentName(dependency.wrappedValue.name) },
            onRemove: { component.localDependencies.removeAll(where: { $0.name == dependency.wrappedValue.name }) }
        )
    }
    
    @ViewBuilder func resourcesView() -> some View {
        expandableDependenciesSection(title: "Resources",
                                      isExpanded: $showingResources,
                                      accessibilityIdentifier: ComponentIdentifiers.resourcesButton) {
            ResourcesView(resources: $component.resources, allTargetTypes: allTargetTypes)
        }
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
    
    @ViewBuilder private func expandableSection<Title: View, Content: View, AccessoryContent: View>(
        isExpanded: Binding<Bool>,
        accessibilityIdentifier: AccessibilityIdentifiable,
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder accessoryContent: @escaping () -> AccessoryContent = { EmptyView() }
    ) -> some View {
        Section {
            if isExpanded.wrappedValue {
                content()
            } else {
                EmptyView()
            }
        } header: {
            HStack {
                Button {
                    isExpanded.wrappedValue.toggle()
                } label: {
                    title()
                }
                .buttonStyle(PlainButtonStyle())
                .with(accessibilityIdentifier: accessibilityIdentifier)
                accessoryContent()
            }
        }
        Divider()
    }
    
    @ViewBuilder private func expandableDependenciesSection<Content: View, AccessoryContent: View>(
        title: String,
        isExpanded: Binding<Bool>,
        accessibilityIdentifier: AccessibilityIdentifiable,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder accessoryContent: @escaping () -> AccessoryContent = { EmptyView() }
    ) -> some View {
        expandableSection(
            isExpanded: isExpanded,
            accessibilityIdentifier: accessibilityIdentifier,
            title: {
                HStack {
                    Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.forward")
                    Text(title)
                }
                .font(.largeTitle.bold())
            },
            content: content,
            accessoryContent: accessoryContent
        )
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
