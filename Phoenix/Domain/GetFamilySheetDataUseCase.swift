import Combine
import Component

protocol GetFamilySheetDataUseCaseProtocol {
    var value: FamilySheetData { get }
}

struct GetFamilySheetDataUseCase: GetFamilySheetDataUseCaseProtocol {
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let getSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol
    
    var value: FamilySheetData {
        let family = getSelectedFamilyUseCase.family
        return map(family: family,
                   allFamilies: getComponentsFamiliesUseCase.families)
    }
    
    init(
        getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
        getSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol
    ) {
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.getSelectedFamilyUseCase = getSelectedFamilyUseCase
    }
    
    func map(
        family: Family,
        allFamilies: [ComponentsFamily]
    ) -> FamilySheetData {
        FamilySheetData(
            family: family,
            rules: allFamilies.map(\.family).map { otherFamily in
                FamilyRule(
                    name: otherFamily.name,
                    enabled: !family.excludedFamilies.contains(where: { otherFamily.name == $0 }))
            }
        )
    }
}
