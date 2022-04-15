import SwiftUI

struct FamiliesView: View {
    @Binding var families: [Family]

    var body: some View {
        List {
            ForEach(families.enumeratedArray(), id: \.element) { index, family in
                HStack {
                    TextField("Family Name", text: Binding(get: { families[index].name },
                                                           set: { families[index].name = $0 }))
                    TextField("Folder Name", text: Binding(get: { families[index].folderName },
                                                           set: { families[index].folderName = $0 }))
                }
            }
        }
    }
}

struct FamiliesView_Previews: PreviewProvider {
    static var previews: some View {
        FamiliesView(families: .constant([
            Family(name: "DataStore", folderName: "DataStores"),
            Family(name: "Repository", folderName: "Repositories"),
            Family(name: "ViewModel", folderName: "ViewModels")
        ]))
    }
}
