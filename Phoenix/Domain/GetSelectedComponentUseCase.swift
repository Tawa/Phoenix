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
        map(componentFamilies: getComponentsFamiliesUseCase.families,
            selection: selectionRepository.value)
    }
    var componentDataPublisher: AnyPublisher<ComponentData, Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            selectionRepository.publisher
        )
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { (families, selection)  in
                self.map(componentFamilies: families, selection: selection)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
    }
    
    private func map(componentFamilies: [ComponentsFamily], selection: Name?) -> ComponentData {
        guard let selection,
              let familyIndex = componentFamilies.firstIndex(where: { $0.family.name == selection.family }),
              let component = componentFamilies[familyIndex].components.first(where: { $0.name == selection })
        else { return .default }
        
        return ComponentData(title: component.name.full)
    }
}
