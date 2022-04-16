import Package
import SwiftUI

struct ComponentView: View {
    @Binding var component: Component?
    @Binding var allComponentNames: [Name]
    @State private var showingPopup: Bool = false

    var body: some View {
        ZStack {
            List {
                VStack(alignment: .leading) {
                    if let component = component {
                        HStack {
                            Text(component.name.full)
                                .font(.largeTitle)
                                .multilineTextAlignment(.leading)
                        }
                        Divider()
                        HStack {
                            Text("Platforms:")
                            Menu(iOSPlatformMenuTitle) {
                                ForEach(iOSVersion.allCases) { version in
                                    Button(action: { self.component?.iOSVersion = version }) {
                                        Text("\(String(describing: version))")
                                    }
                                }
                                if component.iOSVersion != nil {
                                    Button(action: { self.component?.iOSVersion = nil }) {
                                        Text("Remove")
                                    }
                                }
                            }.frame(width: 150)
                            Menu(macOSPlatformMenuTitle) {
                                ForEach(macOSVersion.allCases) { version in
                                    Button(action: { self.component?.macOSVersion = version }) {
                                        Text("\(String(describing: version))")
                                    }
                                }
                                if component.macOSVersion != nil {
                                    Button(action: { self.component?.macOSVersion = nil }) {
                                        Text("Remove")
                                    }
                                }
                            }.frame(width: 150)
                        }
                        Divider()
                        HStack {
                            Text("Module Types:")
                            Toggle(isOn: Binding(
                                get: { self.component?.modules.contains(.contract) == true },
                                set: { isOn in
                                    if isOn {
                                        self.component?.modules.insert(.contract)
                                    } else {
                                        self.component?.modules.remove(.contract)
                                    }
                                }),
                                   label: { Text("Contract") })
                            Toggle(isOn: Binding(
                                get: { self.component?.modules.contains(.implementation) == true },
                                set: { isOn in
                                    if isOn {
                                        self.component?.modules.insert(.implementation)
                                    } else {
                                        self.component?.modules.remove(.implementation)
                                    }
                                }),
                                   label: { Text("Implementation") })
                            Toggle(isOn: Binding(
                                get: { self.component?.modules.contains(.mock) == true },
                                set: { isOn in
                                    if isOn {
                                        self.component?.modules.insert(.mock)
                                    } else {
                                        self.component?.modules.remove(.mock)
                                    }
                                }),
                                   label: { Text("Mock") })
                        }
                        Divider()

                        Section {
                            ForEach(component.dependencies.sorted(by: { $0.name.full < $1.name.full })) { dependency in
                                DependencyView(dependency: Binding(get: { dependency },
                                                                   set: {
                                    self.component?.dependencies.remove(dependency)
                                    self.component?.dependencies.insert($0)
                                }),
                                               onDelete: { self.component?.dependencies.remove(dependency) })
                            }
                        } header: {
                            HStack {
                                Text("Dependencies")
                                    .font(.largeTitle)
                                Button(action: {
                                    showingPopup = true
                                }, label: { Image(systemName: "plus") })
                            }
                        }

                        Divider()

                    } else {
                        HStack {
                            Text("No Component Selected")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()

            }.sheet(isPresented: $showingPopup) {
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
    }

    private var iOSPlatformMenuTitle: String {
        if let iOSVersion = component?.iOSVersion {
            return ".iOS(.\(iOSVersion))"
        } else {
            return "Add iOS"
        }
    }

    private var macOSPlatformMenuTitle: String {
        if let macOSVersion = component?.macOSVersion {
            return ".macOS(.\(macOSVersion))"
        } else {
            return "Add macOS"
        }
    }
}

struct ComponentView_Previews: PreviewProvider {
    struct Preview: View {
        @State var component: Component? = Component(
            name: Name(given: "Wordpress", family: "Repository"),
            iOSVersion: .v13,
            macOSVersion: .v12,
            modules: .init(arrayLiteral: .contract, .implementation, .mock),
            dependencies: [])

        var body: some View {
            ComponentView(component: $component, allComponentNames: .constant([]))
        }
    }

    static var previews: some View {
        Group {
            Preview()
            ComponentView(component: .constant(nil),
                          allComponentNames: .constant([]))
        }
    }
}
