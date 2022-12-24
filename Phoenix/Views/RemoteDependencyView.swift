import Component
import SwiftPackage
import SwiftUI

struct RemoteDependencyView: View {
    @Binding var dependency: RemoteDependency
    
    let allDependencyTypes: [IdentifiableWithSubtype<PackageTargetType>]
    
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("URL:")
                TextField("url", text: $dependency.url)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: onRemove) { Image(systemName: "trash") }
            }
            ExternalDependencyNameView(name: $dependency.name)
            ExternalDependencyVersionView(version: $dependency.version)
            TargetTypesView(targetTypes: $dependency.targetTypes, allDependencyTypes: allDependencyTypes)
        }
        .padding()
    }
}

struct RemoteDependencyView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteDependencyView(
            dependency: .constant(
                .init(
                    url: "git@github.com/repo",
                    name: .name("Name"),
                    value: .branch(name: "main")
                )
            ),
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
            onRemove: {}
        )
    }
}
