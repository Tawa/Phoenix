import Combine
import Component
import Foundation

protocol GetAllDependenciesConfigurationUseCaseProtocol {
    func value(
        defaultDependencies: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
}

struct GetAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol {
    let phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol
    
    func value(
        defaultDependencies: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] {
        map(
            configuration: phoenixDocumentRepository.value.projectConfiguration,
            defaultDependencies: defaultDependencies
        )
    }
    
    init(phoenixDocumentRepository: PhoenixDocumentRepositoryProtocol) {
        self.phoenixDocumentRepository = phoenixDocumentRepository
    }
    
    private func map(
        configuration: ProjectConfiguration,
        defaultDependencies: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] {
        configuration.packageConfigurations.map { packageConfiguration in
            IdentifiableWithSubtypeAndSelection(
                title: packageConfiguration.name,
                subtitle: packageConfiguration.hasTests ? "Tests" : nil,
                value: PackageTargetType(name: packageConfiguration.name, isTests: false),
                subValue: packageConfiguration.hasTests ? PackageTargetType(name: packageConfiguration.name, isTests: true) : nil,
                selectedValue: defaultDependencies[PackageTargetType(name: packageConfiguration.name, isTests: false)],
                selectedSubValue: defaultDependencies[PackageTargetType(name: packageConfiguration.name, isTests: true)])
        }
    }
}
