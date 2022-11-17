import Combine
import Component

protocol GetFamilySheetDataUseCaseProtocol {
    var value: FamilySheetData { get }
    var publisher: AnyPublisher<FamilySheetData, Never> { get }
}

struct GetFamilySheetDataUseCase: GetFamilySheetDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol
    let getSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol
    
    var value: FamilySheetData {
        let family = getSelectedFamilyUseCase.family
        return map(family: family,
                   allDependenciesConfiguration: getAllDependenciesConfigurationUseCase.value(
                    defaultDependencies: family.defaultDependencies
                   ),
                   allFamilies: getComponentsFamiliesUseCase.families,
                   packageConfigurations: getProjectConfigurationUseCase.value.packageConfigurations
                   
        )
    }
    
    var publisher: AnyPublisher<FamilySheetData, Never> {
        getSelectedFamilyUseCase
            .familyPublisher
            .map { family in
                self.map(
                    family: family,
                    allDependenciesConfiguration: getAllDependenciesConfigurationUseCase.value(defaultDependencies: family.defaultDependencies),
                    allFamilies: getComponentsFamiliesUseCase.families,
                    packageConfigurations: getProjectConfigurationUseCase.value.packageConfigurations
                )
            }
            .eraseToAnyPublisher()
    }
    
    init(
        getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol,
        getComponentsFamiliesUseCase: GetComponentsFamiliesUseCaseProtocol,
        getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol,
        getSelectedFamilyUseCase: GetSelectedFamilyUseCaseProtocol
    ) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
        self.getComponentsFamiliesUseCase = getComponentsFamiliesUseCase
        self.getProjectConfigurationUseCase = getProjectConfigurationUseCase
        self.getSelectedFamilyUseCase = getSelectedFamilyUseCase
    }
    
    func map(
        family: Family,
        allDependenciesConfiguration: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>],
        allFamilies: [ComponentsFamily],
        packageConfigurations: [PackageConfiguration]
    ) -> FamilySheetData {
        FamilySheetData(
            family: family,
            allDependenciesConfiguration: allDependenciesConfiguration,
            allDependenciesSelectionValues: packageConfigurations.map(\.name),
            rules: allFamilies.map(\.family).map { otherFamily in
                FamilyRule(
                    name: otherFamily.name,
                    enabled: !family.excludedFamilies.contains(where: { otherFamily.name == $0 }))
            }
        )
    }
}
