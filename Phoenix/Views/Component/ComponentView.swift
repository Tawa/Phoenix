import AccessibilityIdentifiers
import Combine
import Component
import SwiftUI
import SwiftPackage

struct ComponentView: View {
    @EnvironmentObject var composition: Composition
    @Binding var component: Component
    let getComponentTitleUseCase: GetComponentTitleUseCaseProtocol
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol
    
    let onGenerateDemoAppProject: () -> Void
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>]
    let onRemoveResourceWithId: (String) -> Void
    let onShowDependencySheet: () -> Void
    let onShowRemoteDependencySheet: () -> Void
    
    // MARK: - Private
    private var title: String { getComponentTitleUseCase.title(forComponent: component.name) }
    private let allModuleTypes: [String]
    
    @State private var showingLocalDependencies: Bool = false
    @State private var showingRemoteDependencies: Bool = false
    
    init(
        getComponentTitleUseCase: GetComponentTitleUseCaseProtocol,
        getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol,
        getSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol,
        onGenerateDemoAppProject: @escaping () -> Void,
        onRemove: @escaping () -> Void,
        allTargetTypes: [IdentifiableWithSubtype<PackageTargetType>],
        onRemoveResourceWithId: @escaping (String) -> Void,
        onShowDependencySheet: @escaping () -> Void,
        onShowRemoteDependencySheet: @escaping () -> Void
    ) {
        _component = getSelectedComponentUseCase.binding
        
        self.getComponentTitleUseCase = getComponentTitleUseCase
        self.getProjectConfigurationUseCase = getProjectConfigurationUseCase
        
        self.onGenerateDemoAppProject = onGenerateDemoAppProject
        self.onRemove = onRemove
        self.allTargetTypes = allTargetTypes
        self.onRemoveResourceWithId = onRemoveResourceWithId
        self.onShowDependencySheet = onShowDependencySheet
        self.onShowRemoteDependencySheet = onShowRemoteDependencySheet
        
        self.allModuleTypes = getProjectConfigurationUseCase.value.packageConfigurations.map(\.name)
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
                remoteDependenciesView()
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
            TextField("ex: en", text: $component.defaultLocalization.value.nonOptionalBinding).frame(width: 100)
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
                getRelationViewDataUseCase: composition.getRelationViewDataToComponentUseCase(component.name)
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
                }.buttonStyle(PlainButtonStyle())
                Button(action: onShowDependencySheet) { Image(systemName: "plus") }
                    .with(accessibilityIdentifier: ComponentIdentifiers.dependenciesPlusButton)
            }
        }
        Divider()
    }
    
    @ViewBuilder private func remoteDependenciesView() -> some View {
        Section {
            if showingRemoteDependencies {
                LazyVStack {
                    ForEach($component.remoteDependencies) { remoteDependency in
                        HStack {
                            Divider()
                            remoteDependencyView(dependency: remoteDependency)
                        }
                    }
                }
                if component.remoteDependencies.isEmpty {
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
                }.buttonStyle(PlainButtonStyle())
                Button(action: onShowRemoteDependencySheet) { Image(systemName: "plus") }
            }
        }
        Divider()
    }
    
    @ViewBuilder private func componentDependencyView(for dependency: Binding<ComponentDependency>) -> some View {
        RelationView(
            defaultDependencies: dependency.targetTypes,
            title: getComponentTitleUseCase.title(forComponent: dependency.wrappedValue.name),
            getRelationViewDataUseCase: composition.getRelationViewDataBetweenComponentsUseCase((component.name, dependency.wrappedValue.name)),
            onRemove: { component.localDependencies.removeAll(where: { $0.name == dependency.wrappedValue.name }) }
        )
    }
    
    @ViewBuilder func remoteDependencyView(dependency: Binding<RemoteDependency>) -> some View {
        RemoteDependencyView(
            dependency: dependency,
            allDependencyTypes: allTargetTypes,
            onRemove: { component.remoteDependencies.removeAll(where: { $0 == dependency.wrappedValue }) })
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
            HStack(alignment: .top) {
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
