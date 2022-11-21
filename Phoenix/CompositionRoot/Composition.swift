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
    
    lazy var selectionRepository = Factory(scope: .singleton) { [unowned self] in
        SelectionRepository() as SelectionRepositoryProtocol
    }
    
    lazy var componentsFilterRepository = Factory(scope: .singleton) { [unowned self] in
        ComponentsFilterRepository() as ComponentsFilterRepositoryProtocol
    }
    
    // MARK: - Domain
    lazy var getComponentsFilterUseCase = Factory { [unowned self] in
        GetComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        ) as GetComponentsFilterUseCaseProtocol
    }
    
    lazy var getComponentsFamiliesUseCase = Factory { [unowned self] in
        GetComponentsFamiliesUseCase(
            componentsFilterRepository: componentsFilterRepository(),
            documentRepository: phoenixDocumentRepository()
        ) as GetComponentsFamiliesUseCaseProtocol
    }
    
    lazy var getComponentsListItemsUseCase = Factory { [unowned self] in
        GetComponentsListItemsUseCase(
            getComponentsFamiliesUseCase: getComponentsFamiliesUseCase(),
            familyFolderNameProvider: Container.familyFolderNameProvider(),
            selectionRepository: selectionRepository()
        ) as GetComponentsListItemsUseCaseProtocol
    }
    
    lazy var getProjectConfigurationUseCase = Factory { [unowned self] in
        GetProjectConfigurationUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetProjectConfigurationUseCaseProtocol
    }
    
    lazy var deleteComponentUseCase = Factory { [unowned self] in
        DeleteComponentUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as DeleteComponentUseCaseProtocol
    }
    
    lazy var selectComponentUseCase = Factory { [unowned self] in
        SelectComponentUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository(),
            selectionRepository: selectionRepository()
        ) as SelectComponentUseCaseProtocol
    }
    
    lazy var getComponentWithNameUseCase = Factory { [unowned self] in
        GetComponentWithNameUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetComponentWithNameUseCaseProtocol
    }
    
    lazy var getSelectedFamilyUseCase = Factory { [unowned self] in
        GetSelectedFamilyUseCase(
            getComponentsFamiliesUseCase: getComponentsFamiliesUseCase(),
            selectionRepository: selectionRepository(),
            updateFamilyUseCase: updateFamilyUseCase()
        ) as GetSelectedFamilyUseCaseProtocol
    }
    
    lazy var getRelationViewDataUseCase = Factory { [unowned self] in
        GetRelationViewDataUseCase(
            getAllDependenciesConfigurationUseCase: getAllDependenciesConfigurationUseCase(),
            getProjectConfigurationUseCase: getProjectConfigurationUseCase()
        ) as GetRelationViewDataUseCaseProtocol
    }
    
    lazy var getRelationViewDataWithNameUseCase = ParameterFactory { [unowned self] (name: Name) in
        GetRelationViewDataWithNameUseCase(
            getComponentWithNameUseCase: getComponentWithNameUseCase(),
            getRelationViewDataUseCase: getRelationViewDataUseCase(),
            name: name
        ) as GetRelationViewDataWithNameUseCase
    }
    
    lazy var getAllDependenciesConfigurationUseCase = Factory { [unowned self] in
        GetAllDependenciesConfigurationUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetAllDependenciesConfigurationUseCaseProtocol
    }
    
    lazy var getFamilySheetDataUseCase = Factory { [unowned self] in
        GetFamilySheetDataUseCase(
            getComponentsFamiliesUseCase: getComponentsFamiliesUseCase(),
            getSelectedFamilyUseCase: getSelectedFamilyUseCase()
        ) as GetFamilySheetDataUseCaseProtocol
    }
    
    lazy var selectFamilyUseCase = Factory { [unowned self] in
        SelectFamilyUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository(),
            selectionRepository: selectionRepository()
        ) as SelectFamilyUseCaseProtocol
    }
    
    lazy var updateFamilyUseCase = Factory { [unowned self] in
        UpdateFamilyUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as UpdateFamilyUseCaseProtocol
    }
    
    lazy var getComponentTitleUseCase = Factory { [unowned self] in
        GetComponentTitleUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as GetComponentTitleUseCaseProtocol
    }
    
    lazy var getSelectedComponentUseCase = Factory { [unowned self] in
        GetSelectedComponentUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository(),
            getComponentsFamiliesUseCase: getComponentsFamiliesUseCase(),
            selectionRepository: selectionRepository()
        )
    }
    
    lazy var selectNextComponentUseCase = Factory { [unowned self] in
        SelectNextComponentUseCase(
            getComponentsFamiliesUseCase: getComponentsFamiliesUseCase(),
            selectionRepository: selectionRepository()
        ) as SelectNextComponentUseCaseProtocol
    }

    lazy var selectPreviousComponentUseCase = Factory { [unowned self] in
        SelectPreviousComponentUseCase(
            getComponentsFamiliesUseCase: getComponentsFamiliesUseCase(),
            selectionRepository: selectionRepository()
        ) as SelectPreviousComponentUseCaseProtocol
    }

    // MARK: - Presentation
    lazy var componentsListInteractor = Factory { [unowned self] in
        ComponentsListInteractor(
            getComponentsListItemsUseCase: getComponentsListItemsUseCase(),
            selectComponentUseCase: selectComponentUseCase(),
            selectFamilyUseCase: selectFamilyUseCase()
        )
    }
}
