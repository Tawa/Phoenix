import Package
import SwiftUI

class PhoenixDocumentStore: ObservableObject {
    let fileURL: URL?
    private(set) var document: Binding<PhoenixDocument>
    
    init(fileURL: URL?, document: Binding<PhoenixDocument>) {
        self.fileURL = fileURL
        self.document = document
    }

    func getFamily(withName name: String) -> Family? {
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

    func component(withName name: Name, containsDependencyWithName dependencyName: Name) -> Bool {
        var value: Bool = false
        getComponent(withName: name) { component in
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
    private func getComponent(withName name: Name, _ completion: (inout Component) -> Void) {
        guard
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == name }) }),
            let componentIndex = document.families.wrappedValue[familyIndex].components.firstIndex(where: { $0.name == name })
        else { return }
        completion(&document.families[familyIndex].components[componentIndex].wrappedValue)
    }

    private func getFamily(withName name: String, _ completion: (inout Family) -> Void) {
        guard
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.family.name == name })
        else { return }
        completion(&document.families[familyIndex].family.wrappedValue)
    }

    private func get(remoteDependency: RemoteDependency, componentWithName name: Name, _ completion: (inout RemoteDependency) -> Void) {
        getComponent(withName: name) { component in
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

    private func get(dependency: ComponentDependency, componentWithName name: Name, _ completion: (inout ComponentDependency) -> Void) {
        getComponent(withName: name) { component in
            var dependencies = component.dependencies
            guard
                let index = dependencies.firstIndex(where: { $0 == .local(dependency) }),
                case var .local(temp) = dependencies.remove(at: index)
            else { return }
            completion(&temp)
            dependencies.append(.local(temp))
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


    func addNewComponent(withName name: Name, template: Component? = nil) throws {
        if name.given.isEmpty {
            throw NSError(domain: "Given name cannot be empty", code: 500)
        } else if name.family.isEmpty {
            throw NSError(domain: "Component must be part of a family", code: 501)
        } else if nameExists(name: name) {
            throw NSError(domain: "Name already in use", code: 502)
        }

        var componentsFamily: ComponentsFamily = document
            .families
            .first(where: { componentsFamily in
                name.family == componentsFamily.wrappedValue.family.name
            })?.wrappedValue ?? ComponentsFamily(family: Family(name: name.family, ignoreSuffix: false, folder: nil), components: [])
        guard componentsFamily.components.contains(where: { $0.name == name }) == false else { return }

        var array = componentsFamily.components

        let moduleTypes: [String: LibraryType] = document.wrappedValue.projectConfiguration.packageConfigurations
            .reduce(into: [String: LibraryType](), { partialResult, packageConfiguration in
                partialResult[packageConfiguration.name] = .undefined
            })

        let newComponent = Component(name: name,
                                     iOSVersion: template?.iOSVersion,
                                     macOSVersion: template?.macOSVersion,
                                     modules: template?.modules ?? moduleTypes,
                                     dependencies: template?.dependencies ?? [],
                                     resources: template?.resources ?? [])
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

    func updateFamily(withName name: String, ignoresSuffix: Bool) {
        getFamily(withName: name) { $0.ignoreSuffix = ignoresSuffix }
    }

    func updateFamily(withName name: String, folder: String?) {
        getFamily(withName: name) { $0.folder = folder?.isEmpty == true ? nil : folder }
    }
    
    func addDependencyToComponent(withName name: Name, dependencyName: Name) {
        getComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.append(.local(ComponentDependency(name: dependencyName, targetTypes: [:])))
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func addRemoteDependencyToComponent(withName name: Name, dependency: RemoteDependency) {
        getComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.append(.remote(dependency))
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func setIOSVersionForComponent(withName name: Name, iOSVersion: IOSVersion) {
        getComponent(withName: name) { $0.iOSVersion = iOSVersion }
    }

    func removeIOSVersionForComponent(withName name: Name) {
        getComponent(withName: name) { $0.iOSVersion = nil }
    }

    func setMacOSVersionForComponent(withName name: Name, macOSVersion: MacOSVersion) {
        getComponent(withName: name) { $0.macOSVersion = macOSVersion }
    }

    func removeMacOSVersionForComponent(withName name: Name) {
        getComponent(withName: name) { $0.macOSVersion = nil }
    }

    func addModuleTypeForComponent(withName name: Name, moduleType: String) {
        getComponent(withName: name) {
            var modules = $0.modules
            modules[moduleType] = .undefined
            $0.modules = modules
        }
    }

    func removeModuleTypeForComponent(withName name: Name, moduleType: String) {
        getComponent(withName: name) {
            var modules = $0.modules
            modules.removeValue(forKey: moduleType)
            $0.modules = modules
        }
    }

    func set(forComponentWithName name: Name, libraryType: LibraryType?, forModuleType moduleType: String) {
        getComponent(withName: name) {
            $0.modules[moduleType] = libraryType
        }
    }

    func removeComponent(withName name: Name) {
        guard
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == name }) })
        else { return }
        document.families[familyIndex].components.wrappedValue.removeAll(where: { $0.name == name })
        document.families.wrappedValue.removeAll(where: { $0.components.isEmpty })
    }

    func removeDependencyForComponent(withComponentName name: Name, componentDependency: ComponentDependency) {
        getComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.removeAll(where: { $0 == .local(componentDependency) })
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func removeRemoteDependencyForComponent(withComponentName name: Name, dependency: RemoteDependency) {
        getComponent(withName: name) {
            var dependencies = $0.dependencies
            dependencies.removeAll(where: { $0 == .remote(dependency) })
            dependencies.sort()
            $0.dependencies = dependencies
        }
    }

    func updateModuleTypeForDependency(withComponentName name: Name, dependency: ComponentDependency, type: PackageTargetType, value: String?) {
        get(dependency: dependency, componentWithName: name) { dependency in
            if let value = value {
                dependency.targetTypes[type] = value
            } else {
                dependency.targetTypes.removeValue(forKey: type)
            }
        }
    }

    func updateModuleTypeForRemoteDependency(withComponentName name: Name, dependency: RemoteDependency, type: PackageTargetType, value: Bool) {
        get(remoteDependency: dependency, componentWithName: name) { dependency in
            let typeIndex = dependency.targetTypes.firstIndex(of: type)
            if value && typeIndex == nil {
                dependency.targetTypes.append(type)
            } else if !value, let typeIndex = typeIndex {
                dependency.targetTypes.remove(at: typeIndex)
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
        getComponent(withName: name) { $0.resources = resources }
    }

    func addResource(_ folderName: String, forComponentWithName name: Name) {
        getComponent(withName: name) { $0.resources.append(.init(folderName: folderName,
                                                                 type: .process,
                                                                 targets: [])) }
    }

    func removeResource(withId id: String, forComponentWithName name: Name) {
        getComponent(withName: name) { $0.resources.removeAll(where: { $0.id == id }) }
    }
}
