import Foundation

protocol DeleteComponentUseCaseProtocol {
    func deleteComponent(with id: String)
}

struct DeleteComponentUseCase: DeleteComponentUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    func deleteComponent(with id: String) {
        phoenixDocumentRepository.deleteComponent(with: id)
    }
}
