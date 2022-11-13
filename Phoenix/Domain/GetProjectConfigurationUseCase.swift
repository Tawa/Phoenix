import Combine
import Component
import Foundation

protocol GetProjectConfigurationUseCaseProtocol {
    var value: ProjectConfiguration { get }
    var publisher: AnyPublisher<ProjectConfiguration, Never> { get }
}

struct GetProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    var value: ProjectConfiguration { phoenixDocumentRepository.value.projectConfiguration }
    var publisher: AnyPublisher<ProjectConfiguration, Never> {
        phoenixDocumentRepository
            .publisher
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map(\.projectConfiguration)
            .eraseToAnyPublisher()
    }
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
}

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
