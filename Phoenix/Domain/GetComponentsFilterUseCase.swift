import SwiftUI

protocol GetComponentsFilterUseCaseProtocol {
    var binding: Binding<String> { get }
}

struct GetComponentsFilterUseCase: GetComponentsFilterUseCaseProtocol {
    let componentsFilterRepository: ComponentsFilterRepositoryProtocol
    var binding: Binding<String> {
        Binding(get: { componentsFilterRepository.binding.wrappedValue ?? "" },
                set: { componentsFilterRepository.binding.wrappedValue = $0.nilIfEmpty })
    }
    
    init(componentsFilterRepository: ComponentsFilterRepositoryProtocol) {
        self.componentsFilterRepository = componentsFilterRepository
    }
}
