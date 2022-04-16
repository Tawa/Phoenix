import Package
import SwiftUI

struct DependencyView: View {
    @Binding var dependency: ComponentDependency
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(dependency.name.full)
                .font(.title)
            Button(action: onDelete, label: { Text("Remove") })
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
            onDelete: {})
    }
}
