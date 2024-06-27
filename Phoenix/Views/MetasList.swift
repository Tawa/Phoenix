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
