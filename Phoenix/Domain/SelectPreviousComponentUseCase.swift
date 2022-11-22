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
        guard var selectionPath = selectionRepository.selectionPath
        else {
            selectionRepository.select(selectionPath: .init(familyIndex: 0, componentIndex: 0))
            return
        }
        let families = getComponentsFamiliesUseCase.families

        selectionPath.componentIndex -= 1
        if selectionPath.componentIndex < 0 {
            if selectionPath.familyIndex > 0 {
                selectionPath.familyIndex -= 1
            } else {
                selectionPath.familyIndex = families.count - 1
            }
            selectionPath.componentIndex = families[selectionPath.familyIndex].components.count - 1
        }
        selectionRepository.select(selectionPath: selectionPath)
    }
}
