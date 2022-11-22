import Combine
import Component
import Foundation
import PhoenixDocument
import SwiftUI
import ComponentDetailsProviderContract

protocol GetComponentsListItemsUseCaseProtocol {
    var list: [ComponentsListSection] { get }
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> { get }
}

struct GetComponentsListItemsUseCase: GetComponentsListItemsUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    let selectionRepository: SelectionRepositoryProtocol

    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         familyFolderNameProvider: FamilyFolderNameProviderProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.familyFolderNameProvider = familyFolderNameProvider
        self.selectionRepository = selectionRepository
    }
    
    var list: [ComponentsListSection] { map(getComponentsFamiliesUseCase.families,
                                            selectionPath: selectionRepository.selectionPath) }
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            selectionRepository.selectionPathPublisher
        )
        .subscribe(on: DispatchQueue.global(qos: .background))
        .map { (families, selectionPath) in
            self.map(families, selectionPath: selectionPath)
        }
        .eraseToAnyPublisher()
    }
    
    private func map(_ families: [ComponentsFamily], selectionPath: SelectionPath?) -> [ComponentsListSection] {
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
                            isSelected: componentsFamilyElement.offset == selectionPath?.familyIndex && componentElement.offset == selectionPath?.componentIndex
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
