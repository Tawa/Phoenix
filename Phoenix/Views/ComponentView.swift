import Package
import SwiftUI

struct ComponentView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let component: Component
    @Binding var showingDependencyPopover: Bool

    @FocusState private var focusedField: String?

    var body: some View {
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
                    ComponentModuleTypeView(title: "Contract",
                                            isOn: component.modules[.contract] != nil,
                                            onOn: { store.addModuleTypeForSelectedComponent(moduleType: .contract) },
                                            onOff: { store.removeModuleTypeForSelectedComponent(moduleType: .contract) },
                                            selectionData: LibraryType.allCases,
                                            selectionTitle: moduleTypeTitle(for: .contract),
                                            onSelection: { store.set(libraryType: $0, forModuleType: .contract) },
                                            onRemove: { store.set(libraryType: nil, forModuleType: .contract) })
                    Divider()
                    ComponentModuleTypeView(title: "Implementation",
                                            isOn: component.modules[.implementation] != nil,
                                            onOn: { store.addModuleTypeForSelectedComponent(moduleType: .implementation) },
                                            onOff: { store.removeModuleTypeForSelectedComponent(moduleType: .implementation) },
                                            selectionData: LibraryType.allCases,
                                            selectionTitle: moduleTypeTitle(for: .implementation),
                                            onSelection: { store.set(libraryType: $0, forModuleType: .implementation) },
                                            onRemove: { store.set(libraryType: nil, forModuleType: .implementation) })
                    Divider()
                    ComponentModuleTypeView(title: "Mock",
                                            isOn: component.modules[.mock] != nil,
                                            onOn: { store.addModuleTypeForSelectedComponent(moduleType: .mock) },
                                            onOff: { store.removeModuleTypeForSelectedComponent(moduleType: .mock) },
                                            selectionData: LibraryType.allCases,
                                            selectionTitle: moduleTypeTitle(for: .mock),
                                            onSelection: { store.set(libraryType: $0, forModuleType: .mock) },
                                            onRemove: { store.set(libraryType: nil, forModuleType: .mock) })
                    Spacer()
                }.frame(height: 50)
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
                                RemoteDependencyView(
                                    name: dependency.name.name,
                                    urlString: dependency.url,
                                    allVersionsTypes: [
                                        .init(title: "branch", value: ExternalDependencyVersion.branch(name: "main")),
                                        .init(title: "from", value: ExternalDependencyVersion.from(version: "1.0.0"))
                                    ],
                                    onSubmitVersionType: { updateVersion(for: dependency, version: $0) },
                                    versionPlaceholder: versionPlaceholder(for: dependency),
                                    versionTitle: dependency.version.title,
                                    versionText: dependency.version.stringValue,
                                    onSubmitVersionText: { store.updateVersionStringValueForRemoteDependency(dependency: dependency,
                                                                                                             stringValue: $0) },
                                    allDependencyTypes: [
                                        .init(title: "Contract", subtitle: nil, value: TargetType.contract, subValue: nil),
                                        .init(title: "Implementation", subtitle: "Tests", value: TargetType.implementation, subValue: .tests),
                                        .init(title: "Mock", subtitle: nil, value: TargetType.mock, subValue: nil),
                                    ],
                                    dependencyTypes: dependencyTypes(for: dependency),
                                    enabledTypes: enabledDependencyTypes(for: dependency),
                                    onUpdateDependencyType: { store.updateModuleTypeForRemoteDependency(dependency: dependency, type: $0, value: $1) },
                                    onRemove: { store.removeRemoteDependencyForSelectedComponent(dependency: dependency) }
                                )
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

    private func dependencyTypes(for dependency: RemoteDependency) -> [TargetType] {
        component.modules.keys.sorted().reduce(into: [TargetType](), { partialResult, moduleType in
            switch moduleType {
            case .contract:
                partialResult.append(TargetType.contract)
            case .implementation:
                partialResult.append(TargetType.implementation)
                partialResult.append(TargetType.tests)
            case .mock:
                partialResult.append(TargetType.mock)
            }
        })
    }

    private func enabledDependencyTypes(for dependency: RemoteDependency) -> [TargetType] {
        var types = [TargetType]()
        if dependency.contract {
            types.append(.contract)
        }
        if dependency.implementation {
            types.append(.implementation)
        }
        if dependency.tests {
            types.append(.tests)
        }
        if dependency.mock {
            types.append(.mock)
        }

        return types
    }

    private func updateVersion(for dependency: RemoteDependency, version: ExternalDependencyVersion) {
        store.updateVersionForRemoteDependency(dependency: dependency, version: version)
    }

    private func versionPlaceholder(for dependency: RemoteDependency) -> String {
        switch dependency.version {
        case .from:
            return "1.0.0"
        case .branch:
            return "main"
        }
    }
}
