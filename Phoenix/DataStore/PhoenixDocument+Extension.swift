import Component
import Foundation
import PhoenixDocument
import SwiftPackage

extension PhoenixDocument {
    
    func nameExists(name: Name) -> Bool {
        components.values.contains(where: { $0.name == name })
    }
    
    // MARK: - Private
    private mutating func getComponent(withName name: Name, _ completion: (inout Component) -> Void) {
        guard
            let familyIndex = families.firstIndex(where: { $0.components.contains(where: { $0.name == name }) }),
            let componentIndex = families[familyIndex].components.firstIndex(where: { $0.name == name })
        else { return }
        completion(&families[familyIndex].components[componentIndex])
    }
    
    // MARK: - Document modifiers
    mutating func addNewComponent(withName name: Name, template: Component? = nil) throws {
        if name.given.isEmpty {
            throw NSError(domain: "Given name cannot be empty", code: 500)
        } else if name.family.isEmpty {
            throw NSError(domain: "Component must be part of a family", code: 501)
        } else if nameExists(name: name) {
            throw NSError(domain: "Name already in use", code: 502)
        }
        
        var componentsFamily: ComponentsFamily = self
            .families
            .first(where: { componentsFamily in
                name.family == componentsFamily.family.name
            }) ?? ComponentsFamily(family: Family(name: name.family, ignoreSuffix: false, folder: nil), components: [])
        guard componentsFamily.components.contains(where: { $0.name == name }) == false else { return }
        
        var array = componentsFamily.components
        
        let moduleTypes: [String: LibraryType] = projectConfiguration.packageConfigurations
            .reduce(into: [String: LibraryType](), { partialResult, packageConfiguration in
                partialResult[packageConfiguration.name] = .undefined
            })
        
        let newComponent = Component(name: name,
                                     defaultLocalization: .init(),
                                     iOSVersion: template?.iOSVersion,
                                     macOSVersion: template?.macOSVersion,
                                     modules: template?.modules ?? moduleTypes,
                                     localDependencies: template?.localDependencies ?? [],
                                     remoteDependencies: template?.remoteDependencies ?? [],
                                     resources: template?.resources ?? [],
                                     defaultDependencies: [:])
        array.append(newComponent)
        array.sort(by: { $0.name.full < $1.name.full })
        
        componentsFamily.components = array
        
        if let familyIndex = families.firstIndex(where: { $0.family.name == name.family }) {
            families[familyIndex].components = array
        } else {
            var familiesArray = families
            familiesArray.append(componentsFamily)
            familiesArray.sort(by: { $0.family.name < $1.family.name })
            families = familiesArray
        }
    }
    
    mutating func addDependencyToComponent(withName name: Name, dependencyName: Name) {
        var defaultDependencies: [PackageTargetType: String] = component(named: dependencyName)?.defaultDependencies ?? [:]
        if defaultDependencies.isEmpty {
            defaultDependencies = family(named: dependencyName.family)?.defaultDependencies ?? [:]
        }
        if defaultDependencies.isEmpty {
            defaultDependencies = projectConfiguration.defaultDependencies
        }
        
        var targetTypes: [PackageTargetType: String] = [:]
        getComponent(withName: dependencyName) { dependencyComponent in
            if !defaultDependencies.values.contains(where: { dependencyComponent.modules[$0] == nil }) {
                targetTypes = defaultDependencies.filter{ element in
                    dependencyComponent.modules.contains { (key, _) in
                        key == element.value
                    }
                }
            }
        }
        getComponent(withName: name) { component in
            targetTypes = targetTypes.filter { (key, _) in component.modules.contains(where: { $0.key == key.name }) }
            var localDependencies = component.localDependencies
            localDependencies.append(ComponentDependency(name: dependencyName, targetTypes: targetTypes))
            localDependencies.sort()
            component.localDependencies = localDependencies
        }
    }
    
    mutating func addRemoteDependencyToComponent(withName name: Name, dependency: RemoteDependency) {
        getComponent(withName: name) {
            var remoteDependencies = $0.remoteDependencies
            remoteDependencies.append(dependency)
            remoteDependencies.sort()
            $0.remoteDependencies = remoteDependencies
        }
    }
    
    mutating func removeComponent(withName name: Name) {
        guard
            let familyIndex = families.firstIndex(where: { $0.components.contains(where: { $0.name == name }) })
        else { return }
        families[familyIndex].components.removeAll(where: { $0.name == name })
        families.removeAll(where: { $0.components.isEmpty })
    }
}
