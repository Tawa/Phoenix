import AccessibilityIdentifiers
import Component
import SwiftUI

struct FamilyRule: Identifiable {
    var id: String { name }
    let name: String
    let enabled: Bool
}

struct FamilySheet: View {
    let name: String
    let ignoreSuffix: Bool
    let onUpdateSelectedFamily: (Bool) -> Void
    let folderName: String
    let onUpdateFolderName: (String?) -> Void
    let defaultFolderName: String
    let componentNameExample: String
    let allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let allDependenciesSelectionValues: [String]
    let onUpdateTargetTypeValue: (PackageTargetType, String?) -> Void
    let rules: [FamilyRule]
    let onUpdateFamilyRule: (String, Bool) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Family: \(name)")
                    .font(.largeTitle)
                
                Toggle(isOn: Binding(get: { !ignoreSuffix },
                                     set: { onUpdateSelectedFamily($0) })) {
                    Text("Append Component Name with Family Name. ")
                        .bold()
                    + Text("\nExample: \(componentNameExample)")
                        .font(.subheadline.italic())
                }.with(accessibilityIdentifier: FamilySheetIdentifiers.appendNameToggle)
                
                HStack {
                    Text("Folder Name:")
                    TextField("Default: (\(defaultFolderName))",
                              text: Binding(get: { folderName },
                                            set: { onUpdateFolderName($0) }))
                    .with(accessibilityIdentifier: FamilySheetIdentifiers.folderNameTextField)
                    Button(action: { onUpdateFolderName(nil) }) {
                        Text("Use Default")
                    }
                }
                
                Spacer().frame(height: 30)
                
                DependencyView<PackageTargetType, String>(
                    title: "Default Dependencies",
                    allTypes: allDependenciesConfiguration,
                    allSelectionValues: allDependenciesSelectionValues,
                    onUpdateTargetTypeValue: onUpdateTargetTypeValue)
                
                
                VStack(alignment: .leading) {
                    Text("Allow ") + Text(name).bold() + Text(" components to be used in:")
                    ForEach(rules) { rule in
                        Toggle(rule.name,
                               isOn: Binding(get: { rule.enabled },
                                             set: { onUpdateFamilyRule(rule.name, $0) })
                        )
                    }
                }
                .padding()
                
                Button(action: onDismiss) {
                    Text("Done")
                }
                .keyboardShortcut(.cancelAction)
                .with(accessibilityIdentifier: FamilySheetIdentifiers.doneButton)
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
