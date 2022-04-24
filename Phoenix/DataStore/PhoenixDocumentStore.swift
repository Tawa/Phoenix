import Package
import SwiftUI

enum DependencyType {
    case contract
    case implementation
    case tests
    case mock
}

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

    // MARK: - Private
    private func family(for name: Name) -> Family? {
        document.families.first(where: { name.family == $0.wrappedValue.family.name })?.family.wrappedValue
    }

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
                                     modules: [.contract, .implementation, .mock],
                                     dependencies: [])
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
        getSelectedComponent { $0.dependencies.insert(.local(ComponentDependency(name: dependencyName,
                                                                          contract: nil,
                                                                          implementation: nil,
                                                                          tests: nil,
                                                                          mock: nil)))
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
        getSelectedComponent { $0.modules.insert(moduleType) }
    }

    func removeModuleTypeForSelectedComponent(moduleType: ModuleType) {
        getSelectedComponent { $0.modules.remove(moduleType) }
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
        getSelectedComponent { $0.dependencies.remove(.local(componentDependency)) }
    }

    func updateModuleTypeForDependency(dependency: ComponentDependency, type: DependencyType, value: ModuleType?) {
        getSelectedComponent { component in
            guard case var .local(temp) = component.dependencies.remove(.local(dependency))
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
            component.dependencies.insert(.local(temp))
        }
    }
}
