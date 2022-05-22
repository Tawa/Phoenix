import Package
import SwiftUI

struct ComponentView: View {
    @EnvironmentObject private var store: PhoenixDocumentStore

    let title: String
    let onRemove: () -> Void
    let component: Component
    @Binding var showingDependencyPopover: Bool

    @FocusState private var focusedField: String?

    var body: some View {
        List {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Button(role: .destructive, action: onRemove) {
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
                    ForEach(ModuleType.allCases) { moduleType in
                        ComponentModuleTypeView(title: "\(moduleType)",
                                                isOn: component.modules[moduleType] != nil,
                                                onOn: { store.addModuleTypeForSelectedComponent(moduleType: moduleType) },
                                                onOff: { store.removeModuleTypeForSelectedComponent(moduleType: moduleType) },
                                                selectionData: LibraryType.allCases,
                                                selectionTitle: moduleTypeTitle(for: moduleType),
                                                onSelection: { store.set(libraryType: $0, forModuleType: moduleType) },
                                                onRemove: { store.set(libraryType: nil, forModuleType: moduleType) })
                        Divider()
                    }
                    Spacer()
                }.frame(height: 50)
                Divider()

                Section {
                    ForEach(component.dependencies.sorted()) { dependencyType in
                        VStack(spacing: 0) {
                            Divider()
                            switch dependencyType {
                            case let .local(dependency):
                                DependencyView<TargetType, ModuleType>(
                                    title: store.title(for: dependency.name),
                                    onSelection: { store.selectComponent(withName: dependency.name) },
                                    onRemove: { store.removeDependencyForSelectedComponent(componentDependency: dependency) },
                                    allTypes: componentTypes(for: dependency),
                                    allSelectionValues: Array(ModuleType.allCases),
                                    onUpdateTargetTypeValue: { store.updateModuleTypeForDependency(dependency: dependency, type: $0, value: $1) })
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
                                    ].filter { allType in
                                        dependencyTypes(for: dependency).contains(where: { allType.value.id == $0.id })
                                    },
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
                            store.selectedComponent?.resources.map { resource -> DynamicTextFieldList<TargetResources.ResourcesType,
                                                                                                      TargetType>.ValueContainer in
                                return .init(id: resource.id,
                                             value: resource.folderName,
                                             menuOption: resource.type,
                                             targetTypes: resource.targets)
                            } ?? []
                        }, set: { store.updateResource($0.map {
                            ComponentResources(id: $0.id, folderName: $0.value, type: $0.menuOption, targets: $0.targetTypes) })
                        }),
                        allTargetTypes: [
                            .init(title: "Contract", subtitle: nil, value: .contract, subValue: nil),
                            .init(title: "Implementation", subtitle: "Tests",
                                  value: .implementation, subValue: .tests),
                            .init(title: "Mock", subtitle: nil, value: .mock, subValue: nil)
                        ],
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

    private func componentTypes(for dependency: ComponentDependency) -> [IdentifiableWithSubtypeAndSelection<TargetType, ModuleType>] {
        [
            .init(title: "Contract", subtitle: nil, value: .contract, subValue: nil, selectedValue: dependency.contract, selectedSubValue: nil),
            .init(title: "Implementation", subtitle: "Tests",
                  value: .implementation, subValue: .tests,
                  selectedValue: dependency.implementation, selectedSubValue: dependency.tests),
            .init(title: "Mock", subtitle: nil, value: .mock, subValue: nil, selectedValue: dependency.mock, selectedSubValue: nil),
        ].filter { value in
            component.modules.keys.contains { moduleType in
                switch (moduleType, value.value) {
                case (.contract, .contract),
                    (.implementation, .implementation),
                    (.mock, .mock):
                    return true
                default:
                    return false
                }
            }
        }
    }
}
