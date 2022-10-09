import AccessibilityIdentifiers
import SwiftUI

struct FamilySheet: View {
    let name: String
    let ignoreSuffix: Bool
    let onUpdateSelectedFamily: (Bool) -> Void
    let folderName: String
    let onUpdateFolderName: (String?) -> Void
    let defaultFolderName: String
    let componentNameExample: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            VStack {
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
                }
                Button(action: onDismiss) {
                    Text("Done")
                }
                .keyboardShortcut(.cancelAction)
                .with(accessibilityIdentifier: FamilySheetIdentifiers.doneButton)
            }
            .frame(maxWidth: 600)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

//struct FamilySheet_Previews: PreviewProvider {
//    static var previews: some View {
//        FamilySheet(
//            viewModel: FamilySheetViewModel(
//                family: Family(name: "Repository",
//                               ignoreSuffix: false,
//                               folder: nil)))
//        FamilySheet(
//            viewModel: FamilySheetViewModel(
//                family: Family(name: "Shared",
//                               ignoreSuffix: true,
//                               folder: "Support")))
//    }
//}
