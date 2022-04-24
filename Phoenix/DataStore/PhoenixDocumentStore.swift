import Package
import SwiftUI

enum PhoenixDocumentAction {
    case addDependencyToSelectedComponent(dependencyName: Name)
}

class PhoenixDocumentStore: ObservableObject {
    private var document: Binding<PhoenixDocument>
    
    init(document: Binding<PhoenixDocument>) {
        self.document = document
    }
    
    private var selectedComponent: Component? {
        guard
            let selectedName = document.selectedName.wrappedValue,
            let component = document.families.wrappedValue.flatMap(\.components).first(where: { $0.name == selectedName })
        else { return nil }
        return component
    }
    
    var selectedName: Name? { selectedComponent?.name }
    var selectedComponentDependencies: [ComponentDependency] { selectedComponent?.dependencies.sorted(by: { $0.name < $1.name }) ?? [] }
    
    var allNames: [Name] {
        document.wrappedValue.families.flatMap { $0.components }.map(\.name)
    }
    
    func title(for name: Name) -> String {
        let family = family(for: name)
        return family?.ignoreSuffix == true ? name.given : name.given + name.family
    }
    
    // MAKR: - Actions
    func send(action: PhoenixDocumentAction) {
        switch action {
        case .addDependencyToSelectedComponent(let dependencyName):
            addDependencyToSelectedComponent(dependencyName: dependencyName)
        }
    }
    
    
    // MARK: - Private
    private func family(for name: Name) -> Family? {
        document.families.first(where: { name.family == $0.wrappedValue.family.name })?.family.wrappedValue
    }
    
    private func addDependencyToSelectedComponent(dependencyName: Name) {
        guard
            let selectedName = selectedName,
            let familyIndex = document.families.wrappedValue.firstIndex(where: { $0.components.contains(where: { $0.name == selectedName }) }),
            let componentIndex = document.families.wrappedValue[familyIndex].components.firstIndex(where: { $0.name == selectedName })
        else { return }
        document.families[familyIndex].components[componentIndex].dependencies.wrappedValue.insert(
            ComponentDependency(name: dependencyName,
                                contract: nil,
                                implementation: nil,
                                tests: nil,
                                mock: nil))
        
    }
}
