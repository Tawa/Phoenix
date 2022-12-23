import AccessibilityIdentifiers
import Combine
import Component
import SwiftUI

struct RemoteComponentsListRow: Hashable, Identifiable {
    let id: String
    let name: String
    let isSelected: Bool
    
    init(id: String,
         name: String,
         isSelected: Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
}

struct RemoteComponentsList: View {
    let rows: [RemoteComponentsListRow]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(rows) { row in
                    ComponentListItem(
                        name: row.name,
                        isSelected: row.isSelected,
                        onSelect: { onSelect(row.id) }
                    )
                    .with(accessibilityIdentifier: ComponentsListIdentifiers.component(named: row.name))
                }
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
            return "1 component"
        } else {
            return "\(totalRows) components"
        }
    }
}

struct RemoteComponentsList_Previews: PreviewProvider {
    static var previews: some View {
        RemoteComponentsList(
            rows: [
                .init(id: "id0", name: "git@example.com", isSelected: true),
                .init(id: "id1", name: "git@anotherexample.com", isSelected: false),
                .init(id: "id2", name: "git@anotherone.com", isSelected: false)
            ],
            onSelect: { _ in }
        )
    }
}
