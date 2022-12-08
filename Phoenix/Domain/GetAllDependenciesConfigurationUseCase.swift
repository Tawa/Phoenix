import Combine
import Component
import Foundation

protocol GetAllDependenciesConfigurationUseCaseProtocol {
    func value(
        configuration: ProjectConfiguration,
        defaultDependencies: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
}

struct GetAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol {
    
    func value(
        configuration: ProjectConfiguration,
        defaultDependencies: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] {
        map(
            configuration: configuration,
            defaultDependencies: defaultDependencies
        )
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
