import AccessibilityIdentifiers
import Combine
import PhoenixDocument
import SwiftUI

struct MacrosList: View {
    let selected: MacroComponent.ID?
    let rows: [MacroComponent]
    let onSelect: (MacroComponent.ID) -> Void
    
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
            return "1 macro"
        } else {
            return "\(totalRows) macros"
        }
    }
}

struct MacrosList_Previews: PreviewProvider {
    static var previews: some View {
        MacrosList(
            selected: "FeatureMacros",
            rows: [
                MacroComponent(name: "FeatureMacros"),
                MacroComponent(name: "RepositoryMacros"),
                MacroComponent(name: "UserCasesMacros")
            ],
            onSelect: { _ in }
        )
    }
}
