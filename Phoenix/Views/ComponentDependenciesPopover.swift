import Package
import SwiftUI

struct ComponentDependenciesPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore
    @Binding var showingPopup: Bool
    @Binding var showingNewComponentPopup: Bool

    @State private var externalURL: String = ""

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    List {
                        Text("Components:")
                            .font(.largeTitle)
                        ForEach(store.allNames.filter { name in
                            store.selectedName != name && store.selectedComponentDependencies.contains(where: { dependency in dependency.name == name }) == false
                        }) { name in
                            Button {
                                store.addDependencyToSelectedComponent(dependencyName: name)
                                showingPopup = false
                            } label: {
                                Text("\(name.family): \(store.title(for: name))")
                            }
                        }

                        Button(action: { showingNewComponentPopup = true }, label: { Text("Add New") })
                    }

                    List {
                        Text("External Dependency:")
                            .font(.largeTitle)
                        HStack {
                            Text("URL:")
                            TextField("ex: git@github.com:team/repo.git", text: $externalURL)
                        }
                    }
                }
                Button(action: { showingPopup = false }, label: { Text("Cancel") })
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onExitCommand(perform: { showingPopup = false })
    }
}
