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
        let families = getComponentsFamiliesUseCase.families
        let paths = families
            .enumerated()
            .flatMap { familyElement in
                (0..<familyElement.element.components.count)
                    .map { index in
                        SelectionPath(name: familyElement.element.components[index].name)
                    }
        }
        
        var index = paths.firstIndex(of: selectionRepository.selectionPath ?? .init(name: .empty)) ?? 0
        index += 1
        if index >= paths.count {
            index = 0
        }
        selectionRepository.select(selectionPath: paths[index])
    }
}
