import Factory
import PhoenixDocument
import SwiftUI

class Composition {
    let document: Binding<PhoenixDocument>
    
    init(document: Binding<PhoenixDocument>) {
        self.document = document
    }
    
    // MARK: - Data
    lazy var phoenixDocumentRepository = Factory(scope: .singleton) { [unowned self] in
        PhoenixDocumentRepository(
            document: self.document
        ) as PhoenixDocumentRepositoryProtocol
    }
    
    lazy var selectionRepository = Factory(scope: .singleton) { [unowned self] in
        SelectionRepository() as SelectionRepositoryProtocol
    }
    
    lazy var componentsFilterRepository = Factory(scope: .singleton) { [unowned self] in
        ComponentsFilterRepository() as ComponentsFilterRepositoryProtocol
    }
    
    // MARK: - Domain
    lazy var getComponentsListItemsUseCase = Factory(scope: .singleton) { [unowned self] in
        GetComponentsListItemsUseCase(
            componentsFilterRepository: componentsFilterRepository(),
            documentRepository: self.phoenixDocumentRepository(),
            familyFolderNameProvider: Container.familyFolderNameProvider(),
            selectionRepository: self.selectionRepository()
        )
    }
    
    lazy var selectComponentUseCase = Factory(scope: .singleton) { [unowned self] in
        SelectComponentUseCase(
            phoenixDocumentRepository: self.phoenixDocumentRepository(),
            selectionRepository: self.selectionRepository()
        ) as SelectComponentUseCaseProtocol
    }
    
    lazy var clearComponentsFilterUseCase = Factory(scope: .singleton) { [unowned self] in
        ClearComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        )as ClearComponentsFilterUseCaseProtocol
    }
    
    lazy var getComponentsFilterUseCase = Factory(scope: .singleton) { [unowned self] in
        GetComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        )as GetComponentsFilterUseCaseProtocol
    }
    
    lazy var updateComponentsFilterUseCase = Factory(scope: .singleton) { [unowned self] in
        UpdateComponentsFilterUseCase(
            componentsFilterRepository: componentsFilterRepository()
        )as UpdateComponentsFilterUseCaseProtocol
    }
    
    // MARK: - Presentation
    lazy var componentsFilterInteractor = Factory(scope: .singleton) { [unowned self] in
        FilterViewInteractor(
            clearComponentsFilterUseCase: clearComponentsFilterUseCase(),
            getComponentsFilterUseCase: getComponentsFilterUseCase(),
            updateComponentsFilterUseCase: updateComponentsFilterUseCase())
    }
}
