import Package
import SwiftUI

struct ComponentsList: View {
    @EnvironmentObject private var store: PhoenixDocumentStore
    private let familyFolderNameProvider: FamilyFolderNameProviding = FamilyFolderNameProvider()

    @State private var filter: String = ""

    let onAddButton: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: onAddButton) {
                Label {
                    Text("Add New Component")
                } icon: {
                    Image(systemName: "plus")
                }
            }.padding([.top, .horizontal])
            HStack {
                TextField("Filter", text: $filter)
                    .onExitCommand(perform: { filter = "" })
                if !filter.isEmpty {
                    Button(action: { filter = "" }, label: {
                        Image(systemName: "clear.fill")
                    })
                    .aspectRatio(1, contentMode: .fit)
                }
            }.padding()
            List {
                if store.componentsFamilies.isEmpty {
                    Text("0 components")
                        .foregroundColor(.gray)
                } else {
                    ForEach(store.componentsFamilies, id: \.family) { componentsFamily in
                        Section {
                            ForEach(componentsFamily.components.filter { filter.isEmpty ? true : $0.name.full.lowercased().contains(filter.lowercased()) }) { component in
                                ComponentListItem(
                                    name: componentName(component, for: componentsFamily.family),
                                    isSelected: store.selectedName == component.name,
                                    onSelect: { store.selectComponent(withName: component.name) }
                                )
                            }
                        } header: {
                            HStack {
                                Text(familyName(for: componentsFamily.family))
                                    .font(.title.bold())
                                Button(action: { store.selectFamily(withName: componentsFamily.family.name) },
                                       label: { Image(systemName: "rectangle.and.pencil.and.ellipsis") })
                                Spacer()
                            }
                            .padding(.vertical)
                        }
                        Divider()
                    }
                }
            }
            .frame(minHeight: 200, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
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
            ComponentsList(onAddButton: {})
        }
    }

    static var previews: some View {
        Preview()
    }
}
