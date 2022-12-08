import Component
import Factory

extension Container {
    static let getRelationViewDataUseCase = Factory {
        GetRelationViewDataUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase()
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    static let getRelationViewDataBetweenComponentsUseCase = ParameterFactory { (fromComponent: Component?, toComponent: Component?) in
        GetRelationViewDataBetweenComponentsUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            fromComponent: fromComponent,
            toComponent: toComponent
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    static let getRelationViewDataToComponentUseCase = ParameterFactory { (component: Component?) in
        GetRelationViewDataToComponentUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            component: component
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    static let getAllDependenciesConfigurationUseCase = Factory {
        GetAllDependenciesConfigurationUseCase() as GetAllDependenciesConfigurationUseCaseProtocol
    }
}
