import Component

protocol GetRelationViewDataUseCaseProtocol {
    func viewData(defaultDependencies: [PackageTargetType: String]) -> RelationViewData
}

struct GetRelationViewDataUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol
    
    init(getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol,
         getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
        self.getProjectConfigurationUseCase = getProjectConfigurationUseCase
    }
    
    func viewData(defaultDependencies: [PackageTargetType : String]) -> RelationViewData {
        .init(
            types: getAllDependenciesConfigurationUseCase.value(defaultDependencies: defaultDependencies),
            selectionValues: getProjectConfigurationUseCase.value.packageConfigurations.map(\.name)
        )
    }
}

struct GetRelationViewDataWithNameUseCase: GetRelationViewDataUseCaseProtocol {
    let getComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol
    let getRelationViewDataUseCase: GetRelationViewDataUseCaseProtocol
    let name: Name
    
    init(getComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol,
         getRelationViewDataUseCase: GetRelationViewDataUseCaseProtocol,
         name: Name) {
        self.getComponentWithNameUseCase = getComponentWithNameUseCase
        self.getRelationViewDataUseCase = getRelationViewDataUseCase
        self.name = name
    }
    
    func viewData(defaultDependencies: [PackageTargetType : String]) -> RelationViewData {
        var viewData = getRelationViewDataUseCase.viewData(defaultDependencies: defaultDependencies)
        if let component = getComponentWithNameUseCase.component(with: name) {
            viewData.selectionValues = component.modules.keys.sorted()
        } else {
            viewData.selectionValues = []
        }
        return viewData
    }
}
