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
    let familyName: String
    let sections: [ComponentDependenciesListSection]
    let disabledSections: [ComponentDependenciesListSection]
    let onOpenFamilySettings: () -> Void
    let onDismiss: () -> Void
    
    @State private var filter: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            FilterView(text: $filter,
                       onSubmit: performSubmit)
            .with(accessibilityIdentifier: DependenciesSheetIdentifiers.filter)
            .padding(.top)
            List {
                ForEach(filtered(sections: sections)) { section in
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
                Divider()
                let filteredDisabledSections = filtered(sections: disabledSections)
                if !filteredDisabledSections.isEmpty {
                    Text("The following components are not allowed to be used by ").foregroundColor(.red)
                    + Text("\"\(familyName)\"").bold().foregroundColor(.red)
                    + Text(" family rules.").foregroundColor(.red)
                    Text("This rule can be changed in the \"\(familyName)\" Family settings.")
                    Button(action: onOpenFamilySettings) {
                        Text("Open \"\(familyName)\" Family settings.")
                    }
                    ForEach(filtered(sections: disabledSections)) { section in
                        Section {
                            ForEach(section.rows) { row in
                                Button {
                                    row.onSelect()
                                } label: {
                                    Text(row.name)
                                }
                                .disabled(true)
                                .padding(.leading, 2)
                            }
                        } header: {
                            Text(section.name)
                                .font(.title)
                        }
                    }
                }
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
    
    private func filtered(sections: [ComponentDependenciesListSection]) -> [ComponentDependenciesListSection] {
        guard !filter.isEmpty else { return sections }
        return sections
            .map { item -> ComponentDependenciesListSection in
                var section = item
                section.rows.removeAll(where: { !$0.name.lowercased().contains(filter.lowercased()) })
                return section
            }.filter { section in !section.rows.isEmpty }
    }
    
    private func performSubmit() {
        let rows = filtered(sections: sections).flatMap(\.rows)
        guard rows.count == 1 else { return }
        rows.first?.onSelect()
    }
}
