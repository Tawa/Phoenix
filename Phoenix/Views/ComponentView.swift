import Package
import SwiftUI

struct ComponentView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let component: Component
    @Binding var showingDependencyPopover: Bool

    var body: some View {
        ZStack {
            List {
                VStack(alignment: .leading) {
                    HStack {
                        Text(store.title(for: component.name))
                            .font(.largeTitle)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Button(role: .destructive, action: { store.removeSelectedComponent() }) {
                            Image(systemName: "trash")
                        }.help("Remove")
                    }
                    Divider()
                    HStack {
                        Text("Platforms:")
                        Menu(iOSPlatformMenuTitle) {
                            ForEach(IOSVersion.allCases) { version in
                                Button(action: { store.setIOSVersionForSelectedComponent(iOSVersion: version) }) {
                                    Text("\(String(describing: version))")
                                }
                            }
                            if component.iOSVersion != nil {
                                Button(action: { store.removeIOSVersionForSelectedComponent() }) {
                                    Text("Remove")
                                }
                            }
                        }.frame(width: 150)
                        Menu(macOSPlatformMenuTitle) {
                            ForEach(MacOSVersion.allCases) { version in
                                Button(action: { store.setMacOSVersionForSelectedComponent(macOSVersion: version) }) {
                                    Text("\(String(describing: version))")
                                }
                            }
                            if component.macOSVersion != nil {
                                Button(action: { store.removeMacOSVersionForSelectedComponent() }) {
                                    Text("Remove")
                                }
                            }
                        }.frame(width: 150)
                    }
                    Divider()
                    HStack {
                        Text("Module Types:")
                        Toggle(isOn: Binding(
                            get: { component.modules.contains(.contract) },
                            set: { isOn in
                                if isOn {
                                    store.addModuleTypeForSelectedComponent(moduleType: .contract)
                                } else {
                                    store.removeModuleTypeForSelectedComponent(moduleType: .contract)
                                }
                            }),
                               label: { Text("Contract") })
                        Toggle(isOn: Binding(
                            get: { component.modules.contains(.implementation) },
                            set: { isOn in
                                if isOn {
                                    store.addModuleTypeForSelectedComponent(moduleType: .implementation)
                                } else {
                                    store.removeModuleTypeForSelectedComponent(moduleType: .implementation)
                                }
                            }),
                               label: { Text("Implementation") })
                        Toggle(isOn: Binding(
                            get: { component.modules.contains(.mock) },
                            set: { isOn in
                                if isOn {
                                    store.addModuleTypeForSelectedComponent(moduleType: .mock)
                                } else {
                                    store.removeModuleTypeForSelectedComponent(moduleType: .mock)
                                }
                            }),
                               label: { Text("Mock") })
                    }
                    Divider()

                    Section {
                        ForEach(component.dependencies.sorted(by: { $0.name.full < $1.name.full })) { dependency in
                            VStack(spacing: 0) {
                                Divider()
                                DependencyView(dependency: dependency,
                                               types: component.modules)
                            }
                        }
                        .padding([.vertical])
                    } header: {
                        HStack {
                            Text("Dependencies")
                                .font(.largeTitle)
                            Button(action: {
                                showingDependencyPopover = true
                            }, label: { Image(systemName: "plus") })
                        }
                    }

                    Divider()
                }
                .padding()
            }
        }
    }

    private var iOSPlatformMenuTitle: String {
        if let iOSVersion = component.iOSVersion {
            return ".iOS(.\(iOSVersion))"
        } else {
            return "Add iOS"
        }
    }

    private var macOSPlatformMenuTitle: String {
        if let macOSVersion = component.macOSVersion {
            return ".macOS(.\(macOSVersion))"
        } else {
            return "Add macOS"
        }
    }
}

//struct ComponentView_Previews: PreviewProvider {
//    struct Preview: View {
//        @State var component: Component? = Component(
//            name: Name(given: "Wordpress", family: "Repository"),
//            iOSVersion: .v13,
//            macOSVersion: .v12,
//            modules: .init(arrayLiteral: .contract, .implementation, .mock),
//            dependencies: [])
//
//        var body: some View {
//            ComponentView(component: $component,
//                          onRemove: {})
//        }
//    }
//
//    static var previews: some View {
//        Group {
//            Preview()
//            ComponentView(component: .constant(nil),
//                          onRemove: {})
//        }
//    }
//}
