import Component

protocol GetComponentWithNameUseCaseProtocol {
    func component(with name: Name) -> Component?
}

struct GetComponentWithNameUseCase: GetComponentWithNameUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    func component(with name: Name) -> Component? {
        phoenixDocumentRepository
            .value
            .componentsFamilies
            .flatMap(\.components)
            .first(where: { $0.name == name })
    }
}
