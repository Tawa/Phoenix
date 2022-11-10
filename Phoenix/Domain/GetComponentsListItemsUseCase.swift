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
    let documentRepository: PhoenixDocumentRepositoryProtocol
    let familyFolderNameProvider: FamilyFolderNameProviderProtocol
    let selectionRepository: SelectionRepositoryProtocol

    init(documentRepository: PhoenixDocumentRepositoryProtocol,
         familyFolderNameProvider: FamilyFolderNameProviderProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.documentRepository = documentRepository
        self.familyFolderNameProvider = familyFolderNameProvider
        self.selectionRepository = selectionRepository
    }
    
    var list: [ComponentsListSection] { map(documentRepository.value, selection: selectionRepository.value) }
    var listPublisher: AnyPublisher<[ComponentsListSection], Never> {
        Publishers.CombineLatest(
            documentRepository.publisher,
            selectionRepository.publisher
        )
        .map({ (document, selection) in
            self.map(document, selection: selection)
        })
        .eraseToAnyPublisher()
    }
    
    private func map(_ value: PhoenixDocument, selection: Name?) -> [ComponentsListSection] {
        value.componentsFamilies
            .map { componentsFamily in
                    .init(name: sectionTitle(forFamily: componentsFamily.family),
                          folderName: sectionFolderName(forFamily: componentsFamily.family),
                          rows: componentsFamily.components.map { component in
                            .init(
                                id: component.id,
                                name: componentName(component, for: componentsFamily.family),
                                isSelected: component.name == selection,
                                onSelect: {},
                                onDuplicate: {})
                    },
                          onSelect: {})
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
