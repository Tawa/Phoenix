import AccessibilityIdentifiers
import Component
import SwiftUI

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
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Family: \(name)")
                    .font(.largeTitle)
                
                Toggle(isOn: Binding(get: { !ignoreSuffix },
                                     set: { onUpdateSelectedFamily($0) })) {
                    Text("Append Component Name with Family Name. ")
                        .font(.title.bold())
                    + Text("\nExample: \(componentNameExample)")
                        .font(.subheadline.italic())
                }.with(accessibilityIdentifier: FamilySheetIdentifiers.appendNameToggle)
                
                HStack {
                    Text("Folder Name:")
                        .font(.largeTitle)
                    TextField("Default: (\(defaultFolderName))",
                              text: Binding(get: { folderName },
                                            set: { onUpdateFolderName($0) }))
                    .font(.largeTitle)
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
