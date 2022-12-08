import Component
import Factory

extension Container {
    static let getComponentsListItemsUseCase = Factory {
        GetComponentsListItemsUseCase(
            familyFolderNameProvider: familyFolderNameProvider()
        ) as GetComponentsListItemsUseCaseProtocol
    }
    
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
    
    static let selectNextComponentUseCase = Factory {
        SelectNextComponentUseCase() as SelectNextComponentUseCaseProtocol
    }

    static let selectPreviousComponentUseCase = Factory {
        SelectPreviousComponentUseCase() as SelectPreviousComponentUseCaseProtocol
    }
}
