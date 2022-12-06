import Factory
import Component
import PhoenixDocument
import SwiftUI

class Composition: ObservableObject {
    var document: Binding<PhoenixDocument>
    
    init(document: Binding<PhoenixDocument>) {
        self.document = document
    }
    
    // MARK: - Data
    lazy var phoenixDocumentRepository = Factory(scope: .singleton) { [unowned self] in
        PhoenixDocumentRepository(
            document: document
        ) as PhoenixDocumentRepositoryProtocol
    }
    
    lazy var componentsFilterRepository = Factory(scope: .singleton) { [unowned self] in
        ComponentsFilterRepository() as ComponentsFilterRepositoryProtocol
    }
    
    // MARK: - Domain
    lazy var getComponentsListItemsUseCase = Factory { [unowned self] in
        GetComponentsListItemsUseCase(
            familyFolderNameProvider: Container.familyFolderNameProvider()
        ) as GetComponentsListItemsUseCaseProtocol
    }
    
    lazy var deleteComponentUseCase = Factory { [unowned self] in
        DeleteComponentUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as DeleteComponentUseCaseProtocol
    }
        
    lazy var getComponentWithNameUseCase = Factory { [unowned self] in
        GetComponentWithNameUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetComponentWithNameUseCaseProtocol
    }
    
    lazy var getRelationViewDataUseCase = Factory { [unowned self] in
        GetRelationViewDataUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase()
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getRelationViewDataBetweenComponentsUseCase = ParameterFactory { [unowned self] (fromName: Name, toName: Name) in
        GetRelationViewDataBetweenComponentsUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            getComponentWithNameUseCase: getComponentWithNameUseCase(),
            fromName: fromName,
            toName: toName
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getRelationViewDataToComponentUseCase = ParameterFactory { [unowned self] (toName: Name) in
        GetRelationViewDataToComponentUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            getComponentWithNameUseCase: getComponentWithNameUseCase(),
            toName: toName
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getAllDependenciesConfigurationUseCase = Factory { [unowned self] in
        GetAllDependenciesConfigurationUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetAllDependenciesConfigurationUseCaseProtocol
    }
    
    lazy var getComponentTitleUseCase = Factory { [unowned self] in
        GetComponentTitleUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetComponentTitleUseCaseProtocol
    }
    
    lazy var selectNextComponentUseCase = Factory { [unowned self] in
        SelectNextComponentUseCase() as SelectNextComponentUseCaseProtocol
    }

    lazy var selectPreviousComponentUseCase = Factory { [unowned self] in
        SelectPreviousComponentUseCase() as SelectPreviousComponentUseCaseProtocol
    }
}
