import Component
import Foundation

protocol GetComponentTitleUseCaseProtocol {
    func title(forComponent component: Component) -> String
}

struct GetComponentTitleUseCase: GetComponentTitleUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    func title(forComponent component: Component) -> String {
        guard let family = phoenixDocumentRepository.family(named: component.name.family)
        else { return component.name.full }
        var name = component.name.given
        if !family.ignoreSuffix {
            name += family.name
        }
        return name
    }
}
