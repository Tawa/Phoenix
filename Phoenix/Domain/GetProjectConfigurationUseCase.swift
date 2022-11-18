import Combine
import Component
import Foundation
import SwiftUI

protocol GetProjectConfigurationUseCaseProtocol {
    var binding: Binding<ProjectConfiguration> { get }
    var value: ProjectConfiguration { get }
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
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
}
