import AccessibilityIdentifiers
import Combine
import PhoenixDocument
import SwiftUI

struct MetasListRow: Hashable, Identifiable {
    let id: Name
    let name: String
    let isSelected: Bool
    
    init(id: Name,
         name: String,
         isSelected: Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
}

struct MetasList: View {
    let selected: MetaComponent.ID?
    let rows: [MetaComponent]
    let onSelect: (MetaComponent.ID) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(rows, id: \.self) { row in
                    ComponentListItem(
                        name: row.name,
                        isSelected: (selected == row.id),
                        onSelect: { onSelect(row.id) }
                    )
                }
                .contentShape(Rectangle())
                .cornerRadius(8)
                Divider()
                Text(numberOfComponentsString)
                    .foregroundColor(.gray)
            }
        }
        .frame(minHeight: 200, maxHeight: .infinity)
        .listStyle(SidebarListStyle())
    }
    
    private var numberOfComponentsString: String {
        let totalRows = rows.count
        if totalRows == 1 {
            return "1 meta"
        } else {
            return "\(totalRows) Metas"
        }
    }
}

struct MetasList_Previews: PreviewProvider {
    static var previews: some View {
        MetasList(
            selected: "FeatureMetas",
            rows: [
                MetaComponent(name: "FeatureMetas"),
                MetaComponent(name: "RepositoryMetas"),
                MetaComponent(name: "UserCasesMetas")
            ],
            onSelect: { _ in }
        )
    }
}


//struct MetasListSection: Hashable, Identifiable {
//    let id: String
//    
//    let name: String
//    let folderName: String?
//    let rows: [MetasListRow]
//}
//
//struct MetasList: View {
//    let sections: [MetasListSection]
//    let footerText: String
//    let onSelect: (String) -> Void
//    let onSelectSection: (String) -> Void
//    
//    var body: some View {
//        List {
//            ForEach(sections) { section in
//                Section {
//                    ForEach(section.rows) { row in
//                        ComponentListItem(
//                            name: row.name,
//                            isSelected: row.isSelected,
//                            onSelect: { onSelect(row.id) }
//                        )
//                        .with(accessibilityIdentifier: MetasListIdentifiers.component(named: row.name))
//                    }
//                } header: {
//                    Button(action: { onSelectSection(section.id) },
//                           label: {
//                        HStack {
//                            Text(section.name)
//                                .font(.title)
//                            section.folderName.map { folderName -> Text? in
//                                guard folderName != section.name else { return nil }
//                                return Text("(\(Image(systemName: "folder")) \(folderName))")
//                            }?.help("Folder Name")
//                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
//                            Spacer()
//                        }
//                        .contentShape(Rectangle())
//                    })
//                    .buttonStyle(.plain)
//                    .padding(.vertical)
//                    .with(accessibilityIdentifier: MetasListIdentifiers.familySettingsButton(named: section.name))
//                }
//                Divider()
//            }
//            Text(footerText)
//                .lineLimit(nil)
//                .foregroundColor(.gray)
//        }
//        .frame(minHeight: 200, maxHeight: .infinity)
//        .listStyle(SidebarListStyle())
//    }
//}
//
//struct MetasList_Previews: PreviewProvider {
//    static var previews: some View {
//        MetasList(
//            sections: [
//                MetasListSection(
//                    id: "id0",
//                    name: "Repositories",
//                    folderName: nil,
//                    rows: [
//                        MetasListRow(id: Name(given: "Home", family: "Repository"), name: "HomeRepository", isSelected: true),
//                        MetasListRow(id: Name(given: "Settings", family: "Repository"), name: "SettingsRepository", isSelected: false),
//                        MetasListRow(id: Name(given: "About", family: "Repository"), name: "AboutRepository", isSelected: false),
//                    ]
//                ),
//            ],
//            footerText: "3 metas",
//            onSelect: { _ in },
//            onSelectSection: { _ in }
//        )
//    }
//}
