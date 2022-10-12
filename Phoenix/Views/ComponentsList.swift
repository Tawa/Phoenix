import AccessibilityIdentifiers
import SwiftUI

struct ComponentsListRow: Hashable, Identifiable {
    var id: Int { hashValue }
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void
    let onDuplicate: () -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isSelected)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct ComponentsListSection: Hashable, Identifiable {
    var id: Int { hashValue }
    
    let name: String
    let folderName: String?
    let rows: [ComponentsListRow]
    let onSelect: () -> Void
    
    var title: String {
        folderName.map { folderName in
            name + "(Folder: \(folderName)"
        } ?? name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(rows)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct ComponentsList: View {
    @Binding var filter: String
    let sections: [ComponentsListSection]
    
    var body: some View {
        VStack(alignment: .leading) {
            FilterView(filter: $filter)
            List {
                ForEach(sections.filter { !$0.rows.isEmpty }) { section in
                    Section {
                        ForEach(section.rows) { row in
                            ComponentListItem(
                                name: row.name,
                                isSelected: row.isSelected,
                                onSelect: row.onSelect,
                                onDuplicate: row.onDuplicate
                            )
                            .with(accessibilityIdentifier: ComponentsListIdentifiers.component(named: row.name))
                        }
                    } header: {
                        Button(action: section.onSelect,
                               label: {
                            HStack {
                                Text(section.name)
                                    .font(.title.bold())
                                section.folderName.map { folderName -> Text? in
                                    guard folderName != section.name else { return nil }
                                    return Text("(\(Image(systemName: "folder")) \(folderName))").font(.subheadline)
                                }
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            }
                        })
                        .buttonStyle(.plain)
                        .padding(.vertical)
                        .with(accessibilityIdentifier: ComponentsListIdentifiers.familySettingsButton(named: section.name))
                    }
                    Divider()
                }
                Text(numberOfComponentsString)
                    .foregroundColor(.gray)
            }
            .frame(minHeight: 200, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
        }
    }
    
    private var numberOfComponentsString: String {
        let totalRows = sections.flatMap(\.rows).count
        if totalRows == 1 {
            return "1 component"
        } else {
            return "\(totalRows) component"
        }
    }
}

struct ComponentsList_Previews: PreviewProvider {
    struct Preview: View {
        var body: some View {
            ComponentsList(filter: .constant(""), sections: [
                .init(name: "DataStore",
                      folderName: "DataStores",
                      rows: [
                    .init(name: "WordpressDataStore", isSelected: false, onSelect: {}, onDuplicate: {})
                ],
                      onSelect: {}),
                .init(name: "Repository",
                      folderName: "Repositories",
                      rows: [
                    .init(name: "WordpressRepository", isSelected: true, onSelect: {}, onDuplicate: {})
                ],
                      onSelect: {}),
                .init(name: "Shared",
                      folderName: nil,
                      rows: [
                    .init(name: "Networking", isSelected: false, onSelect: {}, onDuplicate: {})
                ],
                      onSelect: {})
                
            ])
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
