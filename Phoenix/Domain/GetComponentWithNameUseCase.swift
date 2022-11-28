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
        let document = phoenixDocumentRepository.value
        guard
            let selectionPath = phoenixDocumentRepository.componentsDictionary[name],
            let familyIndex = document.families.firstIndex(where: { $0.family.name == selectionPath.name.family }),
            let componentIndex = document.families[familyIndex].components.firstIndex(where: { $0.name == selectionPath.name })
        else { return nil }
        return document.families[familyIndex].components[componentIndex]
    }
}
