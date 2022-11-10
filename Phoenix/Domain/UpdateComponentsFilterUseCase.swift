import Foundation

protocol UpdateComponentsFilterUseCaseProtocol {
    func update(value: String)
}

struct UpdateComponentsFilterUseCase: UpdateComponentsFilterUseCaseProtocol {
    let componentsFilterRepository: ComponentsFilterRepositoryProtocol

    init(componentsFilterRepository: ComponentsFilterRepositoryProtocol) {
        self.componentsFilterRepository = componentsFilterRepository
    }
    
    func update(value: String) {
        componentsFilterRepository.update(value: value)
    }
}
