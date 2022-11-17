import Combine
import Component
import Foundation
import SwiftUI

protocol GetProjectConfigurationUseCaseProtocol {
    var binding: Binding<ProjectConfiguration> { get }
    
    var value: ProjectConfiguration { get }
    var publisher: AnyPublisher<ProjectConfiguration, Never> { get }
}

struct GetProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    var binding: Binding<ProjectConfiguration> {
        Binding {
            phoenixDocumentRepository.value.projectConfiguration
        } set: {
            phoenixDocumentRepository.update(configuration: $0)
        }

    }
    
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
