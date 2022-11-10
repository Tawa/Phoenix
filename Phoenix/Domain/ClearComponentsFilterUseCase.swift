import Foundation

protocol ClearComponentsFilterUseCaseProtocol {
    func clear()
}

struct ClearComponentsFilterUseCase: ClearComponentsFilterUseCaseProtocol {
    
    let componentsFilterRepository: ComponentsFilterRepositoryProtocol

    init(componentsFilterRepository: ComponentsFilterRepositoryProtocol) {
        self.componentsFilterRepository = componentsFilterRepository
    }
    
    func clear() {
        componentsFilterRepository.update(value: nil)
    }
}
