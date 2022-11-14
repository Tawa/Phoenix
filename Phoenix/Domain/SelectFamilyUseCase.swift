import Component

protocol SelectFamilyUseCaseProtocol {
    func select(id: String)
    func deselect()
}

struct SelectFamilyUseCase: SelectFamilyUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    let selectionRepository: SelectionRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol,
         selectionRepository: SelectionRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
        self.selectionRepository = selectionRepository
    }

    func select(id: String) {
        phoenixDocumentRepository
            .family(with: id)
            .map(\.name)
            .map(selectionRepository.select(familyName:))
    }
    
    func deselect() {
        selectionRepository.deselectFamilyName()
    }
}
