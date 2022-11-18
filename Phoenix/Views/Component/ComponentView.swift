import AccessibilityIdentifiers
import Combine
import Component
import SwiftUI

struct ComponentView<PlatformsContent, DependencyType, DependencyContent, LibraryType, TargetType, ResourcesType>: View
where
PlatformsContent: View,
DependencyType: Identifiable,
DependencyContent: View,
LibraryType: Identifiable,
TargetType: Identifiable & Hashable,
ResourcesType: CaseIterable & Hashable & Identifiable & RawRepresentable
{
    @Binding var component: Component
    let getComponentTitleUseCase: GetComponentTitleUseCaseProtocol
    
    let platformsContent: () -> PlatformsContent
    let dependencies: [DependencyType]
    let dependencyView: (DependencyType) -> DependencyContent
    let allLibraryTypes: [LibraryType]
    let allModuleTypes: [String]
    let isModuleTypeOn: (String) -> Bool
    let onModuleTypeSwitchedOn: (String) -> Void
    let onModuleTypeSwitchedOff: (String) -> Void
    let moduleTypeTitle: (String) -> String
    let onSelectionOfLibraryTypeForModuleType: (LibraryType?, String) -> Void
    let allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let allDependenciesSelectionValues: [String]
    let onUpdateTargetTypeValue: (PackageTargetType, String?) -> Void
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
    
    init(
        getComponentTitleUseCase: GetComponentTitleUseCaseProtocol,
        getSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol,
        platformsContent: @escaping () -> PlatformsContent,
        dependencies: [DependencyType],
        dependencyView: @escaping (DependencyType) -> DependencyContent,
        allLibraryTypes: [LibraryType],
        allModuleTypes: [String],
        isModuleTypeOn: @escaping (String) -> Bool,
        onModuleTypeSwitchedOn: @escaping (String) -> Void,
        onModuleTypeSwitchedOff: @escaping (String) -> Void,
        moduleTypeTitle: @escaping (String) -> String,
        onSelectionOfLibraryTypeForModuleType: @escaping (LibraryType?, String) -> Void,
        allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>],
        allDependenciesSelectionValues: [String],
        onUpdateTargetTypeValue: @escaping (PackageTargetType, String?) -> Void,
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
        self.platformsContent = platformsContent
        self.dependencies = dependencies
        self.dependencyView = dependencyView
        self.allLibraryTypes = allLibraryTypes
        self.allModuleTypes = allModuleTypes
        self.isModuleTypeOn = isModuleTypeOn
        self.onModuleTypeSwitchedOn = onModuleTypeSwitchedOn
        self.onModuleTypeSwitchedOff = onModuleTypeSwitchedOff
        self.moduleTypeTitle = moduleTypeTitle
        self.onSelectionOfLibraryTypeForModuleType = onSelectionOfLibraryTypeForModuleType
        self.allDependenciesConfiguration = allDependenciesConfiguration
        self.allDependenciesSelectionValues = allDependenciesSelectionValues
        self.onUpdateTargetTypeValue = onUpdateTargetTypeValue
        self.onGenerateDemoAppProject = onGenerateDemoAppProject
        self.onRemove = onRemove
        self.allTargetTypes = allTargetTypes
        self.onRemoveResourceWithId = onRemoveResourceWithId
        self.onAddResourceWithName = onAddResourceWithName
        self.onShowDependencySheet = onShowDependencySheet
        self.onShowRemoteDependencySheet = onShowRemoteDependencySheet
        self._resourcesValueBinding = resourcesValueBinding
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
                        VStack {
                            ForEach(allModuleTypes, id: \.self) { moduleType in
                                ComponentModuleTypeView(title: "\(moduleType)",
                                                        isOn: isModuleTypeOn(moduleType),
                                                        onOn: { onModuleTypeSwitchedOn(moduleType) },
                                                        onOff: { onModuleTypeSwitchedOff(moduleType) },
                                                        selectionData: allLibraryTypes,
                                                        selectionTitle: moduleTypeTitle(moduleType),
                                                        onSelection: { onSelectionOfLibraryTypeForModuleType($0, moduleType) },
                                                        onRemove: { onSelectionOfLibraryTypeForModuleType(nil, moduleType) })
                            }
                        }
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
                    DependencyView<PackageTargetType, String>(
                        title: "Default Dependencies",
                        allTypes: allDependenciesConfiguration,
                        allSelectionValues: allDependenciesSelectionValues,
                        onUpdateTargetTypeValue: onUpdateTargetTypeValue)
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
}
