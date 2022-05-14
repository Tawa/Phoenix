import Package
import SwiftUI

struct ComponentDependenciesPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore
    @Binding var showingPopup: Bool
    
    @State private var externalURL: String = ""
    @State private var externalName: ExternalDependencyName = .name("")
    @State private var externalDescription: ExternalDependencyVersion = .from(version: "")

    @State private var filter: String = ""
    @FocusState private var textFieldFocus

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
        VStack {
            HSplitView {
                VStack(alignment: .leading) {
                    HStack {
                        TextField("Filter", text: $filter)
                            .focused($textFieldFocus)
                            .onAppear(perform: {
                                textFieldFocus = true
                            })
                            .font(.title)
                            .onExitCommand(perform: {
                                if filter.isEmpty {
                                    showingPopup = false
                                } else {
                                    filter = ""
                                }
                            })
                        if !filter.isEmpty {
                            Button(action: { filter = "" }, label: {
                                Image(systemName: "clear.fill")
                            })
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }.padding(16)
                    List {
                        Text("Components:")
                            .font(.largeTitle)
                        let filteredNames = Dictionary(grouping: store.allNames.filter { name in
                            if !filter.isEmpty && !name.full.lowercased().contains(filter.lowercased()) {
                                return false
                            }
                            return store.selectedName != name && !store.selectedComponentDependenciesContains(dependencyName: name)
                        }, by: { $0.family })
                        ForEach(filteredNames.keys.sorted(), id: \.self) { familyName in
                            Section {
                                ForEach(filteredNames[familyName]!) { name in
                                    Button {
                                        store.addDependencyToSelectedComponent(dependencyName: name)
                                        showingPopup = false
                                    } label: {
                                        Text((store.title(for: name)))
                                    }
                                }
                            } header: {
                                Text(familyName)
                                    .font(.title)
                            }
                        }
                        Spacer()
                    }
                    .listStyle(SidebarListStyle())
                    .padding(.horizontal)
                }.frame(width: 400)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
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
                                Menu {
                                    Button(action: {
                                        externalDescription = .from(version: "")
                                    }, label: { Text("from") })
                                    Button(action: {
                                        externalDescription = .branch(name: "")
                                    }, label: { Text("branch") })
                                } label: {
                                    Text(externalDescriptionMenuTitle)
                                }
                            }.frame(width: 100)
                            TextField(externalDescriptionTextPlaceholder, text: Binding(get: { externalDescriptionTextValue }, set: { value in
                                switch externalDescription {
                                case .from:
                                    externalDescription = .from(version: value)
                                case .branch:
                                    externalDescription = .branch(name: value)
                                }
                            }))
                            .font(.title)
                            .padding()
                            Spacer()
                        }

                        HStack {
                            Menu {
                                Button(action: setExternalNameAsName, label: { Text("Name") })
                                Button(action: setExternalNameAsProduct, label: { Text("product") })
                            } label: {
                                Text(externalNameMenuTitle)
                            }
                            .frame(width: 100)

                            TextField("Name", text: Binding(get: { externalName.name }, set: { update(externalName: $0) }))
                                .font(.largeTitle)
                                .padding()
                            if case .product(_, let package) = externalName {
                                TextField("Package", text: Binding(get: { package }, set: { update(externalProduct: $0) }))
                                    .font(.largeTitle)
                                    .padding()
                            }
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
            Button(action: { showingPopup = false },
                   label: { Text("Cancel").font(.largeTitle).padding() })
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onExitCommand(perform: { showingPopup = false })
    }
    
    private var externalDescriptionMenuTitle: String {
        switch externalDescription {
        case .from:
            return "from"
        case .branch:
            return "branch"
        }
    }
    
    private var externalNameMenuTitle: String {
        switch externalName {
        case .name:
            return "name"
        case .product:
            return "product"
        }
    }
    
    private var externalNameString: String {
        switch externalName {
        case .name(let string):
            return string
        case .product(let name, _):
            return name
        }
    }
    
    private var externalNamePackageString: String {
        switch externalName {
        case .name:
            return ""
        case .product(_, let package):
            return package
        }
    }
    
    private func setExternalNameAsName() {
        if case let .product(nameValue, _) = externalName {
            externalName = .name(nameValue)
        } else {
            externalName = .name("")
        }
    }
    
    private func setExternalNameAsProduct() {
        if case let .name(nameValue) = externalName {
            externalName = .product(name: nameValue, package: "")
        } else {
            externalName = .product(name: "", package: "")
        }
    }
    
    private func update(externalName name: String) {
        switch externalName {
        case .name:
            externalName = .name(name)
        case .product(_, let package):
            externalName = .product(name: name, package: package)
        }
    }
    
    private func update(externalProduct package: String) {
        switch externalName {
        case .name:
            break
        case .product(let name, _):
            externalName = .product(name: name, package: package)
        }
    }
}
