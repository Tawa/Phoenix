import Component
import SwiftPackage
import SwiftUI

struct RemoteComponentDependencyView: View {
    @Binding var dependency: RemoteComponentDependency
    let remoteDependency: RemoteComponent?
    let allDependencyTypes: [IdentifiableWithSubtype<PackageTargetType>]
    let onSelect: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("URL: ")
                    .bold()
                Text(dependency.url)
                Button(action: onSelect) {
                    Text("Open")
                }
                Button(action: onRemove) {
                    Image(systemName: "trash")
                }
            }
            ForEach(remoteDependency?.names ?? []) { key in
                HStack {
                    Divider()
                    VStack(alignment: .leading) {
                        Text(title(for: key))
                            .bold()
                        TargetTypesView(
                            targetTypes: .init(get: { dependency.targetTypes[key] ?? [] },
                                               set: { dependency.targetTypes[key] = $0 }),
                            allDependencyTypes: allDependencyTypes
                        )
                    }
                }
            }
        }
    }
    
    private func title(for name: ExternalDependencyName) -> String {
        switch name {
        case .name(let string):
            return "Name: \(string)"
        case .product(let name, let package):
            return "Product Name: \(name) - Package: \(package)"
        }
    }
}

struct RemoteComponentDependencyView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteComponentDependencyView(
            dependency: .constant(
                .init(
                    url: "git@github.com/repo",
                    targetTypes: [
                        .name("Name"):[
                            .init(name: "Implementation", isTests: false),
                            .init(name: "Implementation", isTests: true)
                        ],
                        .product(name: "ProductName", package: "Package"):[
                            .init(name: "Implementation", isTests: false),
                            .init(name: "Implementation", isTests: true)
                        ]
                    ])
            ),
            remoteDependency: nil,
            allDependencyTypes: [
                .init(title: "Contract",
                      subtitle: nil,
                      value: .init(name: "Contract", isTests: false),
                      subValue: nil
                     ),
                .init(title: "Implementation",
                      subtitle: "Tests",
                      value: .init(name: "Implementation", isTests: false),
                      subValue: .init(name: "Implementation", isTests: true)
                     ),
                .init(title: "Mock",
                      subtitle: nil,
                      value: .init(name: "Mock", isTests: false),
                      subValue: nil
                     )
            ],
            onSelect: {},
            onRemove: {}
        )
    }
}
