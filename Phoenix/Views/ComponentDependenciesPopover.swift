import Package
import SwiftUI

struct ComponentDependenciesPopover: View {
    @EnvironmentObject private var store: PhoenixDocumentStore
    @Binding var showingPopup: Bool
    
    @State private var externalURL: String = ""
    @State private var externalName: ExternalDependencyName = .name("")
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
                                            externalDescription = .from(value: "")
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
                                        externalDescription = .from(value: value)
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
                                    TextField("Product", text: Binding(get: { package }, set: { update(externalProduct: $0) }))
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
                Button(action: { showingPopup = false }, label: { Text("Cancel") })
            }
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
