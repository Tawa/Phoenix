import Combine
import Component
import Foundation
import SwiftUI

protocol GetSelectedFamilyUseCaseProtocol {
    var binding: Binding<Family> { get }
    
    var family: Family { get }
}

struct GetSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let selectionRepository: SelectionRepositoryProtocol
    let updateFamilyUseCase: UpdateFamilyUseCaseProtocol
    
    var binding: Binding<Family> {
        Binding {
            family
        } set: {
            updateFamilyUseCase.update(family: $0)
        }

    }

    var family: Family {
        map(families: getComponentsFamiliesUseCase.families,
            familyName: selectionRepository.familyName) ?? defaultFamily()
    }

    init(getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
         selectionRepository: SelectionRepositoryProtocol,
         updateFamilyUseCase: UpdateFamilyUseCaseProtocol) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.selectionRepository = selectionRepository
        self.updateFamilyUseCase = updateFamilyUseCase
    }

    private func map(families: [ComponentsFamily], familyName: String?) -> Family? {
        families.first(where: { $0.family.name == familyName })?.family
    }
    
    private func defaultFamily() -> Family {
        Family(name: "")
    }
}
