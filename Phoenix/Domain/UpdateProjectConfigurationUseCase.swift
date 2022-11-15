import Component

protocol UpdateProjectConfigurationUseCaseProtocol {
    func update(configuration: ProjectConfiguration)
}

struct UpdateProjectConfigurationUseCase: UpdateProjectConfigurationUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    func update(configuration: ProjectConfiguration) {
        phoenixDocumentRepository.update(configuration: configuration)
    }
}
