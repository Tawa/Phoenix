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
        let document = phoenixDocumentRepository.value
        guard let component = document.families.flatMap(\.components).first(where: { $0.id == id }),
              let familyIndex = document.families.firstIndex(where: { $0.family.name == component.name.family }),
              let componentIndex = document.families[familyIndex].components.firstIndex(of: component)
        else { return }
        selectionRepository.select(
            selectionPath: .init(
                name: document.families[familyIndex].components[componentIndex].name)
        )
    }
}
