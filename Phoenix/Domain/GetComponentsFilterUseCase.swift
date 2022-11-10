import Combine

protocol GetComponentsFilterUseCaseProtocol {
    var value: String? { get }
    var publisher: AnyPublisher<String?, Never> { get }
}

struct GetComponentsFilterUseCase: GetComponentsFilterUseCaseProtocol {
    let componentsFilterRepository: ComponentsFilterRepositoryProtocol
    
    var value: String? { componentsFilterRepository.value }
    var publisher: AnyPublisher<String?, Never> { componentsFilterRepository.publisher }
    
    init(componentsFilterRepository: ComponentsFilterRepositoryProtocol) {
        self.componentsFilterRepository = componentsFilterRepository
    }
}
