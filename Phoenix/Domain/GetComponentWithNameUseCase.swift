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
        guard let selectionPath = phoenixDocumentRepository.componentsDictionary[name]
        else { return nil }
        return phoenixDocumentRepository
            .value
            .componentsFamilies[selectionPath.familyIndex].components[selectionPath.componentIndex]
    }
}
