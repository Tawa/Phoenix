import AccessibilityIdentifiers
import Component
import SwiftUI

struct ComponentView<PlatformsContent, DependencyType, DependencyContent, ModuleType, LibraryType, TargetType, ResourcesType>: View
where
PlatformsContent: View,
DependencyType: Identifiable,
DependencyContent: View,
ModuleType: Hashable,
LibraryType: Identifiable,
TargetType: Identifiable & Hashable,
ResourcesType: CaseIterable & Hashable & Identifiable & RawRepresentable
{
    let title: String
    let platformsContent: () -> PlatformsContent
    let dependencies: [DependencyType]
    let dependencyView: (DependencyType) -> DependencyContent
    let allLibraryTypes: [LibraryType]
    let allModuleTypes: [ModuleType]
    let isModuleTypeOn: (ModuleType) -> Bool
    let onModuleTypeSwitchedOn: (ModuleType) -> Void
    let onModuleTypeSwitchedOff: (ModuleType) -> Void
    let moduleTypeTitle: (ModuleType) -> String
    let onSelectionOfLibraryTypeForModuleType: (LibraryType?, ModuleType) -> Void
    let allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let allDependenciesSelectionValues: [String]
    let onUpdateTargetTypeValue: (PackageTargetType, String?) -> Void
    let onGenerateDemoAppProject: () -> Void
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<TargetType>]
    let onRemoveResourceWithId: (String) -> Void
    let onAddResourceWithName: (String) -> Void
    let onShowDependencySheet: () -> Void
    @Binding var resourcesValueBinding: [DynamicTextFieldList<ResourcesType, TargetType>.ValueContainer]

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
                HStack {
                    Text("Platforms:")
                    platformsContent()
                }
                Divider()
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
}
