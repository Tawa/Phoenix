import Component

protocol UpdateFamilyUseCaseProtocol {
    func update(family: Family)
}

struct UpdateFamilyUseCase: UpdateFamilyUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    func update(family: Family) {
        phoenixDocumentRepository.update(family: family)
    }
}
