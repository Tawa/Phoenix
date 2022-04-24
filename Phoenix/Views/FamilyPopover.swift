import SwiftUI
import Package

struct FamilyPopover: View {
    enum FocusFields: Hashable {
        case name
        case suffix
        case folder
    }

    @Binding var family: Family?
    let folderNameProvider: FamilyFolderNameProviding

    private var defaultFolderName: String { folderNameProvider.folderName(forFamily: family?.name ?? "") }
    private var componentNameExample: String { "Component\(family?.ignoreSuffix == true ? "" : family?.name ?? "")" }

    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Family: \(family?.name ?? "")")
                        .font(.largeTitle)

                    Toggle(isOn: Binding(get: { family?.ignoreSuffix != true },
                                         set: { family?.ignoreSuffix = !$0 })) {
                        Text("Append Component Name with Family Name. ")
                            .font(.title.bold())
                        + Text("\nExample: \(componentNameExample)")
                            .font(.subheadline.italic())
                    }

                    HStack {
                        Text("Folder Name:")
                            .font(.largeTitle)
                        TextField("Default: (\(defaultFolderName))",
                                  text: Binding(get: { family?.folder ?? "" },
                                                set: { family?.folder = $0 }))
                        .font(.largeTitle)
                        Button(action: { family?.folder = nil }) {
                            Text("Use Default")
                        }
                    }

                    Spacer().frame(height: 30)
                }
                Button(action: onDismiss) {
                    Text("Done")
                }
            }
            .frame(maxWidth: 600)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onExitCommand(perform: onDismiss)
    }

    private func onDismiss() {
        withAnimation {
            family = nil
        }
    }
}

struct FamilyPopover_Previews: PreviewProvider {
    static var previews: some View {
        FamilyPopover(
            family: .constant(Family(name: "Repository",
                                     ignoreSuffix: false,
                                     folder: nil)),
            folderNameProvider: FamilyFolderNameProvider())

        FamilyPopover(
            family: .constant(Family(name: "Shared",
                                     ignoreSuffix: true,
                                     folder: "Support")),
            folderNameProvider: FamilyFolderNameProvider())
    }
}
