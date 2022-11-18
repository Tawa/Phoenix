import AccessibilityIdentifiers
import Combine
import Component
import SwiftUI
import SwiftPackage

struct ComponentView<DependencyType, DependencyContent, TargetType, ResourcesType>: View
where
DependencyType: Identifiable,
DependencyContent: View,
TargetType: Identifiable & Hashable,
ResourcesType: CaseIterable & Hashable & Identifiable & RawRepresentable
{
    @EnvironmentObject var composition: Composition
    @Binding var component: Component
    let getComponentTitleUseCase: GetComponentTitleUseCaseProtocol
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol
    
    let dependencies: [DependencyType]
    let dependencyView: (DependencyType) -> DependencyContent
    let onGenerateDemoAppProject: () -> Void
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<TargetType>]
    let onRemoveResourceWithId: (String) -> Void
    let onAddResourceWithName: (String) -> Void
    let onShowDependencySheet: () -> Void
    let onShowRemoteDependencySheet: () -> Void
    @Binding var resourcesValueBinding: [DynamicTextFieldList<ResourcesType, TargetType>.ValueContainer]
    
    // MARK: - Private
    private var title: String { getComponentTitleUseCase.title(forComponent: component.name) }
    private let allModuleTypes: [String]
    
    init(
        getComponentTitleUseCase: GetComponentTitleUseCaseProtocol,
        getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol,
        getSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol,
        dependencies: [DependencyType],
        dependencyView: @escaping (DependencyType) -> DependencyContent,
        onGenerateDemoAppProject: @escaping () -> Void,
        onRemove: @escaping () -> Void,
        allTargetTypes: [IdentifiableWithSubtype<TargetType>],
        onRemoveResourceWithId: @escaping (String) -> Void,
        onAddResourceWithName: @escaping (String) -> Void,
        onShowDependencySheet: @escaping () -> Void,
        onShowRemoteDependencySheet: @escaping () -> Void,
        resourcesValueBinding: Binding<[DynamicTextFieldList<ResourcesType, TargetType>.ValueContainer]>
    ) {
        _component = getSelectedComponentUseCase.binding
        
        self.getComponentTitleUseCase = getComponentTitleUseCase
        self.getProjectConfigurationUseCase = getProjectConfigurationUseCase
        
        self.dependencies = dependencies
        self.dependencyView = dependencyView
        self.onGenerateDemoAppProject = onGenerateDemoAppProject
        self.onRemove = onRemove
        self.allTargetTypes = allTargetTypes
        self.onRemoveResourceWithId = onRemoveResourceWithId
        self.onAddResourceWithName = onAddResourceWithName
        self.onShowDependencySheet = onShowDependencySheet
        self.onShowRemoteDependencySheet = onShowRemoteDependencySheet
        self._resourcesValueBinding = resourcesValueBinding
        
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
                
                Section {
                    ForEach(dependencies, content: dependencyView)
                } header: {
                    HStack {
                        Text("Dependencies")
                            .font(.largeTitle.bold())
                        Button(action: onShowDependencySheet) { Image(systemName: "plus") }
                            .with(accessibilityIdentifier: ComponentIdentifiers.dependenciesPlusButton)
                        Button(action: onShowRemoteDependencySheet) { Text("Add Remote Dependency") }
                    }
                }
                Divider()
                
                Section {
                    DynamicTextFieldList(
                        values: $resourcesValueBinding,
                        allTargetTypes: allTargetTypes,
                        onRemoveValue: onRemoveResourceWithId,
                        newValuePlaceholder: "Resources",
                        onNewValue: onAddResourceWithName)
                } header: {
                    Text("Resources")
                        .font(.largeTitle.bold())
                }
                Divider()
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
                getRelationViewDataUseCase: composition.getRelationViewDataUseCase()
            )
        }
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
