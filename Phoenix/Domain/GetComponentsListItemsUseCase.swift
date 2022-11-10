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
    let componentsFilterRepository: ComponentsFilterRepositoryProtocol
    let documentRepository: PhoenixDocumentRepositoryProtocol
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    let selectionRepository: SelectionRepositoryProtocol

    init(componentsFilterRepository: ComponentsFilterRepositoryProtocol,
         documentRepository: PhoenixDocumentRepositoryProtocol,
         familyFolderNameProvider: FamilyFolderNameProviderProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.componentsFilterRepository = componentsFilterRepository
        self.documentRepository = documentRepository
        self.familyFolderNameProvider = familyFolderNameProvider
        self.selectionRepository = selectionRepository
    }
    
    var list: [ComponentsListSection] { map(documentRepository.value,
                                            selection: selectionRepository.value,
                                            filter: componentsFilterRepository.value) }
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> {
        Publishers.CombineLatest3(
            documentRepository.publisher,
            selectionRepository.publisher,
            componentsFilterRepository.publisher
        )
        .map { (document, selection, filter) in
            self.map(document, selection: selection, filter: filter)
        }
        .eraseToAnyPublisher()
    }
    
    private func map(_ value: PhoenixDocument, selection: Name?, filter: String?) -> [ComponentsListSection] {
        value.componentsFamilies
            .compactMap { componentsFamily in
                let section: ComponentsListSection = .init(
                    name: sectionTitle(forFamily: componentsFamily.family),
                    folderName: sectionFolderName(forFamily: componentsFamily.family),
                    rows: componentsFamily.components.compactMap { component in
                        let name = componentName(component, for: componentsFamily.family)
                        if let filter = filter?.lowercased(),
                           !filter.isEmpty,
                           !name.lowercased().contains(filter) {
                            return nil
                        }
                        return .init(
                            id: component.id,
                            name: name,
                            isSelected: component.name == selection,
                            onSelect: {},
                            onDuplicate: {})
                    },
                    onSelect: {})
                
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
