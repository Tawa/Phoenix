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
        guard var selectionPath = selectionRepository.selectionPath
        else {
            selectionRepository.select(selectionPath: .init(familyIndex: 0, componentIndex: 0))
            return
        }
        selectionPath.componentIndex += 1
        let families = getComponentsFamiliesUseCase.families
        if selectionPath.componentIndex >= families[selectionPath.familyIndex].components.count {
            selectionPath.familyIndex = (selectionPath.familyIndex + 1) % families.count
            selectionPath.componentIndex = 0
        }
        selectionRepository.select(selectionPath: selectionPath)
    }
}
