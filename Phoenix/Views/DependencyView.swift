import Package
import SwiftUI

struct DependencyModuleTypeSelectorView: View {
    let title: String
    let value: ModuleType?

    let onValueChange: (ModuleType?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
            Menu {
                ForEach(ModuleType.allCases) { type in
                    Button(String(describing: type), action: { onValueChange(type) })
                }
                if value != nil {
                    Divider()
                    Button(action: { onValueChange(nil) }, label: { Text("Remove") })
                }
            } label: {
                if let value = value {
                    Text(String(describing: value))
                } else {
                    Text("Add")
                }
            }
        }
    }
}

struct DependencyView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let dependency: ComponentDependency
    let types: Set<ModuleType>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(store.title(for: dependency.name))
                    .font(.title)
                Button(action: {
                    store.removeDependencyForSelectedComponent(componentDependency: dependency)
                }, label: { Text("Remove") })
            }
            HStack(alignment: .top) {
                if types.contains(.contract) {
                    DependencyModuleTypeSelectorView(title: "Contract: ",
                                                     value: dependency.contract,
                                                     onValueChange: { newValue in
                        store.updateModuleTypeForDependency(dependency: dependency, type: .contract, value: newValue)
                    })
                }
                if types.contains(.implementation) {
                    VStack {
                        DependencyModuleTypeSelectorView(title: "Implementation: ",
                                                         value: dependency.implementation,
                                                         onValueChange: { newValue in
                            store.updateModuleTypeForDependency(dependency: dependency, type: .implementation, value: newValue)
                        })
                        DependencyModuleTypeSelectorView(title: "Tests: ",
                                                         value: dependency.tests,
                                                         onValueChange: { newValue in
                            store.updateModuleTypeForDependency(dependency: dependency, type: .tests, value: newValue)
                        })
                    }
                }
                if types.contains(.mock) {
                    DependencyModuleTypeSelectorView(title: "Mock: ",
                                                     value: dependency.mock,
                                                     onValueChange: { newValue in
                        store.updateModuleTypeForDependency(dependency: dependency, type: .mock, value: newValue)
                    })
                }
            }
        }.padding()
    }
}

struct DependencyView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyView(
            dependency: ComponentDependency(name: Name(given: "Wordpress", family: "DataStore"),
                                            contract: nil,
                                            implementation: .contract,
                                            tests: .mock,
                                            mock: nil),
            types: [.contract, .implementation, .mock])
    }
}
