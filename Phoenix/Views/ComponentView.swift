import SwiftUI

struct ComponentView<PlatformsContent, DependencyType, DependencyContent, ModuleType, LibraryType, TargetType, ResourcesType>: View
where
PlatformsContent: View,
DependencyType: Identifiable,
DependencyContent: View,
ModuleType: Identifiable,
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
    let onRemove: () -> Void
    let allTargetTypes: [IdentifiableWithSubtype<TargetType>]
    let onRemoveResourceWithId: (String) -> Void
    let onAddResourceWithName: (String) -> Void
    @Binding var resourcesValueBinding: [DynamicTextFieldList<ResourcesType, TargetType>.ValueContainer]
    @Binding var showingDependencyPopover: Bool

    @FocusState private var focusedField: String?

    var body: some View {
        List {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Button(role: .destructive, action: onRemove) {
                        Image(systemName: "trash")
                    }.help("Remove")
                }
                Divider()
                HStack {
                    Text("Platforms:")
                    platformsContent()
                }
                Divider()
                HStack {
                    Text("Module Types:")
                    ForEach(allModuleTypes) { moduleType in
                        ComponentModuleTypeView(title: "\(moduleType)",
                                                isOn: isModuleTypeOn(moduleType),
                                                onOn: { onModuleTypeSwitchedOn(moduleType) },
                                                onOff: { onModuleTypeSwitchedOff(moduleType) },
                                                selectionData: allLibraryTypes,
                                                selectionTitle: moduleTypeTitle(moduleType),
                                                onSelection: { onSelectionOfLibraryTypeForModuleType($0, moduleType) },
                                                onRemove: { onSelectionOfLibraryTypeForModuleType(nil, moduleType) })
                        Divider()
                    }
                    Spacer()
                }.frame(height: 50)
                Divider()

                Section {
                    ForEach(dependencies, content: dependencyView)
                        .padding([.vertical])
                } header: {
                    HStack {
                        Text("Dependencies")
                            .font(.largeTitle)
                        Button(action: {
                            showingDependencyPopover = true
                        }, label: { Image(systemName: "plus") })
                    }
                }
                Divider()

                Section {
                    DynamicTextFieldList(
                        values: $resourcesValueBinding,
                        allTargetTypes: allTargetTypes,
                        onRemoveValue: onRemoveResourceWithId,
                        onNewValue: onAddResourceWithName)
                } header: {
                    Text("Resources")
                        .font(.largeTitle)
                }
                Divider()
            }
            .padding()
        }
    }
}
