import Package
import SwiftUI

struct ComponentView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let component: Component
    @Binding var showingDependencyPopover: Bool

    @FocusState private var focusedField: String?

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
                                         isOnValue: component.modules[.contract] != nil,
                                         whenTurnedOn: { store.addModuleTypeForSelectedComponent(moduleType: .contract) },
                                         whenTurnedOff: { store.removeModuleTypeForSelectedComponent(moduleType: .contract) })

                            if component.modules[.contract] != nil {
                                CustomMenu(title: moduleTypeTitle(for: .contract),
                                           data: LibraryType.allCases,
                                           onSelection: { store.set(libraryType: $0, forModuleType: .contract) },
                                           hasRemove: false,
                                           onRemove: { store.set(libraryType: nil, forModuleType: .contract) })
                            }
                        }
                        .frame(width: 150)
                        Divider()
                        VStack(alignment: .leading) {
                            CustomToggle(title: "Implementation",
                                         isOnValue: component.modules[.implementation] != nil,
                                         whenTurnedOn: { store.addModuleTypeForSelectedComponent(moduleType: .implementation) },
                                         whenTurnedOff: { store.removeModuleTypeForSelectedComponent(moduleType: .implementation) })
                            if component.modules[.implementation] != nil {
                                CustomMenu(title: moduleTypeTitle(for: .implementation),
                                           data: LibraryType.allCases,
                                           onSelection: { store.set(libraryType: $0, forModuleType: .implementation) },
                                           hasRemove: false,
                                           onRemove: { store.set(libraryType: nil, forModuleType: .implementation) })
                            }
                        }
                        .frame(width: 150)
                        Divider()
                        VStack(alignment: .leading) {
                            CustomToggle(title: "Mock",
                                         isOnValue: component.modules[.mock] != nil,
                                         whenTurnedOn: { store.addModuleTypeForSelectedComponent(moduleType: .mock) },
                                         whenTurnedOff: { store.removeModuleTypeForSelectedComponent(moduleType: .mock) })
                            if component.modules[.mock] != nil {
                                CustomMenu(title: moduleTypeTitle(for: .mock),
                                           data: LibraryType.allCases,
                                           onSelection: { store.set(libraryType: $0, forModuleType: .mock) },
                                           hasRemove: false,
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
                                                   types: Array(component.modules.keys))
                                case let .remote(dependency):
                                    RemoteDependencyView(dependency: dependency,
                                                         types: Array(component.modules.keys))
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

                    Section {
                        DynamicTextFieldList(
                            values: Binding(get: {
                                store.selectedComponent?.resources.map { resource -> DynamicTextFieldList<TargetResources.ResourcesType>.ValueContainer in
                                    return .init(id: resource.id,
                                                 value: resource.folderName,
                                                 menuOption: resource.type,
                                                 targetTypes: resource.targets)
                                } ?? []
                            }, set: { store.updateResource($0.map {
                                ComponentResources(id: $0.id, folderName: $0.value, type: $0.menuOption, targets: $0.targetTypes) })
                            }),
                            onRemoveValue: store.removeResource(withId:),
                            onNewValue: store.addResource)
                    } header: {
                        Text("Resources")
                            .font(.largeTitle)
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
        if let libraryType = component.modules[moduleType] {
            return "\(libraryType)"
        } else {
            return "Add Type"
        }
    }
}
