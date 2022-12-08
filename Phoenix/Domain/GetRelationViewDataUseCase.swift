import Component
import PhoenixDocument

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
            types: getAllDependenciesConfigurationUseCase.value(
                configuration: projectConfiguration,
                defaultDependencies: defaultDependencies
            ),
            selectionValues: projectConfiguration.packageConfigurations.map(\.name)
        )
    }
}

struct GetRelationViewDataToComponentUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let component: Component?

    init(getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol,
         component: Component?) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
        self.component = component
    }
    
    func viewData(defaultDependencies: [PackageTargetType : String],
                  projectConfiguration: ProjectConfiguration) -> RelationViewData {
        .init(
            types: getAllDependenciesConfigurationUseCase.value(
                configuration: projectConfiguration,
                defaultDependencies: defaultDependencies
            ),
            selectionValues: component?.modules.keys.sorted() ?? []
        )
    }
}

struct GetRelationViewDataBetweenComponentsUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let fromComponent: Component?
    let toComponent: Component?
    
    init(getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol,
         fromComponent: Component?,
         toComponent: Component?) {
        self.getAllDependenciesConfigurationUseCase = getAllDependenciesConfigurationUseCase
        self.fromComponent = fromComponent
        self.toComponent = toComponent
    }
    
    func viewData(defaultDependencies: [PackageTargetType : String],
                  projectConfiguration: ProjectConfiguration) -> RelationViewData {
        let types = getAllDependenciesConfigurationUseCase
            .value(
                configuration: projectConfiguration,
                defaultDependencies: defaultDependencies
            )
            .filter { value in fromComponent?.modules.keys.contains(where: { value.value.name == $0 }) ?? false }
        
        return RelationViewData(
            types: types,
            selectionValues: toComponent?.modules.keys.sorted() ?? []
        )
    }
}
