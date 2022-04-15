import Package
import SwiftUI

struct ComponentsList: View {
    @Binding var components: [String: [Component]]
    @Binding var selectedName: Name?
    let folderNameForFamily: (String) -> String
    let onAddButton: () -> Void

    var body: some View {
        List {
            ForEach(components.keys.sorted(), id: \.self) { family in
                Section(header: Text(folderNameForFamily(family))) {
                    ForEach(components[family] ?? []) { component in
                        ComponentListItem(
                            name: component.name.given + component.name.family,
                            isSelected: selectedName == component.name,
                            onSelect: { selectedName = component.name }
                        )
                    }
                }
            }

            if components.isEmpty {
                Text("0 components")
                    .foregroundColor(.gray)
            }
            Button(action: onAddButton) {
                Text("Add")
            }
        }
    }
}

struct ComponentsList_Previews: PreviewProvider {
    struct Preview: View {
        @State var components: [String: [Component]] = [:]
        @State var selectedName: Name?

        var body: some View {
            ComponentsList(components: $components,
                           selectedName: $selectedName,
                           folderNameForFamily: { $0 },
                           onAddButton: {})
        }
    }

    static var previews: some View {
        Preview()
    }
}
