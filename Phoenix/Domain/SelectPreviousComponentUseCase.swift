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
        guard let selectionPath = selectionRepository.selectionPath
        else {
            selectionRepository.select(selectionPath: .init(familyIndex: 0, componentIndex: 0))
            return
        }
        let families = getComponentsFamiliesUseCase.families
        let paths = families
            .enumerated()
            .flatMap { familyElement in
                (0..<familyElement.element.components.count)
                    .map { index in
                        SelectionPath(familyIndex: familyElement.offset,
                                      componentIndex: index)
                    }
        }
        
        var index = paths.firstIndex(of: selectionPath) ?? 0
        index -= 1
        if index < 0 {
            index = paths.count - 1
        }
        selectionRepository.select(selectionPath: paths[index])
    }
}
