import AccessibilityIdentifiers
import Combine
import PhoenixDocument
import SwiftUI

struct ComponentsListRow: Hashable, Identifiable {
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

struct ComponentsListSection: Hashable, Identifiable {
    let id: String
    
    let name: String
    let folderName: String?
    let rows: [ComponentsListRow]
}

struct ComponentsList: View {
    let sections: [ComponentsListSection]
    let footerText: String
    let onSelect: (Name) -> Void
    let onSelectSection: (String) -> Void
    
    var body: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        ComponentListItem(
                            name: row.name,
                            isSelected: row.isSelected,
                            onSelect: { onSelect(row.id) }
                        )
                        .with(accessibilityIdentifier: ComponentsListIdentifiers.component(named: row.name))
                    }
                } header: {
                    Button(action: { onSelectSection(section.id) },
                           label: {
                        HStack {
                            Text(section.name)
                                .font(.title)
                            section.folderName.map { folderName -> Text? in
                                guard folderName != section.name else { return nil }
                                return Text("(\(Image(systemName: "folder")) \(folderName))")
                            }?.help("Folder Name")
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    })
                    .buttonStyle(.plain)
                    .padding(.vertical)
                    .with(accessibilityIdentifier: ComponentsListIdentifiers.familySettingsButton(named: section.name))
                }
                Divider()
            }
            Text(footerText)
                .lineLimit(nil)
                .foregroundColor(.gray)
        }
        .frame(minHeight: 200, maxHeight: .infinity)
        .listStyle(SidebarListStyle())
    }
}

struct ComponentsList_Previews: PreviewProvider {
    static var previews: some View {
        ComponentsList(
            sections: [
                ComponentsListSection(
                    id: "id0",
                    name: "Repositories",
                    folderName: nil,
                    rows: [
                        ComponentsListRow(id: Name(given: "Home", family: "Repository"), name: "HomeRepository", isSelected: true),
                        ComponentsListRow(id: Name(given: "Settings", family: "Repository"), name: "SettingsRepository", isSelected: false),
                        ComponentsListRow(id: Name(given: "About", family: "Repository"), name: "AboutRepository", isSelected: false),
                    ]
                ),
            ],
            footerText: "3 components",
            onSelect: { _ in },
            onSelectSection: { _ in }
        )
    }
}
