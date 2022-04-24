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
    var selectedComponentDependencies: [ComponentDependency] { selectedComponent?.dependencies.sorted(by: { $0.name < $1.name }) ?? [] }

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
        getSelectedComponent { $0.dependencies.insert(ComponentDependency(name: dependencyName,
                                                                          contract: nil,
                                                                          implementation: nil,
                                                                          tests: nil,
                                                                          mock: nil))
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
        getSelectedComponent { $0.dependencies.remove(componentDependency) }
    }

    func updateModuleTypeForDependency(dependency: ComponentDependency, type: DependencyType, value: ModuleType?) {
        getSelectedComponent { component in
            guard var temp = component.dependencies.remove(dependency)
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
            component.dependencies.insert(temp)
        }
    }
}
