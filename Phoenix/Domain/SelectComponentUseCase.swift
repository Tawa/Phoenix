import Component

protocol SelectComponentUseCaseProtocol {
    func select(id: String)
}

struct SelectComponentUseCase: SelectComponentUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    let selectionRepository: SelectionRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
        self.selectionRepository = selectionRepository
    }
    
    func select(id: String) {
        phoenixDocumentRepository.component(with: id)
            .map(\.name)
            .map(selectionRepository.select(name:))
    }
}
