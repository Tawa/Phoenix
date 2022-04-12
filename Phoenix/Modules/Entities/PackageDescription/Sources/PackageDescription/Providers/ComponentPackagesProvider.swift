protocol ComponentModulesProviding {
    func modules(for component: Component,
                 dependencies: [ModuleType: [ModuleDescription]]
    ) -> [ModulePackageDescription]
}

struct ComponentModulesProvider: ComponentModulesProviding {
    let moduleFullNameProvider: ModuleFullNameProviding

    init(moduleFullNameProvider: ModuleFullNameProviding) {
        self.moduleFullNameProvider = moduleFullNameProvider
    }

    func modules(for component: Component, dependencies: [ModuleType : [ModuleDescription]]) -> [ModulePackageDescription] {
        component.types.compactMap { type in
            switch type {
            case .contract:
                return contractModule(for: component, dependencies: dependencies[.contract])
            case .implementation:
                return implementationModule(for: component, dependencies: dependencies[.implementation])
            case .mock:
                return mockModule(for: component, dependencies: dependencies[.mock])
            }
        }
    }

    private func contractModule(for component: Component, dependencies: [ModuleDescription]?) -> ModulePackageDescription {
        let name = moduleFullNameProvider.name(for: ModuleDescription(name: component.name, type: .contract))
        return ModulePackageDescription(module: ModuleDescription(name: component.name,
                                                                  type: .contract),
                                        package: PackageDescription(name: name,
                                                                    platforms: component.platforms,
                                                                    products: [
                                                                        .library(.init(name: name,
                                                                                       type: .dynamic,
                                                                                       targets: [name]))
                                                                    ],
                                                                    targets: [
                                                                        Target(name: name,
                                                                               dependencies: [],
                                                                               isTest: false)
                                                                    ])
        )
    }

    private func implementationModule(for component: Component, dependencies: [ModuleDescription]?) -> ModulePackageDescription {
        let implementationModuleDescription = ModuleDescription(name: component.name, type: .implementation)
        let fullName = moduleFullNameProvider.name(for: implementationModuleDescription)
        return ModulePackageDescription(module: ModuleDescription(name: component.name,
                                                                  type: .implementation),
                                        package: PackageDescription(name: fullName,
                                                                    platforms: component.platforms,
                                                                    products: [
                                                                        .library(.init(name: fullName,
                                                                                       type: .static,
                                                                                       targets: [fullName]))
                                                                    ],
                                                                    targets: [
                                                                        Target(name: fullName,
                                                                               dependencies: [
                                                                                ModuleDescription(name: component.name,
                                                                                                  type: .contract)]
                                                                               + dependencies?.map { dependency in
                                                                                   ModuleDescription(name: dependency.name, type: dependency.types)
                                                                               } ?? [],
                                                                               isTest: false),
                                                                        Target(name: fullName + "Tests",
                                                                               dependencies: [implementationModuleDescription],
                                                                               isTest: true)
                                                                    ])
        )
    }

    private func mockModule(for component: Component, dependencies: [ModuleDescription]?) -> ModulePackageDescription {
        let contractModuleDescription = ModuleDescription(name: component.name, type: .contract)
        let mockName = moduleFullNameProvider.name(for: ModuleDescription(name: component.name, type: .mock))
        return ModulePackageDescription(module: ModuleDescription(name: component.name,
                                                                  type: .mock),
                                        package: PackageDescription(name: mockName,
                                                                    platforms: component.platforms,
                                                                    products: [
                                                                        .library(.init(name: mockName,
                                                                                       type: .dynamic,
                                                                                       targets: [mockName]))
                                                                    ],
                                                                    targets: [
                                                                        Target(name: mockName,
                                                                               dependencies: [contractModuleDescription],
                                                                               isTest: false)])
        )
    }
}
