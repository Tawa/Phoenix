import Combine
import Component
import Foundation
import PhoenixDocument

protocol GetComponentsFamiliesUseCaseProtocol {
    var families: [ComponentsFamily] { get }
    var familiesPublisher: AnyPublisher<[ComponentsFamily], Never> { get }
}

struct GetComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol {
    let componentsFilterRepository: ComponentsFilterRepositoryProtocol
    let documentRepository: PhoenixDocumentRepositoryProtocol

    init(componentsFilterRepository: ComponentsFilterRepositoryProtocol,
         documentRepository: PhoenixDocumentRepositoryProtocol) {
        self.componentsFilterRepository = componentsFilterRepository
        self.documentRepository = documentRepository
    }
    
    var families: [ComponentsFamily] { map(documentRepository.value,
                                           filter: componentsFilterRepository.value) }
    var familiesPublisher: AnyPublisher<[ComponentsFamily], Never> {
        Publishers.CombineLatest(
            documentRepository.publisher,
            componentsFilterRepository.publisher
        )
        .subscribe(on: DispatchQueue.global(qos: .background))
        .map { (document, filter) in
            self.map(document, filter: filter)
        }
        .eraseToAnyPublisher()
    }
    
    private func map(_ value: PhoenixDocument, filter: String?) -> [ComponentsFamily] {
        value.componentsFamilies
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
    }
    
    private func componentName(_ component: Component, for family: Family) -> String {
        family.ignoreSuffix == true ? component.name.given : component.name.given + component.name.family
    }
}
