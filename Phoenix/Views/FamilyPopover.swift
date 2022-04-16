import SwiftUI
import Package

struct FamilyPopover: View {
    enum FocusFields: Hashable {
        case name
        case suffix
        case folder
    }
    
    @Binding var family: Family?
    @Binding var isPresenting: Bool
    let folderNameProvider: FamilyFolderNameProviding
    
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Family: \(family?.name ?? "")")
                        .font(.largeTitle)
                    
                    Toggle("Append Component Name with Family Name",
                           isOn: Binding(get: { family?.ignoreSuffix != true },
                                         set: { family?.ignoreSuffix = !$0 }))
                    
                    HStack {
                        Text("Folder Name:")
                        TextField("Default: (\(folderNameProvider.folderName(forFamily: family?.name ?? "")))",
                                  text: Binding(get: { family?.folder ?? "" },
                                                set: { family?.folder = $0 }))
                    }
                    .font(.largeTitle)
                    
                    Spacer().frame(height: 30)
                }
                Button(action: { withAnimation { isPresenting = false } }) {
                    Text("Done")
                }
            }
            .frame(maxWidth: 600)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onExitCommand(perform: { withAnimation { isPresenting = false } })
    }
}

struct FamilyPopover_Previews: PreviewProvider {
    static var previews: some View {
        FamilyPopover(
            family: .constant(Family(name: "Repository",
                                     ignoreSuffix: nil,
                                     folder: nil)),
            isPresenting: .constant(true),
            folderNameProvider: FamilyFolderNameProvider())
        
        FamilyPopover(
            family: .constant(Family(name: "Shared",
                                     ignoreSuffix: true,
                                     folder: "Support")),
            isPresenting: .constant(true),
            folderNameProvider: FamilyFolderNameProvider())
    }
}
