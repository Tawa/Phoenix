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
                                            selection: selectionRepository.value) }
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            selectionRepository.publisher
        )
        .subscribe(on: DispatchQueue.global(qos: .background))
        .map { (families, selection) in
            self.map(families, selection: selection)
        }
        .eraseToAnyPublisher()
    }
    
    private func map(_ families: [ComponentsFamily], selection: Name?) -> [ComponentsListSection] {
        families
            .compactMap { componentsFamily in
                let section: ComponentsListSection = .init(
                    name: sectionTitle(forFamily: componentsFamily.family),
                    folderName: sectionFolderName(forFamily: componentsFamily.family),
                    rows: componentsFamily.components.compactMap { component in
                        let name = componentName(component, for: componentsFamily.family)
                        return .init(
                            id: component.id,
                            name: name,
                            isSelected: component.name == selection
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
