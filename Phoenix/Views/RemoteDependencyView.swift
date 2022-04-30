import Package
import SwiftUI

struct RemoteDependencyView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let dependency: RemoteDependency
    let types: [ModuleType]
    @State private var versionText: String

    internal init(dependency: RemoteDependency, types: [ModuleType]) {
        self.dependency = dependency
        self.types = types
        switch dependency.version {
        case let .from(version):
            versionText = version
        case let .branch(name):
            versionText = name
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(dependency.name.name)
                    .font(.largeTitle)
                Button(action: {
                    store.removeRemoteDependencyForSelectedComponent(dependency: dependency)
                }, label: { Text("Remove") })
                Spacer()
            }
            Text(dependency.url)
                .font(.title)

            HStack {
                Menu {
                    Button("from") {
                        store.updateVersionForRemoteDependency(dependency: dependency, version: .from(version: ""))
                    }
                    Button("branch") {
                        store.updateVersionForRemoteDependency(dependency: dependency, version: .branch(name: ""))
                    }
                } label: {
                    switch dependency.version {
                    case .from:
                        Text("from")
                    case .branch:
                        Text("branch")
                    }
                }
                .frame(width: 150)
                switch dependency.version {
                case let .from(version):
                    TextField("1.0.0", text: .init(get: { version }, set: { versionText = $0 }))
                        .onSubmit { store.updateVersionForRemoteDependency(dependency: dependency, version: .from(version: versionText)) }
                        .font(.largeTitle)
                        .foregroundColor(dependency.version != .from(version: versionText) ? .red : nil)
                case let .branch(name):
                    TextField("main", text: .init(get: { name }, set: { versionText = $0 }))
                        .onSubmit { store.updateVersionForRemoteDependency(dependency: dependency, version: .branch(name: versionText)) }
                        .font(.largeTitle.weight(.regular))
                        .foregroundColor(dependency.version != .branch(name: versionText) ? .red : nil)
                }
                Spacer()
            }

            HStack(alignment: .top) {
                if types.contains(.contract) {
                    Toggle(isOn: Binding(get: { dependency.contract },
                                         set: { store.updateModuleTypeForRemoteDependency(dependency: dependency, type: .contract, value: $0) })) {
                        Text("Contract")
                    }
                }
                if types.contains(.implementation) {
                    VStack {
                        Toggle(isOn: Binding(get: { dependency.implementation },
                                             set: { store.updateModuleTypeForRemoteDependency(dependency: dependency, type: .implementation, value: $0) })) {
                            Text("Implementation")
                        }
                        Toggle(isOn: Binding(get: { dependency.tests },
                                             set: { store.updateModuleTypeForRemoteDependency(dependency: dependency, type: .tests, value: $0) })) {
                            Text("Tests")
                        }
                    }
                }
                if types.contains(.mock) {
                    Toggle(isOn: Binding(get: { dependency.mock },
                                         set: { store.updateModuleTypeForRemoteDependency(dependency: dependency, type: .mock, value: $0) })) {
                        Text("Mocks")
                    }
                }
            }

        }
        .padding()
    }
}

struct RemoteDependencyView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteDependencyView(dependency: RemoteDependency(url: "git@github.com:team/repo.git",
                                                          name: .name("Repo Name"),
                                                          value: .branch(name: "main")),
                             types: ModuleType.allCases)
    }
}
