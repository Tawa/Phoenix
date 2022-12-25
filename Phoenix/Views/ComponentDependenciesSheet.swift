import AccessibilityIdentifiers
import SwiftUI

struct ComponentDependenciesListRow: Hashable, Identifiable {
    var id: Int { hashValue }
    let name: String
    let onSelect: () -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct ComponentDependenciesListSection: Hashable, Identifiable {
    var id: Int { hashValue }
    let name: String
    var rows: [ComponentDependenciesListRow]
}

struct ComponentDependenciesSheet: View {
    
    let sections: [ComponentDependenciesListSection]
    let onDismiss: () -> Void
    
    @State private var filter: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            FilterView(text: $filter,
                       onSubmit: performSubmit)
            .with(accessibilityIdentifier: DependenciesSheetIdentifiers.filter)
            .padding(.top)
            List {
                ForEach(filteredSections) { section in
                    Section {
                        ForEach(section.rows) { row in
                            Button {
                                row.onSelect()
                            } label: {
                                Text(row.name)
                            }
                            .padding(.leading, 2)
                            .with(accessibilityIdentifier: DependenciesSheetIdentifiers.component(named: row.name))
                        }
                    } header: {
                        Text(section.name)
                            .font(.title)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            Button(action: onDismiss) {
                Text("Cancel")
            }
            .keyboardShortcut(.cancelAction)
            .padding()
        }
        .frame(minWidth: 400)
    }
    
    private var filteredSections: [ComponentDependenciesListSection] {
        guard !filter.isEmpty else { return sections }
        return sections
            .map { item -> ComponentDependenciesListSection in
                var section = item
                section.rows.removeAll(where: { !$0.name.lowercased().contains(filter.lowercased()) })
                return section
            }.filter { section in !section.rows.isEmpty }
    }
    
    private func performSubmit() {
        let rows = filteredSections.flatMap(\.rows)
        guard rows.count == 1 else { return }
        rows.first?.onSelect()
    }
}
