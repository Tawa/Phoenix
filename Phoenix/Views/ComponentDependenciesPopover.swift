import Package
import SwiftUI

struct ComponentDependenciesPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore
    @Binding var showingPopup: Bool

    var body: some View {
        ZStack {
            List {
                ForEach(store.allNames.filter { name in
                    store.selectedName != name && store.selectedComponentDependencies.contains(where: { dependency in dependency.name == name }) == false
                }) { name in
                    Button {
                        store.send(action: .addDependencyToSelectedComponent(dependencyName: name))
                        showingPopup = false
                    } label: {
                        Text("\(name.family): \(store.title(for: name))")
                    }

                }
                Button(action: { showingPopup = false }, label: { Text("Cancel") })
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
