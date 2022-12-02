import Combine
import Component
import Foundation
import PhoenixDocument
import SwiftUI
import ComponentDetailsProviderContract

protocol GetComponentsListItemsUseCaseProtocol {
    func componentsListSections(
        _ families: [ComponentsFamily],
        selectedName: Name?,
        filter: String?
    ) -> [ComponentsListSection]
}

struct GetComponentsListItemsUseCase: GetComponentsListItemsUseCaseProtocol {
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    
    init(familyFolderNameProvider: FamilyFolderNameProviderProtocol) {
        self.familyFolderNameProvider = familyFolderNameProvider
    }
    
    func componentsListSections(
        _ families: [ComponentsFamily],
        selectedName: Name?,
        filter: String?
    ) -> [ComponentsListSection] {
        families
            .compactMap { componentsFamily in
                var componentsFamily = componentsFamily
                componentsFamily.components = componentsFamily.components
                    .filter { component in
                        let name = componentName(component, for: componentsFamily.family)
                        if let filter = filter?.lowercased(),
                           !filter.isEmpty,
                           !name.lowercased().contains(filter) {
                            return false
                        }
                        return true
                    }
                return componentsFamily.components.isEmpty ? nil : componentsFamily
            }
            .enumerated()
            .compactMap { componentsFamilyElement in
                let componentsFamily = componentsFamilyElement.element
                let section: ComponentsListSection = .init(
                    id: componentsFamily.family.id,
                    name: sectionTitle(forFamily: componentsFamily.family),
                    folderName: sectionFolderName(forFamily: componentsFamily.family),
                    rows: componentsFamily.components.enumerated().compactMap { componentElement in
                        let component = componentElement.element
                        let name = componentName(component, for: componentsFamily.family)
                        return .init(
                            id: component.id,
                            name: name,
                            isSelected: componentElement.element.name == selectedName
                        )
                    }
                )
                if section.rows.isEmpty { return nil }
                return section
            }
    }
    
    private func sectionTitle(forFamily family: Family) -> String {
        family.name == family.folder ? family.name : familyFolderNameProvider.folderName(forFamily: family.name)
    }
    
    private func sectionFolderName(forFamily family: Family) -> String? {
        let result = family.folder ?? familyFolderNameProvider.folderName(forFamily: family.name)
        guard result != family.name
        else { return nil }
        return result
    }
    
    private func componentName(_ component: Component, for family: Family) -> String {
        family.ignoreSuffix == true ? component.name.given : component.name.given + component.name.family
    }
}
