import Package
import SwiftUI

class PhoenixDocumentStore: ObservableObject {
    private let fileURL: URL?
    private var document: Binding<PhoenixDocument>
    
    init(fileURL: URL?, document: Binding<PhoenixDocument>) {
        self.fileURL = fileURL
        self.document = document
    }

    func getSelectedFamily(withName name: String) -> Family? {
        document.families.wrappedValue.first(where: { $0.family.name == name })?.family
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

    func selectedComponent(withName name: Name?, containsDependencyWithName dependencyName: Name) -> Bool {
        guard let name = name else { return false }
        var value: Bool = false
        getSelectedComponent(withName: name) { component in
            value = component.dependencies.contains { componentDependencyType in
                guard case let .local(componentDependency) = componentDependencyType else { return false }
                return componentDependency.name == dependencyName
            }
        }
        return value
    }

    func family(for name: Name) -> Family? {
        document.families.first(where: { name.family == $0.wrappedValue.family.name })?.family.wrappedValue
    }

    // MARK: - Private
    private func getSelectedComponent(withName selectedName: Name, _ completion: (inout Component) -> Void) {
        guard
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == selectedName }) }),
            let componentIndex = document.families.wrappedValue[familyIndex].components.firstIndex(where: { $0.name == selectedName })
        else { return }
        completion(&document.families[familyIndex].components[componentIndex].wrappedValue)
    }

    private func getSelectedFamily(withName selectedFamilyName: String, _ completion: (inout Family) -> Void) {
        guard
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.family.name == selectedFamilyName })
        else { return }
        completion(&document.families[familyIndex].family.wrappedValue)
    }

    private func get(remoteDependency: RemoteDependency, componentWithName name: Name, _ completion: (inout RemoteDependency) -> Void) {
        getSelectedComponent(withName: name) { component in
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
    func getComponent(withName name: Name) -> Component? {
        guard
            let component = document.families.wrappedValue.flatMap(\.components).first(where: { $0.name == name })
        else { return nil }
        return component
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

    func updateSelectedFamily(withName name: String?, ignoresSuffix: Bool) {
        guard let name = name else { return }
        getSelectedFamily(withName: name) { $0.ignoreSuffix = ignoresSuffix }
    }

    func updateSelectedFamily(withName name: String?, folder: String?) {
        guard let name = name else { return }
        getSelectedFamily(withName: name) { $0.folder = folder?.isEmpty == true ? nil : folder }
    }
    
    func addDependencyToSelectedComponent(withName name: Name?, dependencyName: Name) {
        guard let name = name else { return }
        getSelectedComponent(withName: name) {
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

    func addRemoteDependencyToSelectedComponent(withName name: Name, dependency: RemoteDependency) {
        getSelectedComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.append(.remote(dependency))
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func setIOSVersionForSelectedComponent(withName name: Name, iOSVersion: IOSVersion) {
        getSelectedComponent(withName: name) { $0.iOSVersion = iOSVersion }
    }

    func removeIOSVersionForSelectedComponent(withName name: Name) {
        getSelectedComponent(withName: name) { $0.iOSVersion = nil }
    }

    func setMacOSVersionForSelectedComponent(withName name: Name, macOSVersion: MacOSVersion) {
        getSelectedComponent(withName: name) { $0.macOSVersion = macOSVersion }
    }

    func removeMacOSVersionForSelectedComponent(withName name: Name) {
        getSelectedComponent(withName: name) { $0.macOSVersion = nil }
    }

    func addModuleTypeForSelectedComponent(withName name: Name, moduleType: ModuleType) {
        getSelectedComponent(withName: name) {
            var modules = $0.modules
            modules[moduleType] = .undefined
            $0.modules = modules
        }
    }

    func removeModuleTypeForSelectedComponent(withName name: Name, moduleType: ModuleType) {
        getSelectedComponent(withName: name) {
            var modules = $0.modules
            modules.removeValue(forKey: moduleType)
            $0.modules = modules
        }
    }

    func set(forComponentWithName name: Name, libraryType: LibraryType?, forModuleType moduleType: ModuleType) {
        getSelectedComponent(withName: name) { $0.modules[moduleType] = libraryType }
    }

    func removeComponent(withName name: Name) {
        guard
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == name }) })
        else { return }
        document.families[familyIndex].components.wrappedValue.removeAll(where: { $0.name == name })
        document.families.wrappedValue.removeAll(where: { $0.components.isEmpty })
    }

    func removeDependencyForSelectedComponent(withComponentName name: Name, componentDependency: ComponentDependency) {
        getSelectedComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.removeAll(where: { $0 == .local(componentDependency) })
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func removeRemoteDependencyForSelectedComponent(withComponentName name: Name, dependency: RemoteDependency) {
        getSelectedComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.removeAll(where: { $0 == .remote(dependency) })
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func updateModuleTypeForDependency(withComponentName name: Name, dependency: ComponentDependency, type: TargetType, value: ModuleType?) {
        getSelectedComponent(withName: name) { component in
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

    func updateModuleTypeForRemoteDependency(withComponentName name: Name, dependency: RemoteDependency, type: TargetType, value: Bool) {
        get(remoteDependency: dependency, componentWithName: name) { dependency in
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

    func updateVersionForRemoteDependency(withComponentName name: Name, dependency: RemoteDependency, version: ExternalDependencyVersion) {
        get(remoteDependency: dependency, componentWithName: name) { $0.version = version }
    }

    func updateVersionStringValueForRemoteDependency(withComponentName name: Name, dependency: RemoteDependency, stringValue: String) {
        get(remoteDependency: dependency, componentWithName: name) { dependency in
            switch dependency.version {
            case .from:
                dependency.version = .from(version: stringValue)
            case .branch:
                dependency.version = .branch(name: stringValue)
            }
        }
    }

    func updateResource(_ resources: [ComponentResources], forComponentWithName name: Name) {
        getSelectedComponent(withName: name) { $0.resources = resources }
    }

    func addResource(_ folderName: String, forComponentWithName name: Name) {
        getSelectedComponent(withName: name) { $0.resources.append(.init(folderName: folderName,
                                                         type: .process,
                                                         targets: [])) }
    }

    func removeResource(withId id: String, forComponentWithName name: Name) {
        getSelectedComponent(withName: name) { $0.resources.removeAll(where: { $0.id == id }) }
    }
}
