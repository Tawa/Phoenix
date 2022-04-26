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
                        CustomMenu(title: iOSPlatformMenuTitle,
                                   data: IOSVersion.allCases,
                                   onSelection: store.setIOSVersionForSelectedComponent(iOSVersion:),
                                   hasRemove: component.iOSVersion != nil,
                                   onRemove: store.removeIOSVersionForSelectedComponent)
                        .frame(width: 150)
                        CustomMenu(title: macOSPlatformMenuTitle,
                                   data: MacOSVersion.allCases,
                                   onSelection: store.setMacOSVersionForSelectedComponent(macOSVersion:),
                                   hasRemove: component.macOSVersion != nil,
                                   onRemove: store.removeMacOSVersionForSelectedComponent)
                        .frame(width: 150)
                    }
                    Divider()
                    HStack {
                        Text("Module Types:")
                        VStack(alignment: .leading) {
                            CustomToggle(title: "Contract",
                                         isOnValue: component.modules.contains(.contract),
                                         whenTurnedOn: { store.addModuleTypeForSelectedComponent(moduleType: .contract) },
                                         whenTurnedOff: { store.removeModuleTypeForSelectedComponent(moduleType: .contract) })

                            if component.modules.contains(.contract) {
                                CustomMenu(title: moduleTypeTitle(for: .contract),
                                           data: LibraryType.allCases,
                                           onSelection: { store.set(libraryType: $0, forModuleType: .contract) },
                                           hasRemove: component.moduleTypes[.contract] != nil,
                                           onRemove: { store.set(libraryType: nil, forModuleType: .contract) })
                            }
                        }
                        .frame(width: 150)
                        Divider()
                        VStack(alignment: .leading) {
                            CustomToggle(title: "Implementation",
                                         isOnValue: component.modules.contains(.implementation),
                                         whenTurnedOn: { store.addModuleTypeForSelectedComponent(moduleType: .implementation) },
                                         whenTurnedOff: { store.removeModuleTypeForSelectedComponent(moduleType: .implementation) })
                            if component.modules.contains(.implementation) {
                                CustomMenu(title: moduleTypeTitle(for: .implementation),
                                           data: LibraryType.allCases,
                                           onSelection: { store.set(libraryType: $0, forModuleType: .implementation) },
                                           hasRemove: component.moduleTypes[.implementation] != nil,
                                           onRemove: { store.set(libraryType: nil, forModuleType: .implementation) })
                            }
                        }
                        .frame(width: 150)
                        Divider()
                        VStack(alignment: .leading) {
                            CustomToggle(title: "Mock",
                                         isOnValue: component.modules.contains(.mock),
                                         whenTurnedOn: { store.addModuleTypeForSelectedComponent(moduleType: .mock) },
                                         whenTurnedOff: { store.removeModuleTypeForSelectedComponent(moduleType: .mock) })
                            if component.modules.contains(.mock) {
                                CustomMenu(title: moduleTypeTitle(for: .mock),
                                           data: LibraryType.allCases,
                                           onSelection: { store.set(libraryType: $0, forModuleType: .mock) },
                                           hasRemove: component.moduleTypes[.mock] != nil,
                                           onRemove: { store.set(libraryType: nil, forModuleType: .mock) })
                            }
                        }
                        .frame(width: 150)
                        Spacer()
                    }
                    Divider()

                    Section {
                        ForEach(component.dependencies.sorted()) { dependencyType in
                            VStack(spacing: 0) {
                                Divider()
                                switch dependencyType {
                                case let .local(dependency):
                                    DependencyView(dependency: dependency,
                                                   types: component.modules)
                                case let .remote(dependency):
                                    RemoteDependencyView(dependency: dependency,
                                                         types: component.modules)
                                }
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

    private func moduleTypeTitle(for moduleType: ModuleType) -> String {
        if let libraryType = component.moduleTypes[moduleType] {
            return "\(libraryType)"
        } else {
            return "Add Type"
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
