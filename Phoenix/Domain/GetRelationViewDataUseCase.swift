import Component

protocol GetRelationViewDataUseCaseProtocol {
    func viewData(defaultDependencies: [PackageTargetType: String]) -> RelationViewData
}

struct GetRelationViewDataUseCase: GetRelationViewDataUseCaseProtocol {
    let getAllDependenciesConfigurationUseCase: GetAllDependenciesConfigurationUseCaseProtocol
    let getProjectConfigurationUseCase: GetProjectConfigurationUseCaseProtocol

    func viewData(defaultDependencies: [PackageTargetType : String]) -> RelationViewData {
        .init(
            types: getAllDependenciesConfigurationUseCase.value(defaultDependencies: defaultDependencies),
            selectionValues: getProjectConfigurationUseCase.value.packageConfigurations.map(\.name)
        )
    }
}
