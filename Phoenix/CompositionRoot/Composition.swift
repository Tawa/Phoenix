import Factory
import Component
import PhoenixDocument
import SwiftUI

class Composition: ObservableObject {
    // MARK: - Domain
    lazy var getComponentsListItemsUseCase = Factory { [unowned self] in
        GetComponentsListItemsUseCase(
            familyFolderNameProvider: Container.familyFolderNameProvider()
        ) as GetComponentsListItemsUseCaseProtocol
    }
    
    lazy var getRelationViewDataUseCase = Factory { [unowned self] in
        GetRelationViewDataUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase()
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getRelationViewDataBetweenComponentsUseCase = ParameterFactory { [unowned self] (fromComponent: Component?, toComponent: Component?) in
        GetRelationViewDataBetweenComponentsUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            fromComponent: fromComponent,
            toComponent: toComponent
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getRelationViewDataToComponentUseCase = ParameterFactory { [unowned self] (component: Component?) in
        GetRelationViewDataToComponentUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            component: component
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getAllDependenciesConfigurationUseCase = Factory { [unowned self] in
        GetAllDependenciesConfigurationUseCase() as GetAllDependenciesConfigurationUseCaseProtocol
    }
    
    lazy var selectNextComponentUseCase = Factory { [unowned self] in
        SelectNextComponentUseCase() as SelectNextComponentUseCaseProtocol
    }

    lazy var selectPreviousComponentUseCase = Factory { [unowned self] in
        SelectPreviousComponentUseCase() as SelectPreviousComponentUseCaseProtocol
    }
}
