import Foundation

protocol SelectPreviousComponentUseCaseProtocol {
    func perform()
}

struct SelectPreviousComponentUseCase: SelectPreviousComponentUseCaseProtocol {
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

        let selectedName = selectionRepository.componentName
        if let index = components.firstIndex(where: { $0.name == selectedName }) {
            let result = index > 0 ? (index - 1) : components.count-1
            let name = components[result].name
            selectionRepository.select(name: name)
        } else if let last = components.last {
            selectionRepository.select(name: last.name)
        }
    }
}
