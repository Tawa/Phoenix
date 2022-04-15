import Package
import SwiftUI

struct ComponentsList: View {
    @Binding var componentsFamilies: [ComponentsFamily]
    @Binding var selectedName: Name?
    let folderNameForFamily: (String) -> String
    let onAddButton: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Components:")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            List {
                ForEach(componentsFamilies) { componentsFamily in
                    Section(header: Text(componentsFamily.family.folder ?? componentsFamily.family.name).font(.title)) {
                        ForEach(componentsFamily.components) { component in
                            ComponentListItem(
                                name: component.name.given + component.name.family,
                                isSelected: selectedName == component.name,
                                onSelect: { selectedName = component.name }
                            )
                        }
                    }
                }

                if componentsFamilies.isEmpty {
                    Text("0 components")
                        .foregroundColor(.gray)
                }
                Button(action: onAddButton) {
                    Text("Add")
                }
            }
        }
    }
}

struct ComponentsList_Previews: PreviewProvider {
    struct Preview: View {
        @State var families: [ComponentsFamily] = []
        @State var selectedName: Name?

        var body: some View {
            ComponentsList(componentsFamilies: $families,
                           selectedName: $selectedName,
                           folderNameForFamily: { $0 },
                           onAddButton: {})
        }
    }

    static var previews: some View {
        Preview()
    }
}
