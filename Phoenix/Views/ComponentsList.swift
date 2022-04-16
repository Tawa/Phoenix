import Package
import SwiftUI

struct ComponentsList: View {
    @Binding var componentsFamilies: [ComponentsFamily]
    @Binding var selectedName: Name?
    let onFamilySelection: (Family) -> Void
    let onAddButton: () -> Void
    let familyFolderNameProvider: FamilyFolderNameProviding

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Components:")
                    .font(.largeTitle)
                    .padding()
                Button(action: onAddButton) {
                    Label {
                        Text("Add New Component")
                    } icon: {
                        Image(systemName: "plus")
                    }

                }
                .padding(2)
            }.frame(maxWidth: .infinity)
            List {
                ForEach(componentsFamilies) { componentsFamily in
                    Section(header: HStack {
                        Text(familyName(for: componentsFamily.family))
                            .font(.title)
                        Button(action: { onFamilySelection(componentsFamily.family) },
                               label: { Image(systemName: "rectangle.and.pencil.and.ellipsis") })
                        .buttonStyle(PlainButtonStyle())
                    }) {
                        ForEach(componentsFamily.components) { component in
                            ComponentListItem(
                                name: componentName(component, for: componentsFamily.family),
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
            }
            .padding()
            .listStyle(BorderedListStyle())
        }
    }

    private func componentName(_ component: Component, for family: Family) -> String {
        family.ignoreSuffix == true ? component.name.given : component.name.given + component.name.family
    }

    private func familyName(for family: Family) -> String {
        if let folder = family.folder, !folder.isEmpty {
            return folder
        } else {
            return familyFolderNameProvider.folderName(forFamily: family.name)
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
                           onFamilySelection: { _ in },
                           onAddButton: {},
                           familyFolderNameProvider: FamilyFolderNameProvider())
        }
    }

    static var previews: some View {
        Preview()
    }
}
