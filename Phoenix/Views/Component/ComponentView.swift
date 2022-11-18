import AccessibilityIdentifiers
import Combine
import Component
import SwiftUI
import SwiftPackage

struct ComponentView<PlatformsContent, DependencyType, DependencyContent, TargetType, ResourcesType>: View
where
PlatformsContent: View,
DependencyType: Identifiable,
DependencyContent: View,
TargetType: Identifiable & Hashable,
ResourcesType: CaseIterable & Hashable & Identifiable & RawRepresentable
{
    @EnvironmentObject var composition: Composition
    @Binding var component: Component
    let getComponentTitleUseCase: GetComponentTitleUseCaseProtocol
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol
    
    let platformsContent: () -> PlatformsContent
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
    private var title: String { getComponentTitleUseCase.title(forComponent: component) }
    private let allModuleTypes: [String]

    init(
        getComponentTitleUseCase: GetComponentTitleUseCaseProtocol,
        getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol,
        getSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol,
        platformsContent: @escaping () -> PlatformsContent,
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

        self.platformsContent = platformsContent
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
                Group {
                    HStack {
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
                    Divider()
                }
                Group {
                    HStack(alignment: .top) {
                        Text("Module Types:")
                        ComponentModuleTypesView(dictionary: $component.modules,
                                                 allModuleTypes: allModuleTypes)
                        Spacer()
                    }
                    Divider()
                    
                    defaultLocalizationView()
                    Divider()
                    HStack {
                        Text("Platforms:")
                        platformsContent()
                    }
                    Divider()
                }
                
                Group {
                    RelationView(
                        defaultDependencies: $component.defaultDependencies,
                        title: "Default Dependencies",
                        getRelationViewDataUseCase: composition.getRelationViewDataUseCase()
                    )
                    Divider()
                }
                
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
    
    // MARK: - Private
    @ViewBuilder private func defaultLocalizationView() -> some View {
        HStack(alignment: .top) {
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
    
    private func isModuleTypeOn(_ name: String) -> Bool {
        component.modules[name] != nil
    }
}
