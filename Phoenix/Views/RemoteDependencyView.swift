import Package
import SwiftUI

struct RemoteDependencyView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let dependency: RemoteDependency
    let types: Set<ModuleType>

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
                             types: Set(ModuleType.allCases))
    }
}
