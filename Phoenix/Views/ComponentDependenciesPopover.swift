import Package
import SwiftUI

struct ComponentDependenciesPopover: View {
    @Binding var showingPopup: Bool
    @Binding var component: Component?
    let allComponentNames: [Name]

    var body: some View {
        ZStack {
            List {
                ForEach(allComponentNames.filter { name in
                    self.component?.name != name && self.component?.dependencies.contains(where: { dependency in dependency.name == name }) == false
                }) { name in
                    Text("Name: \(name.full)")
                        .onTapGesture {
                            self.component?.dependencies.insert(
                                ComponentDependency(name: name,
                                                    contract: nil,
                                                    implementation: nil,
                                                    tests: nil,
                                                    mock: nil)
                            )
                            showingPopup = false
                        }
                }
                Button(action: { showingPopup = false }, label: { Text("Cancel") })
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
