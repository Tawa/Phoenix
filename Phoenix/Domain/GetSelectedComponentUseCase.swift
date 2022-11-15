import Combine
import Component
import Foundation

struct ComponentData: Equatable {
    let title: String
    
    static var `default`: ComponentData {
        .init(title: "")
    }
}

protocol GetSelectedComponentUseCaseProtocol {
    var componentData: ComponentData { get }
    var componentDataPublisher: AnyPublisher<ComponentData, Never> { get }
}

struct GetSelectedComponentUseCase: GetSelectedComponentUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let selectionRepository: SelectionRepositoryProtocol
    
    var componentData: ComponentData {
        map(families: getComponentsFamiliesUseCase.families,
            selection: selectionRepository.componentName)
    }
    var componentDataPublisher: AnyPublisher<ComponentData, Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            selectionRepository.componentNamePublisher
        )
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { (families, selection)  in
                self.map(families: families, selection: selection)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
    }
    
    private func map(families: [ComponentsFamily], selection: Name?) -> ComponentData {
        guard let selection,
              let familyIndex = families.firstIndex(where: { $0.family.name == selection.family }),
              let component = families[familyIndex].components.first(where: { $0.name == selection })
        else { return .default }
        
        let title = componentName(component.name, for: families[familyIndex].family)
        
        return ComponentData(title: title)
    }
    
    private func componentName(_ name: Name, for family: Family) -> String {
        family.ignoreSuffix == true ? name.given : name.given + name.family
    }
}
