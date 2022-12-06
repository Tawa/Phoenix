import Component

protocol GetRelationViewDataUseCaseProtocol {
    func viewData(
        defaultDependencies: [PackageTargetType: String],
        projectConfiguration: ProjectConfiguration
    ) -> RelationViewData
}

struct GetRelationViewDataUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    
    init(getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
    }
    
    func viewData(
        defaultDependencies: [PackageTargetType : String],
        projectConfiguration: ProjectConfiguration)
    -> RelationViewData {
        .init(
            types: getAllDependenciesConfigurationUseCase.value(defaultDependencies: defaultDependencies),
            selectionValues: projectConfiguration.packageConfigurations.map(\.name)
        )
    }
}

struct GetRelationViewDataToComponentUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let getComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol
    let toName: Name

    init(getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol,
         getComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol,
         toName: Name) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
        self.getComponentWithNameUseCase = getComponentWithNameUseCase
        self.toName = toName
    }
    
    func viewData(defaultDependencies: [PackageTargetType : String],
                  projectConfiguration: ProjectConfiguration) -> RelationViewData {
        .init(
            types: getAllDependenciesConfigurationUseCase.value(defaultDependencies: defaultDependencies),
            selectionValues: getComponentWithNameUseCase.component(with: toName)?.modules.keys.sorted() ?? []
        )
    }
}

struct GetRelationViewDataBetweenComponentsUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let getComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol
    let fromName: Name
    let toName: Name
    
    init(getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol,
         getComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol,
         fromName: Name,
         toName: Name) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
        self.getComponentWithNameUseCase = getComponentWithNameUseCase
        self.fromName = fromName
        self.toName = toName
    }
    
    func viewData(defaultDependencies: [PackageTargetType : String],
                  projectConfiguration: ProjectConfiguration) -> RelationViewData {
        let fromComponent = getComponentWithNameUseCase.component(with: fromName)
        let toComponent = getComponentWithNameUseCase.component(with: toName)
        
        let types = getAllDependenciesConfigurationUseCase
            .value(defaultDependencies: defaultDependencies)
            .filter { value in fromComponent?.modules.keys.contains(where: { value.value.name == $0 }) ?? false }
        
        return RelationViewData(
            types: types,
            selectionValues: toComponent?.modules.keys.sorted() ?? []
        )
    }
}
