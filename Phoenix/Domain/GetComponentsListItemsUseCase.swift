import Combine
import Component
import Foundation
import PhoenixDocument
import SwiftUI
import ComponentDetailsProviderContract

protocol GetComponentsListItemsUseCaseProtocol {
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> { get }
}

struct GetComponentsListItemsUseCase: GetComponentsListItemsUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let getSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    
    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         getSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol,
         familyFolderNameProvider: FamilyFolderNameProviderProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.getSelectedComponentUseCase = getSelectedComponentUseCase
        self.familyFolderNameProvider = familyFolderNameProvider
    }
    
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            getSelectedComponentUseCase.publisher
        )
        .subscribe(on: DispatchQueue.global(qos: .background))
        .map { (families, component) in
            self.map(families, selectedName: component.name)
        }
        .eraseToAnyPublisher()
    }
    
    private func map(_ families: [ComponentsFamily], selectedName: Name?) -> [ComponentsListSection] {
        families
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
