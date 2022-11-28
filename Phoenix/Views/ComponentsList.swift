import AccessibilityIdentifiers
import Combine
import SwiftUI

struct ComponentsListRow: Hashable, Identifiable {
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

struct ComponentsListSection: Hashable, Identifiable {
    let id: String
    
    let name: String
    let folderName: String?
    let rows: [ComponentsListRow]
}

struct ComponentsList: View {
    @EnvironmentObject var composition: Composition
    
    let sections: [ComponentsListSection]
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.rows) { row in
                            ComponentListItem(
                                name: row.name,
                                isSelected: row.isSelected,
                                onSelect: { composition.selectComponentUseCase().select(id: row.id) },
                                onDuplicate: { }
                            )
                            .with(accessibilityIdentifier: ComponentsListIdentifiers.component(named: row.name))
                        }
                    } header: {
                        Button(action: { composition.selectFamilyUseCase().select(id: section.id) },
                               label: {
                            HStack {
                                Text(section.name)
                                    .font(.title)
                                section.folderName.map { folderName -> Text? in
                                    guard folderName != section.name else { return nil }
                                    return Text("(\(Image(systemName: "folder")) \(folderName))")
                                }?.help("Folder Name")
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
