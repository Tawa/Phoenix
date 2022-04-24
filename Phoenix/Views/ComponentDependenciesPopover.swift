import Package
import SwiftUI

struct ComponentDependenciesPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore
    @Binding var showingPopup: Bool

    @State private var externalURL: String = ""
    @State private var externalName: String = ""
    @State private var externalDescription: ExternalDependencyDescription = .from(value: "")

    private var externalDescriptionTextPlaceholder: String {
        switch externalDescription {
        case .from:
            return "1.0.0"
        case .branch:
            return "main"
        }
    }

    private var externalDescriptionTextValue: String {
        switch externalDescription {
        case .from(let value):
            return value
        case .branch(let name):
            return name
        }
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    ScrollView {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Components:")
                                    .font(.largeTitle)
                                ForEach(store.allNames.filter { name in
                                    store.selectedName != name && !store.selectedComponentDependenciesContains(dependencyName: name)
                                }) { name in
                                    Button {
                                        store.addDependencyToSelectedComponent(dependencyName: name)
                                        showingPopup = false
                                    } label: {
                                        Text("\(name.family): \(store.title(for: name))")
                                    }
                                }
                            }
                            Spacer()
                        }
                    }.frame(width: 400)
                    Divider()
                    ScrollView {
                        VStack(spacing: 0) {
                            Text("External Dependency:")
                                .font(.largeTitle)
                            HStack {
                                HStack {
                                    Text("URL:")
                                        .font(.title)
                                    Spacer()
                                }
                                .frame(width: 100)
                                TextField("ex: git@github.com:team/repo.git", text: $externalURL)
                                    .font(.title)
                                    .padding()
                            }
                            HStack {
                                HStack {
                                    Text("Name")
                                        .font(.largeTitle)
                                    Spacer()
                                }
                                .frame(width: 100)
                                TextField("Name", text: $externalName)
                                    .font(.largeTitle)
                                    .padding()
                            }

                            HStack {
                                HStack {
                                    Menu {
                                        Button(action: { externalDescription = .from(value: "") }, label: { Text("from") })
                                        Button(action: { externalDescription = .branch(name: "") }, label: { Text(".branch") })
                                    } label: {
                                        switch externalDescription {
                                        case .from:
                                            Text("from")
                                        case .branch:
                                            Text(".branch")
                                        }
                                    }
                                }.frame(width: 100)
                                TextField(externalDescriptionTextPlaceholder, text: Binding(get: { externalDescriptionTextValue }, set: { value in
                                    switch externalDescription {
                                    case .from:
                                        externalDescription = .from(value: value)
                                    case .branch:
                                        externalDescription = .branch(name: value)
                                    }
                                }))
                                .font(.title)
                                .padding()
                                Spacer()
                            }

                            Button(action: { store.addRemoteDependencyToSelectedComponent(dependency: RemoteDependency(url: externalURL,
                                                                                                                       name: externalName,
                                                                                                                       value: externalDescription)) }) {
                                Text("Add Remote Dependency")
                            }
                        }
                    }
                    .padding()
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
