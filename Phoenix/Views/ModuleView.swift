import Package
import SwiftUI

struct ModuleView: View {
    @Binding var moduleDescription: ModuleDescription

    var body: some View {
        List {
            Section {
                ForEach(moduleDescription.dependencies) { dependency in
                    switch dependency {
                    case let .module(name, type):
                        HStack {
                            Text(name.full)
                            switch type {
                            case .contract:
                                Text("Contract")
                            case .implementation:
                                Text("Implementation")
                            case .mock:
                                Text("Mock")
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Dependencies")
                        .font(.title)
                    Button(action: { }, label: { Image(systemName: "plus") })
                }
            }
            Divider()

            HStack {
                Toggle(isOn: $moduleDescription.hasTests) {
                    Text("Has Tests")
                        .font(.title)
                }
            }

            if moduleDescription.hasTests {
                Section {
                    ForEach(moduleDescription.testsDependencies) { dependency in
                        switch dependency {
                        case let .module(name, type):
                            HStack {
                                Text(name.full)
                                Menu {

                                } label: {
                                    Text("\(String(describing: type))")
                                }
                                Spacer()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Tests Dependencies")
                            .font(.title)
                        Button(action: { }, label: { Image(systemName: "plus") })
                    }
                }
            }
        }
    }
}

struct ModuleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ModuleView(moduleDescription: .constant(ModuleDescription(
                dependencies: [],
                hasTests: false,
                testsDependencies: [])))
            ModuleView(moduleDescription: .constant(ModuleDescription(
                dependencies: [
                    .module(Name(given: "Wordpress", family: "Repository"), type: .contract)
                ],
                hasTests: true,
                testsDependencies: [
                    .module(Name(given: "Wordpress", family: "Repository"), type: .mock)
                ])))
        }
    }
}
