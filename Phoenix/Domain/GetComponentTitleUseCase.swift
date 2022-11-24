import Component
import Foundation

protocol GetComponentTitleUseCaseProtocol {
    func title(forComponent name: Name) -> String
}

struct GetComponentTitleUseCase: GetComponentTitleUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    func title(forComponent name: Name) -> String {
        guard let family = phoenixDocumentRepository.family(named: name.family)
        else { return name.full }
        var name = name.given
        if !family.ignoreSuffix {
            name += family.name
        }
        return name
    }
}
