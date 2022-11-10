import Foundation

protocol SelectNextComponentUseCaseProtocol {
    func perform()
}

struct SelectNextComponentUseCase: SelectNextComponentUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let selectionRepository: SelectionRepositoryProtocol
    
    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
    }
    
    func perform() {
        let components = getComponentsFamiliesUseCase
            .families
            .flatMap(\.components)
        
        guard !components.isEmpty else { return }

        let selectedName = selectionRepository.value
        if let index = components.firstIndex(where: { $0.name == selectedName }) {
            let result = (index + 1)%components.count
            let name = components[result].name
            selectionRepository.select(name: name)
        } else if let first = components.first {
            selectionRepository.select(name: first.name)
        }
    }
}
