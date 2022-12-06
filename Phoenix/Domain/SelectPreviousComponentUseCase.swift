import Foundation

protocol SelectPreviousComponentUseCaseProtocol {
    func perform()
}

struct SelectPreviousComponentUseCase: SelectPreviousComponentUseCaseProtocol {
    func perform() {
//        let families = getComponentsFamiliesUseCase.families
//        let paths = families
//            .enumerated()
//            .flatMap { familyElement in
//                (0..<familyElement.element.components.count)
//                    .map { index in
//                        SelectionPath(name: familyElement.element.components[index].name)
//                    }
//        }
//        
//        var index = paths.firstIndex(of: selectionRepository.selectionPath ?? .init(name: .empty)) ?? 0
//        index -= 1
//        if index < 0 {
//            index = paths.count - 1
//        }
//        selectionRepository.select(selectionPath: paths[index])
    }
}
