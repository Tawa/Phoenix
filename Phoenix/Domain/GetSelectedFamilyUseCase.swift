import Combine
import Component
import Foundation

protocol GetSelectedFamilyUseCaseProtocol {
    var family: Family { get }
    var familyPublisher: AnyPublisher<Family, Never> { get }
}

struct GetSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let selectionRepository: SelectionRepositoryProtocol

    var family: Family {
        map(families: getComponentsFamiliesUseCase.families,
            familyName: selectionRepository.familyName)
    }
    var familyPublisher: AnyPublisher<Family, Never> {
        Publishers.CombineLatest(
            getComponentsFamiliesUseCase.familiesPublisher,
            selectionRepository.familyNamePublisher
        )
        .subscribe(on: DispatchQueue.global(qos: .background))
        .map { (families, familyName)  in
            self.map(families: families, familyName: familyName)
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
    }

    private func map(families: [ComponentsFamily], familyName: String?) -> Family {
        families.first(where: { $0.family.name == familyName })?.family ?? defaultFamily()
    }
    
    private func defaultFamily() -> Family {
        Family(name: "")
    }
}
