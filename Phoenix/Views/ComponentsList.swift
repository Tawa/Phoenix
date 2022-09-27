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
    let rows: [ComponentsListRow]
    let onSelect: () -> Void
    
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
    @Binding var filterType: FilterType?

    let sections: [ComponentsListSection]
    
    var body: some View {
        VStack(alignment: .leading) {
            FilterView(filter: $filter, filterType: $filterType)
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
                        }
                    } header: {
                        HStack {
                            Text(section.name)
                                .font(.title.bold())
                            Button(action: section.onSelect,
                                   label: { Image(systemName: "rectangle.and.pencil.and.ellipsis") })
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    Divider()
                }
                Text(numberOfComponentsString)
                    .foregroundColor(.gray)
            }
            .searchable(text: $filter)
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
            ComponentsList(filter: .constant(""), filterType: .constant(.text), sections: [
                .init(name: "DataStore", rows: [
                    .init(name: "WordpressDataStore", isSelected: false, onSelect: {}, onDuplicate: {})
                ],
                      onSelect: {}),
                .init(name: "Repository", rows: [
                    .init(name: "WordpressRepository", isSelected: true, onSelect: {}, onDuplicate: {})
                ],
                      onSelect: {}),
                .init(name: "Shared", rows: [
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
