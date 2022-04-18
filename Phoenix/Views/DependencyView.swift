import Package
import SwiftUI

struct DependencyModuleTypeSelectorView: View {
    let title: String
    @Binding var moduleType: ModuleType?

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
            Menu {
                ForEach(ModuleType.allCases) { type in
                    Button(String(describing: type), action: { moduleType = type })
                }
                if moduleType != nil {
                    Divider()
                    Button(action: { moduleType = nil }, label: { Text("Remove") })
                }
            } label: {
                if let contract = moduleType {
                    Text(String(describing: contract))
                } else {
                    Text("Add")
                }
            }
        }
    }
}

struct DependencyView: View {
    @Binding var dependency: ComponentDependency
    let types: Set<ModuleType>
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(dependency.name.full)
                    .font(.title)
                Button(action: onDelete, label: { Text("Remove") })
            }
            HStack {
                if types.contains(.contract) {
                    DependencyModuleTypeSelectorView(title: "Contract: ",
                                                     moduleType: Binding(get: { dependency.contract }, set: { dependency.contract = $0 }))
                    Divider()
                }
                if types.contains(.implementation) {
                    DependencyModuleTypeSelectorView(title: "Implementation: ",
                                                     moduleType: Binding(get: { dependency.implementation }, set: { dependency.implementation = $0 }))
                    Divider()
                    DependencyModuleTypeSelectorView(title: "Tests: ",
                                                     moduleType: Binding(get: { dependency.tests }, set: { dependency.tests = $0 }))
                    Divider()
                }
                if types.contains(.mock) {
                    DependencyModuleTypeSelectorView(title: "Mock: ",
                                                     moduleType: Binding(get: { dependency.mock }, set: { dependency.mock = $0 }))
                }
            }
        }
    }
}

struct DependencyView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyView(
            dependency: .constant(ComponentDependency(name: Name(given: "Wordpress", family: "DataStore"),
                                                      contract: nil,
                                                      implementation: .contract,
                                                      tests: .mock,
                                                      mock: nil)),
            types: [.contract, .implementation, .mock],
            onDelete: {})
    }
}
