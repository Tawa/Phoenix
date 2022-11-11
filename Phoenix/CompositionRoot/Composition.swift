import Factory
import PhoenixDocument
import SwiftUI

class Composition {
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
    
    lazy var deleteComponentUseCase = Factory { [unowned self] in
        DeleteComponentUseCase(
            phoenixDocumentRepository: phoenixDocumentRepository()
        ) as DeleteComponentUseCaseProtocol
    }
    
    lazy var selectComponentUseCase = Factory { [unowned self] in
        SelectComponentUseCase(
            phoenixDocumentRepository: self.phoenixDocumentRepository(),
            selectionRepository: self.selectionRepository()
        ) as SelectComponentUseCaseProtocol
    }
    
    lazy var clearComponentsFilterUseCase = Factory { [unowned self] in
        ClearComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        )as ClearComponentsFilterUseCaseProtocol
    }
    
    lazy var getComponentsFilterUseCase = Factory { [unowned self] in
        GetComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        )as GetComponentsFilterUseCaseProtocol
    }
    
    lazy var updateComponentsFilterUseCase = Factory { [unowned self] in
        UpdateComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        )as UpdateComponentsFilterUseCaseProtocol
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
    lazy var componentsFilterInteractor = Factory { [unowned self] in
        FilterViewInteractor(
            clearComponentsFilterUseCase: clearComponentsFilterUseCase(),
            getComponentsFilterUseCase: getComponentsFilterUseCase(),
            updateComponentsFilterUseCase: updateComponentsFilterUseCase()
        )
    }
    
    lazy var componentsListInteractor = Factory { [unowned self] in
        ComponentsListInteractor(
            getComponentsListItemsUseCase: getComponentsListItemsUseCase(),
            selectComponentUseCase: selectComponentUseCase()
        )
    }
}
