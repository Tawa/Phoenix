import Package
import SwiftUI

class PhoenixDocumentStore: ObservableObject {
    private var document: Binding<PhoenixDocument>
    
    init(document: Binding<PhoenixDocument>) {
        self.document = document
    }
    
    var selectedComponent: Component? {
        guard
            let selectedName = document.selectedName.wrappedValue,
            let component = document.families.wrappedValue.flatMap(\.components).first(where: { $0.name == selectedName })
        else { return nil }
        return component
    }

    var selectedName: Name? { selectedComponent?.name }
    var selectedComponentDependencies: [ComponentDependencyType] { selectedComponent?.dependencies.sorted() ?? [] }

    var selectedFamily: Family? {
        guard let selectedFamilyName = document.selectedFamilyName.wrappedValue else { return nil }
        return document.families.wrappedValue.first(where: { $0.family.name == selectedFamilyName })?.family
    }

    var componentsFamilies: [ComponentsFamily] { document.families.wrappedValue }
    var allNames: [Name] { componentsFamilies.flatMap { $0.components }.map(\.name) }

    func title(for name: Name) -> String {
        let family = family(for: name)
        return family?.ignoreSuffix == true ? name.given : name.given + name.family
    }

    func nameExists(name: Name) -> Bool {
        allNames.contains(name)
    }

    func selectedComponentDependenciesContains(dependencyName: Name) -> Bool {
        selectedComponentDependencies.contains { componentDependencyType in
            guard case let .local(componentDependency) = componentDependencyType else { return false }
            return componentDependency.name == dependencyName
        }
    }

    func family(for name: Name) -> Family? {
        document.families.first(where: { name.family == $0.wrappedValue.family.name })?.family.wrappedValue
    }

    // MARK: - Private
    private func getSelectedComponent(_ completion: (inout Component) -> Void) {
        guard
            let selectedName = selectedName,
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == selectedName }) }),
            let componentIndex = document.families.wrappedValue[familyIndex].components.firstIndex(where: { $0.name == selectedName })
        else { return }
        completion(&document.families[familyIndex].components[componentIndex].wrappedValue)
    }

    private func getSelectedFamily(_ completion: (inout Family) -> Void) {
        guard
            let selectedFamilyName = document.selectedFamilyName.wrappedValue,
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.family.name == selectedFamilyName })
        else { return }
        completion(&document.families[familyIndex].family.wrappedValue)
    }

    private func get(remoteDependency: RemoteDependency, _ completion: (inout RemoteDependency) -> Void) {
        getSelectedComponent { component in
            var dependencies = component.dependencies
            guard
                let index = dependencies.firstIndex(where: { $0 == .remote(remoteDependency) }),
                case var .remote(temp) = dependencies.remove(at: index)
            else { return }
            completion(&temp)
            dependencies.append(.remote(temp))
            dependencies.sort()
            component.dependencies = dependencies
        }
    }

    // MARK: - Document modifiers

    func selectComponent(withName name: Name) {
        document.selectedName.wrappedValue = name
    }

    func addNewComponent(withName name: Name) {
        var componentsFamily: ComponentsFamily = document
            .families
            .first(where: { componentsFamily in
                name.family == componentsFamily.wrappedValue.family.name
            })?.wrappedValue ?? ComponentsFamily(family: Family(name: name.family, ignoreSuffix: false, folder: nil), components: [])
        guard componentsFamily.components.contains(where: { $0.name == name }) == false else { return }

        var array = componentsFamily.components

        let newComponent = Component(name: name,
                                     iOSVersion: nil,
                                     macOSVersion: nil,
                                     modules: [.contract: .dynamic, .implementation: .static, .mock: .undefined],
                                     dependencies: [],
                                     resources: [])
        array.append(newComponent)
        array.sort(by: { $0.name.full < $1.name.full })

        componentsFamily.components = array

        if let familyIndex = document.families.firstIndex(where: { $0.wrappedValue.family.name == name.family }) {
            document.families[familyIndex].components.wrappedValue = array
        } else {
            var familiesArray = document.families.wrappedValue
            familiesArray.append(componentsFamily)
            familiesArray.sort(by: { $0.family.name < $1.family.name })
            document.families.wrappedValue = familiesArray
        }
    }

    func selectFamily(withName name: String) {
        document.selectedFamilyName.wrappedValue = name
    }

    func deselectFamily() {
        document.selectedFamilyName.wrappedValue = nil
    }

    func updateSelectedFamily(ignoresSuffix: Bool) {
        getSelectedFamily { $0.ignoreSuffix = ignoresSuffix }
    }

    func updateSelectedFamily(folder: String?) {
        getSelectedFamily { $0.folder = folder }
    }
    
    func addDependencyToSelectedComponent(dependencyName: Name) {
        getSelectedComponent {
            var dependencies = $0.dependencies
            dependencies.append(.local(ComponentDependency(name: dependencyName,
                                                                          contract: nil,
                                                                          implementation: nil,
                                                                          tests: nil,
                                                                          mock: nil)))
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func addRemoteDependencyToSelectedComponent(dependency: RemoteDependency) {
        getSelectedComponent {
            var dependencies = $0.dependencies
            dependencies.append(.remote(dependency))
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func setIOSVersionForSelectedComponent(iOSVersion: IOSVersion) {
        getSelectedComponent { $0.iOSVersion = iOSVersion }
    }

    func removeIOSVersionForSelectedComponent() {
        getSelectedComponent { $0.iOSVersion = nil }
    }

    func setMacOSVersionForSelectedComponent(macOSVersion: MacOSVersion) {
        getSelectedComponent { $0.macOSVersion = macOSVersion }
    }

    func removeMacOSVersionForSelectedComponent() {
        getSelectedComponent { $0.macOSVersion = nil }
    }

    func addModuleTypeForSelectedComponent(moduleType: ModuleType) {
        getSelectedComponent {
            var modules = $0.modules
            modules[moduleType] = .undefined
            $0.modules = modules
        }
    }

    func removeModuleTypeForSelectedComponent(moduleType: ModuleType) {
        getSelectedComponent {
            var modules = $0.modules
            modules.removeValue(forKey: moduleType)
            $0.modules = modules
        }
    }

    func set(libraryType: LibraryType?, forModuleType moduleType: ModuleType) {
        getSelectedComponent { $0.modules[moduleType] = libraryType }
    }

    func removeSelectedComponent() {
        guard
            let selectedName = selectedName,
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == selectedName }) })
        else { return }
        document.families[familyIndex].components.wrappedValue.removeAll(where: { $0.name == selectedName })
        document.families.wrappedValue.removeAll(where: { $0.components.isEmpty })
        document.selectedName.wrappedValue = nil //document.wrappedValue.families.first?.components.first?.name
    }

    func removeDependencyForSelectedComponent(componentDependency: ComponentDependency) {
        getSelectedComponent {
            var dependencies = $0.dependencies
            dependencies.removeAll(where: { $0 == .local(componentDependency) })
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func removeRemoteDependencyForSelectedComponent(dependency: RemoteDependency) {
        getSelectedComponent {
            var dependencies = $0.dependencies
            dependencies.removeAll(where: { $0 == .remote(dependency) })
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func updateModuleTypeForDependency(dependency: ComponentDependency, type: TargetType, value: ModuleType?) {
        getSelectedComponent { component in
            var dependencies = component.dependencies
            guard
                let index = dependencies.firstIndex(where: { $0 == .local(dependency) }),
                case var .local(temp) = dependencies.remove(at: index)
            else { return }
            switch type {
            case .contract:
                temp.contract = value
            case .implementation:
                temp.implementation = value
            case .tests:
                temp.tests = value
            case .mock:
                temp.mock = value
            }
            dependencies.append(.local(temp))
            dependencies.sort()
            component.dependencies = dependencies
        }
    }

    func updateModuleTypeForRemoteDependency(dependency: RemoteDependency, type: TargetType, value: Bool) {
        get(remoteDependency: dependency) { dependency in
            switch type {
            case .contract:
                dependency.contract = value
            case .implementation:
                dependency.implementation = value
            case .tests:
                dependency.tests = value
            case .mock:
                dependency.mock = value
            }
        }
    }

    func updateVersionForRemoteDependency(dependency: RemoteDependency, version: ExternalDependencyVersion) {
        get(remoteDependency: dependency) { dependency in
            dependency.version = version
        }
    }

    func updateResource(_ resources: [ComponentResources]) {
        getSelectedComponent { $0.resources = resources }
    }

    func addResource(_ folderName: String) {
        getSelectedComponent { $0.resources.append(.init(folderName: folderName,
                                                         type: .process,
                                                         targets: [])) }
    }
}
